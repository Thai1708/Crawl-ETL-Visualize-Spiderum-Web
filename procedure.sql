-- PROCEDURE: public.dim_chu_de()

-- DROP PROCEDURE IF EXISTS public.dim_chu_de();

CREATE OR REPLACE PROCEDURE public.dim_chu_de(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	UPDATE stg_spiderum
		SET id_chu_de = 
			CASE 
				WHEN chu_de = 'QUAN ĐIỂM - TRANH LUẬN' THEN 1
				WHEN chu_de = 'KHOA HỌC - CÔNG NGHỆ' THEN 2
				WHEN chu_de = 'GIÁO DỤC' THEN 3
				WHEN chu_de = 'TÀI CHÍNH' THEN 4
				ELSE 5
			END;
END;
$BODY$;
ALTER PROCEDURE public.dim_chu_de()
    OWNER TO postgres;

-- PROCEDURE: public.dim_tac_gia()

-- DROP PROCEDURE IF EXISTS public.dim_tac_gia();

CREATE OR REPLACE PROCEDURE public.dim_tac_gia(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	TRUNCATE TABLE dim_tac_gia RESTART IDENTITY CASCADE;
	
	INSERT INTO dim_tac_gia (link_tac_gia, ten_tac_gia)
	SELECT DISTINCT link_tac_gia, ten_tac_gia
	FROM stg_spiderum;

	UPDATE stg_spiderum
	SET id_ten_tac_gia = dim_tac_gia.id
	FROM dim_tac_gia
	WHERE stg_spiderum.link_tac_gia = dim_tac_gia.link_tac_gia;
END;
$BODY$;
ALTER PROCEDURE public.dim_tac_gia()
    OWNER TO postgres;

-- PROCEDURE: public.dim_thoi_gian_dang()

-- DROP PROCEDURE IF EXISTS public.dim_thoi_gian_dang();

CREATE OR REPLACE PROCEDURE public.dim_thoi_gian_dang(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	UPDATE stg_spiderum
	SET id_thoi_gian_dang = CAST(TO_CHAR(CURRENT_DATE - INTERVAL '1 day', 'YYYYMMDD') AS INTEGER)
	WHERE thoi_gian_dang = 'Hôm qua';
	
	UPDATE stg_spiderum
	SET id_thoi_gian_dang = CAST(TO_CHAR(CURRENT_DATE, 'YYYYMMDD') AS INTEGER)
	WHERE thoi_gian_dang like 'phút trước' or thoi_gian_dang like 'giờ trước';
	
	WITH updated_data AS (
		SELECT 
			thoi_gian_dang,
			CAST(TO_CHAR(
				MAKE_DATE(
					EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
					CAST((regexp_matches(thoi_gian_dang, 'tháng\s+([0-9]+)'))[1] AS INTEGER),
					CAST((regexp_matches(thoi_gian_dang, '^([0-9]+)'))[1] AS INTEGER)
				),
				'YYYYMMDD'
			) AS INTEGER) AS ngay_thang_nam
		FROM 
			stg_spiderum
		WHERE 
			thoi_gian_dang ~ 'tháng [0-9]$' OR thoi_gian_dang ~ 'tháng [0-9]{2}$'
	)
	UPDATE stg_spiderum AS s
	SET id_thoi_gian_dang = u.ngay_thang_nam
	FROM updated_data AS u
	WHERE s.thoi_gian_dang = u.thoi_gian_dang;
	
	WITH updated_data AS (
		SELECT 
			thoi_gian_dang,
			CAST(TO_CHAR(
				MAKE_DATE(
					CAST((regexp_matches(thoi_gian_dang, '(.[0-9]{4})$'))[1] AS INTEGER),
					CAST((regexp_matches(thoi_gian_dang, 'tháng\s+([0-9]+)'))[1] AS INTEGER),
					CAST((regexp_matches(thoi_gian_dang, '^([0-9]+)'))[1] AS INTEGER)
				),
				'YYYYMMDD'
			) AS INTEGER) AS ngay_thang_nam
		FROM 
			stg_spiderum
		WHERE 
			thoi_gian_dang ~ '(.[0-9]{4})$'
	)
	UPDATE stg_spiderum AS s
	SET id_thoi_gian_dang = u.ngay_thang_nam
	FROM updated_data AS u
	WHERE s.thoi_gian_dang = u.thoi_gian_dang;
END;
$BODY$;
ALTER PROCEDURE public.dim_thoi_gian_dang()
    OWNER TO postgres;

-- PROCEDURE: public.dim_thoi_luong_doc()

-- DROP PROCEDURE IF EXISTS public.dim_thoi_luong_doc();

CREATE OR REPLACE PROCEDURE public.dim_thoi_luong_doc(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Cập nhật thoi_luong_doc_etl
    UPDATE stg_spiderum
    SET thoi_luong_doc_etl = CAST(regexp_replace(thoi_luong_doc, '[^0-9]', '', 'g') AS INTEGER)
    WHERE thoi_luong_doc LIKE '%phút đọc%';

    -- Cập nhật id_thoi_luong_doc
    UPDATE stg_spiderum
    SET id_thoi_luong_doc = 
        CASE 
            WHEN thoi_luong_doc_etl < 5 THEN 1
            WHEN thoi_luong_doc_etl >= 5 AND thoi_luong_doc_etl < 10 THEN 2
            WHEN thoi_luong_doc_etl >= 10 AND thoi_luong_doc_etl < 15 THEN 3
            ELSE 4
        END;
END;
$BODY$;
ALTER PROCEDURE public.dim_thoi_luong_doc()
    OWNER TO postgres;


-- PROCEDURE: public.dim_tuongtac()

-- DROP PROCEDURE IF EXISTS public.dim_tuongtac();

CREATE OR REPLACE PROCEDURE public.dim_tuongtac(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
-- 	TRANSFORM VIEW-------------------------------------------
	WITH updated_views AS (
		SELECT 
			id,  -- thay thế id bằng cột chứa khóa chính của bảng stg_spiderum
			CAST(CAST(regexp_replace(view, '[^0-9.]', '', 'g') AS NUMERIC) * 1000 AS INTEGER) AS view_etl
		FROM stg_spiderum
		WHERE view ~ '.k'
	)
	UPDATE stg_spiderum AS s
	SET view_etl = u.view_etl
	FROM updated_views AS u
	WHERE s.id = u.id;

	UPDATE stg_spiderum 
	SET view_etl = CAST(view as integer)
	WHERE view ~ '^[0-9.]+$';
	
	UPDATE stg_spiderum
    SET id_muc_view = 
        CASE 
            WHEN view_etl = 0 THEN 0
            WHEN view_etl > 0 AND view_etl <= 1000 THEN 2
            WHEN view_etl > 1000 AND view_etl <= 4000 THEN 3
            ELSE 4
		END;
-- 	TRANSFORM VOTE-------------------------------------------
	WITH updated_votes AS (
		SELECT 
			id,  -- thay thế id bằng cột chứa khóa chính của bảng stg_spiderum
			CAST(CAST(regexp_replace(vote, '[^0-9.]', '', 'g') AS NUMERIC) * 1000 AS INTEGER) AS vote_etl
		FROM stg_spiderum
		WHERE vote ~ '.k'
	)
	UPDATE stg_spiderum AS s
	SET vote_etl = u.vote_etl
	FROM updated_votes AS u
	WHERE s.id = u.id;

	UPDATE stg_spiderum 
	SET vote_etl = CAST(vote as integer)
	WHERE vote ~ '^[0-9.]+$';
-- 	TRANSFORM COMMENT-------------------------------------------
	WITH updated_comments AS (
		SELECT 
			id,  -- thay thế id bằng cột chứa khóa chính của bảng stg_spiderum
			CAST(CAST(regexp_replace(comment, '[^0-9.]', '', 'g') AS NUMERIC) * 1000 AS INTEGER) AS comment_etl
		FROM stg_spiderum
		WHERE comment ~ '.k'
	)
	UPDATE stg_spiderum AS s
	SET comment_etl = u.comment_etl
	FROM updated_comments AS u
	WHERE s.id = u.id;

	UPDATE stg_spiderum 
	SET comment_etl = CAST(comment as integer)
	WHERE comment ~ '^[0-9.]+$';
	
-- 	TRANSFORM TUONGTAC_ETL-------------------------------------------	
	UPDATE stg_spiderum 
	SET tuongtac_etl = 
		CASE 
			WHEN COALESCE(view_etl, 0) > 0 THEN ROUND(((ABS(COALESCE(vote_etl, 0)) + COALESCE(comment_etl, 0))::numeric / COALESCE(view_etl, 0)) * 100, 2)
			ELSE 0
		END;
END;
$BODY$;
ALTER PROCEDURE public.dim_tuongtac()
    OWNER TO postgres;

-- PROCEDURE: public.dim_ty_le_tuongtac()

-- DROP PROCEDURE IF EXISTS public.dim_ty_le_tuongtac();

CREATE OR REPLACE PROCEDURE public.dim_ty_le_tuongtac(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	UPDATE stg_spiderum
		SET id_ty_le_tuong_tac = 
			CASE 
				WHEN tuongtac_etl = 0 THEN 1
				WHEN tuongtac_etl > 0 and tuongtac_etl < 1 THEN 2
				WHEN tuongtac_etl >=1 and tuongtac_etl < 3 THEN 3
				ELSE 4
			END;
END;
$BODY$;
ALTER PROCEDURE public.dim_ty_le_tuongtac()
    OWNER TO postgres;

-- PROCEDURE: public.remove_duplicate()

-- DROP PROCEDURE IF EXISTS public.remove_duplicate();

CREATE OR REPLACE PROCEDURE public.remove_duplicate(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
delete from stg_spiderum 
where ctid not in (
	select min(ctid) 
	from stg_spiderum
	group by link_bai_viet
);
END;
$BODY$;
ALTER PROCEDURE public.remove_duplicate()
    OWNER TO postgres;

-- PROCEDURE: public.stg_to_fact_all()

-- DROP PROCEDURE IF EXISTS public.stg_to_fact_all();

CREATE OR REPLACE PROCEDURE public.stg_to_fact_all(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO fact_spiderum_post (id, id_thoi_luong_doc, id_thoi_gian_dang, id_ten_tac_gia, id_chu_de,
								   id_ty_le_tuong_tac, id_muc_view, ten_bai_viet, thoi_luong_doc_etl, vote,
									view, comment, tuongtac_etl
								   ) 
								   select id, id_thoi_luong_doc, id_thoi_gian_dang, id_ten_tac_gia, id_chu_de,
								   id_ty_le_tuong_tac, id_muc_view, ten_bai_viet, thoi_luong_doc_etl, vote_etl,
									view_etl, comment_etl, tuongtac_etl 
								   from stg_spiderum;
								 
END;
$BODY$;
ALTER PROCEDURE public.stg_to_fact_all()
    OWNER TO postgres;

-- PROCEDURE: public.stg_to_fact_daily()

-- DROP PROCEDURE IF EXISTS public.stg_to_fact_daily();

CREATE OR REPLACE PROCEDURE public.stg_to_fact_daily(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	INSERT INTO fact_spiderum_post (id, id_thoi_luong_doc, id_thoi_gian_dang, id_ten_tac_gia, id_chu_de,
								   id_ty_le_tuong_tac, id_muc_view, ten_bai_viet, thoi_luong_doc_etl, vote,
									view, comment, tuongtac_etl
								   ) 
								   select id, id_thoi_luong_doc, id_thoi_gian_dang, id_ten_tac_gia, id_chu_de,
								   id_ty_le_tuong_tac, id_muc_view, ten_bai_viet, thoi_luong_doc_etl, vote_etl,
									view_etl, comment_etl, tuongtac_etl 
								   from stg_spiderum
								   where ngay_crawl = CURRENT_DATE;
END;
$BODY$;
ALTER PROCEDURE public.stg_to_fact_daily()
    OWNER TO postgres;

-- PROCEDURE: public.update_all()

-- DROP PROCEDURE IF EXISTS public.update_all();

CREATE OR REPLACE PROCEDURE public.update_all(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	call dim_chu_de();
	call dim_tac_gia();
	call dim_thoi_gian_dang();
	call dim_thoi_luong_doc();
	call dim_tuongtac();
	call dim_ty_le_tuongtac();
	call remove_duplicate();
	TRUNCATE TABLE fact_spiderum_post;
	call stg_to_fact_all();
END;
$BODY$;
ALTER PROCEDURE public.update_all()
    OWNER TO postgres;

-- PROCEDURE: public.update_daily()

-- DROP PROCEDURE IF EXISTS public.update_daily();

CREATE OR REPLACE PROCEDURE public.update_daily(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	call dim_chu_de();
	call dim_tac_gia();
	call dim_thoi_gian_dang();
	call dim_thoi_luong_doc();
	call dim_tuongtac();
	call dim_ty_le_tuongtac();
	call remove_duplicate();
	call stg_to_fact_daily();
END;
$BODY$;
ALTER PROCEDURE public.update_daily()
    OWNER TO postgres;
