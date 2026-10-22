const assert = require('node:assert/strict');
const { test } = require('node:test');
const updateComment = require('./terraform-pr-comment.cjs');

async function run(comments = [], environment = {}) {
  const original = { ...process.env };
  const calls = [];
  const listComments = () => {};
  const context = {
    repo: { owner: 'owner', repo: 'repo' },
    issue: { number: 2 },
    serverUrl: 'https://github.com',
    runId: 123,
    runNumber: 4,
    actor: 'contributor',
  };
  const github = {
    paginate: async (method, options) => {
      assert.equal(method, listComments);
      assert.equal(options.per_page, 100);
      return comments;
    },
    rest: { issues: {
      listComments,
      createComment: async args => calls.push({ operation: 'create', ...args }),
      updateComment: async args => calls.push({ operation: 'update', ...args }),
    } },
  };
  try {
    Object.assign(process.env, {
      FMT_OUTCOME: 'success',
      INIT_OUTCOME: 'success',
      VALIDATE_OUTCOME: 'success',
      PLAN_OUTCOME: 'success',
      PLAN_OUTPUT: 'Plan: 5 to add, 0 to change, 0 to destroy.',
      PLAN_ERROR: '',
      ...environment,
    });
    await updateComment({ github, context });
  } finally {
    process.env = original;
  }
  assert.equal(calls.length, 1);
  return calls[0];
}

test('creates a comment with step results, change counts, plan and run link', async () => {
  const result = await run();
  assert.equal(result.operation, 'create');
  assert.equal(result.issue_number, 2);
  assert.match(result.body, /<!-- terraform-ci-comment -->/);
  assert.match(result.body, /All checks passed/);
  assert.match(result.body, /\*\*5\*\* to add/);
  assert.match(result.body, /Full plan output/);
  assert.match(result.body, /actions\/runs\/123/);
});

test('updates the bot marker even beyond the first page and ignores other authors', async () => {
  const comments = Array.from({ length: 101 }, (_, id) => ({ id, user: { login: 'contributor' }, body: 'comment' }));
  comments.unshift({ id: 1, user: { login: 'contributor' }, body: '<!-- terraform-ci-comment -->' });
  comments.push({ id: 200, user: { login: 'ant-devbot' }, body: '<!-- terraform-ci-comment --> old plan' });
  const result = await run(comments);
  assert.equal(result.operation, 'update');
  assert.equal(result.comment_id, 200);
});

test('adopts the latest legacy ant-devbot comment instead of adding another', async () => {
  const comments = [20, 21].map(id => ({
    id, user: { login: 'ant-devbot' }, body: '## Terraform Quality Check Update 🤖\nOld status',
  }));
  const result = await run(comments);
  assert.equal(result.operation, 'update');
  assert.equal(result.comment_id, 21);
});

test('reports failed and skipped steps when no plan was produced', async () => {
  const result = await run([], {
    INIT_OUTCOME: 'failure', VALIDATE_OUTCOME: 'skipped', PLAN_OUTCOME: 'skipped', PLAN_OUTPUT: '',
  });
  assert.match(result.body, /Needs attention/);
  assert.match(result.body, /Init \| ❌/);
  assert.match(result.body, /Plan \| ⚠️/);
  assert.match(result.body, /No plan output is available/);
});

test('includes plan errors and keeps long output below the GitHub comment limit', async () => {
  const result = await run([], {
    PLAN_OUTCOME: 'failure', PLAN_OUTPUT: 'x'.repeat(70000), PLAN_ERROR: 'Error: denied',
  });
  assert.match(result.body, /Needs attention/);
  assert.match(result.body, /truncated/);
  assert.ok(result.body.length < 65536);
  const error = await run([], { PLAN_OUTCOME: 'failure', PLAN_OUTPUT: '', PLAN_ERROR: 'Error: denied' });
  assert.match(error.body, /Error: denied/);
});

test('reports no changes and safely fences backticks in repository data', async () => {
  const result = await run([], { PLAN_OUTPUT: 'No changes.\nDescription: ```embedded```' });
  assert.match(result.body, /No infrastructure changes detected/);
  assert.ok(result.body.includes('\n````\n'));
});
