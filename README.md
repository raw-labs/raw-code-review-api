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

This repository provides a **Code Reviewer API Template** for integrating data from **Salesforce**, **Jira**, and **Confluence** into the RAW Labs platform. It demonstrates how to retrieve and manipulate code review-related data using SQL queries on these platforms within RAW Labs. This API serves as a foundation for developers and support teams to access comprehensive code review information, enhancing collaboration and efficiency.

### How It Works

The RAW Labs platform enables the creation of APIs by writing SQL queries that access data from various sources, including Salesforce, Jira, and Confluence, using Steampipe's schemas. RAW Labs employs a Data Access Service (DAS) architecture to connect to multiple origin servers and data sources, allowing seamless, real-time data retrieval without data replication. This API template showcases how RAW Labs interacts with Salesforce for account data, Jira for issue tracking, and Confluence for documentation, providing a unified view essential for effective code reviewing.

### Features

- **Real-Time Data Access**: Query code review data in real-time without data replication.
- **Template Queries**: Utilize predefined queries for common code review operations.
- **Data Integration**: Combine data from Salesforce, Jira, and Confluence supported by RAW Labs.
- **Demonstration of Flexibility**: Highlights RAW Labs' capability to integrate diverse data sources, emphasizing adaptability to various data schemas and optimized data retrieval.

## Getting Started

### Prerequisites

- **Salesforce Account**:
  - Access to a Salesforce workspace with relevant account and issue data.
  - Necessary permissions to read data from Salesforce tables.
  
- **Jira Account**:
  - Access to a Jira instance with issue tracking enabled.
  - Necessary permissions to read data from Jira projects and issues.
  
- **Confluence Account**:
  - Access to a Confluence space containing knowledge base articles.
  - Necessary permissions to read data from Confluence pages.
  
- **RAW Labs Account**:
  - An active RAW Labs account. [Sign up here](https://app.raw-labs.com/register) if you don't have one.
  
- **Permissions**:
  - **Salesforce**:
    - API access enabled.
  - **Jira**:
    - API access enabled.
  - **Confluence**:
    - API access enabled.
  - **RAW Labs**:
    - Admin role to your RAW Labs account.
  
- **Dependencies**:
  - Web browser to access RAW Labs, Salesforce, Jira, and Confluence.
  - Internet connectivity.

### Setup Instructions

1. **Configure Data Source Connections in RAW Labs**:
   - Follow the instructions in the [RAW Labs Salesforce Data Source documentation](https://docs.raw-labs.com/sql/data-sources/salesforce) to set up your Salesforce connection.
   - Similarly, set up connections for [Jira](https://docs.raw-labs.com/sql/data-sources/jira) and [Confluence](https://docs.raw-labs.com/sql/data-sources/confluence).

2. **Clone the Repository**:
   - Clone this repository into your RAW Labs workspace:
     ```bash
     git clone https://github.com/your-repo/code-reviewer-api.git
     ```

3. **Review SQL and YAML Files**:
   - Examine the provided `.sql` and `.yml` files.
   - Each SQL file contains a query, and each YAML file configures the corresponding API endpoint.

4. **Customize the Queries**:
   - Adjust the SQL queries to fit your Salesforce, Jira, and Confluence datasets if necessary.
   - Modify filters, parameters, or entities according to your data schema.

5. **Deploy APIs in RAW Labs**:
   - Use RAW Labs to publish the SQL queries as APIs.
   - Refer to the [Publishing APIs documentation](https://docs.raw-labs.com/docs/publishing-api/overview) for guidance.

6. **Test Your APIs**:
   - Use RAW Labs' testing tools or tools like Postman to test your APIs.

## Domain Entities

### Entities Overview

The template focuses on key code review-related entities typically found across Salesforce, Jira, and Confluence:

- **Account (Salesforce)**: Represents clients or internal teams involved in code projects.
- **Issue (Jira)**: Represents code review tasks, bugs, feature requests, and other work items.
- **Epic (Jira)**: Represents larger code projects or initiatives under which multiple issues fall.
- **Knowledge Base Article (Confluence)**: Documentation and troubleshooting guides related to code projects.
- **Communication (Salesforce Cases or Tasks)**: Represents interactions and communications with clients or teams.

### Entity Relationships

![Class Diagram of Code Reviewer Entities](code_reviewer_entities.png)

*Alt text: Class diagram showing relationships between Account (Salesforce), Issue (Jira), Epic (Jira), and Knowledge Base Article (Confluence) entities.*

## Query Structure

### Basic Structure of SQL Files

Each SQL file contains a query that retrieves data from Salesforce, Jira, and Confluence. The queries are written in standard SQL and are designed for flexibility, supporting dynamic filtering and pagination.

- **Parameters**: Defined at the top of each file using comments in the RAW Labs format.
- **Filters**: Applied in the `WHERE` clause based on parameters.
- **Pagination**: Implemented using `LIMIT` and `OFFSET`.

### Types of Queries

#### Level 1: Basic Queries

These queries retrieve data from single tables and support dynamic filtering and pagination.

**Example:**

```sql
-- @param account_id Filter by account ID.
-- @type account_id integer
-- @default account_id null

-- Additional parameters...

-- @return A list of accounts matching the specified filters with pagination.

WITH filtered_accounts AS (
    SELECT
        account_id,
        account_name,
        industry,
        last_modified_date,
        billing_city,
        billing_country
    FROM salesforce_account
    WHERE (account_id = :account_id OR :account_id IS NULL)
      -- Additional filters...
)
SELECT *
FROM filtered_accounts
ORDER BY account_id
LIMIT COALESCE(:page_size, 25) OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 25);
```

#### Level 2: Intermediate Queries

These queries involve joins between multiple tables to provide more complex data retrieval.

**Example:**

```sql
-- @param epic_key Filter by Jira Epic Key.
-- @type epic_key string
-- @default epic_key null

-- Additional parameters...

-- @return A list of Jira issues under a specific Epic with pagination.

WITH issues_under_epic AS (
    SELECT
        j.issue_id,
        j.key AS jira_issue_key,
        j.summary AS jira_summary,
        j.status AS jira_status,
        j.assignee_display_name,
        j.created_at,
        j.updated_at
    FROM jira_issue AS j
    JOIN jira_epic AS e ON j.epic_id = e.id
    WHERE (e.key = :epic_key OR :epic_key IS NULL)
      -- Additional filters...
)
SELECT *
FROM issues_under_epic
ORDER BY created_at DESC
LIMIT COALESCE(:page_size, 25) OFFSET (COALESCE(:page, 1) - 1) * COALESCE(:page_size, 25);
```

#### Level 3: Advanced Queries

These queries use advanced SQL techniques like window functions and subqueries to provide analytical insights.

**Example:**

```sql
-- @param min_issue_priority Minimum issue priority.
-- @type min_issue_priority integer
-- @default min_issue_priority 3

-- Additional parameters...

-- @return Issues with priority above the specified level and their related knowledge base articles.

WITH high_priority_issues AS (
    SELECT
        j.issue_id,
        j.key AS jira_issue_key,
        j.summary AS jira_summary,
        j.priority,
        j.status,
        e.key AS jira_epic_key
    FROM jira_issue AS j
    JOIN jira_epic AS e ON j.epic_id = e.id
    WHERE j.priority >= :min_issue_priority
      -- Additional filters...
),
related_articles AS (
    SELECT
        cp.page_id,
        cp.title AS article_title,
        cp.url AS article_url,
        cp.last_updated AS article_last_updated,
        hi.jira_issue_key
    FROM confluence_page AS cp
    JOIN high_priority_issues AS hi ON LOWER(cp.title) LIKE '%' || LOWER(hi.jira_issue_key) || '%'
    WHERE cp.space = 'Code_Review_Knowledge_Base'
)
SELECT
    hi.jira_issue_key,
    hi.jira_summary,
    hi.priority,
    hi.status,
    ra.article_title,
    ra.article_url,
    ra.article_last_updated
FROM high_priority_issues AS hi
LEFT JOIN related_articles AS ra ON hi.jira_issue_key = ra.jira_issue_key
ORDER BY hi.priority DESC, hi.jira_issue_key;
```

## Filters and Pagination

### Filters

The template supports various types of filters for flexible querying:

| Filter Type               | Description                                                         | Example                                                                                 |
|---------------------------|---------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| **Equality Filters**     | Checks if a column's value equals the specified parameter or is NULL | `AND (account_id = :account_id OR :account_id IS NULL)`                                 |
| **Substring Search**     | Searches for a substring within a column                            | `AND (jira_summary ILIKE CONCAT('%', :jira_summary, '%') OR :jira_summary IS NULL)`      |
| **Range Filters**        | Filters data within a numeric or date range                         | `AND (created_at >= :start_date OR :start_date IS NULL)`                                |
| **List Filters**         | Matches any value from a list                                       | `AND (category_id IN (:category_ids) OR :category_ids IS NULL)`                         |
| **Priority Filters**     | Filters based on priority levels                                   | `AND (priority >= :min_priority OR :min_priority IS NULL)`                              |

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

This Code Reviewer API template is designed to be adaptable to various datasets and schemas:

- **Modify SQL Queries**: Adjust the provided SQL queries to include additional fields or entities specific to your Salesforce, Jira, and Confluence databases.
- **Add New Endpoints**: Create new SQL and YAML files to define additional API endpoints as needed.
- **Adjust Parameters**: Modify or add parameters in the queries to support custom filters and requirements.

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
    - [Salesforce Data Source](https://docs.raw-labs.com/sql/data-sources/salesforce)
    - [Jira Data Source](https://docs.raw-labs.com/sql/data-sources/jira)
    - [Confluence Data Source](https://docs.raw-labs.com/sql/data-sources/confluence)
    - [Publishing APIs](https://docs.raw-labs.com/docs/publishing-api/overview)

- **Community Forum**:
  - Join the discussion on our [Community Forum](https://www.raw-labs.com/community).

- **Contact Support**:
  - Email us at [support@raw-labs.com](mailto:support@raw-labs.com) for assistance.

## License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- **Contributors**: Thanks to all our contributors for their efforts.
- **Third-Party Tools**: This template utilizes Salesforce, Jira, and Confluence, demonstrating integration with RAW Labs.

## Contact

- **Email**: [support@raw-labs.com](mailto:support@raw-labs.com)
- **Website**: [https://raw-labs.com](https://raw-labs.com)
- **Twitter**: [@RAWLabs](https://twitter.com/raw_labs)
- **Community Forum**: [Forum](https://www.raw-labs.com/community)

---

## Additional Resources

- **RAW Labs Documentation**: Comprehensive guides and references are available at [docs.raw-labs.com](https://docs.raw-labs.com/).
- **Salesforce Data Source**: Detailed instructions on connecting Salesforce with RAW Labs can be found [here](https://docs.raw-labs.com/sql/data-sources/salesforce).
- **Jira Data Source**: Detailed instructions on connecting Jira with RAW Labs can be found [here](https://docs.raw-labs.com/sql/data-sources/jira).
- **Confluence Data Source**: Detailed instructions on connecting Confluence with RAW Labs can be found [here](https://docs.raw-labs.com/sql/data-sources/confluence).
- **Publishing APIs**: Learn how to publish your SQL queries as APIs [here](https://docs.raw-labs.com/docs/publishing-api/overview).
- **Steampipe Schemas**: Explore Steampipe's schemas for Salesforce, Jira, and Confluence [here](https://www.steampipe.io/docs/reference/schemas).
