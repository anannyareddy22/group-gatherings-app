# Group Gatherings App

Our web application allows users to create groups, schedule the events, RSVP, comment and also participate in the polls. This is built using Node.js, Express, EJS and PostgreSQL as part of Phase 03. 

Features:

- User Accounts 
- Registration of a new account
- Login / Log Out
- Sessions are stored using express-session

Groups:

- Users can create new groups 
- Join and leave groups as well
- Group creator becomes admin 

Events:

- Users can create the event with title, description, time and location
- Edit or delete events (admin only)
- View the detailed event page

RSVP’s:

- Users are allowed to select: Yes/No/Maybe
- Automatic RSVP summary 

Comments:

- The group members can comment on the events 
- Comment list also displays user and timestamp 

Polls:

- Organize polls within the events
- Introduce several choices
- One vote per user
- Count of votes displayed live

Tech Stack:

- Node.js
- Express.js
- EJS
- PostgreSQL
- CSS

How to Run:

- Dependencies installation npm install
- PostgreSQL database preparation CREATE DATABASE group_gatherings;
- Launching the server node app.js

Application operates at: http://localhost:3000

Project Layout:

- app.js
- index.ejs
- styles.css
- package.json
- README.md
- node_modules

Members of the Team:

- Anannya Reddy Gade
- Karthik Viyyapu
- Srivardhan Bhogadi
- Pranav Manikanta Inturi

