--
-- postgreSQL database dump
--

\restrict OECf8GWTBGsTyxc7tbqacBba4TONvklTf0tbfXfp15uGwwaebrLbxeU8ypxmp0C

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.comments (
    comment_id integer NOT NULL,
    event_id integer,
    user_id integer,
    body text NOT NULL
);


ALTER TABLE public.comments OWNER TO sbhogad1;

--
-- Name: comments_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: sbhogad1
--

CREATE SEQUENCE public.comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comments_comment_id_seq OWNER TO sbhogad1;

--
-- Name: comments_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sbhogad1
--

ALTER SEQUENCE public.comments_comment_id_seq OWNED BY public.comments.comment_id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.events (
    event_id integer NOT NULL,
    group_id integer,
    title character varying(200) NOT NULL,
    description text,
    start_at timestamp without time zone NOT NULL,
    end_at timestamp without time zone NOT NULL,
    location character varying(255),
    status character varying(15) DEFAULT 'draft'::character varying,
    CONSTRAINT events_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'published'::character varying, 'finalized'::character varying])::text[])))
);


ALTER TABLE public.events OWNER TO sbhogad1;

--
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: sbhogad1
--

CREATE SEQUENCE public.events_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.events_event_id_seq OWNER TO sbhogad1;

--
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sbhogad1
--

ALTER SEQUENCE public.events_event_id_seq OWNED BY public.events.event_id;


--
-- Name: group_members; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.group_members (
    group_id integer NOT NULL,
    user_id integer NOT NULL,
    role character varying(10) NOT NULL,
    CONSTRAINT group_members_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'member'::character varying])::text[])))
);


ALTER TABLE public.group_members OWNER TO sbhogad1;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.groups (
    group_id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.groups OWNER TO sbhogad1;

--
-- Name: groups_group_id_seq; Type: SEQUENCE; Schema: public; Owner: sbhogad1
--

CREATE SEQUENCE public.groups_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_group_id_seq OWNER TO sbhogad1;

--
-- Name: groups_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sbhogad1
--

ALTER SEQUENCE public.groups_group_id_seq OWNED BY public.groups.group_id;


--
-- Name: poll_options; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.poll_options (
    option_id integer NOT NULL,
    poll_id integer,
    value text NOT NULL,
    note text
);


ALTER TABLE public.poll_options OWNER TO sbhogad1;

--
-- Name: poll_options_option_id_seq; Type: SEQUENCE; Schema: public; Owner: sbhogad1
--

CREATE SEQUENCE public.poll_options_option_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.poll_options_option_id_seq OWNER TO sbhogad1;

--
-- Name: poll_options_option_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sbhogad1
--

ALTER SEQUENCE public.poll_options_option_id_seq OWNED BY public.poll_options.option_id;


--
-- Name: poll_votes; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.poll_votes (
    poll_id integer NOT NULL,
    option_id integer,
    user_id integer NOT NULL,
    voted_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.poll_votes OWNER TO sbhogad1;

--
-- Name: polls; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.polls (
    poll_id integer NOT NULL,
    event_id integer,
    type character varying(20) NOT NULL,
    question text NOT NULL,
    is_open boolean DEFAULT true,
    CONSTRAINT polls_type_check CHECK (((type)::text = ANY ((ARRAY['time'::character varying, 'location'::character varying, 'other'::character varying])::text[])))
);


ALTER TABLE public.polls OWNER TO sbhogad1;

--
-- Name: polls_poll_id_seq; Type: SEQUENCE; Schema: public; Owner: sbhogad1
--

CREATE SEQUENCE public.polls_poll_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.polls_poll_id_seq OWNER TO sbhogad1;

--
-- Name: polls_poll_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sbhogad1
--

ALTER SEQUENCE public.polls_poll_id_seq OWNED BY public.polls.poll_id;


--
-- Name: rsvps; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.rsvps (
    event_id integer NOT NULL,
    user_id integer NOT NULL,
    response character varying(10) NOT NULL,
    responded_at timestamp without time zone DEFAULT now(),
    CONSTRAINT rsvps_response_check CHECK (((response)::text = ANY ((ARRAY['yes'::character varying, 'no'::character varying, 'maybe'::character varying])::text[])))
);


ALTER TABLE public.rsvps OWNER TO sbhogad1;

--
-- Name: users; Type: TABLE; Schema: public; Owner: sbhogad1
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL
);


ALTER TABLE public.users OWNER TO sbhogad1;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: sbhogad1
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO sbhogad1;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sbhogad1
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: comments comment_id; Type: DEFAULT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.comments ALTER COLUMN comment_id SET DEFAULT nextval('public.comments_comment_id_seq'::regclass);


--
-- Name: events event_id; Type: DEFAULT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.events ALTER COLUMN event_id SET DEFAULT nextval('public.events_event_id_seq'::regclass);


--
-- Name: groups group_id; Type: DEFAULT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.groups ALTER COLUMN group_id SET DEFAULT nextval('public.groups_group_id_seq'::regclass);


--
-- Name: poll_options option_id; Type: DEFAULT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.poll_options ALTER COLUMN option_id SET DEFAULT nextval('public.poll_options_option_id_seq'::regclass);


--
-- Name: polls poll_id; Type: DEFAULT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.polls ALTER COLUMN poll_id SET DEFAULT nextval('public.polls_poll_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.comments (comment_id, event_id, user_id, body) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.events (event_id, group_id, title, description, start_at, end_at, location, status) FROM stdin;
\.


--
-- Data for Name: group_members; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.group_members (group_id, user_id, role) FROM stdin;
13	11	admin
14	11	member
15	11	admin
17	11	admin
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.groups (group_id, name, description) FROM stdin;
13	Study event	study for exams
14	Music Lovers	A group for people who enjoy music.
15	jhfbvdhf	 vcfbzj
16	shjbfaufbhjera	ajhbvurae
17	90jdvfhusf	jfv nhjgfnshvb
18	fghvnhjdfnbu	jnvhugdnbu
\.


--
-- Data for Name: poll_options; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.poll_options (option_id, poll_id, value, note) FROM stdin;
\.


--
-- Data for Name: poll_votes; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.poll_votes (poll_id, option_id, user_id, voted_at) FROM stdin;
\.


--
-- Data for Name: polls; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.polls (poll_id, event_id, type, question, is_open) FROM stdin;
\.


--
-- Data for Name: rsvps; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.rsvps (event_id, user_id, response, responded_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: sbhogad1
--

COPY public.users (user_id, name, email, password_hash) FROM stdin;
11	Sri	sbhogad1@asu.edu	123345
\.


--
-- Name: comments_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sbhogad1
--

SELECT pg_catalog.setval('public.comments_comment_id_seq', 12, true);


--
-- Name: events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sbhogad1
--

SELECT pg_catalog.setval('public.events_event_id_seq', 17, true);


--
-- Name: groups_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sbhogad1
--

SELECT pg_catalog.setval('public.groups_group_id_seq', 18, true);


--
-- Name: poll_options_option_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sbhogad1
--

SELECT pg_catalog.setval('public.poll_options_option_id_seq', 18, true);


--
-- Name: polls_poll_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sbhogad1
--

SELECT pg_catalog.setval('public.polls_poll_id_seq', 6, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sbhogad1
--

SELECT pg_catalog.setval('public.users_user_id_seq', 20, true);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (comment_id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (group_id, user_id);


--
-- Name: groups groups_name_key; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_name_key UNIQUE (name);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (group_id);


--
-- Name: poll_options poll_options_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.poll_options
    ADD CONSTRAINT poll_options_pkey PRIMARY KEY (option_id);


--
-- Name: poll_votes poll_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_pkey PRIMARY KEY (poll_id, user_id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (poll_id);


--
-- Name: rsvps rsvps_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.rsvps
    ADD CONSTRAINT rsvps_pkey PRIMARY KEY (event_id, user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: comments comments_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: events events_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(group_id) ON DELETE CASCADE;


--
-- Name: group_members group_members_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(group_id) ON DELETE CASCADE;


--
-- Name: group_members group_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: poll_options poll_options_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.poll_options
    ADD CONSTRAINT poll_options_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(poll_id) ON DELETE CASCADE;


--
-- Name: poll_votes poll_votes_option_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_option_id_fkey FOREIGN KEY (option_id) REFERENCES public.poll_options(option_id) ON DELETE CASCADE;


--
-- Name: poll_votes poll_votes_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(poll_id) ON DELETE CASCADE;


--
-- Name: poll_votes poll_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: polls polls_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id) ON DELETE CASCADE;


--
-- Name: rsvps rsvps_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.rsvps
    ADD CONSTRAINT rsvps_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(event_id) ON DELETE CASCADE;


--
-- Name: rsvps rsvps_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sbhogad1
--

ALTER TABLE ONLY public.rsvps
    ADD CONSTRAINT rsvps_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- postgreQL database dump complete
--

\unrestrict OECf8GWTBGsTyxc7tbqacBba4TONvklTf0tbfXfp15uGwwaebrLbxeU8ypxmp0C

