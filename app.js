const express = require("express");
const path = require("path");
const { Pool } = require("pg");
const session = require("express-session");

const app = express();

const pool = new Pool({
  host: "localhost",
  port: 5432,
  user: "sbhogad1",
  password: "Alterego@90",
  database: "group_gatherings"
});

app.set("view engine", "ejs");
app.set("views", __dirname);

app.use(express.static(__dirname));
app.use(express.urlencoded({ extended: true }));

app.use(
  session({
    secret: "CHANGE_THIS_SECRET",
    resave: false,
    saveUninitialized: false
  })
);

app.use((req, res, next) => {
  res.locals.currentUser = req.session.user || null;
  next();
});

function requireLogin(req, res, next) {
  if (!req.session.user) return res.redirect("/");
  next();
}

app.post("/register", async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) return res.redirect("/");
  try {
    const result = await pool.query(
      `INSERT INTO users (name, email, password_hash)
       VALUES ($1, $2, $3)
       ON CONFLICT (email) DO NOTHING
       RETURNING user_id, name, email`,
      [name, email, password]
    );
    let user;
    if (result.rows.length > 0) {
      user = result.rows[0];
    } else {
      const existing = await pool.query(
        "SELECT user_id, name, email FROM users WHERE email=$1",
        [email]
      );
      user = existing.rows[0];
    }
    req.session.user = user;
    res.redirect("/");
  } catch (err) {
    res.redirect("/");
  }
});

app.post("/login", async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT user_id, name, email
       FROM users
       WHERE email=$1 AND password_hash=$2`,
      [req.body.email, req.body.password]
    );
    if (result.rows.length === 0) return res.redirect("/");
    req.session.user = result.rows[0];
    res.redirect("/");
  } catch (err) {
    res.redirect("/");
  }
});

app.get("/logout", (req, res) => req.session.destroy(() => res.redirect("/")));

async function loadHomeData(userId) {
  const groups = await pool.query(
    `SELECT g.*, 
            COUNT(DISTINCT gm.user_id) AS member_count,
            MAX(CASE WHEN gm.user_id=$1 THEN gm.role ELSE NULL END) AS current_role
     FROM groups g
     LEFT JOIN group_members gm ON gm.group_id = g.group_id
     GROUP BY g.group_id
     ORDER BY g.group_id`,
    [userId]
  );
  const events = await pool.query(
    `SELECT e.*, g.name AS group_name
     FROM events e
     JOIN groups g ON g.group_id = e.group_id
     ORDER BY e.start_at, e.event_id`
  );
  return { groups: groups.rows, events: events.rows };
}

app.get("/", async (req, res) => {
  try {
    const userId = req.session.user ? req.session.user.user_id : null;
    const { groups, events } = await loadHomeData(userId);
    res.render("index", {
      groups,
      events,
      selectedEvent: null,
      editEvent: null,
      rsvps: [],
      rsvpSummary: null,
      comments: [],
      polls: [],
      canComment: false,
      isAdmin: false
    });
  } catch (err) {
    res.send("Error loading homepage");
  }
});

app.post("/groups", requireLogin, async (req, res) => {
  const { name, description } = req.body;
  const userId = req.session.user.user_id;
  try {
    const result = await pool.query(
      `INSERT INTO groups (name, description)
       VALUES ($1, $2)
       RETURNING group_id`,
      [name, description || null]
    );
    const groupId = result.rows[0].group_id;
    await pool.query(
      `INSERT INTO group_members (group_id, user_id, role)
       VALUES ($1, $2, 'admin')
       ON CONFLICT DO NOTHING`,
      [groupId, userId]
    );
    res.redirect("/");
  } catch (err) {
    res.redirect("/");
  }
});

app.post("/groups/:id/join", requireLogin, async (req, res) => {
  try {
    await pool.query(
      `INSERT INTO group_members (group_id, user_id, role)
       VALUES ($1, $2, 'member')
       ON CONFLICT DO NOTHING`,
      [req.params.id, req.session.user.user_id]
    );
    res.redirect("/");
  } catch (err) {
    res.redirect("/");
  }
});

app.post("/groups/:id/leave", requireLogin, async (req, res) => {
  try {
    await pool.query(
      "DELETE FROM group_members WHERE group_id=$1 AND user_id=$2",
      [req.params.id, req.session.user.user_id]
    );
    res.redirect("/");
  } catch (err) {
    res.redirect("/");
  }
});

app.post("/events", requireLogin, async (req, res) => {
  const { group_id, title, description, start_at, end_at, location, status } =
    req.body;
  try {
    await pool.query(
      `INSERT INTO events (group_id, title, description, start_at, end_at, location, status)
       VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [
        group_id,
        title,
        description || null,
        start_at,
        end_at,
        location || null,
        status || "draft"
      ]
    );
    res.redirect("/");
  } catch (err) {
    res.redirect("/");
  }
});

app.get("/events/:id", async (req, res) => {
  const eventId = parseInt(req.params.id, 10);
  const userId = req.session.user ? req.session.user.user_id : null;
  try {
    const { groups, events } = await loadHomeData(userId);
    const ev = await pool.query(
      `SELECT e.*, g.name AS group_name
       FROM events e 
       JOIN groups g ON g.group_id = e.group_id
       WHERE e.event_id=$1`,
      [eventId]
    );
    if (ev.rows.length === 0) return res.redirect("/");
    const selectedEvent = ev.rows[0];
    const rsvps = await pool.query(
      `SELECT r.*, u.name
       FROM rsvps r 
       JOIN users u ON u.user_id=r.user_id
       WHERE r.event_id=$1
       ORDER BY u.name`,
      [eventId]
    );
    const summaryRes = await pool.query(
      `SELECT response, COUNT(*) AS count
       FROM rsvps 
       WHERE event_id=$1
       GROUP BY response`,
      [eventId]
    );
    const summary = { yes: 0, no: 0, maybe: 0 };
    summaryRes.rows.forEach((r) => (summary[r.response] = Number(r.count)));
    const comments = await pool.query(
      `SELECT c.*, u.name
       FROM comments c 
       JOIN users u ON u.user_id=c.user_id
       WHERE event_id=$1
       ORDER BY c.comment_id`,
      [eventId]
    );
    let canComment = false;
    let isAdmin = false;
    if (userId) {
      const mem = await pool.query(
        `SELECT role 
         FROM group_members gm
         JOIN events e ON e.group_id=gm.group_id
         WHERE gm.user_id=$1 AND e.event_id=$2`,
        [userId, eventId]
      );
      if (mem.rows.length > 0) {
        canComment = true;
        if (mem.rows[0].role === "admin") isAdmin = true;
      }
    }
    const pollsRes = await pool.query(
      `SELECT * FROM polls WHERE event_id=$1 ORDER BY poll_id`,
      [eventId]
    );
    let polls = [];
    if (pollsRes.rows.length > 0) {
      const pollIds = pollsRes.rows.map((p) => p.poll_id);
      const options = await pool.query(
        `SELECT o.*, COUNT(v.user_id) AS vote_count
         FROM poll_options o
         LEFT JOIN poll_votes v ON v.option_id=o.option_id
         WHERE o.poll_id = ANY($1::int[])
         GROUP BY o.option_id
         ORDER BY o.option_id`,
        [pollIds]
      );
      const byPoll = {};
      options.rows.forEach((opt) => {
        if (!byPoll[opt.poll_id]) byPoll[opt.poll_id] = [];
        byPoll[opt.poll_id].push(opt);
      });
      polls = pollsRes.rows.map((poll) => ({
        ...poll,
        options: byPoll[poll.poll_id] || []
      }));
    }
    res.render("index", {
      groups,
      events,
      selectedEvent,
      editEvent: null,
      rsvps: rsvps.rows,
      rsvpSummary: summary,
      comments: comments.rows,
      polls,
      canComment,
      isAdmin
    });
  } catch (err) {
    res.redirect("/");
  }
});

app.get("/events/:id/edit", requireLogin, async (req, res) => {
  const eventId = req.params.id;
  const userId = req.session.user.user_id;
  try {
    const ev = await pool.query(
      `SELECT e.*, g.name AS group_name, gm.role
       FROM events e
       JOIN groups g ON g.group_id = e.group_id
       JOIN group_members gm ON gm.group_id = e.group_id AND gm.user_id=$1
       WHERE e.event_id=$2`,
      [userId, eventId]
    );
    if (ev.rows.length === 0) return res.send("Event not found");
    if (ev.rows[0].role !== "admin") return res.send("Only admins can edit events");
    const event = ev.rows[0];
    const { groups, events } = await loadHomeData(userId);
    res.render("index", {
      groups,
      events,
      selectedEvent: null,
      editEvent: event,
      rsvps: [],
      rsvpSummary: null,
      comments: [],
      polls: [],
      canComment: false,
      isAdmin: true
    });
  } catch (err) {
    res.redirect("/");
  }
});

app.post("/events/:id/edit", requireLogin, async (req, res) => {
  const eventId = req.params.id;
  const userId = req.session.user.user_id;
  const { title, description, start_at, end_at, location, status } = req.body;
  try {
    const role = await pool.query(
      `SELECT gm.role
       FROM events e
       JOIN group_members gm ON gm.group_id=e.group_id
       WHERE e.event_id=$1 AND gm.user_id=$2`,
      [eventId, userId]
    );
    if (role.rows.length === 0 || role.rows[0].role !== "admin")
      return res.send("Only admins can edit events");
    await pool.query(
      `UPDATE events
       SET title=$1, description=$2, start_at=$3, end_at=$4, 
           location=$5, status=$6
       WHERE event_id=$7`,
      [title, description, start_at, end_at, location, status, eventId]
    );
    res.redirect(`/events/${eventId}`);
  } catch (err) {
    res.redirect(`/events/${eventId}`);
  }
});

app.post("/events/:id/rsvp", requireLogin, async (req, res) => {
  const eventId = req.params.id;
  const userId = req.session.user.user_id;
  await pool.query(
    `INSERT INTO rsvps (event_id, user_id, response)
     VALUES ($1,$2,$3)
     ON CONFLICT (event_id, user_id)
     DO UPDATE SET response=EXCLUDED.response, responded_at=NOW()`,
    [eventId, userId, req.body.response]
  );
  res.redirect(`/events/${eventId}`);
});

app.post("/events/:id/comments", requireLogin, async (req, res) => {
  const eventId = req.params.id;
  const userId = req.session.user.user_id;
  const allowed = await pool.query(
    `SELECT 1 FROM group_members gm
     JOIN events e ON e.group_id = gm.group_id
     WHERE gm.user_id=$1 AND e.event_id=$2`,
    [userId, eventId]
  );
  if (allowed.rows.length === 0) return res.redirect(`/events/${eventId}`);
  await pool.query(
    `INSERT INTO comments (event_id, user_id, body)
     VALUES ($1,$2,$3)`,
    [eventId, userId, req.body.body]
  );
  res.redirect(`/events/${eventId}`);
});

app.post("/events/:id/polls", requireLogin, async (req, res) => {
  const eventId = parseInt(req.params.id, 10);
  const userId = req.session.user.user_id;
  const { type, question, option1, option2, option3 } = req.body;
  try {
    const mem = await pool.query(
      `SELECT gm.role
       FROM group_members gm
       JOIN events e ON e.group_id = gm.group_id
       WHERE gm.user_id=$1 AND e.event_id=$2`,
      [userId, eventId]
    );
    if (mem.rows.length === 0 || mem.rows[0].role !== "admin")
      return res.redirect(`/events/${eventId}`);
    const pollRes = await pool.query(
      `INSERT INTO polls (event_id, type, question)
       VALUES ($1, $2, $3)
       RETURNING poll_id`,
      [eventId, type, question]
    );
    const pollId = pollRes.rows[0].poll_id;
    const options = [option1, option2, option3].filter(
      (o) => o && o.trim().length > 0
    );
    for (const opt of options) {
      await pool.query(
        `INSERT INTO poll_options (poll_id, value)
         VALUES ($1, $2)`,
        [pollId, opt.trim()]
      );
    }
    res.redirect(`/events/${eventId}`);
  } catch (err) {
    res.redirect(`/events/${eventId}`);
  }
});

app.post("/polls/:pollId/vote", requireLogin, async (req, res) => {
  const pollId = parseInt(req.params.pollId, 10);
  const userId = req.session.user.user_id;
  const { option_id, event_id } = req.body;
  try {
    await pool.query(
      `INSERT INTO poll_votes (poll_id, option_id, user_id)
       VALUES ($1,$2,$3)
       ON CONFLICT (poll_id, user_id)
       DO UPDATE SET option_id = EXCLUDED.option_id, voted_at = NOW()`,
      [pollId, option_id, userId]
    );
    res.redirect(`/events/${event_id}`);
  } catch (err) {
    res.redirect(`/events/${event_id}`);
  }
});

app.post("/events/:id/delete", requireLogin, async (req, res) => {
  const eventId = req.params.id;
  const userId = req.session.user.user_id;
  try {
    const role = await pool.query(
      `SELECT gm.role
       FROM events e
       JOIN group_members gm ON gm.group_id=e.group_id
       WHERE e.event_id=$1 AND gm.user_id=$2`,
      [eventId, userId]
    );
    if (role.rows.length === 0 || role.rows[0].role !== "admin")
      return res.send("Admins only.");
    await pool.query("DELETE FROM events WHERE event_id=$1", [eventId]);
    res.redirect("/");
  } catch (err) {
    res.redirect("/");
  }
});

const PORT = 3000;
app.listen(PORT, () =>
  console.log(`App running → http://localhost:${PORT}`)
);
