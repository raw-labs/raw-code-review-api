-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @param github_pull_request_number GitHub pull request number
-- @type github_pull_request_number integer
-- @param pull_request_review_state GitHub pull request review state: APPROVED, COMMENTED, CHANGES_REQUESTED
-- @type pull_request_review_state varchar
-- @default pull_request_review_state NULL
-- @return Get GitHub Pull Request Reviews
SELECT 
  github_pull_request_review.id,
  github_pull_request_review.number,
  github_pull_request_review.state,
  github_pull_request.created_at AS pr_created_date,
  github_pull_request_review.submitted_at AS pr_review_submitted_date,
  github_pull_request.created_at,
  github_pull_request_review.body,
  github_pull_request_review.author -> 'login' as author_username
FROM github.github_pull_request_review 
    INNER JOIN github.github_pull_request 
        ON github_pull_request_review.number=github_pull_request.number
WHERE github_pull_request_review.repository_full_name=:github_repository_full_name
  AND github_pull_request.repository_full_name=:github_repository_full_name 
  AND github_pull_request_review.number=:github_pull_request_number
  AND 
    (upper(github_pull_request_review.state)=upper(:pull_request_review_state) OR :pull_request_review_state IS NULL)
