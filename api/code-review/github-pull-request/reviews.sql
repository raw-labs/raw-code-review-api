-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @default github_repository_full_name null
-- @param github_pull_request_number GitHub pull request number
-- @type github_pull_request_number integer
-- @default github_pull_request_number null
-- @return Get GitHub Pull Request Reviews
SELECT 
  github_pull_request_review.id,
  github_pull_request_review.number,
  github_pull_request_review.state,
  github_pull_request_review.submitted_at,
  github_pull_request_review.body,
  github_pull_request_review.author -> 'login' as author_username
FROM github.github_pull_request_review
WHERE github_pull_request_review.repository_full_name=:github_repository_full_name 
  AND github_pull_request_review.number=:github_pull_request_number
