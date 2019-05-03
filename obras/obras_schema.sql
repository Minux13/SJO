CREATE TABLE contracts ( 
    id serial NOT NULL,
    number character varying NOT NULL,
    title character varying NOT NULL,
    description text,
    provider integer NOT NULL,
    delivery_status  integer NOT NULL,
    initial_contracted_amount double precision NOT NULL,
    kickoff date NOT NULL,
    ending date NOT NULL,
    down_payment date,
    down_payment_amount double precision,
    ext_agreement date,
    ext_agreement_amount double precision,
    final_contracted_amount double precision,
    total_amount_paid double precision,
    outstanding_down_payment double precision,
    blocked boolean DEFAULT false,
    inceptor_uuid character varying NOT NULL,
    inception_time timestamp with time zone NOT NULL,
    touch_latter_time timestamp with time zone NOT NULL
);

ALTER TABLE ONLY contracts
    ADD CONSTRAINT contract_pkey PRIMARY KEY (id);

ALTER TABLE ONLY contracts
    ADD CONSTRAINT contract_unique_title UNIQUE (title);

COMMENT ON TABLE  contracts IS 'Relacion que alberga los contratos';
COMMENT ON COLUMN contracts.title IS 'Nombre con el que se identifica a este contrato';
COMMENT ON COLUMN contracts.inceptor_uuid IS 'Usuario que origino este contrato';
COMMENT ON COLUMN contracts.inception_time IS 'Fecha en la que se registro este contrato';
COMMENT ON COLUMN contracts.touch_latter_time IS 'Apunta a la ultima fecha de alteracion de el registro';
COMMENT ON COLUMN contracts.kickoff IS 'Fecha para su inicio';
COMMENT ON COLUMN contracts.ending IS 'Fecha para su conclusion';


CREATE TABLE categories ( 
    id integer NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL
);

ALTER TABLE ONLY categories
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);

ALTER TABLE ONLY categories
    ADD CONSTRAINT category_unique_title UNIQUE (title);

COMMENT ON TABLE  categories IS 'Relacion que alberga los posibles valores para el attributo categoria de un proyecto';
COMMENT ON COLUMN categories.title IS 'Nombre con el que se identifica a esta categoria';


CREATE TABLE cities ( 
    id integer NOT NULL,
    title character varying NOT NULL
);

ALTER TABLE ONLY cities
    ADD CONSTRAINT city_pkey PRIMARY KEY (id);

ALTER TABLE ONLY cities
    ADD CONSTRAINT city_unique_title UNIQUE (title);

COMMENT ON TABLE  cities IS 'Relacion que alberga los posibles valores para el attributo ciudad de un proyecto';
COMMENT ON COLUMN cities.title IS 'Nombre con el que se identifica a esta ciudad';


CREATE TABLE projects (
    id serial NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    city integer NOT NULL,
    category integer NOT NULL,
    department integer NOT NULL,
    budget double precision NOT NULL,
    contract integer NOT NULL,
    planed_kickoff date NOT NULL,
    planed_ending date NOT NULL,
    blocked boolean DEFAULT false,
    inceptor_uuid character varying NOT NULL,
    inception_time timestamp with time zone NOT NULL,
    touch_latter_time timestamp with time zone NOT NULL
);

ALTER TABLE ONLY projects
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);

ALTER TABLE ONLY projects
    ADD CONSTRAINT project_unique_title UNIQUE (title);


COMMENT ON TABLE  projects IS 'Relacion que alberga proyectos';
COMMENT ON COLUMN projects.category IS 'Llave foranea a tabla de attributo categoria';
COMMENT ON COLUMN projects.contract IS 'Llave foranea a tabla de attributo contrato';
COMMENT ON COLUMN projects.department IS 'Llave foranea a table de attributo dependencia de gobierno';
COMMENT ON COLUMN projects.title IS 'Nombre con el que se identifica a este proyecto';
COMMENT ON COLUMN projects.planed_kickoff IS 'Fecha planeada para su inicio';
COMMENT ON COLUMN projects.planed_ending IS 'Fecha planeada para su conclusion';
COMMENT ON COLUMN projects.inceptor_uuid IS 'Usuario que origino este proyecto';
COMMENT ON COLUMN projects.inception_time IS 'Fecha en la que se registro este proyecto';
COMMENT ON COLUMN projects.touch_latter_time IS 'Apunta a la ultima fecha de alteracion de el registro';
COMMENT ON COLUMN projects.blocked IS 'Implementacion de feature borrado logico';


CREATE FUNCTION project_edit(
    _project_id integer,
    _title character varying,
    _description text,
    _city integer,
    _category integer,
    _department integer,
    _contract integer,
    _budget double precision,
    _planed_kickoff date,
    _planed_ending date
) RETURNS record LANGUAGE plpgsql AS $$

DECLARE

    current_moment timestamp with time zone = now();
    coincidences integer := 0;
    latter_id integer := 0;

    -- dump of errors
    rmsg text;

BEGIN

    CASE

        WHEN _project_id = 0 THEN

            -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            -- STARTS - Validates clave unica
            --
            -- JUSTIFICATION: Clave unica is created by another division
            -- We should only abide with the format
            -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

            -- pending implementation

            -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            -- ENDS   - Validates clave_unica
            -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

            INSERT INTO projects (
                title,
                description,
                city,
                category,
                department,
                budget,
                contract,
                planed_kickoff,
                planed_ending,
                inceptor_uuid,
                inception_time,
                touch_latter_time
            ) VALUES (
                _title,
                _description,
                _city,
                _category,
                _department,
                _budget,
                _contract,
                _planed_kickoff,
                _planed_ending,
                _inceptor_uuid,
                current_moment,
                current_moment
            ) RETURNING id INTO latter_id;

        WHEN _project_id > 0 THEN

            -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            -- STARTS - Validates obra id
            --
            -- JUSTIFICATION: Because UPDATE statement does not issue
            -- any exception if nothing was updated.
            -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            SELECT count(id)
            FROM projects INTO coincidences
            WHERE not blocked AND id = _project_id;

            IF not coincidences = 1 THEN
                RAISE EXCEPTION 'obra identifier % does not exist', _obra_id;
            END IF;
            -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
            -- ENDS - Validate obra id
            -- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

            UPDATE projects
            SET title = _title, description = _description,
                planed_kickoff = _planed_kickoff,
	        planed_ending = _planed_ending,
                city = _city, category = _category,
                budget = _budget, contract = _contract,
                department = _department,
		touch_latter_time = current_moment
            WHERE id = _project_id;

            -- Upon edition we return obra id as latter id
            latter_id = _project_id;

        ELSE
            RAISE EXCEPTION 'negative obra identifier % is unsupported', _obra_id;

    END CASE;

    return ( latter_id::integer, ''::text );

    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS rmsg = MESSAGE_TEXT;
            return ( -1::integer, rmsg::text );

    RETURN rv;

END;
$$;
