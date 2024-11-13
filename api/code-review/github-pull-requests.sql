-- @param username jira username
-- @type username varchar
-- @default username null
-- @param jira_key Jira Key
-- @type jira_key varchar
-- @default jira_key null
-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @param github_pull_request_number GitHub pull request number
-- @type github_pull_request_number integer
-- @default github_pull_request_number null
-- @param pr_creation_date Creation date of Github Pull Request
-- @type pr_creation_date date
-- @default pr_creation_date current_date - interval '15' day
-- @param is_github_pull_request_open if true then search for open GitHub Pull Requests, else if it's false then search for closed ones, else search for both open and closed PRs
-- @type is_github_pull_request_open boolean
-- @default is_github_pull_request_open null
-- @param page Current page number.
-- @type page integer
-- @default page 1
-- @param page_size Number of records per page.
-- @type page_size integer
-- @default page_size 25
-- @return GitHub Pull Requests
WITH prs AS (
  SELECT
    github_pull_request.number,
    github_pull_request.title,
    github_pull_request.created_at,
    github_pull_request.updated_at,
    github_pull_request.url,
    github_pull_request.state,
    github_pull_request.author -> 'avatar_url' as author_github_avatar_url, 
    github_pull_request.author -> 'login' as author_github_username,
    github_pull_request.author -> 'url' as author_github_user_url, 
   -- REGEXP_MATCHES(github_pull_request.title, '([A-Z]+-[0-9]+)', 'g') AS issue_keys,
    github_pull_request.assignees
  FROM
    github.github_pull_request 
  WHERE
    (
        (:is_github_pull_request_open IS NULL)
        OR
        (:is_github_pull_request_open AND upper(github_pull_request.state) = 'OPEN')
        OR
        (NOT(:is_github_pull_request_open) AND upper(github_pull_request.state) != 'OPEN')
    )
    AND github_pull_request.repository_full_name=:github_repository_full_name
    AND (github_pull_request.number=:github_pull_request_number OR :github_pull_request_number IS NULL)
    AND (github_pull_request.created_at>=GREATEST(current_date - interval '15' day, :pr_creation_date))
),
jira_pr AS (
  SELECT
    prs.number AS pr_number,
    prs.title AS pr_title,
    prs.created_at AS pr_created_at,
    prs.updated_at AS pr_updated_at,
    prs.state AS pr_state,
    prs.url AS pr_url,
    prs.author_github_username AS pr_author,
    prs.issue_keys[1] AS jira_issue_key,
    jira_issue.summary AS jira_summary,
    jira_issue.status AS jira_status,
    jira_issue.assignee_display_name AS jira_assignee
  FROM
    prs
  LEFT JOIN
    -- jira.jira_issue ON jira_issue."key" = prs.issue_keys[1]
    prs ON prs.title ilike concat('%', jira_issue."key", '%') 
  WHERE
  (jira_issue.created>= (:pr_creation_date - interval '15' day)) -- consider Jira issues created 15 days before opening the respective Github Pull Request
  AND (jira_issue.assignee_display_name ilike concat('%', :username, '%') OR :username IS NULL)
  AND (jira_issue."key" ilike :jira_key OR :jira_key IS NULL)
)
SELECT *
FROM jira_pr
ORDER BY pr_number DESC
LIMIT COALESCE(:page_size, 15) OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 15);
