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
followers INTEGER DEFAULT 0,
status CHECK(status IN ('active', 'suspended')), 
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
FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE, 
FOREIGN KEY(org_id) REFERENCES Organizations(org_id) ON DELETE CASCADE);

CREATE TABLE Repositories(
repo_id INTEGER,
name TEXT NOT NULL,
description TEXT,
visibility TEXT NOT NULL CHECK(visibility IN ('public', 'private')),
owner_user_id,
owner_org_id,
PRIMARY KEY(repo_id),
FOREIGN KEY(owner_user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
FOREIGN KEY(owner_org_id) REFERENCES Organizations(org_id) ON DELETE CASCADE,
CHECK(owner_user_id IS NOT NULL OR owner_org_id IS NOT NULL));

CREATE TABLE Commits(
commit_id TEXT,
author_id,
repo_id,
message TEXT NOT NULL,
timestamp,
PRIMARY KEY(commit_id),
FOREIGN KEY(author_id) REFERENCES Users(user_id) ON DELETE SET NULL,
FOREIGN KEY(repo_id) REFERENCES Repositories(repo_id) ON DELETE CASCADE);

CREATE TABLE Pull_requests(
pr_id INTEGER,
repo_id,
title,
description,
status TEXT CHECK(status IN ('open', 'closed', 'merged')),
creator_id,
PRIMARY KEY(pr_id),
FOREIGN KEY(repo_id) REFERENCES Repositories(repo_id) ON DELETE CASCADE,
FOREIGN KEY(creator_id) REFERENCES Users(user_id) ON DELETE SET NULL);

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
INSERT INTO Users VALUES (1, 'mintz',  'mintz@email.com',  'hashed_pw1', 'AI developer',    'Leiden, NL', '100',    'active');
INSERT INTO Users VALUES (2, 'janek',  'janek@email.com',  'hashed_pw2', 'Full stack dev',  'Amsterdam, NL', '67',     'active');
INSERT INTO Users VALUES (3, 'ceco',    'ceco@email.com',    'hashed_pw3', 'Data scientist',  'Rotterdam, NL', '69',     'active');
INSERT INTO Users VALUES (4, 'travis',  'travis@email.com',  'hashed_pw4', 'DevOps engineer', 'Utrecht, NL',   '10000',     'active');
INSERT INTO Users VALUES (5, 'mara',   'mara@email.com',   'hashed_pw5', 'Backend dev',     'Den Haag, NL',  '0',     'suspended');

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

-- Repositories
INSERT INTO Repositories VALUES (1, 'promptshop-api', 'REST API for PromptShop',  'public',  1, NULL);
INSERT INTO Repositories VALUES (2, 'ml-models',      'ML model collection',      'private', 2, NULL);
INSERT INTO Repositories VALUES (3, 'leiden-tools',   'University utility tools', 'public',  NULL, 7);
INSERT INTO Repositories VALUES (4, 'opendev-core',   'Core open source library', 'public',  NULL, 8);
INSERT INTO Repositories VALUES (5, 'data-pipeline',  'Data pipeline framework',  'private', 3, NULL);
INSERT INTO Repositories VALUES (6, 'portfolio',  'Personal portfolio',  'public', 3, NULL);

-- Commits
INSERT INTO Commits VALUES ('a1b2c3d4', 1, 1, 'Initial commit',        '2024-01-10T09:00:00');
INSERT INTO Commits VALUES ('b2c3d4e5', 2, 1, 'Add auth module',       '2024-01-15T11:00:00');
INSERT INTO Commits VALUES ('c3d4e5f6', 2, 1, 'Fix auth bug',          '2024-01-20T14:00:00');
INSERT INTO Commits VALUES ('d4e5f6g7', 3, 2, 'Add ML base model',     '2024-02-10T10:00:00');
INSERT INTO Commits VALUES ('e5f6g7h8', 5, 3, 'University tools init', '2024-03-01T08:00:00');
INSERT INTO Commits VALUES ('f6g7h8i9', 1, 2, 'Improve README',        '2024-01-25T16:00:00');
INSERT INTO Commits VALUES ('g7h8i9j0', 4, 3, 'Add ResNet50 model',    '2024-04-01T13:00:00');

-- Pull_Requests
INSERT INTO Pull_Requests VALUES (1, 1, 'Add authentication',     'Implement OAuth2 flow',          'merged', 1);
INSERT INTO Pull_Requests VALUES (2, 1, 'Fix auth edge case',     NULL,                             'open',   2);
INSERT INTO Pull_Requests VALUES (3, 2, 'Add ResNet model',       'Deep learning image classifier', 'merged', 2);
INSERT INTO Pull_Requests VALUES (4, 3, 'Improve data pipeline',  NULL,                             'open',   3);
INSERT INTO Pull_Requests VALUES (5, 4, 'Fix documentation typo', NULL,                             'closed', 4);


-- View all tables --

SELECT * FROM Accounts;
SELECT * FROM Users;
SELECT * FROM Organizations;
SELECT * FROM Membership;
SELECT * FROM Repositories;
SELECT * FROM Commits;
SELECT * FROM Pull_Requests;


-----=== QUERIES ===-----

--1
SELECT Users.username, Repositories.name AS repository_name FROM Users JOIN Repositories ON Users.user_id = Repositories.owner_user_id;
-- Outputs each user's username that owns a repository and the repositories they own.
-- Actual Output:
-- username,	repository_name
-- mintz,	promptshop-api
-- janek,	ml-models
-- ceco, data-pipeline
-- ceco,	portfolio

--2
SELECT org_id, COUNT(user_id) AS member_count FROM Membership GROUP BY org_id HAVING COUNT(user_id) > 1;
-- Outputs IDs of organizations with more than one member. Shows total number of members in each organization as well.
-- Actual Output:
-- org_id,	member_count
-- 6,	2
-- 7,	2


--3 
SELECT username FROM Users EXCEPT SELECT username FROM Users WHERE user_id = 3;
--  Outputs all usernames except for 'ceco'.
-- Actual Output:
-- username
-- janek
-- mara
-- mintz
-- travis

--4
SELECT repo_id, name FROM Repositories 
WHERE (SELECT COUNT(pr_id) FROM Pull_Requests WHERE Pull_Requests.repo_id = Repositories.repo_id AND Pull_Requests.status = 'open') >= 1;
-- Outputs the repositories that have at least one unresolved pull requests.
-- Actual Output:
-- repo_id, name
-- 1, promptshop-api
-- 3, leiden-tools

--5
SELECT account_type, COUNT(account_id) * 100.0 / (SELECT COUNT(*) FROM Accounts) 
AS percentage FROM Accounts GROUP BY account_type;
-- Outputs the percentage of accounts that are either a user or an organization.
-- Actual Output:
-- account_type, percentage
-- organization, 37.5
-- user, 62.5

--6
SELECT name, bio FROM Organizations WHERE name LIKE '%AI%' OR bio LIKE '%AI%';
-- Show all "AI-focused" organizations that mention AI in their name or bio
-- Actual Output
-- name, bio
-- promptshop, AI start up
