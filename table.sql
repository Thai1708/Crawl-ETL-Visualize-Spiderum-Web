-- Table: public.stg_spiderum

-- DROP TABLE IF EXISTS public.stg_spiderum;

CREATE TABLE IF NOT EXISTS public.stg_spiderum
(
    id integer NOT NULL DEFAULT nextval('stg_spiderum__id_seq'::regclass),
    ten_bai_viet character varying(600) COLLATE pg_catalog."default",
    link_bai_viet character varying(1000) COLLATE pg_catalog."default",
    thoi_luong_doc character varying(20) COLLATE pg_catalog."default",
    thoi_gian_dang character varying(50) COLLATE pg_catalog."default",
    ten_tac_gia character varying(100) COLLATE pg_catalog."default",
    link_tac_gia character varying(1000) COLLATE pg_catalog."default",
    vote character varying(20) COLLATE pg_catalog."default",
    view character varying(20) COLLATE pg_catalog."default",
    comment character varying(20) COLLATE pg_catalog."default",
    chu_de character varying(100) COLLATE pg_catalog."default",
    id_thoi_luong_doc integer,
    id_thoi_gian_dang integer,
    id_ten_tac_gia integer,
    id_chu_de integer,
    thoi_luong_doc_etl integer,
    vote_etl integer,
    view_etl integer,
    comment_etl integer,
    id_muc_view integer,
    id_ty_le_tuong_tac integer,
    tuongtac_etl numeric,
    ngay_crawl date,
    CONSTRAINT stg_spiderum__pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.stg_spiderum
    OWNER to postgres;


-- Table: public.fact_spiderum_post

-- DROP TABLE IF EXISTS public.fact_spiderum_post;

CREATE TABLE IF NOT EXISTS public.fact_spiderum_post
(
    id integer NOT NULL,
    id_thoi_luong_doc integer,
    id_thoi_gian_dang integer,
    id_ten_tac_gia integer,
    id_chu_de integer,
    id_ty_le_tuong_tac integer,
    id_muc_view integer,
    ten_bai_viet character varying(600) COLLATE pg_catalog."default",
    thoi_luong_doc_etl integer,
    vote integer,
    view integer,
    comment integer,
    tuongtac_etl numeric,
    CONSTRAINT fact_spiderum_post_pkey PRIMARY KEY (id),
    CONSTRAINT fk_id_chu_de FOREIGN KEY (id_chu_de)
        REFERENCES public.dim_chu_de (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_id_muc_view FOREIGN KEY (id_muc_view)
        REFERENCES public.dim_muc_view (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_id_ten_tac_gia FOREIGN KEY (id_ten_tac_gia)
        REFERENCES public.dim_tac_gia (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_id_thoi_gian_dang FOREIGN KEY (id_thoi_gian_dang)
        REFERENCES public.dim_thoi_gian_dang (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_id_thoi_luong_doc FOREIGN KEY (id_thoi_luong_doc)
        REFERENCES public.dim_thoi_luong_doc (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_id_ty_le_tuong_tac FOREIGN KEY (id_ty_le_tuong_tac)
        REFERENCES public.dim_ty_le_tuongtac (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.fact_spiderum_post
    OWNER to postgres;