-- @param username (Optional) jira username
-- @type username varchar
-- @default username null
-- @param jira_key (Optional) Jira Key
-- @type jira_key varchar
-- @default jira_key null
-- @param jira_issue_creation_date_from (Optional) Creation date of Jira issue is before or equal to jira_issue_creation_date_to. Format is YYYY-MM-DD.
-- @type jira_issue_creation_date_from date
-- @default jira_issue_creation_date_from current_date - interval '15' day
-- @param jira_issue_creation_date_to (Optional) Creation date of Jira issue is after or equal to jira_issue_creation_date_from. Format is YYYY-MM-DD.
-- @type jira_issue_creation_date_to date
-- @default jira_issue_creation_date_to current_date
-- @param jira_project_key (Optional) Jira Project Key. If not specified, then issues from all projects are processed.
-- @type jira_project_key varchar
-- @default jira_project_key null
-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @param is_without_pull_request if true then search for Jira issues without any related GitHub Pull Requests, otherwise search for Jira issues with GitHub Pull Request(s)
-- @type is_without_pull_request boolean
-- @default is_without_pull_request true
-- @param is_jira_issue_open if true then search for open Jira issues, otherwise search for Closed, Done or Resolved Jira issues
-- @type is_jira_issue_open boolean
-- @default is_jira_issue_open true
-- @param page Current page number.
-- @type page integer
-- @default page 1
-- @param page_size Number of records per page.
-- @type page_size integer
-- @default page_size 25
-- @return Retrieves Jira issues
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
),
jira_base AS (
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
    (
        (:is_jira_issue_open AND upper(jira_issue.status_category) NOT IN ('DONE', 'CLOSED', 'RESOLVED')) 
        OR 
        (upper(jira_issue.status_category) IN ('DONE', 'CLOSED', 'RESOLVED'))
    )
    AND (
        (:is_without_pull_request AND prs.issue_keys IS NULL) 
        OR 
        (not(:is_without_pull_request) AND prs.issue_keys IS NOT NULL)
    )
    AND (
        ( jira_issue.created>=:jira_issue_creation_date_from )
        AND
        ( jira_issue.created<=:jira_issue_creation_date_to )
    )
    AND (
        jira_issue.project_key = :jira_project_key OR :jira_project_key IS NULL
    )
    AND (
        jira_issue.assignee_display_name ilike concat('%', :username, '%') OR :username IS NULL
    )
    AND (
        jira_issue."key" ilike :jira_key OR :jira_key IS NULL
    )
)
SELECT *
FROM jira_base
ORDER BY jira_issue_key DESC
LIMIT COALESCE(:page_size, 15) OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 15);
