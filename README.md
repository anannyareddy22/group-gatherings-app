# Group Gatherings App

A web application that allows users to create groups, schedule events, RSVP, comment, and participate in polls.
Built using Node.js, Express, EJS, and PostgreSQL as part of the ASU Phase 3 Project.

Features:

- User Accounts

- Register a new account

- Log in / Log out

- Sessions stored using express-session

Groups:

- Create new groups

- Join and leave groups

- Group creator becomes admin

Events:

- Create events with title, description, time, and location

- Edit or delete events (admin only)

- View detailed event page

RSVPs:

- Users can select: Yes / No / Maybe

- Automatic RSVP summary

Comments:

- Group members can comment on events

- Comment list displays user and timestamp

Polls:

- Create polls inside events

- Add multiple options

- Users can vote once

- Vote counts update live

Tech Stack:

- Node.js

- Express.js

- EJS

- PostgreSQL

- CSS

How to Run:

1. Install dependencies
npm install

2. Create PostgreSQL database
CREATE DATABASE group_gatherings;

3. Start the server
node app.js

App runs at: http://localhost:3000

Project Structure:

- app.js
- index.ejs
- styles.css
- package.json
- README.md
- node_modules

Team Members:

- Anannya Reddy Gade

- Karthik Viyyapu

- Srivardhan Bhogadi

- Pranav Manikanta Inturi 