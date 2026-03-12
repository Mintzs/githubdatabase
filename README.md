# githubdatabase
A relational database schema modelling GitHub's core entities using SQLite.

## Overview
This project designs and implements a relational database schema that 
reflects how GitHub structures its data: from user accounts and 
organizations to repositories, branches, commits, and pull requests.

## Schema

The database consists of the following tables:

| Table | Description |
|---|---|
| `Accounts` | Shared parent entity for users and organizations |
| `Users` | Individual GitHub user accounts |
| `Organizations` | GitHub organization accounts |
| `Membership` | Weak entity linking users to organizations (with role) |
| `Teams` | Subgroups within an organization |
| `Repositories` | Code repositories owned by a user or organization |
| `Branches` | Named branches within a repository |
| `Commits` | Individual code snapshots |
| `Pull_Requests` | Proposals to merge one branch into another |
| `Comments` | Weak entity for comments on pull requests or commits |
