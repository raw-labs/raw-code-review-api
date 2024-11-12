---

# 🛠️ **Code Reviewer API**

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
4. [Query Structure](#query-structure)
   - [Basic Structure of SQL Files](#basic-structure-of-sql-files)
   - [Types of Queries](#types-of-queries)
5. [Filters and Pagination](#filters-and-pagination)
   - [Filters](#filters)
   - [Pagination](#pagination)
6. [Customization](#customization)
7. [Contributing](#contributing)
8. [Support and Troubleshooting](#support-and-troubleshooting)
9. [License](#license)
10. [Acknowledgements](#acknowledgements)
11. [Contact](#contact)

---

## Introduction

### Description

This repository provides a **Code Reviewer API template** for integrating data from **GitHub** and **Jira** into the RAW Labs platform. It demonstrates how to retrieve and manipulate code review data using SQL queries on GitHub repositories and Jira issues within RAW Labs. This API serves as a showcase of RAW Labs' capability to seamlessly integrate multiple data sources, highlighting its flexibility and adaptability for enhancing code review processes.

### How It Works

The RAW Labs platform enables the creation of APIs by writing SQL queries that can access data from various data sources, including GitHub and Jira. Utilizing Steampipe's schemas for these platforms, RAW Labs facilitates real-time data retrieval without the need for data replication. This API template illustrates how RAW Labs interacts with GitHub for pull request management and Jira for issue tracking, providing a unified view of code reviews and related tasks.

### Features

- **Real-Time Data Access**: Query Jira issues and GitHub pull requests in real-time without data replication.
- **Template Queries**: Utilize predefined queries for common code review operations.
- **Data Integration**: Combine data from Jira and GitHub to gain comprehensive insights into code review processes.
- **Enhanced Reporting**: Generate detailed reports on pull request comments, reviews, and associated Jira issues.
- **Demonstration of Flexibility**: Showcases RAW Labs' ability to proxy multiple data sources, emphasizing adaptability to various workflows and data schemas.

## Getting Started

### Prerequisites

- **Jira Account**:
  - Access to a Jira workspace with relevant repositories and issues.
  - Necessary permissions to read data from Jira projects and issues.
- **GitHub Account**:
  - Access to GitHub repositories with pull requests.
  - Necessary permissions to read data from GitHub repositories.
- **RAW Labs Account**:
  - An active RAW Labs account. [Sign up here](https://app.raw-labs.com/register) if you don't have one.
- **Permissions**:
  - **Jira**:
    - API access enabled.
  - **GitHub**:
    - Personal access tokens with appropriate scopes (e.g., `repo`, `read:org`).
  - **RAW Labs**:
    - Admin role to your RAW Labs account.
- **Dependencies**:
  - Web browser to access RAW Labs, Jira, and GitHub.
  - Internet connectivity.

### Setup Instructions

1. **Configure Jira and GitHub Connections in RAW Labs**:
   - Follow the instructions in the [RAW Labs Jira Data Source documentation](https://docs.raw-labs.com/sql/data-sources/jira) and [RAW Labs GitHub Data Source documentation](https://docs.raw-labs.com/sql/data-sources/github) to set up your Jira and GitHub connections.

2. **Clone the Repository**:
   - Clone this repository into your RAW Labs workspace.

3. **Review SQL and YAML Files**:
   - Examine the provided `.sql` and `.yml` files.
   - Each SQL file contains a query, and each YAML file configures the corresponding API endpoint.

4. **Customize the Queries**:
   - Adjust the SQL queries to fit your Jira and GitHub datasets if necessary.
   - Modify filters, parameters, or entities according to your data schema.

5. **Deploy APIs in RAW Labs**:
   - Use RAW Labs to publish the SQL queries as APIs.
   - Refer to the [Publishing APIs documentation](https://docs.raw-labs.com/docs/publishing-api/overview) for guidance.

6. **Test Your APIs**:
   - Use RAW Labs' testing tools or tools like Postman to test your APIs.

## Domain Entities

### Entities Overview

The template focuses on key code review entities typically found in software development workflows:

- **GitHub Pull Request (PR)**: Represents a proposed change to a repository, including the changes made and discussions around them.
- **GitHub PR Comment**: Individual comments made on a pull request, providing feedback or suggestions.
- **GitHub PR Review**: Formal reviews of a pull request, including approval or rejection.
- **GitHub PR Reviewer**: Users assigned to review a pull request.
- **Jira Issue**: Tasks, bugs, or feature requests tracked in Jira, often associated with specific code changes.
- **Jira Issue Type**: Classification of Jira issues (e.g., Bug, Task, Story).
- **Jira Project**: Grouping of related Jira issues within an organization.

### Entity Relationships

![Class Diagram of Code Reviewer Entities](code_reviewer_entities.png)

*Alt text: Class diagram showing relationships between GitHub Pull Requests, Comments, Reviews, Reviewers, and Jira Issues.*

## Query Structure

### Basic Structure of SQL Files

Each SQL file contains a query that retrieves data from Jira and GitHub. The queries are written in standard SQL and are designed for flexibility, supporting dynamic filtering and pagination.

- **Parameters**: Defined at the top of each file using comments in the RAW Labs format.
- **Filters**: Applied in the `WHERE` clause based on parameters.
- **Pagination**: Implemented using `LIMIT` and `OFFSET`.

### Types of Queries

#### Level 1: Basic Queries

These queries retrieve data from single tables and support dynamic filtering and pagination.

**Example:**

```sql
-- @param github_repository_full_name Filter by GitHub repository name.
-- @type github_repository_full_name string
-- @default github_repository_full_name null

-- @param github_pull_request_number Filter by GitHub pull request number.
-- @type github_pull_request_number integer
-- @default github_pull_request_number null

-- @param page Current page number.
-- @type page integer
-- @default page 1

-- @param page_size Number of records per page.
-- @type page_size integer
-- @default page_size 25

-- @return A list of PR comments matching the specified filters with pagination.

WITH filtered_comments AS (
    SELECT
        comment.id AS comment_id,
        comment.pull_request_number AS pr_number,
        comment.created_at,
        comment.updated_at,
        comment.body,
        comment.author_username
    FROM github_pull_request_comments AS comment
    WHERE (comment.github_repository_full_name = :github_repository_full_name OR :github_repository_full_name IS NULL)
      AND (comment.github_pull_request_number = :github_pull_request_number OR :github_pull_request_number IS NULL)
)
SELECT *
FROM filtered_comments
ORDER BY created_at DESC
LIMIT COALESCE(:page_size, 25) OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 25);
```

#### Level 2: Intermediate Queries

These queries involve joins between multiple tables to provide more complex data retrieval.

**Example:**

```sql
-- @param github_repository_full_name Filter by GitHub repository name.
-- @type github_repository_full_name string
-- @default github_repository_full_name null

-- @param github_pull_request_number Filter by GitHub pull request number.
-- @type github_pull_request_number integer
-- @default github_pull_request_number null

-- @return A list of PR reviews with author details.

WITH pr_reviews AS (
    SELECT
        review.id AS review_id,
        review.pull_request_number AS pr_number,
        review.state,
        review.submitted_at,
        review.body,
        review.author_username
    FROM github_pull_request_reviews AS review
    WHERE (review.github_repository_full_name = :github_repository_full_name OR :github_repository_full_name IS NULL)
      AND (review.pull_request_number = :github_pull_request_number OR :github_pull_request_number IS NULL)
)
SELECT *
FROM pr_reviews
ORDER BY submitted_at DESC;
```

#### Level 3: Advanced Queries

These queries use advanced SQL techniques like window functions and subqueries to provide analytical insights.

**Example:**

```sql
-- @param jira_key Jira Issue Key to filter PRs.
-- @type jira_key string
-- @default jira_key null

-- @return PRs with associated Jira issues and their statuses.

WITH pr_with_jira AS (
    SELECT
        pr.number AS pr_number,
        pr.title AS pr_title,
        pr.created_at AS pr_created_at,
        pr.updated_at AS pr_updated_at,
        pr.url AS pr_url,
        pr_author.username AS pr_author_username,
        jira.key AS jira_issue_key,
        jira.summary AS jira_summary,
        jira.status AS jira_status,
        jira.assignee AS jira_assignee
    FROM github_pull_requests AS pr
    LEFT JOIN jira_issue AS jira ON LOWER(jira.key) = LOWER(pr.jira_key)
    LEFT JOIN github_users AS pr_author ON pr.author_id = pr_author.id
    WHERE (:jira_key IS NULL OR jira.key = :jira_key)
      AND pr.state = 'open'
)
SELECT *
FROM pr_with_jira
ORDER BY pr_created_at DESC;
```

## Filters and Pagination

### Filters

The template supports various types of filters for flexible querying:

| Filter Type          | Description                                                  | Example                                                                                     |
|----------------------|--------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| **Equality Filters** | Checks if a column's value equals the specified parameter or is NULL | `AND (j.key = :jira_key OR :jira_key IS NULL)`                                             |
| **Substring Search** | Searches for a substring within a column                     | `AND (j.summary ILIKE CONCAT('%', :jira_summary, '%') OR :jira_summary IS NULL)`            |
| **Range Filters**    | Filters data within a numeric or date range                  | `AND (pr.created_at >= :start_date OR :start_date IS NULL)`                                 |
| **List Filters**     | Matches any value from a list                                | `AND (pr.author_username IN (:reviewer_usernames) OR :reviewer_usernames IS NULL)`           |

### Pagination

The queries support pagination through `LIMIT` and `OFFSET`.

- **Parameters**:
  - `:page` (integer): The current page number (default is 1).
  - `:page_size` (integer): The number of records per page (default is 25).

**Example:**

```sql
LIMIT COALESCE(:page_size, 25)
OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 25);
```

## Customization

This Code Reviewer API template is designed to be adaptable to various development workflows and repository structures:

- **Modify SQL Queries**: Adjust the provided SQL queries to include additional fields or entities specific to your Jira and GitHub setups.
- **Add New Endpoints**: Create new SQL and YAML files to define additional API endpoints as needed.
- **Adjust Parameters**: Modify or add parameters in the queries to support custom filters and data retrieval requirements.

## Contributing

We welcome contributions!

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
    - [Jira Data Source](https://docs.raw-labs.com/sql/data-sources/jira)
    - [GitHub Data Source](https://docs.raw-labs.com/sql/data-sources/github)
    - [Publishing APIs](https://docs.raw-labs.com/docs/publishing-api/overview)

- **Community Forum**:
  - Join the discussion on our [Community Forum](https://www.raw-labs.com/community).

- **Contact Support**:
  - Email us at [support@raw-labs.com](mailto:support@raw-labs.com) for assistance.

## License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- **Contributors**: Thanks to all our contributors for their efforts.
- **Third-Party Tools**: This template utilizes Jira and GitHub and demonstrates integration with RAW Labs.

## Contact

- **Email**: [support@raw-labs.com](mailto:support@raw-labs.com)
- **Website**: [https://raw-labs.com](https://raw-labs.com)
- **Twitter**: [@RAWLabs](https://twitter.com/raw_labs)
- **Community Forum**: [Forum](https://www.raw-labs.com/community)

---

## Additional Resources

- **RAW Labs Documentation**: Comprehensive guides and references are available at [docs.raw-labs.com](https://docs.raw-labs.com/).
- **Jira Data Source**: Detailed instructions on connecting Jira with RAW Labs can be found [here](https://docs.raw-labs.com/sql/data-sources/jira).
- **GitHub Data Source**: Detailed instructions on connecting GitHub with RAW Labs can be found [here](https://docs.raw-labs.com/sql/data-sources/github).
- **Publishing APIs**: Learn how to publish your SQL queries as APIs [here](https://docs.raw-labs.com/docs/publishing-api/overview).
- **SQL Language**: Explore RAW Labs' SQL language for data manipulation [here](https://docs.raw-labs.com/sql/overview).
