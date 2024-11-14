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
-- @param pr_creation_date_from Creation date of Github Pull Request is after or equal to pr_creation_date_from. Format is YYYY-MM-DD.
-- @type pr_creation_date_from date
-- @default pr_creation_date_from current_date - interval '15' day
-- @param pr_creation_date_to Creation date of Github Pull Request is before or equal to pr_creation_date_to. Format is YYYY-MM-DD.
-- @type pr_creation_date_to date
-- @default pr_creation_date_to current_date
-- @param is_github_pull_request_open if true then search for open GitHub Pull Requests, else if it's false then search for closed ones, else search for both open and closed PRs. The default behaviour if no value is specified (hence NULL) is to retrieve all types of PRs
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
    AND (:github_pull_request_number IS NULL OR github_pull_request.number=:github_pull_request_number)
    AND (github_pull_request.created_at>=:pr_creation_date_from AND github_pull_request.created_at<=:pr_creation_date_to)
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
    jira_issue."key" AS jira_issue_key,
    jira_issue.summary AS jira_summary,
    jira_issue.status AS jira_status,
    jira_issue.assignee_display_name AS jira_assignee
  FROM
    prs
  LEFT JOIN jira.jira_issue
    ON prs.title ilike CONCAT('%', jira_issue."key", '%')
  WHERE
  (jira_issue.created>= (:pr_creation_date_from - interval '15' day)) -- consider Jira issues created 15 days before opening the respective Github Pull Request
  AND (jira_issue.assignee_display_name ilike concat('%', :username, '%') OR :username IS NULL)
  AND (jira_issue."key" ilike :jira_key OR :jira_key IS NULL)
)
SELECT *
FROM jira_pr
ORDER BY pr_number DESC
LIMIT COALESCE(:page_size, 15) OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 15);
