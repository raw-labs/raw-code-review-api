-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @param github_pull_request_number GitHub pull request number
-- @type github_pull_request_number integer
-- @return Get GitHub Pull Request Comments
SELECT 
  github_pull_request_comment.id,
  github_pull_request_comment.number,
  github_pull_request_comment.published_at,
  github_pull_request_comment.created_at,
  github_pull_request_comment.body,
  github_pull_request_comment.author -> 'login' as author_username,
  github_pull_request_comment.can_delete
FROM github.github_pull_request_comment
WHERE github_pull_request_comment.repository_full_name=:github_repository_full_name 
  AND github_pull_request_comment.number=:github_pull_request_number
