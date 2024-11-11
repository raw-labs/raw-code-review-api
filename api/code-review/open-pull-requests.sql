-- @param username jira username
-- @type username varchar
-- @default username null
-- @param jira_key Jira Key
-- @type jira_key varchar
-- @default jira_key null
-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @default github_repository_full_name null
-- @param github_pull_request_number GitHub pull request number
-- @type github_pull_request_number integer
-- @default github_pull_request_number null
-- @return open GitHub Pull Requests
WITH prs AS (
  SELECT
    github_pull_request.number,
    github_pull_request.title,
    github_pull_request.created_at,
    github_pull_request.updated_at,
    github_pull_request.url,
    github_pull_request.author -> 'avatar_url' as author_github_avatar_url, 
    github_pull_request.author -> 'login' as author_github_username,
    github_pull_request.author -> 'url' as author_github_user_url, 
    REGEXP_MATCHES(github_pull_request.title, '([A-Z]+-[0-9]+)', 'g') AS issue_keys,
    github_pull_request.assignees
  FROM
    github.github_pull_request 
  WHERE
    upper(github_pull_request.state) = 'OPEN'
    AND github_pull_request.repository_full_name=:github_repository_full_name
    AND (github_pull_request.number=:github_pull_request_number OR :github_pull_request_number IS NULL)
)
SELECT
  prs.number AS pr_number,
  prs.title AS pr_title,
  prs.created_at AS pr_created_at,
  prs.updated_at AS pr_updated_at,
  prs.url AS pr_url,
  prs.author_github_username AS pr_author,
  prs.issue_keys[1] AS jira_issue_key,
  jira_issue.summary AS jira_summary,
  jira_issue.status AS jira_status,
  jira_issue.assignee_display_name AS jira_assignee
FROM
  prs
LEFT JOIN
  jira.jira_issue ON jira_issue."key" = prs.issue_keys[1]
WHERE 
-- jira_issue.status_category NOT IN ('Done') -- This does NOT work since all status & status_category fields are currently NULL
jira_issue.created>= (current_date - interval '1' month)
AND (jira_issue.assignee_display_name ilike concat('%', :username, '%') OR :username IS NULL)
AND (jira_issue."key" ilike :jira_key OR :jira_key IS NULL)
;
