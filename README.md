# 🛠️ Code Reviewer API

## Table of Contents

1. [Introduction](#introduction)
   - [Description](#description)
   - [How It Works](#how-it-works)
   - [Features](#features)
2. [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Setup Instructions](#setup-instructions)
3. [Domain Entities](#domain-entities)
   - [Entities Overview](#entities-overview)
   - [Entity Relationships](#entity-relationships)
4. [API Endpoints](#api-endpoints)
   - [Endpoint Overview](#endpoint-overview)
   - [Endpoint Details](#endpoint-details)
5. [Query Structure](#query-structure)
   - [Basic Structure of SQL Files](#basic-structure-of-sql-files)
   - [Types of Queries](#types-of-queries)
6. [Filters and Pagination](#filters-and-pagination)
   - [Filters](#filters)
   - [Pagination](#pagination)
7. [Customization](#customization)
8. [Contributing](#contributing)
9. [Support and Troubleshooting](#support-and-troubleshooting)
10. [License](#license)
11. [Acknowledgements](#acknowledgements)
12. [Contact](#contact)

---

## Introduction

### Description

The **Code Reviewer API** provides a unified interface for integrating data from **GitHub** and **Jira** to enhance code review processes. It allows users to retrieve and analyze information related to pull requests, code reviews, comments, reviewers, and associated Jira issues. This API demonstrates how to seamlessly integrate multiple data sources using SQL queries within the RAW Labs platform, streamlining workflows and improving collaboration.

### How It Works

The RAW Labs platform enables the creation of APIs by writing SQL queries that can access data from various sources, including GitHub and Jira. By leveraging these capabilities, the Code Reviewer API allows for real-time data retrieval and analysis without the need for data replication. The API facilitates interactions with GitHub pull requests and Jira issues, providing a consolidated view of the code review lifecycle.

### Features

- **Integrated Data Access**: Combine data from GitHub and Jira to gain comprehensive insights into code review processes.
- **Real-Time Information**: Query up-to-date information directly from GitHub and Jira.
- **Flexible Querying**: Utilize dynamic filtering and pagination to tailor data retrieval to specific needs.
- **Enhanced Reporting**: Generate detailed reports on pull requests, reviews, comments, reviewers, and associated Jira issues.
- **Scalability and Customization**: Adapt the API to various workflows and organizational structures.

## Getting Started

### Prerequisites

- **RAW Labs Account**:
  - An active RAW Labs account. [Sign up here](https://app.raw-labs.com/register) if you don't have one.
- **GitHub Access**:
  - Access to GitHub repositories with pull requests.
  - Personal access tokens with appropriate scopes (e.g., `repo`, `read:org`).
- **Jira Access**:
  - Access to a Jira workspace with relevant projects and issues.
  - Necessary permissions to read data from Jira projects and issues.
- **Permissions**:
  - **GitHub**:
    - Personal access token with required scopes.
  - **Jira**:
    - API access enabled and credentials with read permissions.
- **Dependencies**:
  - Web browser to access RAW Labs, GitHub, and Jira.
  - Internet connectivity.

### Setup Instructions

1. **Configure GitHub and Jira Connections in RAW Labs**:
   - Follow the instructions in the [RAW Labs GitHub Data Source documentation](https://docs.raw-labs.com/sql/data-sources/github) and [RAW Labs Jira Data Source documentation](https://docs.raw-labs.com/sql/data-sources/jira) to set up your connections.
   - Ensure that the necessary credentials and tokens are securely stored in RAW Labs.

2. **Clone the Repository**:
   - Clone this repository into your RAW Labs workspace.
   - Use the RAW Labs platform to import the SQL queries and endpoint configurations.

3. **Review SQL and YAML Files**:
   - Examine the provided `.sql` files, which contain the SQL queries for each endpoint.
   - Each `.sql` file is accompanied by a `.yml` file that defines the API endpoint configuration.

4. **Customize the Queries**:
   - Adjust the SQL queries to fit your GitHub and Jira datasets if necessary.
   - Modify filters, parameters, or entities according to your data schema and organizational needs.

5. **Deploy APIs in RAW Labs**:
   - Use RAW Labs to publish the SQL queries as APIs.
   - Refer to the [Publishing APIs documentation](https://docs.raw-labs.com/docs/publishing-api/overview) for guidance on deploying your APIs.

6. **Test Your APIs**:
   - Use RAW Labs' testing tools or external tools like Postman to test your APIs.
   - Verify that the endpoints return the expected data and handle parameters correctly.

## Domain Entities

### Entities Overview

The Code Reviewer API focuses on key entities involved in code review processes:

- **Pull Request (PR)**: A proposed change to a repository, including code changes, discussions, and reviews.
- **PR Comment**: Feedback or discussion points made on a pull request.
- **PR Review**: Formal reviews of a pull request, which may include approvals, change requests, or comments.
- **Reviewer**: Users assigned to review a pull request.
- **Jira Issue**: Tasks, bugs, or feature requests tracked in Jira, often associated with specific code changes.
- **Assignee**: The person responsible for a Jira issue.

### Entity Relationships

The entities are interconnected to provide a comprehensive view of the code review process:

- A **Pull Request** may be linked to one or more **Jira Issues** via references in the PR title or description.
- **PR Comments** and **PR Reviews** are associated with specific **Pull Requests**.
- **Reviewers** are assigned to **Pull Requests** to perform code reviews.
- **Jira Issues** may be associated with multiple **Pull Requests** if multiple code changes are related to the same issue.

![Entity Relationship Diagram](entity_relationship_diagram.png)

*Note: The diagram illustrates the relationships between pull requests, comments, reviews, reviewers, and Jira issues.*

## API Endpoints

### Endpoint Overview

The Code Reviewer API provides several endpoints to interact with integrated data from GitHub and Jira. The key endpoints include:

1. **Retrieve Pull Requests with Jira Information**:
   - **Endpoint**: `/api/code-review/github-pull-requests`
   - **Description**: Retrieves GitHub pull requests with associated Jira issue details, supporting various filters and pagination.

2. **Retrieve Jira Issues**:
   - **Endpoint**: `/api/code-review/jira_issues`
   - **Description**: Retrieves Jira issues, with options to filter by assignment, status, and whether they have associated pull requests.

3. **Retrieve Pull Request Reviewers**:
   - **Endpoint**: `/api/code-review/github-pull-request/reviewers`
   - **Description**: Retrieves information about reviewers assigned to a specific pull request.

4. **Retrieve Pull Request Reviews**:
   - **Endpoint**: `/api/code-review/github-pull-request/reviews`
   - **Description**: Retrieves reviews for a specific pull request, including review states and comments.

5. **Retrieve Pull Request Comments**:
   - **Endpoint**: `/api/code-review/github-pull-request/comments`
   - **Description**: Retrieves comments made on a specific pull request.

### Endpoint Details

#### 1. Retrieve Pull Requests with Jira Information

- **Endpoint**: `/api/code-review/github-pull-requests`
- **Method**: `GET`
- **Description**: Retrieves pull requests from a specified GitHub repository, including associated Jira issue information.
- **Parameters**:
  - `github_repository_full_name` (string, required): Full name of the GitHub repository (e.g., `owner/repo`).
  - `github_pull_request_number` (integer, optional): Specific pull request number to retrieve.
  - `username` (string, optional): Filter by Jira assignee username.
  - `jira_key` (string, optional): Filter by specific Jira issue key.
  - `pr_creation_date_from` (date, optional): Start date for pull request creation date filter.
  - `pr_creation_date_to` (date, optional): End date for pull request creation date filter.
  - `is_github_pull_request_open` (boolean, optional): Filter by pull request open/closed status.
  - `page` (integer, optional): Page number for pagination (default: 1).
  - `page_size` (integer, optional): Number of records per page (default: 25).
- **Response**: Returns a list of pull requests with their details and associated Jira issue information.

#### 2. Retrieve Jira Issues

- **Endpoint**: `/api/code-review/jira_issues`
- **Method**: `GET`
- **Description**: Retrieves Jira issues, optionally filtering by assignment, creation date, project key, and whether they have associated pull requests.
- **Parameters**:
  - `username` (string, optional): Filter by Jira assignee username.
  - `jira_key` (string, optional): Filter by specific Jira issue key.
  - `jira_issue_creation_date_from` (date, optional): Start date for Jira issue creation date filter.
  - `jira_issue_creation_date_to` (date, optional): End date for Jira issue creation date filter.
  - `jira_project_key` (string, optional): Filter by Jira project key.
  - `is_without_pull_request` (boolean, optional): Filter issues without associated pull requests.
  - `is_jira_issue_open` (boolean, optional): Filter by Jira issue open/closed status.
  - `page` (integer, optional): Page number for pagination (default: 1).
  - `page_size` (integer, optional): Number of records per page (default: 25).
- **Response**: Returns a list of Jira issues with their details.

#### 3. Retrieve Pull Request Reviewers

- **Endpoint**: `/api/code-review/github-pull-request/reviewers`
- **Method**: `GET`
- **Description**: Retrieves reviewers assigned to a specific pull request.
- **Parameters**:
  - `github_repository_full_name` (string, required): Full name of the GitHub repository.
  - `github_pull_request_number` (integer, required): Pull request number.
- **Response**: Returns a list of reviewers with their GitHub usernames, URLs, and roles.

#### 4. Retrieve Pull Request Reviews

- **Endpoint**: `/api/code-review/github-pull-request/reviews`
- **Method**: `GET`
- **Description**: Retrieves reviews for a specific pull request, including the review state and any comments.
- **Parameters**:
  - `github_repository_full_name` (string, required): Full name of the GitHub repository.
  - `github_pull_request_number` (integer, required): Pull request number.
- **Response**: Returns a list of reviews with details such as reviewer username, state, and comments.

#### 5. Retrieve Pull Request Comments

- **Endpoint**: `/api/code-review/github-pull-request/comments`
- **Method**: `GET`
- **Description**: Retrieves comments made on a specific pull request.
- **Parameters**:
  - `github_repository_full_name` (string, required): Full name of the GitHub repository.
  - `github_pull_request_number` (integer, required): Pull request number.
- **Response**: Returns a list of comments with details such as author username, body, and timestamps.

## Query Structure

### Basic Structure of SQL Files

Each SQL file corresponds to an API endpoint and contains the SQL query that retrieves the required data. The queries are parameterized to allow dynamic filtering based on user input.

- **Parameters**: Defined at the top of each file using comments in the RAW Labs format (e.g., `-- @param`, `-- @type`, `-- @default`).
- **CTEs (Common Table Expressions)**: Used to structure the query and handle intermediate results.
- **Joins**: Utilized to combine data from GitHub and Jira sources.
- **Filters**: Applied in the `WHERE` clause based on the parameters provided.
- **Pagination**: Implemented using `LIMIT` and `OFFSET` clauses.

### Types of Queries

#### Integrated Queries

These queries retrieve and combine data from both GitHub and Jira to provide a unified view.

**Example**:

```sql
-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @param github_pull_request_number GitHub pull request number
-- @type github_pull_request_number integer
-- @default github_pull_request_number null
-- @param username Jira assignee username
-- @type username varchar
-- @default username null
-- @param jira_key Jira Issue Key
-- @type jira_key varchar
-- @default jira_key null
-- @param pr_creation_date_from Start date for PR creation date filter
-- @type pr_creation_date_from date
-- @default pr_creation_date_from current_date - interval '15' day
-- @param pr_creation_date_to End date for PR creation date filter
-- @type pr_creation_date_to date
-- @default pr_creation_date_to current_date
-- @param is_github_pull_request_open Filter by PR open/closed status
-- @type is_github_pull_request_open boolean
-- @default is_github_pull_request_open null
-- @param page Current page number
-- @type page integer
-- @default page 1
-- @param page_size Number of records per page
-- @type page_size integer
-- @default page_size 25
-- @return GitHub Pull Requests with Jira Information

WITH prs AS (
  SELECT
    pr.number AS pr_number,
    pr.title AS pr_title,
    pr.created_at AS pr_created_at,
    pr.updated_at AS pr_updated_at,
    pr.url AS pr_url,
    pr.state AS pr_state,
    pr.author ->> 'login' AS pr_author,
    REGEXP_MATCHES(pr.title, '([A-Z]+-[0-9]+)', 'g') AS jira_keys
  FROM
    github.github_pull_request AS pr
  WHERE
    pr.repository_full_name = :github_repository_full_name
    AND (:github_pull_request_number IS NULL OR pr.number = :github_pull_request_number)
    AND (
      :is_github_pull_request_open IS NULL OR
      (:is_github_pull_request_open = TRUE AND pr.state = 'open') OR
      (:is_github_pull_request_open = FALSE AND pr.state != 'open')
    )
    AND pr.created_at BETWEEN :pr_creation_date_from AND :pr_creation_date_to
),
jira_pr AS (
  SELECT
    prs.*,
    ji.key AS jira_issue_key,
    ji.summary AS jira_summary,
    ji.status AS jira_status,
    ji.assignee_display_name AS jira_assignee
  FROM
    prs
  LEFT JOIN
    jira.jira_issue AS ji ON ji.key = prs.jira_keys[1]
  WHERE
    (:username IS NULL OR ji.assignee_display_name ILIKE '%' || :username || '%')
    AND (:jira_key IS NULL OR ji.key ILIKE :jira_key)
)
SELECT *
FROM jira_pr
ORDER BY pr_number DESC
LIMIT COALESCE(:page_size, 25)
OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 25);
```

#### Specific Entity Queries

These queries focus on a specific entity, such as retrieving comments or reviews for a pull request.

**Example**:

```sql
-- @param github_repository_full_name GitHub repository name
-- @type github_repository_full_name varchar
-- @param github_pull_request_number GitHub pull request number
-- @type github_pull_request_number integer
-- @return Get Pull Request Comments

SELECT 
  c.id,
  c.number,
  c.published_at,
  c.created_at,
  c.body,
  c.author ->> 'login' AS author_username,
  c.can_delete
FROM
  github.github_pull_request_comment AS c
WHERE
  c.repository_full_name = :github_repository_full_name
  AND c.number = :github_pull_request_number;
```

## Filters and Pagination

### Filters

The API supports various filters to refine the data retrieved:

- **String Matching**: Filters based on matching strings, such as repository names, usernames, or issue keys.
- **Date Ranges**: Filters data within specified date ranges. Date parameters must not exceed a range of 15 days. If a date range exceeds this limit, the API will return an error message prompting the user to adjust the dates.
- **Boolean Flags**: Filters based on boolean parameters, such as `is_github_pull_request_open` or `is_without_pull_request`.
- **Numeric Ranges**: Filters based on numeric values, such as pull request numbers.

### Pagination

Pagination is implemented to manage large datasets and improve performance.

- **Parameters**:
  - `page` (integer): The current page number (default is 1).
  - `page_size` (integer): The number of records per page (default is 25).
- **Usage**:
  - The `LIMIT` clause is set to the `page_size`.
  - The `OFFSET` is calculated as `(page - 1) * page_size`.
- **Example**:

```sql
LIMIT COALESCE(:page_size, 25)
OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 25);
```

## Customization

The Code Reviewer API template is designed to be adaptable to various development workflows and repository structures:

- **Modify SQL Queries**: Adjust the provided SQL queries to include additional fields or entities specific to your GitHub and Jira setups.
- **Add New Endpoints**: Create new SQL and YAML files to define additional API endpoints as needed.
- **Adjust Parameters**: Modify or add parameters in the queries to support custom filters and data retrieval requirements.
- **Enhance Functionality**: Integrate additional data sources or services to extend the capabilities of the API.

## Contributing

We welcome contributions to enhance the Code Reviewer API!

- **Reporting Issues**:
  - Submit issues via [GitHub Issues](https://github.com/raw-labs/code-reviewer-api/issues).

- **Contributing Code**:
  1. Fork the repository.
  2. Create a feature branch: `git checkout -b feature/YourFeature`.
  3. Commit your changes: `git commit -m 'Add YourFeature'`.
  4. Push to the branch: `git push origin feature/YourFeature`.
  5. Open a Pull Request with a detailed description of your changes.

- **Code Guidelines**:
  - Follow the [RAW Labs Coding Standards](https://docs.raw-labs.com/coding-standards).
  - Write clear commit messages.
  - Include documentation for new features.

## Support and Troubleshooting

- **Documentation**:
  - Refer to the [RAW Labs Documentation](https://docs.raw-labs.com/docs/) for detailed guides.
    - [Using Data Sources](https://docs.raw-labs.com/docs/sql/data-sources/overview)
    - [GitHub Data Source](https://docs.raw-labs.com/sql/data-sources/github)
    - [Jira Data Source](https://docs.raw-labs.com/sql/data-sources/jira)
    - [Publishing APIs](https://docs.raw-labs.com/docs/publishing-api/overview)

- **Community Forum**:
  - Join the discussion on our [Community Forum](https://www.raw-labs.com/community).

- **Contact Support**:
  - Email us at [support@raw-labs.com](mailto:support@raw-labs.com) for assistance.

## License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- **Contributors**: Thanks to all our contributors for their efforts.
- **Third-Party Tools**: This template utilizes GitHub and Jira data sources and demonstrates integration with RAW Labs.

## Contact

- **Email**: [support@raw-labs.com](mailto:support@raw-labs.com)
- **Website**: [https://raw-labs.com](https://raw-labs.com)
- **Twitter**: [@RAWLabs](https://twitter.com/raw_labs)
- **Community Forum**: [Forum](https://www.raw-labs.com/community)

---

## Additional Resources

- **RAW Labs Documentation**: Comprehensive guides and references are available at [docs.raw-labs.com](https://docs.raw-labs.com/).
- **GitHub Data Source**: Detailed instructions on connecting GitHub with RAW Labs can be found [here](https://docs.raw-labs.com/sql/data-sources/github).
- **Jira Data Source**: Detailed instructions on connecting Jira with RAW Labs can be found [here](https://docs.raw-labs.com/sql/data-sources/jira).
- **Publishing APIs**: Learn how to publish your SQL queries as APIs [here](https://docs.raw-labs.com/docs/publishing-api/overview).
- **SQL Language**: Explore RAW Labs' SQL language for data manipulation [here](https://docs.raw-labs.com/sql/overview).

