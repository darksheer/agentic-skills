# Digest Template

Templates for the daily triage digest in different formats.

---

## Detailed Format

```markdown
# Jules Wrangler Digest — {date}

**Run time**: {start_time} – {end_time} ({duration})
**Mode**: {autonomy_mode}
**Repos monitored**: {repo_count} ({repo_list_or_"all"})

---

## Summary

| Metric | Count |
|--------|-------|
| Sessions scanned | {total} |
| Promoted to PR | {promoted} |
| Awaiting your approval | {pending} |
| Rejected | {rejected} |
| Still active (skipped) | {active} |
| Failed (skipped) | {failed} |

---

## Promoted Sessions

These sessions were auto-promoted to PRs and handed to github-babysitter pr-care:

| # | Session | Repo | Category | Score | PR | Status |
|---|---------|------|----------|-------|----|--------|
| 1 | {title} | {owner/repo} | {category} | {score} | [#{pr}]({url}) | {pr_status} |

---

## Awaiting Your Approval

These sessions scored well but require human sign-off:

| # | Session | Repo | Category | Score | Risk Reason |
|---|---------|------|----------|-------|-------------|
| 1 | {title} | {owner/repo} | {category} | {score} | {why_flagged} |

**To approve**: Reply with "Promote session {id}" or "Promote all pending"
**To reject**: Reply with "Reject session {id}" with optional reason

---

## Rejected Sessions

These sessions were not promoted:

| # | Session | Repo | Reason |
|---|---------|------|--------|
| 1 | {title} | {owner/repo} | {rejection_reason} |

---

## Sessions Needing Attention

| # | Session | State | Issue |
|---|---------|-------|-------|
| 1 | {title} | AWAITING_USER_FEEDBACK | Jules needs input: "{question}" |
| 2 | {title} | AWAITING_PLAN_APPROVAL | Plan ready for review |

---

## Learning Notes

- Promotion rate this week: {rate}%
- Average score of promoted sessions: {avg_score}
- Most common category: {top_category}
- {any_threshold_adjustments}
```

---

## Summary Format

```markdown
# Jules Wrangler — {date}

**{promoted} promoted** | {pending} awaiting approval | {rejected} rejected | {active} still running

Top promotions:
- [{title}]({pr_url}) → {owner/repo} ({category}, score {score})
- [{title}]({pr_url}) → {owner/repo} ({category}, score {score})

{pending_count} sessions need your approval — reply "Show pending" for details.
```

---

## Minimal Format

```markdown
Jules Wrangler {date}: {promoted}↑ {pending}⏸ {rejected}✗ ({total} scanned)
```

---

## Slack Message Format

When posting to Slack, use blocks:

```json
{
  "blocks": [
    {
      "type": "header",
      "text": { "type": "plain_text", "text": "Jules Wrangler Digest — {date}" }
    },
    {
      "type": "section",
      "fields": [
        { "type": "mrkdwn", "text": "*Promoted:* {promoted}" },
        { "type": "mrkdwn", "text": "*Pending:* {pending}" },
        { "type": "mrkdwn", "text": "*Rejected:* {rejected}" },
        { "type": "mrkdwn", "text": "*Scanned:* {total}" }
      ]
    },
    {
      "type": "section",
      "text": { "type": "mrkdwn", "text": "*Top Promotions:*\n• <{pr_url}|{title}> ({category})\n• <{pr_url}|{title}> ({category})" }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": { "type": "plain_text", "text": "View All Pending" },
          "action_id": "view_pending"
        }
      ]
    }
  ]
}
```

---

## GitHub Issue Format

When posting as a GitHub issue:

**Title**: `Jules Wrangler Digest — {date}`
**Labels**: `jules-wrangler`, `digest`
**Body**: Use the Detailed Format above

Close the issue automatically after 7 days or when all pending items are resolved.
