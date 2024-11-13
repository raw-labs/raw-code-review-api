-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @param github_pull_request_number GitHub pull request number
-- @type github_pull_request_number integer
-- @return Get GitHub Pull Request Reviewers
SELECT 
  github_pull_request_review.author -> 'url' as reviewer_github_user_url, 
  github_pull_request_review.author -> 'avatar' as reviewer_github_user_avatar_url, 
  github_pull_request_review.author_association,
  github_pull_request_review.author_can_push_to_repository,
  github_pull_request_review.author_login as reviewer_github_username
FROM github.github_pull_request_review
WHERE github_pull_request_review.repository_full_name=:github_repository_full_name 
  AND github_pull_request_review.number=:github_pull_request_number
