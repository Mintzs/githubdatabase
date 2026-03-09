
-- "DROP TABLE" commands to rerun SQL queries in reverse order of table creation to account for table dependencies --

DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Pull_Requests;
DROP TABLE IF EXISTS Commits;
DROP TABLE IF EXISTS Branches;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Membership;
DROP TABLE IF EXISTS Repositories;
DROP TABLE IF EXISTS Organizations;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Accounts;

-- Creating Tables & Entities --

CREATE TABLE Accounts(
account_id INTEGER, 
account_type TEXT,
PRIMARY KEY(account_id));

CREATE TABLE Users(
user_id INTEGER, 
username VARCHAR(39) NOT NULL UNIQUE, 
email TEXT NOT NULL UNIQUE, 
password TEXT, 
bio TEXT, 
location TEXT, 
status, 
PRIMARY KEY(user_id),
FOREIGN KEY(user_id) REFERENCES Accounts(account_id));

CREATE TABLE Organizations(
org_id INTEGER, 
name VARCHAR(39) NOT NULL UNIQUE, 
bio TEXT, 
location TEXT, 
PRIMARY KEY(org_id),
FOREIGN KEY(org_id) REFERENCES Accounts(account_id));

CREATE TABLE Membership( -- weak entity reliant on user_id and org_id for identification --
membership_id INTEGER,
role TEXT NOT NULL,
joined_at TEXT NOT NULL,
user_id,
org_id,
PRIMARY KEY(membership_id),
FOREIGN KEY(user_id) REFERENCES Users(user_id),
FOREIGN KEY(org_id) REFERENCES Organizations(org_id));

CREATE TABLE Teams( -- subgroup of organizations -- 
team_id INTEGER,
name TEXT,
description TEXT,
org_id,
PRIMARY KEY(team_id),
FOREIGN KEY(org_id) REFERENCES Organizations(org_id));

CREATE TABLE Repositories(
repo_id INTEGER,
name TEXT NOT NULL,
description TEXT,
visibility TEXT NOT NULL,
owner_user_id,
owner_org_id,
PRIMARY KEY(repo_id),
FOREIGN KEY(owner_user_id) REFERENCES Users(user_id),
FOREIGN KEY(owner_org_id) REFERENCES Organizations(org_id));

CREATE TABLE Branches(
branch_id INTEGER,
name TEXT NOT NULL,
repo_id,
PRIMARY KEY(branch_id),
FOREIGN KEY(repo_id) REFERENCES Repositories(repo_id));

CREATE TABLE Commits(
commit_id TEXT,
branch_id,
author_id,
message TEXT NOT NULL,
timestamp,
PRIMARY KEY(commit_id),
FOREIGN KEY(branch_id) REFERENCES Branches(branch_id),
FOREIGN KEY(author_id) REFERENCES Users(user_id));

CREATE TABLE Pull_requests(
pr_id INTEGER,
title,
description,
status TEXT,
source_branch_id,
target_branch_id,
creator_id,
PRIMARY KEY(pr_id),
FOREIGN KEY(source_branch_id) REFERENCES Branches(branch_id),
FOREIGN KEY(target_branch_id) REFERENCES Branches(branch_id),
FOREIGN KEY(creator_id) REFERENCES Users(user_id));

CREATE TABLE Comments( -- weak entity reliant on pr_id or commit_id --
comment_id INTEGER,
content TEXT,
author_id,
pr_id,
commit_id,
timestamp TEXT NOT NULL,
PRIMARY KEY(comment_id),
FOREIGN KEY(author_id) REFERENCES Users(user_id),
FOREIGN KEY(commit_id) REFERENCES Commits(commit_id),
FOREIGN KEY(pr_id) REFERENCES Pull_requests(pr_id)); 

-- Inserting data values into each table --

-- Accounts (must be inserted first)
INSERT INTO Accounts VALUES (1, 'user');
INSERT INTO Accounts VALUES (2, 'user');
INSERT INTO Accounts VALUES (3, 'user');
INSERT INTO Accounts VALUES (4, 'user');
INSERT INTO Accounts VALUES (5, 'user');
INSERT INTO Accounts VALUES (6, 'organization');
INSERT INTO Accounts VALUES (7, 'organization');
INSERT INTO Accounts VALUES (8, 'organization');

-- Users (user_id matches account_id)
INSERT INTO Users VALUES (1, 'mintz',  'mintz@email.com',  'hashed_pw1', 'AI developer',    'Leiden, NL',    'active');
INSERT INTO Users VALUES (2, 'janek',  'janek@email.com',  'hashed_pw2', 'Full stack dev',  'Amsterdam, NL', 'active');
INSERT INTO Users VALUES (3, 'ceco',    'ceco@email.com',    'hashed_pw3', 'Data scientist',  'Rotterdam, NL', 'active');
INSERT INTO Users VALUES (4, 'travis',  'travis@email.com',  'hashed_pw4', 'DevOps engineer', 'Utrecht, NL',   'active');
INSERT INTO Users VALUES (5, 'mara',   'mara@email.com',   'hashed_pw5', 'Backend dev',     'Den Haag, NL',  'suspended');

-- Organizations (org_id matches account_id, starting from 6)
INSERT INTO Organizations VALUES (6, 'promptshop', 'AI start up',  'Amsterdam, NL');
INSERT INTO Organizations VALUES (7, 'leiden-uni', 'Leiden University', 'Leiden, NL');
INSERT INTO Organizations VALUES (8, 'opendev',    'Open source org',   'Utrecht, NL');

-- Membership
INSERT INTO Membership VALUES (1, 'admin',  '2024-01-01', 1, 6);
INSERT INTO Membership VALUES (2, 'member', '2024-02-01', 2, 6);
INSERT INTO Membership VALUES (3, 'admin',  '2024-03-01', 3, 7);
INSERT INTO Membership VALUES (4, 'member', '2024-04-01', 4, 7);
INSERT INTO Membership VALUES (5, 'member', '2024-05-01', 5, 8);

-- Teams
INSERT INTO Teams VALUES (1, 'ai-team',  'AI development team',           6);
INSERT INTO Teams VALUES (2, 'research', 'Research and analysis',         7);
INSERT INTO Teams VALUES (3, 'devops',   'Infrastructure and deployment', 6);
INSERT INTO Teams VALUES (4, 'backend',  'Backend services',              8);
INSERT INTO Teams VALUES (5, 'frontend', 'UI and design',                 6);

-- Repositories
INSERT INTO Repositories VALUES (1, 'promptshop-api', 'REST API for PromptShop',  'public',  1,    NULL);
INSERT INTO Repositories VALUES (2, 'ml-models',      'ML model collection',      'private', 2,    NULL);
INSERT INTO Repositories VALUES (3, 'leiden-tools',   'University utility tools', 'public',  NULL, 7);
INSERT INTO Repositories VALUES (4, 'opendev-core',   'Core open source library', 'public',  NULL, 8);
INSERT INTO Repositories VALUES (5, 'data-pipeline',  'Data pipeline framework',  'private', 3,    NULL);

-- Branches
INSERT INTO Branches VALUES (1, 'main',           1);
INSERT INTO Branches VALUES (2, 'feature/auth',   1);
INSERT INTO Branches VALUES (3, 'main',           2);
INSERT INTO Branches VALUES (4, 'feature/resnet', 2);
INSERT INTO Branches VALUES (5, 'main',           3);

-- Commits
INSERT INTO Commits VALUES ('a1b2c3d4', 1, 1, 'Initial commit',        '2024-01-10T09:00:00');
INSERT INTO Commits VALUES ('b2c3d4e5', 2, 1, 'Add auth module',       '2024-01-15T11:00:00');
INSERT INTO Commits VALUES ('c3d4e5f6', 2, 1, 'Fix auth bug',          '2024-01-20T14:00:00');
INSERT INTO Commits VALUES ('d4e5f6g7', 3, 2, 'Add ML base model',     '2024-02-10T10:00:00');
INSERT INTO Commits VALUES ('e5f6g7h8', 5, 3, 'University tools init', '2024-03-01T08:00:00');
INSERT INTO Commits VALUES ('f6g7h8i9', 1, 2, 'Improve README',        '2024-01-25T16:00:00');
INSERT INTO Commits VALUES ('g7h8i9j0', 4, 5, 'Add ResNet50 model',    '2024-04-01T13:00:00');

-- Pull_Requests
INSERT INTO Pull_Requests VALUES (1, 'Add authentication',     'Implement OAuth2 flow',          'merged', 2, 1, 1);
INSERT INTO Pull_Requests VALUES (2, 'Fix auth edge case',     NULL,                             'open',   2, 1, 2);
INSERT INTO Pull_Requests VALUES (3, 'Add ResNet model',       'Deep learning image classifier', 'merged', 4, 3, 2);
INSERT INTO Pull_Requests VALUES (4, 'Improve data pipeline',  NULL,                             'open',   4, 3, 3);
INSERT INTO Pull_Requests VALUES (5, 'Fix documentation typo', NULL,                             'closed', 2, 1, 4);

-- Comments
INSERT INTO Comments VALUES (1, 'LGTM, great implementation!',   1, 1,    NULL,       '2024-01-17T10:00:00');
INSERT INTO Comments VALUES (2, 'Needs more unit tests',         2, 2,    NULL,       '2024-01-28T14:00:00');
INSERT INTO Comments VALUES (3, 'ResNet looks good to me',       1, 3,    NULL,       '2024-02-12T09:00:00');
INSERT INTO Comments VALUES (4, 'Initial commit looks clean',    2, NULL, 'a1b2c3d4', '2024-01-11T10:00:00');
INSERT INTO Comments VALUES (5, 'Please add more documentation', 3, 4,    NULL,       '2024-03-06T11:00:00');


-- View all tables --

SELECT * FROM Accounts;
SELECT * FROM Users;
SELECT * FROM Organizations;
SELECT * FROM Membership;
SELECT * FROM Teams;
SELECT * FROM Repositories;
SELECT * FROM Branches;
SELECT * FROM Commits;
SELECT * FROM Pull_Requests;
SELECT * FROM Comments;


