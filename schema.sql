--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3 (Homebrew)
-- Dumped by pg_dump version 15.3 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: employees; Type: TABLE; Schema: public
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    full_name text NOT NULL,
    job text NOT NULL,
    organization_id integer NOT NULL
);

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: organizations; Type: TABLE; Schema: public
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name text NOT NULL
);

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: employees id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public
--

COPY public.employees (id, full_name, job, organization_id) FROM stdin;
4	John Doe	CEO	6
5	Jane Smith	COO	6
7	Shelby Bihotz	Software engineer	6
8	Chris Lee	Founder	12
9	Pete Hanson	Lead Teaching Assistant	12
10	Mark Zuckerberg	CEO	14
11	Andrew Bosworth	CTO	14
12	Susan Li	CFO	14
13	Javier Olivan	COO	14
14	Chris Cox	CPO	14
15	Jennifer Newstead	CLO	14
16	Lori Goler	Head of People	14
17	Dave Wehner	CSO	14
18	Maxin Williams	CDO	14
19	Bill Gates	Founder	4
20	Satya Nadella	CEO	4
21	Amy Hood	CFO	4
22	Judson Althoff	CCO	4
23	Sam Altman	CEO	9
24	Brad Lightcap	COO	9
25	Ilya Sutskever	Chief Scientist	9
26	Mira Murati	CTO	9
27	Franco Waisfeld	CEO	2
28	Zach Katz	CMO	2
29	Alin Ferenczi	Full Stack Developer	2
30	Elon Musk	Technoking	1
31	Zachary Kirkhorn	Master of Coin	1
32	Andrew Baglino	Senior Vice President	1
33	Tom Zhu	Senior Vice President	1
6	Bill Jenkins	Software engineer	6
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public
--

COPY public.organizations (id, name) FROM stdin;
1	Tesla
2	Reveler
4	Microsoft
5	Nvidia
9	OpenAI
14	Meta
6	Intuit
12	Launch School
\.


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('public.employees_id_seq', 34, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('public.organizations_id_seq', 23, true);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_name_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_name_key UNIQUE (name);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: employees employees_organization_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

