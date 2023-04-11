SET check_function_bodies = false;
CREATE SCHEMA teste;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
CREATE FUNCTION public.ativo_circulante_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	ativo_circulante int;
	BEGIN
		SELECT 
            SUM(vfd.value)
        FROM 
            valuations_financial_data vfd
        JOIN valuations_financial_data_type vfdtype
        	ON vfdtype.id = vfd.financial_data_type
        WHERE
            vfdtype.accounts_type = 'ativocirculante'
            AND 
            vfd.valuation = identificador 
       INTO ativo_circulante;      
       return ativo_circulante;
	END;
	$$;
CREATE FUNCTION public.ativo_nao_circulante_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	ativo_nao_circulante int;
	BEGIN
		SELECT 
            SUM(vfd.value)
        FROM 
            valuations_financial_data vfd
        JOIN valuations_financial_data_type vfdtype
        	ON vfdtype.id = vfd.financial_data_type
        WHERE
            vfdtype.accounts_type = 'ativonaocirculante'
            AND 
            vfd.valuation = identificador 
       INTO ativo_nao_circulante;      
       return ativo_nao_circulante;
	END;
	$$;
CREATE FUNCTION public.check_box_ativo_circulante(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
	SELECT
		COUNT(vfd.value)::decimal/3
	FROM valuations_financial_data vfd
	LEFT JOIN valuations_financial_data_type vfdt 
		ON vfd.financial_data_type = vfdt.id
	WHERE vfd.valuation = var_valuation_id 
	AND vfdt.accounts_type = 'ativocirculante'
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_ativo_nao_circulante(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
	SELECT
		COUNT(vfd.value)::decimal/4
	FROM valuations_financial_data vfd
	LEFT JOIN valuations_financial_data_type vfdt 
		ON vfd.financial_data_type = vfdt.id
	WHERE vfd.valuation = var_valuation_id 
	AND vfdt.accounts_type = 'ativonaocirculante'
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_cdn(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT
	COUNT(has_type)::decimal/3
	FROM valuations_cnd vc  
	WHERE vc.valuation = var_valuation_id
	AND has_type IS NOT NULL
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_custo(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
	SELECT
		COUNT(vfd.value)::decimal/1
	FROM valuations_financial_data vfd
	LEFT JOIN valuations_financial_data_type vfdt 
		ON vfd.financial_data_type = vfdt.id
	WHERE vfd.valuation = var_valuation_id 
	AND vfdt.accounts_type = 'custo'
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_dados_empresa(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
   SELECT
	(0 + CASE WHEN vci.company_name IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vci.fancy_name IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vci.phone IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vci.email IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vci.capital IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vci.creation_date IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vci.legal_nature IS NULL THEN 0 ELSE 1 END)::decimal / 7 
FROM valuations_cnpj_information vci 
	WHERE vci.valuation = var_valuation_id
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_deducoes(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
	SELECT
		COUNT(vfd.value)::decimal/2
	FROM valuations_financial_data vfd
	LEFT JOIN valuations_financial_data_type vfdt 
		ON vfd.financial_data_type = vfdt.id
	WHERE vfd.valuation = var_valuation_id 
	AND vfdt.accounts_type = 'deducoes'
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_descricao(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT COUNT("type")::decimal/4
	FROM valuations_description vd 
	WHERE vd.valuation = var_valuation_id
	AND text IS NOT NULL
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_despesa(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
	SELECT
		COUNT(vfd.value)::decimal/8
	FROM valuations_financial_data vfd
	LEFT JOIN valuations_financial_data_type vfdt 
		ON vfd.financial_data_type = vfdt.id
	WHERE vfd.valuation = var_valuation_id 
	AND vfdt.accounts_type = 'despesas'
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_diferenciais(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT COUNT(valuation)::decimal/5
	FROM valuations_and_differentials vad 
	WHERE vad.valuation = var_valuation_id
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_endereco(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
   SELECT
	(0 + CASE WHEN vca.public_place  IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vca."number" IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vca.district IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vca.city IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vca.country IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vca.zip_code IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vca.formatted_address IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vca."map" IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vca.state  IS NULL THEN 0 ELSE 1 END)::decimal / 9
FROM valuations_cnpj_address vca 
	WHERE vca.valuation = var_valuation_id
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_expectativa(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT
	(0 + CASE WHEN expectation IS NULL THEN 0 ELSE 1 END)
	FROM valuations_consultant_expectations vce
	WHERE vce.valuation = var_valuation_id
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_imagens(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT COUNT(valuation)::decimal/5
	FROM valuations_photos vp  
	WHERE vp.valuation = var_valuation_id
	AND url IS NOT NULL
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_informacoes(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT
	CASE WHEN vi.reason IS NULL THEN 0 ELSE 1 END
	FROM valuations_information vi 
	WHERE vi.valuation = var_valuation_id
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_marca_registrada(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT
	CASE WHEN vi.has IS NULL THEN 0 ELSE 1 END
	FROM valuations_inpi vi 
	WHERE vi.valuation = var_valuation_id
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_mercado(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
   SELECT
	(CASE WHEN vam.main_market IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vam.specific_market IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vam.sector IS NULL THEN 0 ELSE 1 END +
	CASE WHEN vam."type" IS NULL THEN 0 ELSE 1 END)::decimal / 4
FROM valuations_and_market vam 
WHERE vam.valuation = var_valuation_id
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_passivo_circulante(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
	SELECT
		COUNT(vfd.value)::decimal/5
	FROM valuations_financial_data vfd
	LEFT JOIN valuations_financial_data_type vfdt 
		ON vfd.financial_data_type = vfdt.id
	WHERE vfd.valuation = var_valuation_id 
	AND vfdt.accounts_type = 'passivocirculante'
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_presenca_digital(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT COUNT(valuation)::decimal/3
	FROM valuations_digital_presence vdp 
	WHERE vdp.valuation = var_valuation_id
	AND description IS NOT NULL
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_receita(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
	SELECT
		COUNT(vfd.value)::decimal/1
	FROM valuations_financial_data vfd
	LEFT JOIN valuations_financial_data_type vfdt 
		ON vfd.financial_data_type = vfdt.id
	WHERE vfd.valuation = var_valuation_id 
	AND vfdt.accounts_type = 'receita'
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.check_box_tributacao(var_valuation_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
 DECLARE
	output decimal;
 BEGIN
    SELECT COUNT(valuation)::decimal/1
	FROM valuations_cnpj_simples_nacional vcsn  
	WHERE vcsn.valuation = var_valuation_id AND
	simples_optant IS NOT NULL
	INTO output;
	return output;
 END;
 $$;
CREATE FUNCTION public.custo_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	custo int;
	BEGIN
		SELECT 
        	SUM(vfd.value) * 12
        FROM 
            valuations_financial_data vfd
        JOIN valuations_financial_data_type vfdtype
        	ON vfdtype.id = vfd.financial_data_type
        WHERE
            vfdtype.accounts_type = 'custo'
            AND 
            vfd.valuation = identificador 
       INTO custo;      
       return custo;
	END;
	$$;
CREATE FUNCTION public.deducoes_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	deducoes int;
	BEGIN
		SELECT 
        	SUM(vfd.value) * 12
        FROM 
            valuations_financial_data vfd
        JOIN valuations_financial_data_type vfdtype
        	ON vfdtype.id = vfd.financial_data_type
        WHERE
            vfdtype.accounts_type = 'deducoes'
            AND 
            vfd.valuation = identificador 
       INTO deducoes;      
       return deducoes;
	END;
	$$;
CREATE FUNCTION public.despesa_por_id() RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	despesa int;
	BEGIN
		SELECT 
            SUM(somar_account_type_no_valuations_financial_type(identificador, 'despesas')) * 12
		INTO despesa;      
       return despesa;
	END;
	$$;
CREATE FUNCTION public.despesa_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	despesa int;
	BEGIN
		SELECT 
            SUM(somar_account_type_no_valuations_financial_type(identificador, 'despesas')) * 12
		INTO despesa;      
       return despesa;
	END;
	$$;
CREATE FUNCTION public.fornecedores_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	fornecedores int;
	BEGIN
		SELECT 
        	SUM(vfd.value)
        FROM 
            valuations_financial_data vfd
        JOIN valuations_financial_data_type vfdtype
        	ON vfdtype.id = vfd.financial_data_type
        WHERE
            vfdtype."name"  = 'fornecedores'
            AND 
            vfd.valuation = identificador 
       INTO fornecedores;      
       return fornecedores;
	END;
	$$;
CREATE FUNCTION public.lucro_bruto_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	lucro_liquido int;
	BEGIN
		SELECT 
        	pegar_receita_por_id(identificador) - custo_por_id(identificador) - deducoes_por_id(identificador)
       INTO lucro_liquido;      
       return lucro_liquido;
	END;
	$$;
CREATE FUNCTION public.lucro_liquido_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	lucro_liquido int;
	BEGIN
		SELECT 
            pegar_receita_por_id(identificador) - custo_por_id(identificador) -
            deducoes_por_id(identificador) - despesa_por_id(identificador)
       INTO lucro_liquido;      
       return lucro_liquido;
	END;
	$$;
CREATE FUNCTION public.passivo_circulante_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	passivo_circulante int;
	BEGIN
		SELECT 
            SUM(vfd.value)
        FROM 
            valuations_financial_data vfd
        JOIN valuations_financial_data_type vfdtype
        	ON vfdtype.id = vfd.financial_data_type
        WHERE
            vfdtype.accounts_type = 'passivocirculante'
            AND 
            vfd.valuation = identificador 
       INTO passivo_circulante;      
       return passivo_circulante;
	END;
	$$;
CREATE FUNCTION public.pegar_caixa_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	caixa int;
	BEGIN
		SELECT 
            vfd.value
        FROM 
            valuations_financial_data vfd
        WHERE
            vfd.financial_data_type IN ('274de548-7103-4db2-adb4-075595547a96',
                						'667fbcf4-31cd-43cd-9176-cb346437f4d6',
                						'20dbf518-6528-44f4-ab40-6d938d0f5f34')
            AND 
            vfd.valuation = identificador 
        LIMIT 1 INTO caixa;      
       return caixa;
	END;
	$$;
CREATE FUNCTION public.pegar_estoque_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	estoque int;
	BEGIN
		SELECT 
            vfd.value
        FROM 
            valuations_financial_data vfd
        WHERE
            vfd.financial_data_type IN ('a185d47c-cb03-4c31-bfa2-42950a2e8da3',
										'dbe70148-2428-483c-8edb-6960090e3499',
										'bef7b056-df65-44b9-82c1-55c6fb7a5183')
            AND 
            vfd.valuation = identificador 
        LIMIT 1 INTO estoque;      
       return estoque;
	END;
	$$;
CREATE FUNCTION public.pegar_id_da_cidade_e_sigla(city text, sigla text) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
	DECLARE
	city_id UUID;
	BEGIN
		SELECT c.id
		from cities c 
		LEFT JOIN states s 
			ON s.id = c.state 
		WHERE c."name" = city AND s.initials = sigla
		INTO city_id;      
       return city_id;
	END;
	$$;
CREATE FUNCTION public.pegar_recebiveis_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	recebiveis int;
	BEGIN
		SELECT 
            vfd.value
        FROM 
            valuations_financial_data vfd
        WHERE
            vfd.financial_data_type IN ('a54f6bb6-024a-4a35-be07-bcc03ec0a445',
										'6ae8558a-38f5-4731-ba61-cfe855c2cd81',
										'1e9bea19-1721-4d27-afbd-a618c480e4db')
            AND 
            vfd.valuation = identificador 
        LIMIT 1 INTO recebiveis;      
       return recebiveis;
	END;
	$$;
CREATE FUNCTION public.pegar_receita_por_id(identificador uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	receita int;
	BEGIN
		SELECT 
            SUM(somar_account_type_no_valuations_financial_type(identificador, 'receita')) * 12
		INTO receita;      
       return receita;
	END;
	$$;
CREATE FUNCTION public.refresh_mat_view_valuations_information_for_datastudio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    refresh materialized view valuations_information_for_datastudio;
    return null;
end $$;
CREATE FUNCTION public.set_current_timestamp_created_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."created_at" = NOW();
  RETURN _new;
END;
$$;
CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE FUNCTION public.somar_account_type_no_valuations_financial_type(identificador uuid, account_type text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE
	deducoes int;
	BEGIN
		SELECT 
        	SUM(vfd.value)
        FROM 
            valuations_financial_data vfd
        JOIN valuations_financial_data_type vfdtype
        	ON vfdtype.id = vfd.financial_data_type
        WHERE
            vfdtype.accounts_type = account_type
            AND 
            vfd.valuation = identificador 
       INTO deducoes;      
       return deducoes;
	END;
	$$;
CREATE FUNCTION public.update_materialized_view_for_valuation_data_studio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
 refresh materialized view valuations_information_for_datastudio;
 return true;
end;
$$;
CREATE TABLE public.age_groups (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.anbima_tax_values (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tax jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    vertice integer NOT NULL
);
CREATE TABLE public.bacen_anual_marketplace_expectations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    indicator_type text NOT NULL,
    indicator_details text,
    date date NOT NULL,
    average double precision NOT NULL,
    median double precision NOT NULL,
    standard_deviation double precision NOT NULL,
    minimum double precision NOT NULL,
    maximum double precision NOT NULL,
    number_of_respondents integer NOT NULL,
    base_calculation double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    reference_date integer NOT NULL
);
CREATE TABLE public.bacen_indicator_types (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.balance_companies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    type text NOT NULL,
    sector uuid NOT NULL,
    sub_sector uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.balance_financial (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    date date NOT NULL,
    company_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.balance_financial_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    financial_data_type uuid NOT NULL,
    financial uuid NOT NULL,
    valor numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.balance_financial_data_type (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.branches (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    sector text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.calculator_company_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    lead uuid NOT NULL,
    age integer NOT NULL,
    cnpj text,
    share_capital integer,
    type uuid DEFAULT 'c6e9fad9-27ca-421f-a031-c1eee7bcc35c'::uuid NOT NULL,
    other_type text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    reason text NOT NULL,
    other_reason text,
    company_name text,
    employees integer,
    company_moment text,
    trademark boolean DEFAULT false
);
CREATE TABLE public.calculator_final_value (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    lead uuid NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.calculator_lead (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    computer_id text NOT NULL,
    profile uuid NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    phone text NOT NULL,
    city uuid NOT NULL,
    source text,
    medium text,
    campaign text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.calculator_methods_calculated (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    lead uuid NOT NULL,
    type text NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.calculator_methods_calculated_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.calculator_profiles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    video text NOT NULL,
    text text NOT NULL,
    call_to_action text,
    url text,
    "time" integer NOT NULL
);
CREATE TABLE public.calculator_values (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    lead uuid NOT NULL,
    type text NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.calculator_values_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.calculator_whatsapp_checker (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    lead uuid NOT NULL,
    valid boolean,
    trying boolean NOT NULL,
    count_trying integer NOT NULL,
    sent_rd boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.cities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    state uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.client_portal_ad (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    id_link integer NOT NULL,
    profile_id uuid NOT NULL,
    company_id uuid NOT NULL,
    company_sector text NOT NULL,
    foundation_year integer NOT NULL,
    employee_number integer NOT NULL,
    is_seasonal boolean NOT NULL,
    seasonality_periods json,
    monthly_revenue double precision NOT NULL,
    monthly_net_profit double precision NOT NULL,
    selling_value double precision NOT NULL,
    selling_type text NOT NULL,
    localization text NOT NULL,
    ad_title text NOT NULL,
    ad_description text NOT NULL,
    ad_aproved boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    main_img text,
    other_imgs json,
    city uuid,
    company_type uuid DEFAULT 'c6e9fad9-27ca-421f-a031-c1eee7bcc35c'::uuid,
    permanent_link text NOT NULL
);
COMMENT ON TABLE public.client_portal_ad IS 'Tabela de anúncios gratuitos do Portal do Cliente.';
CREATE SEQUENCE public.client_portal_ad_free_id_link_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.client_portal_ad_free_id_link_seq OWNED BY public.client_portal_ad.id_link;
CREATE TABLE public.client_portal_ad_status (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    ad_id uuid NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    reason text,
    is_disabled boolean DEFAULT false,
    disabled_at timestamp without time zone DEFAULT now()
);
CREATE TABLE public.client_portal_companies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    fantasy_name text NOT NULL,
    cnpj text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    infos json DEFAULT json_build_object() NOT NULL
);
COMMENT ON TABLE public.client_portal_companies IS 'Tabela de empresas do Portal do Cliente.';
CREATE TABLE public.client_portal_fingerprints (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    computer_id_one text,
    computer_id_two text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    "user" uuid
);
COMMENT ON TABLE public.client_portal_fingerprints IS 'Stores IDs from computers to track clients "offline".';
CREATE TABLE public.client_portal_logs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    ad_id uuid NOT NULL,
    computer_id uuid NOT NULL,
    log_type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.client_portal_mail_send (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email text NOT NULL,
    subject text NOT NULL,
    message text NOT NULL,
    sent boolean DEFAULT false NOT NULL,
    sending boolean DEFAULT false NOT NULL,
    send_after timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.client_portal_phone_confirmation_process (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    client_portal_profile uuid NOT NULL,
    code text,
    expiration_date text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.client_portal_phone_confirmation_process IS 'Tabela para o processo de confimação de número para clientes do Marketplace.';
CREATE TABLE public.client_portal_profiles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    cpf text,
    phone text,
    phone_confirmed boolean DEFAULT false,
    interests json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    consulting_companies uuid DEFAULT '0d795a16-47b6-498e-9ba5-26339cf3e8fd'::uuid NOT NULL,
    profile_type uuid DEFAULT '5a4a23a6-563d-4a7a-b4dd-596cc9a575d1'::uuid NOT NULL,
    picture text
);
COMMENT ON TABLE public.client_portal_profiles IS 'Perfis de clientes do Portal do Cliente';
CREATE TABLE public.client_portal_sms_send (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    phone text NOT NULL,
    message text NOT NULL,
    sending boolean DEFAULT false NOT NULL,
    send_after timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    sent boolean DEFAULT false NOT NULL
);
CREATE TABLE public.client_portal_tokens (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    token text,
    expiration_date text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.client_portal_whatsapp_send (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    phone text NOT NULL,
    message text NOT NULL,
    sent boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    sending boolean DEFAULT false NOT NULL,
    send_after timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.client_portal_whatsapp_send IS 'Apenas uma tabela para enviar mensagens no whats';
CREATE TABLE public.company_federal_cnd (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cnpj text NOT NULL,
    name text,
    date timestamp with time zone NOT NULL,
    emitted_at timestamp with time zone NOT NULL,
    valid_until timestamp with time zone NOT NULL,
    body text NOT NULL,
    code text NOT NULL,
    pdf_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_valid boolean
);
CREATE TABLE public.company_information_by_valuation (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    employees integer NOT NULL,
    area numeric NOT NULL,
    market_time numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.company_state_cnd (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cnpj text NOT NULL,
    date timestamp with time zone NOT NULL,
    pdf_url text NOT NULL,
    validation_result_risk text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.company_tax_activity (
    activity_name text NOT NULL,
    activity_description text NOT NULL,
    tax_percentage double precision NOT NULL
);
CREATE TABLE public.company_tax_annex (
    annex_name text NOT NULL,
    annex_description text
);
CREATE TABLE public.company_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    branch uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.consultants (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    administrator boolean DEFAULT false NOT NULL,
    picture text,
    consulting_companies uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    disabled_at timestamp with time zone,
    available_valuations integer DEFAULT 0 NOT NULL,
    sign text,
    occupation text,
    document text,
    resume1 text,
    resume2 text,
    resume3 text
);
CREATE TABLE public.consultants_and_valuations (
    consultant uuid NOT NULL,
    valuation uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type text NOT NULL
);
CREATE TABLE public.consultants_and_valuations_type (
    value text NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.consulting_companies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    logo text,
    external_email text NOT NULL,
    available_valuations integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    disabled_at timestamp with time zone,
    description text,
    sida text DEFAULT 'https://sida.buyco.com.br'::text NOT NULL
);
CREATE TABLE public.consulting_company_clients (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    cpf text,
    phone1 text NOT NULL,
    phone2 text,
    email text NOT NULL,
    consulting_companies uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    disabled_at timestamp with time zone
);
CREATE TABLE public.damodaran_betas (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    beta double precision NOT NULL,
    d_e_ratio double precision NOT NULL,
    effective_tax_rate double precision NOT NULL,
    unlevered_beta double precision NOT NULL,
    cash_firm_value double precision NOT NULL,
    unlevered_beta_corrected_for_cash double precision NOT NULL,
    hi_lo_risk double precision NOT NULL,
    std_deviation_equity double precision NOT NULL,
    std_deviation_operating_income double precision NOT NULL,
    industry uuid NOT NULL,
    region uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    year integer NOT NULL
);
COMMENT ON TABLE public.damodaran_betas IS 'A coluna std_deviation_operating_income fala sobre o standard deviation nos últimos 10 anos!';
CREATE TABLE public.damodaran_historical_growth_rates (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    industry uuid NOT NULL,
    region uuid NOT NULL,
    cagr_net_income_last double precision NOT NULL,
    cagr_revenues_last double precision NOT NULL,
    exp_growth_revenues double precision NOT NULL,
    exp_growth_eps double precision NOT NULL,
    year integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
COMMENT ON TABLE public.damodaran_historical_growth_rates IS 'Ambos campos de CAGR se referem aos últimos 5 anos; Ambos campos de Growth se referem aos próximos 2 anos.';
CREATE TABLE public.damodaran_industries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.damodaran_margins (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    year integer NOT NULL,
    industry uuid NOT NULL,
    region uuid NOT NULL,
    gross_margin double precision NOT NULL,
    net_margin double precision NOT NULL,
    ebtida_sales double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.damodaran_multiple_ebitda (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    year integer NOT NULL,
    industry uuid NOT NULL,
    region uuid NOT NULL,
    "EV_EBITDAReD" double precision NOT NULL,
    "EV_EBITDA" double precision NOT NULL,
    "EV_EBIT" double precision NOT NULL,
    "EV_EBIT_1_t" double precision NOT NULL,
    "EV_EBITDAReD_all" double precision NOT NULL,
    "EV_EBITDA_all" double precision NOT NULL,
    "EV_EBIT_all" double precision NOT NULL,
    "EV_EBIT_1_t_all" double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.damodaran_multiple_sale (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    year integer NOT NULL,
    industry uuid NOT NULL,
    region uuid NOT NULL,
    price_sales double precision NOT NULL,
    net_margin double precision NOT NULL,
    ev_sales double precision NOT NULL,
    pre_tax_operating_margin double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.damodaran_number_firms (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    year integer NOT NULL,
    industry uuid NOT NULL,
    region uuid NOT NULL,
    number_firms integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.damodaran_regions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    description text
);
CREATE TABLE public.damodaran_total_betas (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    year integer NOT NULL,
    industry uuid NOT NULL,
    region uuid NOT NULL,
    avg_unlevered_beta double precision NOT NULL,
    avg_levered_beta double precision NOT NULL,
    avg_correlation_with_market double precision NOT NULL,
    total_unlevered_beta double precision NOT NULL,
    total_levered_beta double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.differentials (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    description text NOT NULL,
    sector text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.digital_valuation_clients (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    consulting_company uuid NOT NULL,
    name text NOT NULL,
    phone text,
    email text NOT NULL,
    quantity integer NOT NULL,
    code text,
    cpf text,
    origin text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    expiration_date text
);
CREATE TABLE public.digital_valuation_cnpj (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cnpj text NOT NULL,
    digital_valuation_information uuid NOT NULL,
    fancy_name text NOT NULL,
    company_name text NOT NULL,
    membership json NOT NULL,
    primary_activity text NOT NULL,
    address json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.digital_valuation_descriptions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    operation text,
    partners text,
    tax text,
    owner text,
    customer text,
    expansion text,
    strategy text,
    business_type text,
    other_business_description text,
    evaluation_reason text,
    valuation_information_id uuid NOT NULL,
    bought boolean,
    bussiness_setup_description text,
    bought_price double precision,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    management_and_monitoring text,
    expansion_phase text,
    strategic_plan text,
    cost_expense_structure text,
    governance jsonb,
    revenue_growth text,
    expense_expectation uuid,
    tax_regime text
);
CREATE TABLE public.digital_valuation_differentials (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    digital_valuation_information uuid NOT NULL,
    differentials uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.digital_valuation_expense_expectations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    description text,
    percentage numeric
);
COMMENT ON TABLE public.digital_valuation_expense_expectations IS 'Tabela referente à expectativa de custos e despesas do digital_valuation';
CREATE TABLE public.digital_valuation_final_value (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    digital_valuation_information uuid NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    revenue numeric NOT NULL,
    profit numeric NOT NULL
);
CREATE TABLE public.digital_valuation_financial_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    digital_valuation_information uuid NOT NULL,
    financial_data_type uuid NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.digital_valuation_information (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    version text NOT NULL,
    year integer NOT NULL,
    consulting_companies uuid NOT NULL,
    digital_valuation_client uuid NOT NULL,
    reason text,
    ecommerce boolean,
    area integer,
    market_time integer,
    creation_value integer,
    company_type uuid DEFAULT 'c6e9fad9-27ca-421f-a031-c1eee7bcc35c'::uuid,
    partners_working integer,
    collaborators_working integer,
    pdf_url text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_refunded boolean DEFAULT false NOT NULL
);
CREATE TABLE public.digital_valuation_log (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    digital_valuation_information uuid NOT NULL,
    log json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.digital_valuation_methods_calculated (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    digital_valuation_information uuid NOT NULL,
    type text NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.digital_valuation_methods_calculated_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.digital_valuation_rg_type (
    value text NOT NULL,
    description text
);
COMMENT ON TABLE public.digital_valuation_rg_type IS 'Tabela referente ao tipo de crescimento da receita do digital valuation';
CREATE TABLE public.digital_valuation_voucher (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation_client uuid,
    consulting_company uuid NOT NULL,
    voucher text NOT NULL,
    valid_until timestamp with time zone NOT NULL,
    used_when timestamp with time zone,
    postback text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.embi_risk_values (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sercode text NOT NULL,
    date timestamp with time zone NOT NULL,
    value integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.generic_pdf_generate (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type text NOT NULL,
    background_pdf text,
    front_rules jsonb NOT NULL,
    state text,
    front_pdf text,
    final_pdf text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    callback text
);
COMMENT ON TABLE public.generic_pdf_generate IS 'Tabela para geração de pdf.';
CREATE TABLE public.google_calendar_event (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email text NOT NULL,
    summary text NOT NULL,
    description text NOT NULL,
    attendees jsonb NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.google_calendar_oauth (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email text NOT NULL,
    token text NOT NULL,
    refresh_token text NOT NULL,
    token_uri text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    scope text NOT NULL,
    expiry_date timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.highlights (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    text text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.indexes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    date date NOT NULL,
    value numeric NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.indexes_type (
    value text NOT NULL,
    name text
);
CREATE TABLE public.indicators (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    year integer NOT NULL,
    type text NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.indicators_type (
    value text NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.ma_advertisements (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    title text NOT NULL,
    sale_type text NOT NULL,
    company_type text NOT NULL,
    address text NOT NULL,
    registered_brand boolean NOT NULL,
    text_conclusion text NOT NULL,
    text_first text NOT NULL,
    text_second text NOT NULL,
    text_third text NOT NULL,
    text_structure text NOT NULL,
    dre text,
    balance text,
    picture1 text NOT NULL,
    picture2 text NOT NULL,
    picture3 text NOT NULL,
    picture4 text NOT NULL,
    map text NOT NULL,
    market_name text NOT NULL,
    market_description text NOT NULL,
    consultant text NOT NULL,
    highlights json NOT NULL,
    differentials json NOT NULL,
    invest_m2 integer NOT NULL,
    invest_workers integer NOT NULL,
    invest_profit_margin double precision NOT NULL,
    invest_current_liquidity double precision NOT NULL,
    invest_monthly_roi double precision NOT NULL,
    invest_equilibrium_point integer NOT NULL,
    indicated_sale_price integer NOT NULL,
    negotiation_company_value integer NOT NULL,
    negotiation_receivables integer NOT NULL,
    negotiation_passives integer NOT NULL,
    negotiation_net_sale integer NOT NULL,
    negotiation_working_capital integer NOT NULL,
    negotiation_investment integer NOT NULL,
    digital_site text NOT NULL,
    digital_facebook text NOT NULL,
    digital_instagram text NOT NULL,
    average_revenue double precision DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.nefin_risk_values (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    risk_type text NOT NULL,
    date date NOT NULL,
    value double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_12_months_results (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    company uuid NOT NULL,
    date date NOT NULL,
    net_revenue numeric NOT NULL,
    ebit numeric NOT NULL,
    net_profit numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_3_months_results (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    company uuid NOT NULL,
    date date NOT NULL,
    net_revenue numeric NOT NULL,
    ebit numeric NOT NULL,
    net_profit numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_balance (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    company uuid NOT NULL,
    total_assests numeric NOT NULL,
    availability numeric NOT NULL,
    current_assets numeric NOT NULL,
    total_debt numeric NOT NULL,
    equity numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    date date NOT NULL
);
CREATE TABLE public.open_companies_earnings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    company uuid NOT NULL,
    date date NOT NULL,
    value numeric NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_earnings_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.open_companies_growth (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    company uuid NOT NULL,
    year integer NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_indicators (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    company uuid NOT NULL,
    type text NOT NULL,
    date date NOT NULL,
    value numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_indicators_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.open_companies_information (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    type text NOT NULL,
    sector uuid NOT NULL,
    subsector uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_log (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    ativo text NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.open_companies_sector (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_sub_sector (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    sector uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.open_companies_values (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    company uuid NOT NULL,
    date date NOT NULL,
    price numeric NOT NULL,
    max_price numeric NOT NULL,
    min_price numeric NOT NULL,
    total_shares numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.profile (
    value text NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.profile_test_information (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email text NOT NULL,
    executor_percent integer NOT NULL,
    communicator_percent integer NOT NULL,
    planner_percent integer NOT NULL,
    analyst_percent integer NOT NULL,
    all_answers json NOT NULL,
    name text NOT NULL,
    whatsapp text,
    investment_period text NOT NULL,
    investment_range text NOT NULL,
    interests json NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.profile_test_investment_periods (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    period text NOT NULL
);
CREATE TABLE public.profile_test_investment_ranges (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    range text NOT NULL
);
CREATE TABLE public.profiles_type (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type text NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.reasons_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.sector_analysis (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    title character varying,
    general_summary text,
    specific_summary text,
    quantity character varying,
    opportunity character varying,
    employees character varying,
    audience character varying,
    image text,
    type text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    comments text,
    deleted_at timestamp without time zone
);
CREATE TABLE public.sector_analysis_activities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    text character varying NOT NULL,
    image text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    sector_analysis uuid NOT NULL
);
CREATE TABLE public.sector_analysis_and_age_groups (
    sector_analysis uuid NOT NULL,
    age_groups uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.sector_analysis_and_target_audiences (
    sector_analysis uuid NOT NULL,
    target_audiences uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.sector_analysis_indicators (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sector_analysis uuid NOT NULL,
    year integer NOT NULL,
    value numeric NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.sector_analysis_indicators_type (
    value text NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.sector_analysis_type (
    value text NOT NULL,
    name text
);
CREATE TABLE public.sectors (
    value text NOT NULL,
    name text
);
CREATE TABLE public.selic (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    selic_value double precision NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.sida_clients_state (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    client_id uuid NOT NULL,
    is_overdue boolean NOT NULL,
    debt_paid double precision NOT NULL,
    total_debt double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    locked boolean DEFAULT false NOT NULL
);
COMMENT ON TABLE public.sida_clients_state IS 'Tabela sobre estado de inadimplência (usei "overdue" como tradução de "inadimplente")';
CREATE TABLE public.simples_nacional_aliquot (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    range integer NOT NULL,
    aliquot numeric NOT NULL,
    deduct numeric NOT NULL,
    attachment integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.simples_nacional_range (
    id integer NOT NULL,
    min numeric NOT NULL,
    max numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.simples_nacional_range IS 'Simples Faixa 2022';
CREATE TABLE public.states (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    initials text NOT NULL
);
CREATE TABLE public.suggestions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sector_analysis uuid NOT NULL,
    text text NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.target_audiences (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.taxation (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text NOT NULL,
    url text
);
CREATE TABLE public.taxation_type (
    value text NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    profile text
);
CREATE TABLE public.users_signup_process (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email text NOT NULL,
    code text,
    expiration_date text,
    signup_finalized boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    interests json NOT NULL,
    name text NOT NULL,
    phone text
);
CREATE TABLE public.valorizei_sent (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    from_name text NOT NULL,
    from_mail text NOT NULL,
    to_name text NOT NULL,
    to_mail text NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valorizei_types (
    value text NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.valuation_model_config (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    consulting_companies uuid NOT NULL,
    key text NOT NULL,
    value json NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.valuation_model_image (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    consulting_companies uuid NOT NULL,
    link text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuation_model_pages (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    consulting_companies uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    model text NOT NULL,
    type text NOT NULL,
    header boolean,
    footer boolean,
    content json
);
CREATE TABLE public.valuations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cnpj text NOT NULL,
    version text NOT NULL,
    year integer NOT NULL,
    consulting_companies uuid NOT NULL,
    consulting_company_client uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    removed_at timestamp with time zone
);
CREATE TABLE public.valuations_accountant_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_and_activities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    activity uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_and_differentials (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    differential uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_and_market (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    main_market uuid,
    specific_market uuid,
    sector text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    type uuid DEFAULT 'c6e9fad9-27ca-421f-a031-c1eee7bcc35c'::uuid,
    other_type text,
    damodaran_sector uuid,
    damodaran_region uuid
);
CREATE TABLE public.valuations_and_spotlight (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    spotlight text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_chat_consultant (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    is_client boolean NOT NULL,
    speaker_name text NOT NULL,
    text text,
    file text,
    read_at text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at text
);
CREATE TABLE public.valuations_cnd (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text NOT NULL,
    url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    has_type boolean
);
CREATE TABLE public.valuations_cnd_type (
    value text NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.valuations_cnpj_activities (
    code text NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_cnpj_activity_types (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_cnpj_address (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    public_place text,
    number text,
    district text,
    city text,
    country text,
    zip_code text,
    formatted_address text,
    map text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    state text,
    complement text
);
CREATE TABLE public.valuations_cnpj_and_activities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    activity text NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_cnpj_information (
    valuation uuid NOT NULL,
    company_name text,
    fancy_name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    creation_date date,
    phone text,
    email text,
    capital integer,
    legal_nature text
);
CREATE TABLE public.valuations_cnpj_information_legal_nature (
    code text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_cnpj_membership (
    valuation uuid NOT NULL,
    name text,
    tax_id text,
    role text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);
CREATE TABLE public.valuations_cnpj_membership_role (
    code text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_cnpj_simples_nacional (
    valuation uuid NOT NULL,
    last_update timestamp without time zone,
    simples_optant boolean,
    simples_included date,
    simples_excluded date,
    simei_optant boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_cnpj_status (
    valuation uuid NOT NULL,
    status text,
    status_date date,
    status_reason text,
    special_status text,
    special_status_date date,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.valuations_consultant_expectations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    expectation numeric,
    threat numeric,
    projection integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    justification text
);
CREATE TABLE public.valuations_data_colect (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    collecting boolean DEFAULT true NOT NULL,
    allow_manual boolean DEFAULT true NOT NULL,
    allow_files boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    plus boolean DEFAULT false NOT NULL,
    collecting_plus boolean DEFAULT false NOT NULL
);
CREATE TABLE public.valuations_data_colect_files (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_data_colect_files_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_description (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text NOT NULL,
    text text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    client_text text,
    url text
);
CREATE TABLE public.valuations_description_type (
    value text NOT NULL,
    text text NOT NULL
);
CREATE TABLE public.valuations_digital_presence (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    social_network text NOT NULL,
    description text,
    likes integer,
    rating numeric,
    votes integer,
    followers integer,
    engagement numeric,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    comments integer,
    social_network_title text
);
CREATE TABLE public.valuations_digital_presence_text (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type text NOT NULL,
    text text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_digital_presence_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_external_ids (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    external_id text NOT NULL,
    external_id_type text NOT NULL
);
CREATE TABLE public.valuations_external_ids_types (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_files (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_final_value (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    final_value double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.valuations_financial_accounts_type (
    value text NOT NULL,
    name text NOT NULL,
    descrition text
);
CREATE TABLE public.valuations_financial_data (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    financial_data_type uuid NOT NULL,
    value numeric,
    url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_financial_data_type (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    accounts_type text NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    sector text NOT NULL,
    hint text,
    explanation text,
    "order" integer,
    dev boolean DEFAULT false NOT NULL
);
CREATE TABLE public.valuations_financial_sheets (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    balance_sheet json,
    income_statement json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_finantial_spreadsheet (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_information (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    reason text,
    important_notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    employees integer,
    area integer,
    market_time integer,
    ecommerce boolean DEFAULT false,
    creation_value integer,
    trademark boolean
);
CREATE TABLE public.valuations_information_reason (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_inpi (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    has boolean,
    url text
);
CREATE TABLE public.valuations_market_risk (
    name text NOT NULL,
    description text NOT NULL,
    value numeric NOT NULL
);
CREATE TABLE public.valuations_methods (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    methods json,
    weights json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_methods_value (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    methods_value json NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.valuations_notes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    text text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    disabled_at timestamp with time zone
);
CREATE TABLE public.valuations_photos (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    photos_type text NOT NULL,
    url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_photos_type (
    value text NOT NULL,
    description text
);
CREATE TABLE public.valuations_plus_charts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    text text
);
CREATE TABLE public.valuations_plus_charts_type (
    name text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_plus_dynamic_analisys (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    text1 text NOT NULL,
    text2 text NOT NULL,
    result json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_plus_ebitda_analisys (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    text1 text NOT NULL,
    text2 text NOT NULL,
    result json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_plus_period (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text NOT NULL,
    current json NOT NULL,
    ajust json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_plus_period_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_plus_projection (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    data jsonb,
    sheet_id text,
    sheet_status text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.valuations_plus_projection IS 'Tabela de projeções do valuation_plus';
CREATE TABLE public.valuations_plus_results (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text NOT NULL,
    current json NOT NULL,
    ajust json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_plus_results_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE public.valuations_plus_risk_analisys (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    text1 text NOT NULL,
    text2 text NOT NULL,
    result json NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_progress (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    progress jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.valuations_status (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    avaliable_value_generation integer DEFAULT 3 NOT NULL,
    avaliable_pdf_generation integer DEFAULT 1 NOT NULL,
    avaliable_review integer DEFAULT 2 NOT NULL,
    status_value_generation text,
    status_pdf_generation text,
    pdf_link text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    valuation_done boolean DEFAULT false NOT NULL,
    in_catalog boolean DEFAULT false NOT NULL,
    finalized_at timestamp without time zone
);
CREATE TABLE public.valuations_taxation (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valuation uuid NOT NULL,
    type text,
    infos jsonb,
    projection jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.valuations_taxation IS 'infos: in this field has the extra informations about the taxation. || projection:  in this field has the projections if the valuation is plus.';
COMMENT ON COLUMN public.valuations_taxation.infos IS 'in this field has the extra informations about the taxation.';
COMMENT ON COLUMN public.valuations_taxation.projection IS 'in this field has the projections if the valuation is plus.';
CREATE TABLE public.valuations_taxation_type (
    value text NOT NULL,
    description text NOT NULL
);
CREATE TABLE teste."ABV" (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);
CREATE TABLE teste.nova_tabela (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE teste.teste (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE teste.teste_migration (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);
ALTER TABLE ONLY public.client_portal_ad ALTER COLUMN id_link SET DEFAULT nextval('public.client_portal_ad_free_id_link_seq'::regclass);
ALTER TABLE ONLY public.valuations_financial_accounts_type
    ADD CONSTRAINT accounts_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_cnpj_address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.age_groups
    ADD CONSTRAINT age_groups_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.anbima_tax_values
    ADD CONSTRAINT anbima_tax_values_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.bacen_anual_marketplace_expectations
    ADD CONSTRAINT bacen_anual_marketplace_expectations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.bacen_indicator_types
    ADD CONSTRAINT bacen_indicator_type_description_key UNIQUE (description);
ALTER TABLE ONLY public.bacen_indicator_types
    ADD CONSTRAINT bacen_indicator_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.balance_companies
    ADD CONSTRAINT balance_companies_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.balance_financial_data
    ADD CONSTRAINT balance_financial_data_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.balance_financial_data_type
    ADD CONSTRAINT balance_financial_data_type_name_key UNIQUE (name);
ALTER TABLE ONLY public.balance_financial_data_type
    ADD CONSTRAINT balance_financial_data_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.balance_financial
    ADD CONSTRAINT balance_financial_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.calculator_company_data
    ADD CONSTRAINT calculator_company_data_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.calculator_final_value
    ADD CONSTRAINT calculator_final_value_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.calculator_lead
    ADD CONSTRAINT calculator_lead_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.calculator_methods_calculated
    ADD CONSTRAINT calculator_methods_calculated_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.calculator_methods_calculated_type
    ADD CONSTRAINT calculator_methods_calculated_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.calculator_profiles
    ADD CONSTRAINT calculator_profiles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.calculator_values
    ADD CONSTRAINT calculator_values_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.calculator_values_type
    ADD CONSTRAINT calculator_values_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.calculator_whatsapp_checker
    ADD CONSTRAINT calculator_whatsapp_checker_lead_key UNIQUE (lead);
ALTER TABLE ONLY public.calculator_whatsapp_checker
    ADD CONSTRAINT calculator_whatsapp_checker_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_name_state_key UNIQUE (name, state);
ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_ad
    ADD CONSTRAINT client_portal_ad_free_company_id_key UNIQUE (company_id);
ALTER TABLE ONLY public.client_portal_ad
    ADD CONSTRAINT client_portal_ad_free_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_ad
    ADD CONSTRAINT client_portal_ad_permanent_link_key UNIQUE (permanent_link);
ALTER TABLE ONLY public.client_portal_ad_status
    ADD CONSTRAINT client_portal_ad_status_ad_id_key UNIQUE (ad_id);
ALTER TABLE ONLY public.client_portal_ad_status
    ADD CONSTRAINT client_portal_ad_status_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_companies
    ADD CONSTRAINT client_portal_companies_cnpj_key UNIQUE (cnpj);
ALTER TABLE ONLY public.client_portal_companies
    ADD CONSTRAINT client_portal_companies_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_fingerprints
    ADD CONSTRAINT client_portal_fingerprints_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_logs
    ADD CONSTRAINT client_portal_logs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_mail_send
    ADD CONSTRAINT client_portal_mail_send_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_phone_confirmation_process
    ADD CONSTRAINT client_portal_phone_confirmation_process_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_profiles
    ADD CONSTRAINT client_portal_profiles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_profiles
    ADD CONSTRAINT client_portal_profiles_user_id_key UNIQUE (user_id);
ALTER TABLE ONLY public.client_portal_sms_send
    ADD CONSTRAINT client_portal_sms_send_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_tokens
    ADD CONSTRAINT client_portal_tokens_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.client_portal_whatsapp_send
    ADD CONSTRAINT client_portal_whatsapp_send_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.company_federal_cnd
    ADD CONSTRAINT company_cnd_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.company_information_by_valuation
    ADD CONSTRAINT company_information_by_valuation_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.company_state_cnd
    ADD CONSTRAINT company_state_cnd_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.company_tax_activity
    ADD CONSTRAINT company_tax_activity_pkey PRIMARY KEY (activity_name);
ALTER TABLE ONLY public.company_tax_annex
    ADD CONSTRAINT company_tax_annex_pkey PRIMARY KEY (annex_name);
ALTER TABLE ONLY public.company_types
    ADD CONSTRAINT company_types_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_consultant_expectations
    ADD CONSTRAINT consultant_expectations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.consultants
    ADD CONSTRAINT consultant_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.consultants_and_valuations
    ADD CONSTRAINT consultants_and_valuations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.consultants_and_valuations_type
    ADD CONSTRAINT consultants_and_valuations_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.consultants_and_valuations
    ADD CONSTRAINT consultants_and_valuations_valuation_type_key UNIQUE (valuation, type);
ALTER TABLE ONLY public.consultants
    ADD CONSTRAINT consultants_email_key UNIQUE (email);
ALTER TABLE ONLY public.consulting_companies
    ADD CONSTRAINT consulting_companies_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.consulting_company_clients
    ADD CONSTRAINT consulting_company_client_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_betas
    ADD CONSTRAINT damodaran_betas_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_historical_growth_rates
    ADD CONSTRAINT damodaran_historical_growth_rates_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_industries
    ADD CONSTRAINT damodaran_industries_description_key UNIQUE (description);
ALTER TABLE ONLY public.damodaran_industries
    ADD CONSTRAINT damodaran_industries_name_key UNIQUE (name);
ALTER TABLE ONLY public.damodaran_industries
    ADD CONSTRAINT damodaran_industries_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_margins
    ADD CONSTRAINT damodaran_margins_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_multiple_ebitda
    ADD CONSTRAINT damodaran_multiple_ebitda_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_multiple_sale
    ADD CONSTRAINT damodaran_multiples_sales_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_number_firms
    ADD CONSTRAINT damodaran_number_firms_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_regions
    ADD CONSTRAINT damodaran_regions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.damodaran_total_betas
    ADD CONSTRAINT damodaran_total_betas_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.differentials
    ADD CONSTRAINT differentials_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_clients
    ADD CONSTRAINT digital_valuation_clients_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_cnpj
    ADD CONSTRAINT digital_valuation_cnpj_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_voucher
    ADD CONSTRAINT digital_valuation_cupom_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_descriptions
    ADD CONSTRAINT digital_valuation_descriptions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_differentials
    ADD CONSTRAINT digital_valuation_differentials_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_expense_expectations
    ADD CONSTRAINT digital_valuation_expense_expectations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_final_value
    ADD CONSTRAINT digital_valuation_final_value_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_financial_data
    ADD CONSTRAINT digital_valuation_financial_data_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_information
    ADD CONSTRAINT digital_valuation_information_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_log
    ADD CONSTRAINT digital_valuation_log_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_methods_calculated
    ADD CONSTRAINT digital_valuation_methods_calculated_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.digital_valuation_methods_calculated_type
    ADD CONSTRAINT digital_valuation_methods_calculated_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.digital_valuation_rg_type
    ADD CONSTRAINT digital_valuation_rg_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.embi_risk_values
    ADD CONSTRAINT embi_risk_values_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_financial_data
    ADD CONSTRAINT financial_data_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_financial_data_type
    ADD CONSTRAINT financial_data_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.generic_pdf_generate
    ADD CONSTRAINT generic_pdf_generate_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.google_calendar_event
    ADD CONSTRAINT google_calendar_event_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.google_calendar_oauth
    ADD CONSTRAINT google_calendar_oauth_email_key UNIQUE (email);
ALTER TABLE ONLY public.google_calendar_oauth
    ADD CONSTRAINT google_calendar_oauth_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.highlights
    ADD CONSTRAINT highlights_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.indexes
    ADD CONSTRAINT indexes_date_key UNIQUE (date);
ALTER TABLE ONLY public.indexes
    ADD CONSTRAINT indexes_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.indexes_type
    ADD CONSTRAINT indexes_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.indicators
    ADD CONSTRAINT indicators_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.indicators_type
    ADD CONSTRAINT indicators_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.indicators
    ADD CONSTRAINT indicators_year_type_key UNIQUE (year, type);
ALTER TABLE ONLY public.valuations_inpi
    ADD CONSTRAINT inpi_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.ma_advertisements
    ADD CONSTRAINT ma_advertisements_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.ma_advertisements
    ADD CONSTRAINT ma_advertisements_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.nefin_risk_values
    ADD CONSTRAINT nefin_risk_values_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_log
    ADD CONSTRAINT open_comapnies_log_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_12_months_results
    ADD CONSTRAINT open_companies_12_months_results_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_3_months_results
    ADD CONSTRAINT open_companies_3_months_results_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_balance
    ADD CONSTRAINT open_companies_balance_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_earnings
    ADD CONSTRAINT open_companies_earnings_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_earnings_type
    ADD CONSTRAINT open_companies_earnings_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.open_companies_growth
    ADD CONSTRAINT open_companies_growth_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_indicators
    ADD CONSTRAINT open_companies_indicators_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_indicators_type
    ADD CONSTRAINT open_companies_indicators_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.open_companies_information
    ADD CONSTRAINT open_companies_information_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_sector
    ADD CONSTRAINT open_companies_sector_name_key UNIQUE (name);
ALTER TABLE ONLY public.open_companies_sector
    ADD CONSTRAINT open_companies_sector_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_sub_sector
    ADD CONSTRAINT open_companies_sub_sector_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.open_companies_values
    ADD CONSTRAINT open_companies_values_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.profile_test_investment_periods
    ADD CONSTRAINT profile_test_investment_periods_period_key UNIQUE (period);
ALTER TABLE ONLY public.profile_test_investment_periods
    ADD CONSTRAINT profile_test_investment_periods_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profile_test_investment_ranges
    ADD CONSTRAINT profile_test_investment_ranges_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profile_test_investment_ranges
    ADD CONSTRAINT profile_test_investment_ranges_range_key UNIQUE (range);
ALTER TABLE ONLY public.profile_test_information
    ADD CONSTRAINT profiles_from_test_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profiles_type
    ADD CONSTRAINT profiles_type_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.reasons_type
    ADD CONSTRAINT reasons_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.sector_analysis_activities
    ADD CONSTRAINT sector_analysis_activities_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.sector_analysis_and_age_groups
    ADD CONSTRAINT sector_analysis_and_age_groups_pkey PRIMARY KEY (sector_analysis, age_groups);
ALTER TABLE ONLY public.sector_analysis_and_target_audiences
    ADD CONSTRAINT sector_analysis_and_target_audiences_pkey PRIMARY KEY (sector_analysis, target_audiences);
ALTER TABLE ONLY public.sector_analysis_indicators
    ADD CONSTRAINT sector_analysis_indicators_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.sector_analysis_indicators
    ADD CONSTRAINT sector_analysis_indicators_sector_analysis_year_type_key UNIQUE (sector_analysis, year, type);
ALTER TABLE ONLY public.sector_analysis_indicators_type
    ADD CONSTRAINT sector_analysis_indicators_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.sector_analysis
    ADD CONSTRAINT sector_analysis_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.sector_analysis_type
    ADD CONSTRAINT sector_analysis_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.sectors
    ADD CONSTRAINT sectors_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.selic
    ADD CONSTRAINT selic_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.sida_clients_state
    ADD CONSTRAINT sida_clients_state_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.simples_nacional_aliquot
    ADD CONSTRAINT simples_nacional_aliquot_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.simples_nacional_range
    ADD CONSTRAINT simples_nacional_range_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.target_audiences
    ADD CONSTRAINT target_audiences_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.taxation
    ADD CONSTRAINT taxation_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.taxation_type
    ADD CONSTRAINT taxation_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users_signup_process
    ADD CONSTRAINT users_signup_process_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valorizei_sent
    ADD CONSTRAINT valorizei_sent_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valorizei_types
    ADD CONSTRAINT valorizei_types_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuation_and_market_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_cnpj_activities
    ADD CONSTRAINT valuation_cnpj_activities_code_key UNIQUE (code);
ALTER TABLE ONLY public.valuations_cnpj_activities
    ADD CONSTRAINT valuation_cnpj_activities_pkey PRIMARY KEY (code);
ALTER TABLE ONLY public.valuations_cnpj_activity_types
    ADD CONSTRAINT valuation_cnpj_activity_types_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_cnpj_and_activities
    ADD CONSTRAINT valuation_cnpj_and_activities_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_cnpj_information_legal_nature
    ADD CONSTRAINT valuation_cnpj_information_legal_nature_pkey PRIMARY KEY (code);
ALTER TABLE ONLY public.valuations_cnpj_information
    ADD CONSTRAINT valuation_cnpj_information_pkey PRIMARY KEY (valuation);
ALTER TABLE ONLY public.valuations_cnpj_membership_role
    ADD CONSTRAINT valuation_cnpj_membership_role_code_key UNIQUE (code);
ALTER TABLE ONLY public.valuations_cnpj_membership_role
    ADD CONSTRAINT valuation_cnpj_membership_role_pkey PRIMARY KEY (code);
ALTER TABLE ONLY public.valuations_cnpj_simples_nacional
    ADD CONSTRAINT valuation_cnpj_simples_nacional_pkey PRIMARY KEY (valuation);
ALTER TABLE ONLY public.valuations_cnpj_status
    ADD CONSTRAINT valuation_cnpj_status_pkey PRIMARY KEY (valuation);
ALTER TABLE ONLY public.valuations_information
    ADD CONSTRAINT valuation_information_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuation_model_config
    ADD CONSTRAINT valuation_model_config_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuation_model_image
    ADD CONSTRAINT valuation_model_image_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuation_model_pages
    ADD CONSTRAINT valuation_model_pages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_accountant_data
    ADD CONSTRAINT valuations_accountant_data_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_and_activities
    ADD CONSTRAINT valuations_and_activities_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_and_differentials
    ADD CONSTRAINT valuations_and_differentials_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuations_and_market_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_and_spotlight
    ADD CONSTRAINT valuations_and_spotlight_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_chat_consultant
    ADD CONSTRAINT valuations_chat_consultant_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_cnd
    ADD CONSTRAINT valuations_cnd_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_cnd_type
    ADD CONSTRAINT valuations_cnd_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_cnd
    ADD CONSTRAINT valuations_cnd_valuation_type_key UNIQUE (valuation, type);
ALTER TABLE ONLY public.valuations_cnpj_membership
    ADD CONSTRAINT valuations_cnpj_membership_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations
    ADD CONSTRAINT valuations_cnpj_version_year_consulting_companies_key UNIQUE (cnpj, version, year, consulting_companies);
ALTER TABLE ONLY public.valuations_data_colect_files
    ADD CONSTRAINT valuations_data_colect_files_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_data_colect_files_type
    ADD CONSTRAINT valuations_data_colect_files_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_data_colect
    ADD CONSTRAINT valuations_data_colect_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_data_colect
    ADD CONSTRAINT valuations_data_colect_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_description
    ADD CONSTRAINT valuations_description_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_description_type
    ADD CONSTRAINT valuations_description_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_description
    ADD CONSTRAINT valuations_description_valuation_type_key UNIQUE (valuation, type);
ALTER TABLE ONLY public.valuations_digital_presence
    ADD CONSTRAINT valuations_digital_presence_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_digital_presence_text
    ADD CONSTRAINT valuations_digital_presence_text_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_digital_presence_type
    ADD CONSTRAINT valuations_digital_presence_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_digital_presence
    ADD CONSTRAINT valuations_digital_presence_valuation_social_network_key UNIQUE (valuation, social_network);
ALTER TABLE ONLY public.valuations_external_ids
    ADD CONSTRAINT valuations_external_ids_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_external_ids_types
    ADD CONSTRAINT valuations_external_ids_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_files
    ADD CONSTRAINT valuations_files_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_final_value
    ADD CONSTRAINT valuations_final_value_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_final_value
    ADD CONSTRAINT valuations_final_value_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_financial_data_type
    ADD CONSTRAINT valuations_financial_data_type_name_sector_key UNIQUE (name, sector);
ALTER TABLE ONLY public.valuations_financial_sheets
    ADD CONSTRAINT valuations_financial_sheets_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_finantial_spreadsheet
    ADD CONSTRAINT valuations_finantial_spreadsheet_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_finantial_spreadsheet
    ADD CONSTRAINT valuations_finantial_spreadsheet_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_information_reason
    ADD CONSTRAINT valuations_information_reason_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_market_risk
    ADD CONSTRAINT valuations_market_risk_pkey PRIMARY KEY (name);
ALTER TABLE ONLY public.valuations_methods
    ADD CONSTRAINT valuations_methods_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_methods
    ADD CONSTRAINT valuations_methods_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_methods_value
    ADD CONSTRAINT valuations_methods_value_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_methods_value
    ADD CONSTRAINT valuations_methods_value_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_notes
    ADD CONSTRAINT valuations_notes_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_photos
    ADD CONSTRAINT valuations_photos_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_photos_type
    ADD CONSTRAINT valuations_photos_type_name_key UNIQUE (value);
ALTER TABLE ONLY public.valuations_photos_type
    ADD CONSTRAINT valuations_photos_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations
    ADD CONSTRAINT valuations_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_plus_charts
    ADD CONSTRAINT valuations_plus_charts_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_plus_charts_type
    ADD CONSTRAINT valuations_plus_charts_type_pkey PRIMARY KEY (name);
ALTER TABLE ONLY public.valuations_plus_charts
    ADD CONSTRAINT valuations_plus_charts_valuation_type_key UNIQUE (valuation, type);
ALTER TABLE ONLY public.valuations_plus_dynamic_analisys
    ADD CONSTRAINT valuations_plus_dynamic_analisys_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_plus_ebitda_analisys
    ADD CONSTRAINT valuations_plus_ebitda_analisys_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_plus_ebitda_analisys
    ADD CONSTRAINT valuations_plus_ebitda_analisys_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_plus_period
    ADD CONSTRAINT valuations_plus_period_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_plus_period_type
    ADD CONSTRAINT valuations_plus_period_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_plus_period
    ADD CONSTRAINT valuations_plus_period_valuation_type_key UNIQUE (valuation, type);
ALTER TABLE ONLY public.valuations_plus_projection
    ADD CONSTRAINT valuations_plus_projection_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_plus_projection
    ADD CONSTRAINT valuations_plus_projection_sheet_url_key UNIQUE (sheet_id);
ALTER TABLE ONLY public.valuations_plus_projection
    ADD CONSTRAINT valuations_plus_projection_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_plus_results
    ADD CONSTRAINT valuations_plus_results_project_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_plus_results
    ADD CONSTRAINT valuations_plus_results_project_valuation_type_key UNIQUE (valuation, type);
ALTER TABLE ONLY public.valuations_plus_results_type
    ADD CONSTRAINT valuations_plus_results_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_plus_risk_analisys
    ADD CONSTRAINT valuations_plus_risk_analisys_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_progress
    ADD CONSTRAINT valuations_progress_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_progress
    ADD CONSTRAINT valuations_progress_valuations_key UNIQUE (valuation);
ALTER TABLE ONLY public.valuations_status
    ADD CONSTRAINT valuations_status_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_taxation
    ADD CONSTRAINT valuations_taxation_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.valuations_taxation_type
    ADD CONSTRAINT valuations_taxation_type_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public.valuations_taxation
    ADD CONSTRAINT valuations_taxation_valuation_key UNIQUE (valuation);
ALTER TABLE ONLY teste."ABV"
    ADD CONSTRAINT "ABV_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY teste.nova_tabela
    ADD CONSTRAINT nova_tabela_pkey PRIMARY KEY (id);
ALTER TABLE ONLY teste.teste_migration
    ADD CONSTRAINT teste_migration_pkey PRIMARY KEY (id);
ALTER TABLE ONLY teste.teste
    ADD CONSTRAINT teste_pkey PRIMARY KEY (id);
CREATE TRIGGER set_public_address_updated_at BEFORE UPDATE ON public.valuations_cnpj_address FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_address_updated_at ON public.valuations_cnpj_address IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_age_groups_updated_at BEFORE UPDATE ON public.age_groups FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_age_groups_updated_at ON public.age_groups IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_anbima_tax_values_updated_at BEFORE UPDATE ON public.anbima_tax_values FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_anbima_tax_values_updated_at ON public.anbima_tax_values IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_bacen_anual_marketplace_expectations_updated_at BEFORE UPDATE ON public.bacen_anual_marketplace_expectations FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_bacen_anual_marketplace_expectations_updated_at ON public.bacen_anual_marketplace_expectations IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_balance_companies_updated_at BEFORE UPDATE ON public.balance_companies FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_balance_companies_updated_at ON public.balance_companies IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_balance_financial_data_type_updated_at BEFORE UPDATE ON public.balance_financial_data_type FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_balance_financial_data_type_updated_at ON public.balance_financial_data_type IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_balance_financial_data_updated_at BEFORE UPDATE ON public.balance_financial_data FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_balance_financial_data_updated_at ON public.balance_financial_data IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_balance_financial_updated_at BEFORE UPDATE ON public.balance_financial FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_balance_financial_updated_at ON public.balance_financial IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_branches_updated_at BEFORE UPDATE ON public.branches FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_branches_updated_at ON public.branches IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_calculator_company_data_updated_at BEFORE UPDATE ON public.calculator_company_data FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_calculator_company_data_updated_at ON public.calculator_company_data IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_calculator_final_value_updated_at BEFORE UPDATE ON public.calculator_final_value FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_calculator_final_value_updated_at ON public.calculator_final_value IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_calculator_lead_updated_at BEFORE UPDATE ON public.calculator_lead FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_calculator_lead_updated_at ON public.calculator_lead IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_calculator_methods_calculated_updated_at BEFORE UPDATE ON public.calculator_methods_calculated FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_calculator_methods_calculated_updated_at ON public.calculator_methods_calculated IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_calculator_profiles_updated_at BEFORE UPDATE ON public.calculator_profiles FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_calculator_profiles_updated_at ON public.calculator_profiles IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_calculator_values_updated_at BEFORE UPDATE ON public.calculator_values FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_calculator_values_updated_at ON public.calculator_values IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_calculator_whatsapp_checker_updated_at BEFORE UPDATE ON public.calculator_whatsapp_checker FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_calculator_whatsapp_checker_updated_at ON public.calculator_whatsapp_checker IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_cities_updated_at BEFORE UPDATE ON public.cities FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_cities_updated_at ON public.cities IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_ad_free_updated_at BEFORE UPDATE ON public.client_portal_ad FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_ad_free_updated_at ON public.client_portal_ad IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_ad_status_updated_at BEFORE UPDATE ON public.client_portal_ad_status FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_ad_status_updated_at ON public.client_portal_ad_status IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_companies_updated_at BEFORE UPDATE ON public.client_portal_companies FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_companies_updated_at ON public.client_portal_companies IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_fingerprints_updated_at BEFORE UPDATE ON public.client_portal_fingerprints FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_fingerprints_updated_at ON public.client_portal_fingerprints IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_logs_updated_at BEFORE UPDATE ON public.client_portal_logs FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_logs_updated_at ON public.client_portal_logs IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_mail_send_updated_at BEFORE UPDATE ON public.client_portal_mail_send FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_mail_send_updated_at ON public.client_portal_mail_send IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_phone_confirmation_process_updated_at BEFORE UPDATE ON public.client_portal_phone_confirmation_process FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_phone_confirmation_process_updated_at ON public.client_portal_phone_confirmation_process IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_profiles_updated_at BEFORE UPDATE ON public.client_portal_profiles FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_profiles_updated_at ON public.client_portal_profiles IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_sms_send_updated_at BEFORE UPDATE ON public.client_portal_sms_send FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_sms_send_updated_at ON public.client_portal_sms_send IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_tokens_updated_at BEFORE UPDATE ON public.client_portal_tokens FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_tokens_updated_at ON public.client_portal_tokens IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_client_portal_whatsapp_send_updated_at BEFORE UPDATE ON public.client_portal_whatsapp_send FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_client_portal_whatsapp_send_updated_at ON public.client_portal_whatsapp_send IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_company_cnd_updated_at BEFORE UPDATE ON public.company_federal_cnd FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_company_cnd_updated_at ON public.company_federal_cnd IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_company_information_by_valuation_updated_at BEFORE UPDATE ON public.company_information_by_valuation FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_company_information_by_valuation_updated_at ON public.company_information_by_valuation IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_company_state_cnd_updated_at BEFORE UPDATE ON public.company_state_cnd FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_company_state_cnd_updated_at ON public.company_state_cnd IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_company_types_updated_at BEFORE UPDATE ON public.company_types FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_company_types_updated_at ON public.company_types IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_consultant_expectations_updated_at BEFORE UPDATE ON public.valuations_consultant_expectations FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_consultant_expectations_updated_at ON public.valuations_consultant_expectations IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_consultants_and_valuations_updated_at BEFORE UPDATE ON public.consultants_and_valuations FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_consultants_and_valuations_updated_at ON public.consultants_and_valuations IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_consultants_updated_at BEFORE UPDATE ON public.consultants FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_consultants_updated_at ON public.consultants IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_consulting_companies_updated_at BEFORE UPDATE ON public.consulting_companies FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_consulting_companies_updated_at ON public.consulting_companies IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_consulting_company_clients_updated_at BEFORE UPDATE ON public.consulting_company_clients FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_consulting_company_clients_updated_at ON public.consulting_company_clients IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_betas_updated_at BEFORE UPDATE ON public.damodaran_betas FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_betas_updated_at ON public.damodaran_betas IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_historical_growth_rates_updated_at BEFORE UPDATE ON public.damodaran_historical_growth_rates FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_historical_growth_rates_updated_at ON public.damodaran_historical_growth_rates IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_industries_updated_at BEFORE UPDATE ON public.damodaran_industries FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_industries_updated_at ON public.damodaran_industries IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_margins_updated_at BEFORE UPDATE ON public.damodaran_margins FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_margins_updated_at ON public.damodaran_margins IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_multiple_ebitda_updated_at BEFORE UPDATE ON public.damodaran_multiple_ebitda FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_multiple_ebitda_updated_at ON public.damodaran_multiple_ebitda IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_multiples_sales_updated_at BEFORE UPDATE ON public.damodaran_multiple_sale FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_multiples_sales_updated_at ON public.damodaran_multiple_sale IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_number_firms_updated_at BEFORE UPDATE ON public.damodaran_number_firms FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_number_firms_updated_at ON public.damodaran_number_firms IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_regions_updated_at BEFORE UPDATE ON public.damodaran_regions FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_regions_updated_at ON public.damodaran_regions IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_damodaran_total_betas_updated_at BEFORE UPDATE ON public.damodaran_total_betas FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_damodaran_total_betas_updated_at ON public.damodaran_total_betas IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_differentials_updated_at BEFORE UPDATE ON public.differentials FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_differentials_updated_at ON public.differentials IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_clients_updated_at BEFORE UPDATE ON public.digital_valuation_clients FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_clients_updated_at ON public.digital_valuation_clients IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_cnpj_updated_at BEFORE UPDATE ON public.digital_valuation_cnpj FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_cnpj_updated_at ON public.digital_valuation_cnpj IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_cupom_updated_at BEFORE UPDATE ON public.digital_valuation_voucher FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_cupom_updated_at ON public.digital_valuation_voucher IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_descriptions_updated_at BEFORE UPDATE ON public.digital_valuation_descriptions FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_descriptions_updated_at ON public.digital_valuation_descriptions IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_differentials_updated_at BEFORE UPDATE ON public.digital_valuation_differentials FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_differentials_updated_at ON public.digital_valuation_differentials IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_final_value_updated_at BEFORE UPDATE ON public.digital_valuation_final_value FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_final_value_updated_at ON public.digital_valuation_final_value IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_financial_data_updated_at BEFORE UPDATE ON public.digital_valuation_financial_data FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_financial_data_updated_at ON public.digital_valuation_financial_data IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_information_updated_at BEFORE UPDATE ON public.digital_valuation_information FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_information_updated_at ON public.digital_valuation_information IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_log_updated_at BEFORE UPDATE ON public.digital_valuation_log FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_log_updated_at ON public.digital_valuation_log IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_digital_valuation_methods_calculated_updated_at BEFORE UPDATE ON public.digital_valuation_methods_calculated FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_digital_valuation_methods_calculated_updated_at ON public.digital_valuation_methods_calculated IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_embi_risk_values_updated_at BEFORE UPDATE ON public.embi_risk_values FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_embi_risk_values_updated_at ON public.embi_risk_values IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_financial_data_type_updated_at BEFORE UPDATE ON public.valuations_financial_data_type FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_financial_data_type_updated_at ON public.valuations_financial_data_type IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_financial_data_updated_at BEFORE UPDATE ON public.valuations_financial_data FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_financial_data_updated_at ON public.valuations_financial_data IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_generic_pdf_generate_updated_at BEFORE UPDATE ON public.generic_pdf_generate FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_generic_pdf_generate_updated_at ON public.generic_pdf_generate IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_google_calendar_event_updated_at BEFORE UPDATE ON public.google_calendar_event FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_google_calendar_event_updated_at ON public.google_calendar_event IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_google_calendar_oauth_created_at BEFORE UPDATE ON public.google_calendar_oauth FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_created_at();
COMMENT ON TRIGGER set_public_google_calendar_oauth_created_at ON public.google_calendar_oauth IS 'trigger to set value of column "created_at" to current timestamp on row update';
CREATE TRIGGER set_public_highlights_updated_at BEFORE UPDATE ON public.highlights FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_highlights_updated_at ON public.highlights IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_indexes_updated_at BEFORE UPDATE ON public.indexes FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_indexes_updated_at ON public.indexes IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_indicators_updated_at BEFORE UPDATE ON public.indicators FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_indicators_updated_at ON public.indicators IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_ma_advertisements_updated_at BEFORE UPDATE ON public.ma_advertisements FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_ma_advertisements_updated_at ON public.ma_advertisements IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_nefin_risk_values_updated_at BEFORE UPDATE ON public.nefin_risk_values FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_nefin_risk_values_updated_at ON public.nefin_risk_values IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_12_months_results_updated_at BEFORE UPDATE ON public.open_companies_12_months_results FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_12_months_results_updated_at ON public.open_companies_12_months_results IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_3_months_results_updated_at BEFORE UPDATE ON public.open_companies_3_months_results FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_3_months_results_updated_at ON public.open_companies_3_months_results IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_balance_updated_at BEFORE UPDATE ON public.open_companies_balance FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_balance_updated_at ON public.open_companies_balance IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_earnings_updated_at BEFORE UPDATE ON public.open_companies_earnings FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_earnings_updated_at ON public.open_companies_earnings IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_growth_updated_at BEFORE UPDATE ON public.open_companies_growth FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_growth_updated_at ON public.open_companies_growth IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_indicators_updated_at BEFORE UPDATE ON public.open_companies_indicators FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_indicators_updated_at ON public.open_companies_indicators IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_information_updated_at BEFORE UPDATE ON public.open_companies_information FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_information_updated_at ON public.open_companies_information IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_sector_updated_at BEFORE UPDATE ON public.open_companies_sector FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_sector_updated_at ON public.open_companies_sector IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_sub_sector_updated_at BEFORE UPDATE ON public.open_companies_sub_sector FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_sub_sector_updated_at ON public.open_companies_sub_sector IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_open_companies_values_updated_at BEFORE UPDATE ON public.open_companies_values FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_open_companies_values_updated_at ON public.open_companies_values IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_profile_test_information_updated_at BEFORE UPDATE ON public.profile_test_information FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_profile_test_information_updated_at ON public.profile_test_information IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_profiles_type_updated_at BEFORE UPDATE ON public.profiles_type FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_profiles_type_updated_at ON public.profiles_type IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_sector_analysis_activities_updated_at BEFORE UPDATE ON public.sector_analysis_activities FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_sector_analysis_activities_updated_at ON public.sector_analysis_activities IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_sector_analysis_and_age_groups_updated_at BEFORE UPDATE ON public.sector_analysis_and_age_groups FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_sector_analysis_and_age_groups_updated_at ON public.sector_analysis_and_age_groups IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_sector_analysis_and_target_audiences_updated_at BEFORE UPDATE ON public.sector_analysis_and_target_audiences FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_sector_analysis_and_target_audiences_updated_at ON public.sector_analysis_and_target_audiences IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_sector_analysis_indicators_updated_at BEFORE UPDATE ON public.sector_analysis_indicators FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_sector_analysis_indicators_updated_at ON public.sector_analysis_indicators IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_sector_analysis_updated_at BEFORE UPDATE ON public.sector_analysis FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_sector_analysis_updated_at ON public.sector_analysis IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_selic_updated_at BEFORE UPDATE ON public.selic FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_selic_updated_at ON public.selic IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_sida_clients_state_updated_at BEFORE UPDATE ON public.sida_clients_state FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_sida_clients_state_updated_at ON public.sida_clients_state IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_simples_nacional_aliquot_updated_at BEFORE UPDATE ON public.simples_nacional_aliquot FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_simples_nacional_aliquot_updated_at ON public.simples_nacional_aliquot IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_simples_nacional_range_updated_at BEFORE UPDATE ON public.simples_nacional_range FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_simples_nacional_range_updated_at ON public.simples_nacional_range IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_states_updated_at BEFORE UPDATE ON public.states FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_states_updated_at ON public.states IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_target_audiences_updated_at BEFORE UPDATE ON public.target_audiences FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_target_audiences_updated_at ON public.target_audiences IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_users_signup_process_updated_at BEFORE UPDATE ON public.users_signup_process FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_users_signup_process_updated_at ON public.users_signup_process IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_users_updated_at ON public.users IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valorizei_sent_updated_at BEFORE UPDATE ON public.valorizei_sent FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valorizei_sent_updated_at ON public.valorizei_sent IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_and_market_updated_at BEFORE UPDATE ON public.valuations_and_market FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_and_market_updated_at ON public.valuations_and_market IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_cnpj_activities_updated_at BEFORE UPDATE ON public.valuations_cnpj_activities FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_cnpj_activities_updated_at ON public.valuations_cnpj_activities IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_cnpj_and_activities_updated_at BEFORE UPDATE ON public.valuations_cnpj_and_activities FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_cnpj_and_activities_updated_at ON public.valuations_cnpj_and_activities IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_cnpj_information_updated_at BEFORE UPDATE ON public.valuations_cnpj_information FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_cnpj_information_updated_at ON public.valuations_cnpj_information IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_cnpj_membership_updated_at BEFORE UPDATE ON public.valuations_cnpj_membership FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_cnpj_membership_updated_at ON public.valuations_cnpj_membership IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_cnpj_simples_nacional_updated_at BEFORE UPDATE ON public.valuations_cnpj_simples_nacional FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_cnpj_simples_nacional_updated_at ON public.valuations_cnpj_simples_nacional IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_cnpj_status_updated_at BEFORE UPDATE ON public.valuations_cnpj_status FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_cnpj_status_updated_at ON public.valuations_cnpj_status IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_information_updated_at BEFORE UPDATE ON public.valuations_information FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_information_updated_at ON public.valuations_information IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_model_config_updated_at BEFORE UPDATE ON public.valuation_model_config FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_model_config_updated_at ON public.valuation_model_config IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_model_image_updated_at BEFORE UPDATE ON public.valuation_model_image FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_model_image_updated_at ON public.valuation_model_image IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuation_model_pages_updated_at BEFORE UPDATE ON public.valuation_model_pages FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuation_model_pages_updated_at ON public.valuation_model_pages IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_accountant_data_updated_at BEFORE UPDATE ON public.valuations_accountant_data FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_accountant_data_updated_at ON public.valuations_accountant_data IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_and_activities_updated_at BEFORE UPDATE ON public.valuations_and_activities FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_and_activities_updated_at ON public.valuations_and_activities IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_and_differentials_updated_at BEFORE UPDATE ON public.valuations_and_differentials FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_and_differentials_updated_at ON public.valuations_and_differentials IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_and_spotlight_updated_at BEFORE UPDATE ON public.valuations_and_spotlight FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_and_spotlight_updated_at ON public.valuations_and_spotlight IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_chat_consultant_updated_at BEFORE UPDATE ON public.valuations_chat_consultant FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_chat_consultant_updated_at ON public.valuations_chat_consultant IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_cnd_updated_at BEFORE UPDATE ON public.valuations_cnd FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_cnd_updated_at ON public.valuations_cnd IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_data_colect_files_updated_at BEFORE UPDATE ON public.valuations_data_colect_files FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_data_colect_files_updated_at ON public.valuations_data_colect_files IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_data_colect_updated_at BEFORE UPDATE ON public.valuations_data_colect FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_data_colect_updated_at ON public.valuations_data_colect IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_description_updated_at BEFORE UPDATE ON public.valuations_description FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_description_updated_at ON public.valuations_description IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_digital_presence_text_updated_at BEFORE UPDATE ON public.valuations_digital_presence_text FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_digital_presence_text_updated_at ON public.valuations_digital_presence_text IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_digital_presence_updated_at BEFORE UPDATE ON public.valuations_digital_presence FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_digital_presence_updated_at ON public.valuations_digital_presence IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_files_updated_at BEFORE UPDATE ON public.valuations_files FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_files_updated_at ON public.valuations_files IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_final_value_updated_at BEFORE UPDATE ON public.valuations_final_value FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_final_value_updated_at ON public.valuations_final_value IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_financial_sheets_updated_at BEFORE UPDATE ON public.valuations_financial_sheets FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_financial_sheets_updated_at ON public.valuations_financial_sheets IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_finantial_spreadsheet_updated_at BEFORE UPDATE ON public.valuations_finantial_spreadsheet FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_finantial_spreadsheet_updated_at ON public.valuations_finantial_spreadsheet IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_methods_updated_at BEFORE UPDATE ON public.valuations_methods FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_methods_updated_at ON public.valuations_methods IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_methods_value_updated_at BEFORE UPDATE ON public.valuations_methods_value FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_methods_value_updated_at ON public.valuations_methods_value IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_notes_updated_at BEFORE UPDATE ON public.valuations_notes FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_notes_updated_at ON public.valuations_notes IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_photos_updated_at BEFORE UPDATE ON public.valuations_photos FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_photos_updated_at ON public.valuations_photos IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_plus_charts_updated_at BEFORE UPDATE ON public.valuations_plus_charts FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_plus_charts_updated_at ON public.valuations_plus_charts IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_plus_dynamic_analisys_updated_at BEFORE UPDATE ON public.valuations_plus_dynamic_analisys FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_plus_dynamic_analisys_updated_at ON public.valuations_plus_dynamic_analisys IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_plus_ebitda_analisys_updated_at BEFORE UPDATE ON public.valuations_plus_ebitda_analisys FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_plus_ebitda_analisys_updated_at ON public.valuations_plus_ebitda_analisys IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_plus_period_updated_at BEFORE UPDATE ON public.valuations_plus_period FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_plus_period_updated_at ON public.valuations_plus_period IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_plus_projection_updated_at BEFORE UPDATE ON public.valuations_plus_projection FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_plus_projection_updated_at ON public.valuations_plus_projection IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_plus_results_project_updated_at BEFORE UPDATE ON public.valuations_plus_results FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_plus_results_project_updated_at ON public.valuations_plus_results IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_plus_risk_analisys_updated_at BEFORE UPDATE ON public.valuations_plus_risk_analisys FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_plus_risk_analisys_updated_at ON public.valuations_plus_risk_analisys IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_progress_updated_at BEFORE UPDATE ON public.valuations_progress FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_progress_updated_at ON public.valuations_progress IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_status_updated_at BEFORE UPDATE ON public.valuations_status FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_status_updated_at ON public.valuations_status IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_taxation_updated_at BEFORE UPDATE ON public.valuations_taxation FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_taxation_updated_at ON public.valuations_taxation IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_valuations_updated_at BEFORE UPDATE ON public.valuations FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_valuations_updated_at ON public.valuations IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.valuations_cnpj_address
    ADD CONSTRAINT address_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.bacen_anual_marketplace_expectations
    ADD CONSTRAINT bacen_anual_marketplace_expectations_indicator_value_fkey FOREIGN KEY (indicator_type) REFERENCES public.bacen_indicator_types(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.balance_companies
    ADD CONSTRAINT balance_companies_sector_fkey FOREIGN KEY (sector) REFERENCES public.open_companies_sector(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.balance_companies
    ADD CONSTRAINT balance_companies_sub_sector_fkey FOREIGN KEY (sub_sector) REFERENCES public.open_companies_sub_sector(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.balance_financial
    ADD CONSTRAINT balance_financial_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.balance_companies(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.balance_financial_data
    ADD CONSTRAINT balance_financial_data_financial_data_type_fkey FOREIGN KEY (financial_data_type) REFERENCES public.balance_financial_data_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.balance_financial_data
    ADD CONSTRAINT balance_financial_data_financial_fkey FOREIGN KEY (financial) REFERENCES public.balance_financial(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_sector_fkey FOREIGN KEY (sector) REFERENCES public.sectors(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.calculator_company_data
    ADD CONSTRAINT calculator_company_data_lead_fkey FOREIGN KEY (lead) REFERENCES public.calculator_lead(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.calculator_company_data
    ADD CONSTRAINT calculator_company_data_type_fkey FOREIGN KEY (type) REFERENCES public.company_types(id) ON UPDATE SET DEFAULT ON DELETE SET DEFAULT;
ALTER TABLE ONLY public.calculator_final_value
    ADD CONSTRAINT calculator_final_value_lead_fkey FOREIGN KEY (lead) REFERENCES public.calculator_lead(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.calculator_lead
    ADD CONSTRAINT calculator_lead_city_fkey FOREIGN KEY (city) REFERENCES public.cities(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.calculator_lead
    ADD CONSTRAINT calculator_lead_profile_fkey FOREIGN KEY (profile) REFERENCES public.calculator_profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.calculator_methods_calculated
    ADD CONSTRAINT calculator_methods_calculated_lead_fkey FOREIGN KEY (lead) REFERENCES public.calculator_lead(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.calculator_methods_calculated
    ADD CONSTRAINT calculator_methods_calculated_type_fkey FOREIGN KEY (type) REFERENCES public.calculator_methods_calculated_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.calculator_values
    ADD CONSTRAINT calculator_values_lead_fkey FOREIGN KEY (lead) REFERENCES public.calculator_lead(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.calculator_values
    ADD CONSTRAINT calculator_values_type_fkey FOREIGN KEY (type) REFERENCES public.calculator_values_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.calculator_whatsapp_checker
    ADD CONSTRAINT calculator_whatsapp_checker_lead_fkey FOREIGN KEY (lead) REFERENCES public.calculator_lead(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_state_fkey FOREIGN KEY (state) REFERENCES public.states(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_ad
    ADD CONSTRAINT client_portal_ad_city_fkey FOREIGN KEY (city) REFERENCES public.cities(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_ad
    ADD CONSTRAINT client_portal_ad_company_type_fkey FOREIGN KEY (company_type) REFERENCES public.company_types(id) ON UPDATE SET DEFAULT ON DELETE SET DEFAULT;
ALTER TABLE ONLY public.client_portal_ad
    ADD CONSTRAINT client_portal_ad_free_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.client_portal_companies(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_ad
    ADD CONSTRAINT client_portal_ad_free_company_sector_fkey FOREIGN KEY (company_sector) REFERENCES public.sectors(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_ad
    ADD CONSTRAINT client_portal_ad_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.client_portal_profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_ad_status
    ADD CONSTRAINT client_portal_ad_status_ad_id_fkey FOREIGN KEY (ad_id) REFERENCES public.client_portal_ad(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_companies
    ADD CONSTRAINT client_portal_companies_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.client_portal_profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_fingerprints
    ADD CONSTRAINT client_portal_fingerprints_user_fkey FOREIGN KEY ("user") REFERENCES public.client_portal_profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_logs
    ADD CONSTRAINT client_portal_logs_ad_id_fkey FOREIGN KEY (ad_id) REFERENCES public.client_portal_ad(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_phone_confirmation_process
    ADD CONSTRAINT client_portal_phone_confirmation_pro_client_portal_profile_fkey FOREIGN KEY (client_portal_profile) REFERENCES public.client_portal_profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_profiles
    ADD CONSTRAINT client_portal_profiles_consulting_companies_fkey FOREIGN KEY (consulting_companies) REFERENCES public.consulting_companies(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_profiles
    ADD CONSTRAINT client_portal_profiles_profile_type_fkey FOREIGN KEY (profile_type) REFERENCES public.profiles_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_profiles
    ADD CONSTRAINT client_portal_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.client_portal_tokens
    ADD CONSTRAINT client_portal_tokens_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.client_portal_profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.company_information_by_valuation
    ADD CONSTRAINT company_information_by_valuation_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.company_types
    ADD CONSTRAINT company_types_branch_fkey FOREIGN KEY (branch) REFERENCES public.branches(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_consultant_expectations
    ADD CONSTRAINT consultant_expectations_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_betas
    ADD CONSTRAINT damodaran_betas_industry_fkey FOREIGN KEY (industry) REFERENCES public.damodaran_industries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_betas
    ADD CONSTRAINT damodaran_betas_region_fkey FOREIGN KEY (region) REFERENCES public.damodaran_regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_historical_growth_rates
    ADD CONSTRAINT damodaran_historical_growth_rates_industry_fkey FOREIGN KEY (industry) REFERENCES public.damodaran_industries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_historical_growth_rates
    ADD CONSTRAINT damodaran_historical_growth_rates_region_fkey FOREIGN KEY (region) REFERENCES public.damodaran_regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_margins
    ADD CONSTRAINT damodaran_margins_industry_fkey FOREIGN KEY (industry) REFERENCES public.damodaran_industries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_margins
    ADD CONSTRAINT damodaran_margins_region_fkey FOREIGN KEY (region) REFERENCES public.damodaran_regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_multiple_ebitda
    ADD CONSTRAINT damodaran_multiple_ebitda_industry_fkey FOREIGN KEY (industry) REFERENCES public.damodaran_industries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_multiple_ebitda
    ADD CONSTRAINT damodaran_multiple_ebitda_region_fkey FOREIGN KEY (region) REFERENCES public.damodaran_regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_multiple_sale
    ADD CONSTRAINT damodaran_multiples_sales_industry_fkey FOREIGN KEY (industry) REFERENCES public.damodaran_industries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_multiple_sale
    ADD CONSTRAINT damodaran_multiples_sales_region_fkey FOREIGN KEY (region) REFERENCES public.damodaran_regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_number_firms
    ADD CONSTRAINT damodaran_number_firms_industry_fkey FOREIGN KEY (industry) REFERENCES public.damodaran_industries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_number_firms
    ADD CONSTRAINT damodaran_number_firms_region_fkey FOREIGN KEY (region) REFERENCES public.damodaran_regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_total_betas
    ADD CONSTRAINT damodaran_total_betas_industry_fkey FOREIGN KEY (industry) REFERENCES public.damodaran_industries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.damodaran_total_betas
    ADD CONSTRAINT damodaran_total_betas_region_fkey FOREIGN KEY (region) REFERENCES public.damodaran_regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.differentials
    ADD CONSTRAINT differentials_sector_fkey FOREIGN KEY (sector) REFERENCES public.sectors(value);
ALTER TABLE ONLY public.digital_valuation_clients
    ADD CONSTRAINT digital_valuation_clients_consulting_company_fkey FOREIGN KEY (consulting_company) REFERENCES public.consulting_companies(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_cnpj
    ADD CONSTRAINT digital_valuation_cnpj_digital_valuation_information_fkey FOREIGN KEY (digital_valuation_information) REFERENCES public.digital_valuation_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_voucher
    ADD CONSTRAINT digital_valuation_cupom_consulting_company_fkey FOREIGN KEY (consulting_company) REFERENCES public.consulting_companies(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_descriptions
    ADD CONSTRAINT digital_valuation_descriptions_expense_expectation_fkey FOREIGN KEY (expense_expectation) REFERENCES public.digital_valuation_expense_expectations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_descriptions
    ADD CONSTRAINT digital_valuation_descriptions_revenue_growth_fkey FOREIGN KEY (revenue_growth) REFERENCES public.digital_valuation_rg_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_descriptions
    ADD CONSTRAINT digital_valuation_descriptions_valuation_information_id_fkey FOREIGN KEY (valuation_information_id) REFERENCES public.digital_valuation_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_differentials
    ADD CONSTRAINT digital_valuation_differentials_differentials_fkey FOREIGN KEY (differentials) REFERENCES public.differentials(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_differentials
    ADD CONSTRAINT digital_valuation_differentials_digital_valuation_informatio FOREIGN KEY (digital_valuation_information) REFERENCES public.digital_valuation_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_final_value
    ADD CONSTRAINT digital_valuation_final_value_digital_valuation_informatio_fkey FOREIGN KEY (digital_valuation_information) REFERENCES public.digital_valuation_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_financial_data
    ADD CONSTRAINT digital_valuation_financial_data_digital_valuation_informati FOREIGN KEY (digital_valuation_information) REFERENCES public.digital_valuation_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_financial_data
    ADD CONSTRAINT digital_valuation_financial_data_financial_data_type_fkey FOREIGN KEY (financial_data_type) REFERENCES public.valuations_financial_data_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_information
    ADD CONSTRAINT digital_valuation_information_company_type_fkey FOREIGN KEY (company_type) REFERENCES public.company_types(id) ON UPDATE SET DEFAULT ON DELETE SET DEFAULT;
ALTER TABLE ONLY public.digital_valuation_information
    ADD CONSTRAINT digital_valuation_information_consulting_companies_fkey FOREIGN KEY (consulting_companies) REFERENCES public.consulting_companies(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_information
    ADD CONSTRAINT digital_valuation_information_digital_valuation_client_fkey FOREIGN KEY (digital_valuation_client) REFERENCES public.digital_valuation_clients(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_log
    ADD CONSTRAINT digital_valuation_log_digital_valuation_information_fkey FOREIGN KEY (digital_valuation_information) REFERENCES public.digital_valuation_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_methods_calculated
    ADD CONSTRAINT digital_valuation_methods_cal_digital_valuation_informatio_fkey FOREIGN KEY (digital_valuation_information) REFERENCES public.digital_valuation_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_methods_calculated
    ADD CONSTRAINT digital_valuation_methods_calculated_type_fkey FOREIGN KEY (type) REFERENCES public.digital_valuation_methods_calculated_type(value) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE ONLY public.digital_valuation_voucher
    ADD CONSTRAINT digital_valuation_voucher_valuation_client_fkey FOREIGN KEY (valuation_client) REFERENCES public.digital_valuation_clients(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.highlights
    ADD CONSTRAINT highlights_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.indexes
    ADD CONSTRAINT indexes_type_fkey FOREIGN KEY (type) REFERENCES public.indexes_type(value);
ALTER TABLE ONLY public.indicators
    ADD CONSTRAINT indicators_type_fkey FOREIGN KEY (type) REFERENCES public.indicators_type(value) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_inpi
    ADD CONSTRAINT inpi_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.ma_advertisements
    ADD CONSTRAINT ma_advertisements_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_12_months_results
    ADD CONSTRAINT open_companies_12_months_results_company_fkey FOREIGN KEY (company) REFERENCES public.open_companies_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_3_months_results
    ADD CONSTRAINT open_companies_3_months_results_company_fkey FOREIGN KEY (company) REFERENCES public.open_companies_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_balance
    ADD CONSTRAINT open_companies_balance_company_fkey FOREIGN KEY (company) REFERENCES public.open_companies_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_earnings
    ADD CONSTRAINT open_companies_earnings_company_fkey FOREIGN KEY (company) REFERENCES public.open_companies_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_earnings
    ADD CONSTRAINT open_companies_earnings_type_fkey FOREIGN KEY (type) REFERENCES public.open_companies_earnings_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_growth
    ADD CONSTRAINT open_companies_growth_company_fkey FOREIGN KEY (company) REFERENCES public.open_companies_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_indicators
    ADD CONSTRAINT open_companies_indicators_company_fkey FOREIGN KEY (company) REFERENCES public.open_companies_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_indicators
    ADD CONSTRAINT open_companies_indicators_type_fkey FOREIGN KEY (type) REFERENCES public.open_companies_indicators_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_information
    ADD CONSTRAINT open_companies_information_sector_fkey FOREIGN KEY (sector) REFERENCES public.open_companies_sector(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_information
    ADD CONSTRAINT open_companies_information_subsector_fkey FOREIGN KEY (subsector) REFERENCES public.open_companies_sub_sector(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_sub_sector
    ADD CONSTRAINT open_companies_sub_sector_sector_fkey FOREIGN KEY (sector) REFERENCES public.open_companies_sector(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.open_companies_values
    ADD CONSTRAINT open_companies_values_company_fkey FOREIGN KEY (company) REFERENCES public.open_companies_information(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.profile_test_information
    ADD CONSTRAINT profile_test_information_investment_period_fkey FOREIGN KEY (investment_period) REFERENCES public.profile_test_investment_periods(period) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.profile_test_information
    ADD CONSTRAINT profile_test_information_investment_range_fkey FOREIGN KEY (investment_range) REFERENCES public.profile_test_investment_ranges(range) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.sector_analysis_activities
    ADD CONSTRAINT sector_analysis_activities_sector_analysis_fkey FOREIGN KEY (sector_analysis) REFERENCES public.sector_analysis(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.sector_analysis_and_age_groups
    ADD CONSTRAINT sector_analysis_and_age_groups_age_groups_fkey FOREIGN KEY (age_groups) REFERENCES public.age_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.sector_analysis_and_age_groups
    ADD CONSTRAINT sector_analysis_and_age_groups_sector_analysis_fkey FOREIGN KEY (sector_analysis) REFERENCES public.sector_analysis(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.sector_analysis_and_target_audiences
    ADD CONSTRAINT sector_analysis_and_target_audiences_sector_analysis_fkey FOREIGN KEY (sector_analysis) REFERENCES public.sector_analysis(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.sector_analysis_and_target_audiences
    ADD CONSTRAINT sector_analysis_and_target_audiences_target_audiences_fkey FOREIGN KEY (target_audiences) REFERENCES public.target_audiences(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.sector_analysis_indicators
    ADD CONSTRAINT sector_analysis_indicators_sector_analysis_fkey FOREIGN KEY (sector_analysis) REFERENCES public.sector_analysis(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.sector_analysis_indicators
    ADD CONSTRAINT sector_analysis_indicators_type_fkey FOREIGN KEY (type) REFERENCES public.sector_analysis_indicators_type(value) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.sector_analysis
    ADD CONSTRAINT sector_analysis_sector_analysis_type_fkey FOREIGN KEY (type) REFERENCES public.sector_analysis_type(value);
ALTER TABLE ONLY public.sida_clients_state
    ADD CONSTRAINT sida_clients_state_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.consulting_company_clients(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.simples_nacional_aliquot
    ADD CONSTRAINT simples_nacional_aliquot_range_fkey FOREIGN KEY (range) REFERENCES public.simples_nacional_range(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.taxation
    ADD CONSTRAINT taxation_type_fkey FOREIGN KEY (type) REFERENCES public.taxation_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.taxation
    ADD CONSTRAINT taxation_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valorizei_sent
    ADD CONSTRAINT valorizei_sent_type_fkey FOREIGN KEY (type) REFERENCES public.valorizei_types(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuation_and_market_main_market_fkey FOREIGN KEY (main_market) REFERENCES public.sector_analysis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuation_and_market_sector_fkey FOREIGN KEY (sector) REFERENCES public.sectors(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuation_and_market_specific_market_fkey FOREIGN KEY (specific_market) REFERENCES public.sector_analysis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuation_and_market_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_and_activities
    ADD CONSTRAINT valuation_cnpj_and_activities_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_information
    ADD CONSTRAINT valuation_cnpj_information_legal_nature_fkey FOREIGN KEY (legal_nature) REFERENCES public.valuations_cnpj_information_legal_nature(code) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_information
    ADD CONSTRAINT valuation_cnpj_information_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_membership
    ADD CONSTRAINT valuation_cnpj_membership_role_fkey FOREIGN KEY (role) REFERENCES public.valuations_cnpj_membership_role(code) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_membership
    ADD CONSTRAINT valuation_cnpj_membership_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_simples_nacional
    ADD CONSTRAINT valuation_cnpj_simples_nacional_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_status
    ADD CONSTRAINT valuation_cnpj_status_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_information
    ADD CONSTRAINT valuation_information_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuation_model_config
    ADD CONSTRAINT valuation_model_config_consulting_companies_fkey FOREIGN KEY (consulting_companies) REFERENCES public.consulting_companies(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuation_model_image
    ADD CONSTRAINT valuation_model_image_consulting_companies_fkey FOREIGN KEY (consulting_companies) REFERENCES public.consulting_companies(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_accountant_data
    ADD CONSTRAINT valuations_accountant_data_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_and_activities
    ADD CONSTRAINT valuations_and_activities_activity_fkey FOREIGN KEY (activity) REFERENCES public.sector_analysis_activities(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_activities
    ADD CONSTRAINT valuations_and_activities_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_differentials
    ADD CONSTRAINT valuations_and_differentials_differential_fkey FOREIGN KEY (differential) REFERENCES public.differentials(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_differentials
    ADD CONSTRAINT valuations_and_differentials_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuations_and_market_damodaran_region_fkey FOREIGN KEY (damodaran_region) REFERENCES public.damodaran_regions(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuations_and_market_damodaran_sector_fkey FOREIGN KEY (damodaran_sector) REFERENCES public.damodaran_industries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_and_market
    ADD CONSTRAINT valuations_and_market_type_fkey FOREIGN KEY (type) REFERENCES public.company_types(id) ON UPDATE SET DEFAULT ON DELETE SET DEFAULT;
ALTER TABLE ONLY public.valuations_and_spotlight
    ADD CONSTRAINT valuations_and_spotlight_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_chat_consultant
    ADD CONSTRAINT valuations_chat_consultant_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnd
    ADD CONSTRAINT valuations_cnd_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_cnd_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnd
    ADD CONSTRAINT valuations_cnd_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_and_activities
    ADD CONSTRAINT valuations_cnpj_and_activities_activity_fkey FOREIGN KEY (activity) REFERENCES public.valuations_cnpj_activities(code) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_cnpj_and_activities
    ADD CONSTRAINT valuations_cnpj_and_activities_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_cnpj_activity_types(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_data_colect_files
    ADD CONSTRAINT valuations_data_colect_files_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_data_colect_files_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_data_colect_files
    ADD CONSTRAINT valuations_data_colect_files_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_data_colect
    ADD CONSTRAINT valuations_data_colect_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_description
    ADD CONSTRAINT valuations_description_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_description_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_description
    ADD CONSTRAINT valuations_description_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_digital_presence
    ADD CONSTRAINT valuations_digital_presence_social_network_fkey FOREIGN KEY (social_network) REFERENCES public.valuations_digital_presence_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_digital_presence_text
    ADD CONSTRAINT valuations_digital_presence_text_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_digital_presence_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_digital_presence
    ADD CONSTRAINT valuations_digital_presence_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_external_ids
    ADD CONSTRAINT valuations_external_ids_external_id_type_fkey FOREIGN KEY (external_id_type) REFERENCES public.valuations_external_ids_types(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_external_ids
    ADD CONSTRAINT valuations_external_ids_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_files
    ADD CONSTRAINT valuations_files_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_final_value
    ADD CONSTRAINT valuations_final_value_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_financial_data_type
    ADD CONSTRAINT valuations_financial_data_type_sector_fkey FOREIGN KEY (sector) REFERENCES public.sectors(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_financial_sheets
    ADD CONSTRAINT valuations_financial_sheets_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_finantial_spreadsheet
    ADD CONSTRAINT valuations_finantial_spreadsheet_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_information
    ADD CONSTRAINT valuations_information_reason_fkey FOREIGN KEY (reason) REFERENCES public.valuations_information_reason(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_methods
    ADD CONSTRAINT valuations_methods_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_methods_value
    ADD CONSTRAINT valuations_methods_value_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_notes
    ADD CONSTRAINT valuations_notes_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_photos
    ADD CONSTRAINT valuations_photos_photos_type_fkey FOREIGN KEY (photos_type) REFERENCES public.valuations_photos_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_photos
    ADD CONSTRAINT valuations_photos_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_plus_charts
    ADD CONSTRAINT valuations_plus_charts_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_plus_charts_type(name) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_plus_charts
    ADD CONSTRAINT valuations_plus_charts_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_plus_dynamic_analisys
    ADD CONSTRAINT valuations_plus_dynamic_analisys_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_plus_ebitda_analisys
    ADD CONSTRAINT valuations_plus_ebitda_analisys_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_plus_period
    ADD CONSTRAINT valuations_plus_period_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_plus_period_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_plus_projection
    ADD CONSTRAINT valuations_plus_projection_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id);
ALTER TABLE ONLY public.valuations_plus_results
    ADD CONSTRAINT valuations_plus_results_project_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_plus_results_type(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_plus_results
    ADD CONSTRAINT valuations_plus_results_project_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_plus_risk_analisys
    ADD CONSTRAINT valuations_plus_risk_analisys_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.valuations_status
    ADD CONSTRAINT valuations_status_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.valuations_taxation
    ADD CONSTRAINT valuations_taxation_type_fkey FOREIGN KEY (type) REFERENCES public.valuations_taxation_type(value);
ALTER TABLE ONLY public.valuations_taxation
    ADD CONSTRAINT valuations_taxation_valuation_fkey FOREIGN KEY (valuation) REFERENCES public.valuations(id) ON UPDATE CASCADE ON DELETE CASCADE;
