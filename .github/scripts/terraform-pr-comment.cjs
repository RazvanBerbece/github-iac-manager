const marker = '<!-- terraform-ci-comment -->';

module.exports = async ({ github, context }) => {
  const repo = { owner: context.repo.owner, repo: context.repo.repo };
  const comments = await github.paginate(github.rest.issues.listComments, {
    ...repo,
    issue_number: context.issue.number,
    per_page: 100,
  });
  const botComments = comments.filter(comment => comment.user?.login === 'ant-devbot');
  const existing = botComments.find(comment => comment.body?.includes(marker))
    || botComments.findLast(comment => comment.body?.startsWith('## Terraform Quality Check Update'));

  const steps = [
    ['Format', process.env.FMT_OUTCOME || 'skipped'],
    ['Init', process.env.INIT_OUTCOME || 'skipped'],
    ['Validate', process.env.VALIDATE_OUTCOME || 'skipped'],
    ['Plan', process.env.PLAN_OUTCOME || 'skipped'],
  ];
  const allPassed = steps.every(([, outcome]) => outcome === 'success');
  const anyFailed = steps.some(([, outcome]) => outcome === 'failure');
  const status = allPassed ? 'All checks passed' : anyFailed ? 'Needs attention' : 'Partially run';
  const icon = outcome => outcome === 'success' ? '✅' : outcome === 'failure' ? '❌' : '⚠️';
  const plan = [process.env.PLAN_OUTPUT, process.env.PLAN_ERROR].filter(Boolean).join('\n');
  const summary = plan.match(/(\d+) to add, (\d+) to change, (\d+) to destroy/);
  const runUrl = `${context.serverUrl}/${repo.owner}/${repo.repo}/actions/runs/${context.runId}`;
  const planSummary = summary
    ? `**${summary[1]}** to add, **${summary[2]}** to change, **${summary[3]}** to destroy.`
    : plan.includes('No changes.') ? 'No infrastructure changes detected.' : '';
  const output = plan.length > 60000
    ? `${plan.slice(0, 60000)}\n\n... (truncated; see the full workflow run)`
    : plan || 'No plan output is available. Check the step results and workflow logs.';
  // Keep repository descriptions containing backticks inside the code block.
  const fence = '`'.repeat(Math.max(3, ...Array.from(output.matchAll(/`+/g), match => match[0].length + 1)));
  const body = [
    marker,
    `## 🏗️ Terraform Plan — ${status}`,
    '',
    '| Step | Status |',
    '| --- | --- |',
    ...steps.map(([name, outcome]) => `| ${name} | ${icon(outcome)} \`${outcome}\` |`),
    '',
    planSummary,
    '',
    '<details><summary>Full plan output</summary>',
    '',
    fence,
    output,
    fence,
    '',
    '</details>',
    '',
    `[View run](${runUrl}) | Triggered by @${context.actor} | Run #${context.runNumber}`,
  ].join('\n');

  if (existing) {
    await github.rest.issues.updateComment({ ...repo, comment_id: existing.id, body });
  } else {
    await github.rest.issues.createComment({ ...repo, issue_number: context.issue.number, body });
  }
};
