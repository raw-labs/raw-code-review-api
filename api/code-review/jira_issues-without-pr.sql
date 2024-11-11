-- @param username (Optional) jira username
-- @type username varchar
-- @default username null
-- @param jira_key (Optional) Jira Key
-- @type jira_key varchar
-- @default jira_key null
-- @param jira_issue_creation_date (Optional) Creation date of Jira issue
-- @type jira_issue_creation_date date
-- @default jira_issue_creation_date null
-- @param jira_project_key (Optional) Jira Project Key. If not specified, then issues from all projects are processed.
-- @type jira_project_key varchar
-- @default jira_project_key null
-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @default github_repository_full_name null
-- @return Retrieves Jira issues that do not have an associated open pull request. Useful for identifying issues that may need code development or have been overlooked.
WITH prs AS (
  SELECT
    github_pull_request.number,
    github_pull_request.title,
    github_pull_request.created_at,
    github_pull_request.updated_at,
    github_pull_request.author,
    github_pull_request.url,
    REGEXP_MATCHES(github_pull_request.title, '([A-Z]+-[0-9]+)', 'g') AS issue_keys,
    github_pull_request.assignees
  FROM
    github.github_pull_request
  WHERE
    upper(github_pull_request.state) = 'OPEN'
    AND github_pull_request.repository_full_name=:github_repository_full_name
)
SELECT
  jira_issue."key" AS jira_issue_key,
  jira_issue.summary AS jira_summary,
  jira_issue.status AS jira_status,
  jira_issue.assignee_display_name AS jira_assignee,
  jira_issue.created AS jra_creation_date
FROM
  jira.jira_issue
LEFT JOIN
  prs ON jira_issue."key" = prs.issue_keys[1]
WHERE 
-- jira_issue.status_category NOT IN ('Done', 'Closed', 'Resolved') -- This does NOT work since all status & status_category fields are currently NULL
prs.issue_keys IS NULL
AND (jira_issue.project_key = :jira_project_key OR :jira_project_key IS NULL)
AND ((:jira_issue_creation_date IS NOT NULL AND jira_issue.created>=GREATEST(current_date - interval '15' day, :jira_issue_creation_date::timestamp)) OR (:jira_issue_creation_date IS NULL AND jira_issue.created>= current_date - interval '1' month))
AND (jira_issue.assignee_display_name ilike concat('%', :username, '%') OR :username IS NULL)
AND (jira_issue."key" ilike :jira_key OR :jira_key IS NULL)
;
