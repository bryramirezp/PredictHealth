-- =============================================
-- POPULATE DATABASE - 100 INSTITUTIONS, DOCTORS, PATIENTS
-- Generated on: 2025-10-30 18:01:04
-- =============================================

-- =============================================
-- REFERENCE TABLES (must be populated first)
-- =============================================

-- Institution types
INSERT INTO institution_types (name, description, category) VALUES
    ('hospital', 'General or specialized hospital providing inpatient and outpatient care', 'healthcare'),
    ('preventive_clinic', 'Clinic focused on preventive medicine and health promotion', 'healthcare'),
    ('health_center', 'Primary healthcare center for basic medical services', 'healthcare')
ON CONFLICT (name) DO NOTHING;

-- Email types
INSERT INTO email_types (name, description) VALUES
    ('primary', 'Primary contact email address'),
    ('secondary', 'Secondary contact email address'),
    ('work', 'Work-related email address'),
    ('personal', 'Personal email address'),
    ('notification', 'Email for system notifications'),
    ('billing', 'Email for billing and financial communications')
ON CONFLICT (name) DO NOTHING;

-- Phone types
INSERT INTO phone_types (name, description) VALUES
    ('primary', 'Primary contact number'),
    ('secondary', 'Secondary contact number'),
    ('mobile', 'Mobile phone number'),
    ('work', 'Work phone number'),
    ('home', 'Home phone number'),
    ('emergency', 'Emergency contact phone')
ON CONFLICT (name) DO NOTHING;

-- Countries
INSERT INTO countries (name, iso_code, iso_code_2, phone_code, currency_code) VALUES
    ('Mexico', 'MEX', 'MX', '+52', 'MXN'),
    ('United States', 'USA', 'US', '+1', 'USD'),
    ('Canada', 'CAN', 'CA', '+1', 'CAD')
ON CONFLICT (iso_code) DO NOTHING;

-- Regions (Mexican states)
INSERT INTO regions (country_id, name, region_code, region_type) VALUES
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Ciudad de México', 'CDMX', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Nuevo León', 'NL', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Jalisco', 'JAL', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Guanajuato', 'GTO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'México', 'MEX', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Michoacán', 'MICH', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Morelos', 'MOR', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Nayarit', 'NAY', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Sinaloa', 'SIN', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Sonora', 'SON', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Veracruz', 'VER', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Puebla', 'PUE', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Querétaro', 'QRO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Quintana Roo', 'QROO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'San Luis Potosí', 'SLP', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tabasco', 'TAB', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tamaulipas', 'TAMPS', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tlaxcala', 'TLAX', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Yucatán', 'YUC', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Zacatecas', 'ZAC', 'state')
ON CONFLICT (country_id, name) DO NOTHING;

-- =============================================
-- MEDICAL INSTITUTIONS (100)
-- =============================================

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('163749fb-8b46-4447-a8b7-95b4a59531b6', 'Despacho Grijalva, Mascareñas y Parra', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://despacho-grijalva-mascarenas-y-parra.predicthealth.com', 'LIC-MX-HOSP-101', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('83b74179-f6ef-4219-bc70-c93f4393a350', 'Laboratorios Saldivar, Santillán y Villanueva', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://laboratorios-saldivar-santillan-y-villanueva.predicthealth.com', 'LIC-MX-HEAL-102', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('50503414-ca6d-4c1a-a34f-18719e2fd555', 'Trejo-Vigil e Hijos', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://trejo-vigil-e-hijos.predicthealth.com', 'LIC-MX-PREV-103', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('9b581d3c-9e93-4f39-80bb-294752065866', 'Club Barajas, del Valle y Carrero', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://club-barajas-del-valle-y-carrero.predicthealth.com', 'LIC-MX-HEAL-104', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('e0e34926-8d48-4db0-afb9-b20b6eeb1ecb', 'Collazo-Barrientos', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://collazo-barrientos.predicthealth.com', 'LIC-MX-HOSP-105', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('81941e1d-820a-4313-8177-e44278d9a981', 'Corporacin Prado, Dávila y Noriega', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://corporacin-prado-davila-y-noriega.predicthealth.com', 'LIC-MX-HEAL-106', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('a725b15f-039b-4256-843a-51a2968633fd', 'Corporacin Navarro-Collado', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://corporacin-navarro-collado.predicthealth.com', 'LIC-MX-HOSP-107', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d', 'Iglesias, Soria y Chacón', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://iglesias-soria-y-chacon.predicthealth.com', 'LIC-MX-HOSP-108', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('d471d2d1-66a1-4de0-8754-127059786888', 'Castillo-Zayas', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://castillo-zayas.predicthealth.com', 'LIC-MX-PREV-109', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('8fd698b3-084d-4248-a28e-2708a5862e27', 'Club Mesa y Riojas', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://club-mesa-y-riojas.predicthealth.com', 'LIC-MX-HOSP-110', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('7b96a7bb-041f-4331-be05-e97cab7dafc0', 'Ojeda y Baca S. R.L. de C.V.', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://ojeda-y-baca-s-r-l-de-c-v.predicthealth.com', 'LIC-MX-HOSP-111', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('5da54d5d-de0c-4277-a43e-6a89f987e77c', 'Murillo y Quintanilla S.A.', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://murillo-y-quintanilla-s-a.predicthealth.com', 'LIC-MX-HOSP-112', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('c9014e88-309c-4cb0-a28d-25b510e1e522', 'Grupo Collazo, Hinojosa y Valdés', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://grupo-collazo-hinojosa-y-valdes.predicthealth.com', 'LIC-MX-HOSP-113', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('8e889f63-2c86-44ab-959f-fdc365353d5d', 'Club Verdugo y Tejeda', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://club-verdugo-y-tejeda.predicthealth.com', 'LIC-MX-PREV-114', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('67787f7c-fdee-4e30-80bd-89008ebfe419', 'Zaragoza e Hijos', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://zaragoza-e-hijos.predicthealth.com', 'LIC-MX-HEAL-115', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('4721cb90-8fb0-4fd6-b19e-160b4ac0c744', 'Ceballos-Tello', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://ceballos-tello.predicthealth.com', 'LIC-MX-HOSP-116', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('09c54a60-6267-4439-9c8b-8c9012842942', 'Bañuelos e Hijos', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://banuelos-e-hijos.predicthealth.com', 'LIC-MX-PREV-117', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('a670c73c-cc47-42fe-88c9-0fa37359779b', 'Despacho Jaramillo, Salas y Carrero', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://despacho-jaramillo-salas-y-carrero.predicthealth.com', 'LIC-MX-HEAL-118', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('373769ab-b720-4269-bfb9-02546401ce99', 'Páez-Navarro S.A.', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://paez-navarro-s-a.predicthealth.com', 'LIC-MX-HEAL-119', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('ec040a7f-96b2-4a7d-85ed-3741fcdcfc75', 'Proyectos Mata y Jurado', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://proyectos-mata-y-jurado.predicthealth.com', 'LIC-MX-HEAL-120', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0', 'Laboratorios Trejo, García y Lucero', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://laboratorios-trejo-garcia-y-lucero.predicthealth.com', 'LIC-MX-PREV-121', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('6c287a0e-9d4c-4574-932f-7d499aa4146c', 'Industrias Valverde y Leal', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://industrias-valverde-y-leal.predicthealth.com', 'LIC-MX-HEAL-122', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('a14c189c-ee90-4c29-b465-63d43a9d0010', 'Castillo, Lugo y Zamora', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://castillo-lugo-y-zamora.predicthealth.com', 'LIC-MX-PREV-123', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('e040eabc-0ac9-47f7-89ae-24246e1c12dd', 'Montenegro, Alcala y Nieves', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://montenegro-alcala-y-nieves.predicthealth.com', 'LIC-MX-HEAL-124', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('9c8636c9-015b-4c18-a641-f5da698b6fd8', 'Montenegro y Pichardo S.A. de C.V.', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://montenegro-y-pichardo-s-a-de-c-v.predicthealth.com', 'LIC-MX-HOSP-125', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa', 'Lucio-Marrero y Asociados', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://lucio-marrero-y-asociados.predicthealth.com', 'LIC-MX-HOSP-126', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('146a692b-6d46-4c26-a165-092fe771400e', 'Proyectos Iglesias-Verdugo', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://proyectos-iglesias-verdugo.predicthealth.com', 'LIC-MX-PREV-127', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('6297ae0f-7fee-472d-87ec-e22b87ce6ffb', 'Dueñas-Esquivel S. R.L. de C.V.', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://duenas-esquivel-s-r-l-de-c-v.predicthealth.com', 'LIC-MX-HEAL-128', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('66e6aa6c-596c-442e-85fb-b143875d0dfc', 'Valencia-Toro', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://valencia-toro.predicthealth.com', 'LIC-MX-HOSP-129', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('46af545e-6db8-44ba-a7f9-9fd9617f4a09', 'Solano-Rodrígez', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://solano-rodrigez.predicthealth.com', 'LIC-MX-HEAL-130', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('a56b6787-94e9-49f0-8b3a-6ff5979773fc', 'Laboratorios Vásquez-Zepeda', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://laboratorios-vasquez-zepeda.predicthealth.com', 'LIC-MX-HEAL-131', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf', 'Club Montañez-Almaraz', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://club-montanez-almaraz.predicthealth.com', 'LIC-MX-PREV-132', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('4bfa1a0a-0434-45e0-b454-03140b992f53', 'Proyectos Alvarez, Godínez y Estévez', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://proyectos-alvarez-godinez-y-estevez.predicthealth.com', 'LIC-MX-HOSP-133', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('33ba98b9-c46a-47c1-b266-d8a4fe557290', 'Grupo Carvajal, Murillo y Regalado', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://grupo-carvajal-murillo-y-regalado.predicthealth.com', 'LIC-MX-PREV-134', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('f4764cd3-47e9-4408-b0ee-9b9001c5459d', 'Industrias Bahena, Nieto y Acosta', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://industrias-bahena-nieto-y-acosta.predicthealth.com', 'LIC-MX-HOSP-135', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8', 'Villagómez S.A.', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://villagomez-s-a.predicthealth.com', 'LIC-MX-PREV-136', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d', 'Lucero-Fajardo e Hijos', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://lucero-fajardo-e-hijos.predicthealth.com', 'LIC-MX-HOSP-137', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('8be78aaa-c408-452e-bf01-8e831ab5c63a', 'Laboratorios Arellano-Rosas', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://laboratorios-arellano-rosas.predicthealth.com', 'LIC-MX-HOSP-138', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('8fb0899c-732e-4f03-8209-d52ef41a6a76', 'Alba-Casas', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://alba-casas.predicthealth.com', 'LIC-MX-HEAL-139', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('3a9084e7-74c5-4e0b-b786-2c93d9cd39ee', 'Club Zambrano, Arredondo y Guerra', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://club-zambrano-arredondo-y-guerra.predicthealth.com', 'LIC-MX-HEAL-140', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('54481b92-e5f5-421b-ba21-89bf520a2d87', 'Club Ballesteros-Cornejo', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://club-ballesteros-cornejo.predicthealth.com', 'LIC-MX-PREV-141', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('68f1a02a-d348-4d1e-99ee-733d832a3f43', 'Espinoza y Villegas A.C.', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://espinoza-y-villegas-a-c.predicthealth.com', 'LIC-MX-HEAL-142', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('36983990-abe8-4f1c-9c1b-863b9cab3ca9', 'Alfaro, Pacheco y Villalpando', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://alfaro-pacheco-y-villalpando.predicthealth.com', 'LIC-MX-HEAL-143', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('b654860f-ec74-42d6-955e-eeedde2df0dd', 'Grupo Ibarra y Elizondo', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://grupo-ibarra-y-elizondo.predicthealth.com', 'LIC-MX-HOSP-144', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('be133600-848e-400b-9bc8-c52a4f3cf10d', 'Ávila y Maestas S.A.', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://avila-y-maestas-s-a.predicthealth.com', 'LIC-MX-PREV-145', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('25e918f3-692f-4f51-b630-4caa1dd825a1', 'Gastélum y Guerrero y Asociados', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://gastelum-y-guerrero-y-asociados.predicthealth.com', 'LIC-MX-HEAL-146', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('cc46221e-f387-463c-9d11-9464d8209f7b', 'Escobedo y Guerrero A.C.', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://escobedo-y-guerrero-a-c.predicthealth.com', 'LIC-MX-PREV-147', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('a15d4a4b-1bc4-4ee5-a168-714f71d94e42', 'Laboratorios Cavazos y Valentín', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://laboratorios-cavazos-y-valentin.predicthealth.com', 'LIC-MX-HOSP-148', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('3d7c5771-0692-4a2f-a4c6-6af2b561282b', 'Leal-Valdez S.A. de C.V.', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://leal-valdez-s-a-de-c-v.predicthealth.com', 'LIC-MX-HEAL-149', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('16b25a77-b84a-44ac-8540-c5bfa9b3b6b0', 'Carvajal y Urías A.C.', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://carvajal-y-urias-a-c.predicthealth.com', 'LIC-MX-HOSP-150', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('2040ac28-7210-4fbd-9716-53872211bcd9', 'Alonso S.A.', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://alonso-s-a.predicthealth.com', 'LIC-MX-HOSP-151', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('0d826581-b9d8-4828-8848-9332fe38d169', 'Arteaga-Malave', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://arteaga-malave.predicthealth.com', 'LIC-MX-HEAL-152', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('c0595f94-c8f4-413c-a05c-7cfca773563c', 'Briones y Esquibel S.C.', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://briones-y-esquibel-s-c.predicthealth.com', 'LIC-MX-PREV-153', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5', 'Mares, Altamirano y Gil', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://mares-altamirano-y-gil.predicthealth.com', 'LIC-MX-PREV-154', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('ad2c792b-5015-4238-b221-fa28e8b061fc', 'Corporacin Hurtado, Martínez y Bueno', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://corporacin-hurtado-martinez-y-bueno.predicthealth.com', 'LIC-MX-HEAL-155', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('c3e96b10-f0ca-421e-b402-aba6d595cf27', 'Leyva y Saavedra e Hijos', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://leyva-y-saavedra-e-hijos.predicthealth.com', 'LIC-MX-PREV-156', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('a5b1202a-9112-404b-b7de-ddf0f62711f8', 'Corporacin Pacheco, Hurtado y Holguín', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://corporacin-pacheco-hurtado-y-holguin.predicthealth.com', 'LIC-MX-HOSP-157', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('ac6f8f54-21c8-475b-bea6-19e31643392d', 'Despacho Guerrero, Noriega y Zavala', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://despacho-guerrero-noriega-y-zavala.predicthealth.com', 'LIC-MX-PREV-158', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('43dee983-676a-4e33-a6b0-f0a72f46d06c', 'Montaño-Lira', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://montano-lira.predicthealth.com', 'LIC-MX-HOSP-159', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('f7799f28-3ab7-4b36-8a3a-b23890a5f0ca', 'Pelayo-Arenas', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://pelayo-arenas.predicthealth.com', 'LIC-MX-HEAL-160', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('08a7fe9e-c043-4fed-89e4-93a416a20089', 'Gil y Coronado y Asociados', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://gil-y-coronado-y-asociados.predicthealth.com', 'LIC-MX-HOSP-161', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('89ab21cf-089e-4210-8e29-269dfbd38d71', 'Crespo, Peña y Rosado', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://crespo-pena-y-rosado.predicthealth.com', 'LIC-MX-HOSP-162', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f', 'Jimínez, Arroyo y Ramón', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://jiminez-arroyo-y-ramon.predicthealth.com', 'LIC-MX-HOSP-163', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0', 'de León S.C.', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://de-leon-s-c.predicthealth.com', 'LIC-MX-HEAL-164', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('3cf42c93-4941-4d8d-8656-aafa9e987177', 'Robles-Loera A.C.', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://robles-loera-a-c.predicthealth.com', 'LIC-MX-HOSP-165', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('1926fa2a-dab7-420e-861b-c2b6dfe0174e', 'Industrias Ponce y Soto', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://industrias-ponce-y-soto.predicthealth.com', 'LIC-MX-PREV-166', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('0b2f4464-5141-44a3-a26d-f8acc1fb955e', 'Madera S.A.', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://madera-s-a.predicthealth.com', 'LIC-MX-PREV-167', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('1fec9665-52bc-49a7-b028-f0d78440463c', 'Proyectos Tejada, Ramón y Caldera', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://proyectos-tejada-ramon-y-caldera.predicthealth.com', 'LIC-MX-HOSP-168', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a', 'Estévez-Carrera', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://estevez-carrera.predicthealth.com', 'LIC-MX-HEAL-169', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('8cfdeaad-c727-4a4d-b5d5-b69dd43c0854', 'Laboratorios Puga, Coronado y Carmona', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://laboratorios-puga-coronado-y-carmona.predicthealth.com', 'LIC-MX-PREV-170', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('7a6ce151-14b5-4d12-b6bb-1fba18636353', 'Menchaca-Vela S. R.L. de C.V.', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://menchaca-vela-s-r-l-de-c-v.predicthealth.com', 'LIC-MX-HOSP-171', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('f1ab98f4-98de-420f-9c4b-c31eee92df21', 'Carreón y Soliz S.C.', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://carreon-y-soliz-s-c.predicthealth.com', 'LIC-MX-HEAL-172', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('a074c3ea-f255-4cf2-ae3f-727f9186be3c', 'Zarate-Solano', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://zarate-solano.predicthealth.com', 'LIC-MX-HOSP-173', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('0e3821a8-80d6-4fa9-8313-3ed45b83c28b', 'de la Crúz-Espinoza e Hijos', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://de-la-cruz-espinoza-e-hijos.predicthealth.com', 'LIC-MX-PREV-174', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('3d521bc9-692d-4a0d-a3d7-80e816b86374', 'Laboratorios Valdés-Ruelas', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://laboratorios-valdes-ruelas.predicthealth.com', 'LIC-MX-HOSP-175', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('47393461-e570-448b-82b1-1cef15441262', 'Espinosa S. R.L. de C.V.', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://espinosa-s-r-l-de-c-v.predicthealth.com', 'LIC-MX-HEAL-176', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('744b4a03-e575-4978-b10e-6c087c9e744b', 'Villarreal-Ocasio', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://villarreal-ocasio.predicthealth.com', 'LIC-MX-PREV-177', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('9a18b839-1b93-44fb-9d8a-2ea12388e887', 'Corporacin Carrasco y López', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://corporacin-carrasco-y-lopez.predicthealth.com', 'LIC-MX-HOSP-178', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('1d9a84f8-fd22-4249-9b25-36c1d2ecc71b', 'Cisneros-Concepción', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://cisneros-concepcion.predicthealth.com', 'LIC-MX-HOSP-179', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Jurado-Guardado', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://jurado-guardado.predicthealth.com', 'LIC-MX-PREV-180', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('eea6be20-e19f-485f-ab54-537a7c28245f', 'Club Pérez y Godoy', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://club-perez-y-godoy.predicthealth.com', 'LIC-MX-PREV-181', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('eb602cae-423a-455d-a22e-d47aea5eb650', 'de la Fuente-Arias', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://de-la-fuente-arias.predicthealth.com', 'LIC-MX-HOSP-182', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('bb17faca-a7b2-4de8-bf29-2fcb569ef554', 'Hernandes-Leiva S.A.', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://hernandes-leiva-s-a.predicthealth.com', 'LIC-MX-HEAL-183', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('44a33aab-1a23-4995-bd07-41f95b34fd57', 'Grupo Garza y Arellano', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://grupo-garza-y-arellano.predicthealth.com', 'LIC-MX-HEAL-184', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('5462455f-fbe3-44c8-b0d1-0644c433aca6', 'Laboratorios Navarrete-Anaya', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://laboratorios-navarrete-anaya.predicthealth.com', 'LIC-MX-PREV-185', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('d050617d-dc89-4f28-b546-9680dd1c5fad', 'Club Armas-Polanco', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://club-armas-polanco.predicthealth.com', 'LIC-MX-PREV-186', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('7227444e-b122-48f4-8f01-2cda439507b1', 'Olivera, Lovato y Saavedra', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://olivera-lovato-y-saavedra.predicthealth.com', 'LIC-MX-HEAL-187', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('d86c173a-8a1d-43b4-a0c1-c836afdc378b', 'Grupo Ochoa-Corrales', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://grupo-ochoa-corrales.predicthealth.com', 'LIC-MX-HOSP-188', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('fb0a848d-4d51-4416-86bc-e568f694f9e7', 'Bañuelos-Montaño', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://banuelos-montano.predicthealth.com', 'LIC-MX-PREV-189', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('ccccdffb-bc26-4d80-a590-0cd86dd5a1bc', 'Meléndez-Arriaga', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://melendez-arriaga.predicthealth.com', 'LIC-MX-HOSP-190', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('8cb48822-4d4c-42ed-af7f-737d3107b1db', 'Corporacin Menchaca y Salgado', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://corporacin-menchaca-y-salgado.predicthealth.com', 'LIC-MX-HOSP-191', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('700b8c76-7ad1-4453-9ce3-f598565c6452', 'Club Salcedo y Segura', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://club-salcedo-y-segura.predicthealth.com', 'LIC-MX-PREV-192', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('d3cb7dc8-9240-4800-a1d9-bf65c5dac801', 'Grupo Rosas, Mena y Sandoval', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://grupo-rosas-mena-y-sandoval.predicthealth.com', 'LIC-MX-HEAL-193', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('06c71356-e038-4c3d-bfea-7865acacb684', 'Club Otero, Valadez y Crespo', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://club-otero-valadez-y-crespo.predicthealth.com', 'LIC-MX-HOSP-194', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('30e2b2ec-9553-454e-92a4-c1dc89609cbb', 'Industrias Esquibel, Mesa y Valle', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://industrias-esquibel-mesa-y-valle.predicthealth.com', 'LIC-MX-HOSP-195', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('2eead5aa-095b-418a-bd02-e3a917971887', 'Calvillo y Benavides A.C.', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://calvillo-y-benavides-a-c.predicthealth.com', 'LIC-MX-PREV-196', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('05afd7e1-bb93-4c83-90a7-48a65b6e7598', 'Industrias Ledesma, Jurado y Pantoja', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://industrias-ledesma-jurado-y-pantoja.predicthealth.com', 'LIC-MX-PREV-197', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', 'Cervantes-Peralta', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://cervantes-peralta.predicthealth.com', 'LIC-MX-HEAL-198', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('454f4ba6-cb6d-4f27-9d76-08f5b358b484', 'Rico y Escobar S.A.', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://rico-y-escobar-s-a.predicthealth.com', 'LIC-MX-PREV-199', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES ('389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282', 'Báez-Viera S.A.', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://baez-viera-s-a.predicthealth.com', 'LIC-MX-PREV-200', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

-- =============================================
-- DOCTORS (100)
-- =============================================

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7', '5da54d5d-de0c-4277-a43e-6a89f987e77c', 'María José', 'Rosales', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-101', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 10, 1820.5484694501044, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('3e5b08ed-529d-45f0-8145-8371609882c1', '3cf42c93-4941-4d8d-8656-aafa9e987177', 'Sessa', 'Irizarry', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-102', (SELECT id FROM doctor_specialties WHERE name = 'Emergency Medicine'), 25, 1798.9133008410108, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('57031194-3c31-4320-86c4-fd370789efac', '9b581d3c-9e93-4f39-80bb-294752065866', 'Indira', 'Olmos', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-103', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 1, 1069.560705370771, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('dc42b779-4b49-418b-ab0a-92caa2a8d6de', '5da54d5d-de0c-4277-a43e-6a89f987e77c', 'Perla', 'Zavala', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-104', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 28, 1531.1141247992014, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('14abdfde-e4c9-460c-9ce2-17886600b20d', 'ad2c792b-5015-4238-b221-fa28e8b061fc', 'Fidel', 'Urbina', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-105', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 26, 697.261665017979, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('df863eba-f0b8-4b1a-bdd1-71ed2f816ed7', '83b74179-f6ef-4219-bc70-c93f4393a350', 'Rebeca', 'Paredes', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-106', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 20, 1414.439841743252, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('ba712fc8-c4d2-4e22-ae18-1991c46bc85d', '0d826581-b9d8-4828-8848-9332fe38d169', 'Mario', 'Gaona', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-107', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 14, 1780.5471612352076, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('bbf715a1-3947-4642-a67a-b5c4c0c085d2', '68f1a02a-d348-4d1e-99ee-733d832a3f43', 'Luis', 'Ceja', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-108', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 17, 1885.3725276791888, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec', '0d826581-b9d8-4828-8848-9332fe38d169', 'Sergio', 'Guevara', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-109', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 30, 1672.310583180069, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('0fbbaab0-2284-4ac6-b1c9-498b5b3c4567', 'a074c3ea-f255-4cf2-ae3f-727f9186be3c', 'Natalia', 'Barrientos', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-110', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 19, 1647.399458521279, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('b6994d45-b80e-4260-834c-facdf3ea8eee', '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282', 'Berta', 'Rincón', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-111', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 13, 1974.6457673143727, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('f7cdc060-94e6-47ad-90e9-939ed86fb6da', '89ab21cf-089e-4210-8e29-269dfbd38d71', 'Lorenzo', 'Rivera', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-112', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 29, 916.1068967773256, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('23785934-fbf0-442c-add3-05df84fa5d17', 'ad2c792b-5015-4238-b221-fa28e8b061fc', 'Omar', 'Trujillo', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-113', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 30, 1832.72622190695, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('bf7a015c-1589-42b3-b1e8-103fcbc0b041', '47393461-e570-448b-82b1-1cef15441262', 'Elvira', 'Ochoa', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-114', (SELECT id FROM doctor_specialties WHERE name = 'Emergency Medicine'), 12, 1892.7239747524109, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('4fa9d0ff-2c51-4918-b48a-b5cb37d444a3', '8fd698b3-084d-4248-a28e-2708a5862e27', 'Natalia', 'Murillo', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-115', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 5, 1636.8174507122815, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('93dbdfc0-e05c-4eb6-975c-360eb8d293c1', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Pedro', 'Valdés', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-116', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 14, 1298.7791626648886, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('a6db1b41-d601-4840-99e9-3d7d18901399', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', 'Eugenio', 'Uribe', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-117', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 7, 1825.6575375584948, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('d5e98ce0-e6f8-4577-a0dd-3281aa303b32', 'eb602cae-423a-455d-a22e-d47aea5eb650', 'Linda', 'Trejo', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-118', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 13, 741.4549406100004, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('44da48b1-6ff6-4db9-9de5-34e22de0429a', '700b8c76-7ad1-4453-9ce3-f598565c6452', 'Susana', 'Acosta', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-119', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 25, 1864.4664473162245, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('3fafc20d-72d5-4633-95a0-df6b9ed175b6', '2eead5aa-095b-418a-bd02-e3a917971887', 'Rodrigo', 'Mota', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-120', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 6, 877.3693189815785, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('c4fac110-0b61-4fb0-943d-0d00af7ed0cd', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Linda', 'Magaña', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-121', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 18, 832.6172910698294, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('88870e4f-1333-4bcc-8daf-c8743d61f3cb', 'a074c3ea-f255-4cf2-ae3f-727f9186be3c', 'José Luis', 'Rubio', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-122', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 16, 973.8751107618863, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('6f035f60-87f7-4a9c-9501-4b8704facba3', '50503414-ca6d-4c1a-a34f-18719e2fd555', 'Concepción', 'Barajas', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-123', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 8, 1198.2611367004054, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('58a814d3-a275-436b-8e5c-4e743fed242f', 'a074c3ea-f255-4cf2-ae3f-727f9186be3c', 'Débora', 'Delgadillo', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-124', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 21, 1409.058033155979, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('f67c2f76-9bf1-43e4-8d0e-c0a94298f35b', '5462455f-fbe3-44c8-b0d1-0644c433aca6', 'Augusto', 'Roque', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-125', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 29, 1678.5856766823106, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('fb4d84a0-7bc1-4815-b7a3-b1719c616c79', 'bb17faca-a7b2-4de8-bf29-2fcb569ef554', 'Francisca', 'Garay', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-126', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 20, 1781.097848848585, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('c0bdb808-eb5f-479f-9261-dbbf9ff031a6', 'cc46221e-f387-463c-9d11-9464d8209f7b', 'Judith', 'Sevilla', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-127', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 14, 1626.9701822694929, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('f501d643-d308-41e0-8ffc-8bfb52d64e13', 'a725b15f-039b-4256-843a-51a2968633fd', 'Nelly', 'Robles', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-128', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 26, 1234.8688013998544, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('adeb74f6-f3dc-43a7-a841-6d24aba046ba', 'ad2c792b-5015-4238-b221-fa28e8b061fc', 'Soledad', 'Noriega', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-129', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 15, 614.0556557742492, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('dd24da99-43c7-4d6b-acc0-32fc0c237d02', 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf', 'Silvano', 'Espinosa', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-130', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 20, 744.1878645102779, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('0408b031-caa3-4b7c-ae65-d05342cf5c05', '8be78aaa-c408-452e-bf01-8e831ab5c63a', 'Fabiola', 'Saavedra', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-131', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 17, 857.0255377052487, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('a865edbe-d50c-4bd1-b556-ae32d9d1858c', '50503414-ca6d-4c1a-a34f-18719e2fd555', 'Silvia', 'Enríquez', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-132', (SELECT id FROM doctor_specialties WHERE name = 'Emergency Medicine'), 7, 944.9610992661446, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('2a0aaddd-ea43-40bb-b5df-877b1b0d20f1', '43dee983-676a-4e33-a6b0-f0a72f46d06c', 'Maximiliano', 'Segura', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-133', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 27, 1874.870767908305, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('4754ba59-3dc1-4be2-a770-44d7c34184bc', '05afd7e1-bb93-4c83-90a7-48a65b6e7598', 'José María', 'Serna', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-134', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 16, 1820.900979573417, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('16e23379-6774-417d-8104-a8e6f4712909', 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0', 'Eugenio', 'Gastélum', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-135', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 17, 1855.569931759183, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('07527c1a-efd5-45e4-a0d9-01ba5207bb2f', 'ad2c792b-5015-4238-b221-fa28e8b061fc', 'Eva', 'Cotto', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-136', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 22, 1272.3970969346597, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('c186d1ad-fcba-4f6e-acd7-86cb4c09938e', '700b8c76-7ad1-4453-9ce3-f598565c6452', 'Indira', 'Ramón', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-137', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 3, 680.6636223483489, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('4cecebec-e16f-4949-a18b-8bfebae86618', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Patricia', 'Angulo', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-138', (SELECT id FROM doctor_specialties WHERE name = 'Emergency Medicine'), 15, 1658.5175815606315, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('6d21a37a-43d8-440b-bc64-87bb0ae1d45d', '46af545e-6db8-44ba-a7f9-9fd9617f4a09', 'Helena', 'Valladares', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-139', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 26, 697.985685551003, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('4d75aae7-5d33-44ad-a297-a32ff407415d', '0e3821a8-80d6-4fa9-8313-3ed45b83c28b', 'Rubén', 'Pacheco', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-140', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 29, 1120.373107716658, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('e901dbc1-3eed-4e5e-b23c-58d808477e33', 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75', 'Samuel', 'Garibay', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-141', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 12, 757.934370066895, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('61bb20b9-7520-42be-accf-743c84a0b934', '8cb48822-4d4c-42ed-af7f-737d3107b1db', 'Joaquín', 'Vigil', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-142', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 14, 648.1805011556503, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('b5a04df6-baea-460f-a946-f7b7606c9982', 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf', 'Amador', 'Arenas', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-143', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 17, 1537.6586609408932, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('c1182c2e-0624-42f9-aef6-7e7a1a2b7dba', '8fb0899c-732e-4f03-8209-d52ef41a6a76', 'Felipe', 'Hidalgo', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-144', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 7, 1248.4878410840688, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('0b238725-a392-4fbb-956b-0f71e15bc6da', '700b8c76-7ad1-4453-9ce3-f598565c6452', 'María Teresa', 'Baca', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-145', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 24, 1022.8427857194084, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('63ec3e7d-b8e4-4988-9bc3-5b655f830e31', '7227444e-b122-48f4-8f01-2cda439507b1', 'Miguel Ángel', 'Pérez', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-146', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 28, 1371.0499674439768, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('d4df85ce-6d2b-46c9-b9cd-48b2490b3c88', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Jonás', 'Madera', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-147', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 23, 1660.901175306237, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('71618fe0-25a1-4281-98af-51797de3ae0a', '33ba98b9-c46a-47c1-b266-d8a4fe557290', 'Arcelia', 'de la Rosa', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-148', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 6, 1875.0695339692652, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('389524b6-608c-4b31-affa-305b79635816', '7227444e-b122-48f4-8f01-2cda439507b1', 'Esther', 'Echeverría', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-149', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 5, 1393.8138741980008, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('c0356e82-1510-4557-b654-cf84ac13f425', 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0', 'Sofía', 'Montez', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-150', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 12, 634.1185926393296, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('ce44b08f-7dae-4844-ae53-e01ac2f28f45', '36983990-abe8-4f1c-9c1b-863b9cab3ca9', 'Débora', 'Segura', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-151', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 6, 901.1910717691768, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('9c9838c2-4464-4fbb-bc22-8f4ac64b4efe', 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca', 'Luis Miguel', 'Villarreal', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-152', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 30, 1214.4224692017738, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('e8db5b49-5605-41e5-91f2-d456b68c5ade', '373769ab-b720-4269-bfb9-02546401ce99', 'Esmeralda', 'Parra', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-153', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 30, 1387.666261369931, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('96d6da02-ca2f-4ace-b239-4584544e8230', 'd471d2d1-66a1-4de0-8754-127059786888', 'Patricia', 'Téllez', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-154', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 19, 1152.6209654049749, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('38bf2ce6-5014-4bc1-8e32-9b9257eea501', '373769ab-b720-4269-bfb9-02546401ce99', 'Timoteo', 'Tafoya', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-155', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 26, 1812.8749645467972, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c', 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca', 'Amanda', 'Ferrer', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-156', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 20, 1872.6512937695736, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('8ce8b684-8f8d-4828-987d-389dfe64afd1', '5da54d5d-de0c-4277-a43e-6a89f987e77c', 'Caridad', 'Villa', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-157', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 12, 1196.9624788775964, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('ca8bf565-35d3-40f3-b741-603201f6f072', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Héctor', 'Castro', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-158', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 30, 891.6219728357532, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('2937cc2f-22b7-4488-b9f8-a0795800a840', '16b25a77-b84a-44ac-8540-c5bfa9b3b6b0', 'Abraham', 'Rodarte', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-159', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 2, 825.9224314015128, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('f8a511e3-b97b-4d17-8240-46520497ef7c', '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0', 'Gloria', 'Briones', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-160', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 4, 1758.2806029243852, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('879bcb9a-8520-4d02-b12b-ba5afa629d41', '1926fa2a-dab7-420e-861b-c2b6dfe0174e', 'José Luis', 'Bahena', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-161', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 28, 820.5122633755898, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('7817761a-e7c5-47cb-a260-7e243c11ef2f', 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa', 'Daniela', 'Laboy', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-162', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 30, 507.88118453431844, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('48384f36-0b57-4943-899f-cbffd4ec37b6', '9b581d3c-9e93-4f39-80bb-294752065866', 'Bruno', 'Ledesma', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-163', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 13, 528.5508530663591, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('0fc70684-777f-43eb-895d-9cb90ce0f584', 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42', 'Noelia', 'Garica', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-164', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 29, 1697.0956452210535, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('a849f14b-3741-4e38-9dfb-6cc7d46265e8', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Mitzy', 'Godoy', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-165', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 4, 1814.1177404590908, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('22128ae9-ba6e-4e99-821a-dc445e76d641', '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d', 'Sessa', 'Medina', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-166', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 9, 1929.1404464945394, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('6c711a31-c752-44f2-b6cb-480f9bf6af1f', '30e2b2ec-9553-454e-92a4-c1dc89609cbb', 'Mitzy', 'Aguayo', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-167', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 4, 1203.758305535247, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('ab923e2e-5d13-41e4-9c73-2f62cca0699d', '4bfa1a0a-0434-45e0-b454-03140b992f53', 'Patricio', 'Monroy', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-168', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 21, 1859.793221410492, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('a7f19796-4c62-4a2b-82de-7c2677804e6a', '3d7c5771-0692-4a2f-a4c6-6af2b561282b', 'Homero', 'Valentín', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-169', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 2, 1371.4640268746211, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('28958f29-28c6-405a-acf5-949ffcaec286', 'c9014e88-309c-4cb0-a28d-25b510e1e522', 'Porfirio', 'Farías', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-170', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 2, 1259.8622465078256, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('472116b5-933e-4f63-b3ca-e8c8f5d30bb4', 'f4764cd3-47e9-4408-b0ee-9b9001c5459d', 'Gonzalo', 'Cortés', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-171', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 15, 827.5293947075577, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('a2beaa02-c033-4e45-b702-305d5ce41e34', '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d', 'Marisol', 'Tello', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-172', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 17, 1962.8081006469422, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('5879ec30-c291-476d-a48c-284fadf5f98a', '8be78aaa-c408-452e-bf01-8e831ab5c63a', 'Mateo', 'Serrato', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-173', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 27, 674.2716422392414, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('d512bd88-12a3-45f9-85e8-14fb3cb5a6e1', 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca', 'Reina', 'Camacho', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-174', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 19, 1833.4599928809907, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('757d6edf-5aa8-461b-ac4f-9e8365017424', '7227444e-b122-48f4-8f01-2cda439507b1', 'Homero', 'Rodarte', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-175', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 7, 1374.1699488498052, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('c0d54a00-2ee9-4827-a7fb-6196ef15bdee', '66e6aa6c-596c-442e-85fb-b143875d0dfc', 'Martín', 'Treviño', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-176', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 30, 1365.0683761329578, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('a7ada88a-7935-4dd5-8a4f-935c4b7c0bab', '0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d', 'Wilfrido', 'Salazar', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-177', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 10, 754.3240987284792, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('4664d394-c950-4dbf-9b40-7b34c6d6dabb', '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a', 'Uriel', 'Velázquez', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-178', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 20, 616.0168420164408, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('c16b254c-dcf7-4a31-a101-1ed86b62477e', '36983990-abe8-4f1c-9c1b-863b9cab3ca9', 'Jos', 'Briones', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-179', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 12, 1127.8215040274422, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('e0926c16-7f63-41ae-a091-1d0688c88322', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', 'David', 'Domínguez', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-180', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 28, 1258.2912005630676, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('250b33c9-1ba3-44e6-9c35-cde7000d6d53', 'c0595f94-c8f4-413c-a05c-7cfca773563c', 'Adán', 'Ferrer', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-181', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 5, 818.207205039145, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('b6c86aef-75e2-4c64-bceb-e7de898b5a1b', '1fec9665-52bc-49a7-b028-f0d78440463c', 'Irene', 'Cisneros', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-182', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 16, 674.6942758815503, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('a3fb2dae-2a69-434f-86a9-65ae48c8f690', '89ab21cf-089e-4210-8e29-269dfbd38d71', 'Alta  Gracia', 'Orellana', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-183', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 9, 1767.8945606153254, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('820c1228-3d2d-4766-900f-32940f14e74b', '9c8636c9-015b-4c18-a641-f5da698b6fd8', 'Cristal', 'Balderas', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-184', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 11, 1500.667748378782, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('da3dbacf-8df0-46cf-bbef-b51615063a9b', '89ab21cf-089e-4210-8e29-269dfbd38d71', 'Marisol', 'Ulloa', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-185', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 27, 609.921900557382, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('e6ce6823-6c4d-4ead-98d7-78b94483fe2c', 'fb0a848d-4d51-4416-86bc-e568f694f9e7', 'Alfonso', 'Cazares', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-186', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 3, 508.0963785095697, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('84cb6703-edfc-4180-9f80-619064c9684e', 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75', 'Elisa', 'Oquendo', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-187', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 3, 1404.8470815409128, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('21e4d7a9-73dc-4156-b413-b389c2e92a0d', '163749fb-8b46-4447-a8b7-95b4a59531b6', 'Silvano', 'Brito', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-188', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 1, 745.4792217824033, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('85eb8041-b502-4b90-b586-c7c4593b5347', 'cc46221e-f387-463c-9d11-9464d8209f7b', 'Úrsula', 'Casares', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-189', (SELECT id FROM doctor_specialties WHERE name = 'Diabetes Management'), 4, 1103.2367663731668, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9', 'fb0a848d-4d51-4416-86bc-e568f694f9e7', 'Marcela', 'Corona', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-190', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 3, 622.5874729820757, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('22d570dd-a72e-4599-8f13-df952d35d616', 'a5b1202a-9112-404b-b7de-ddf0f62711f8', 'Catalina', 'Orta', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-191', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine'), 24, 1502.1926942789607, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('04a9b2e7-638b-4fe0-a106-16b582d946ab', 'cc46221e-f387-463c-9d11-9464d8209f7b', 'René', 'Morales', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-192', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 12, 1098.577928061714, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('03e547d1-325a-46ea-bc94-c188abf53f0f', '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b', 'Benjamín', 'Leal', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-193', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 27, 1300.8891221618808, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('5a6de593-99b5-4942-a379-fd21b2a4999f', '744b4a03-e575-4978-b10e-6c087c9e744b', 'Catalina', 'Alarcón', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-194', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 24, 1866.112430681261, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('b7dd043b-953f-4e04-8a80-1c613d3c6675', '8be78aaa-c408-452e-bf01-8e831ab5c63a', 'Pedro', 'Riojas', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-195', (SELECT id FROM doctor_specialties WHERE name = 'Emergency Medicine'), 17, 531.7101560012575, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('852beb97-3c99-4391-879f-98f0c2154c20', '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d', 'Olivia', 'Nieto', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-196', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology'), 12, 957.5749254434024, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('86bb4262-7a96-444b-a096-d3a1bd7782e7', '8cb48822-4d4c-42ed-af7f-737d3107b1db', 'Victoria', 'Corona', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-197', (SELECT id FROM doctor_specialties WHERE name = 'General Medicine'), 8, 616.9319870768871, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('b441c98a-1075-4013-9fc2-9242d910713f', 'a670c73c-cc47-42fe-88c9-0fa37359779b', 'Daniela', 'Gallegos', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-198', (SELECT id FROM doctor_specialties WHERE name = 'Preventive Medicine'), 9, 1952.603299811138, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('77486cf8-54d8-4120-856f-642ebae74d48', 'd56e3cb0-d9e2-48fc-9c16-c4a96b90c00f', 'Victoria', 'Urbina', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-199', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology'), 2, 1771.212990072843, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES ('0e2fa589-05b2-402c-9722-1022a0121b04', '44a33aab-1a23-4995-bd07-41f95b34fd57', 'Leonardo', 'Aguirre', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-200', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine'), 29, 512.368971988745, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

-- =============================================
-- PATIENTS (100)
-- =============================================

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', '0408b031-caa3-4b7c-ae65-d05342cf5c05', '7a6ce151-14b5-4d12-b6bb-1fba18636353', 'Linda', 'Nájera', '1967-11-10', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Mariano Munguia Romero', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c', 'b6c86aef-75e2-4c64-bceb-e7de898b5a1b', 'a725b15f-039b-4256-843a-51a2968633fd', 'Marisela', 'Rocha', '1971-08-16', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Oswaldo Montoya', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('959aa1dd-346b-4542-8f99-0d5e75301249', 'b5a04df6-baea-460f-a946-f7b7606c9982', '83b74179-f6ef-4219-bc70-c93f4393a350', 'Homero', 'Miranda', '1976-02-23', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Genaro Arredondo Mota', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('59402562-ce5f-450e-8e6c-9630514fe164', '4664d394-c950-4dbf-9b40-7b34c6d6dabb', '81941e1d-820a-4313-8177-e44278d9a981', 'Manuel', 'Vela', '1989-09-27', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Dr. Yuridia Galvez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('f81c87d6-32f1-4c79-993a-18db4734ef65', 'f7cdc060-94e6-47ad-90e9-939ed86fb6da', 'd050617d-dc89-4f28-b546-9680dd1c5fad', 'Paulina', 'Cervántez', '1975-03-12', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Timoteo Arredondo Corral', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('0b6b8229-4027-4ec7-8bce-c805de96ced3', 'ca8bf565-35d3-40f3-b741-603201f6f072', 'f1ab98f4-98de-420f-9c4b-c31eee92df21', 'Benjamín', 'Serna', '1972-08-13', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Silvia Jose Luis Flores Alcaraz', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', '820c1228-3d2d-4766-900f-32940f14e74b', '9c8636c9-015b-4c18-a641-f5da698b6fd8', 'Rosa', 'Gálvez', '1962-06-23', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Ilse Jeronimo de Leon', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 'a2beaa02-c033-4e45-b702-305d5ce41e34', '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b', 'Nelly', 'Montemayor', '1991-08-01', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Adalberto Saldivar Curiel', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 'c1182c2e-0624-42f9-aef6-7e7a1a2b7dba', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Rolando', 'Jaimes', '1994-12-27', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Antonia Patricio Roldan', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('cd0c2f0c-de08-439c-93c9-0feab1d433cc', '0e2fa589-05b2-402c-9722-1022a0121b04', 'ad2c792b-5015-4238-b221-fa28e8b061fc', 'Bruno', 'Ureña', '1966-01-16', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Ursula Patricio Madrid', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', '0fbbaab0-2284-4ac6-b1c9-498b5b3c4567', 'a074c3ea-f255-4cf2-ae3f-727f9186be3c', 'Luis Manuel', 'Morales', '1956-10-02', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Alfredo Abril Matos', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('7893292b-965a-41da-896a-d0780c91fdd5', '5a6de593-99b5-4942-a379-fd21b2a4999f', 'cc46221e-f387-463c-9d11-9464d8209f7b', 'David', 'Benavídez', '1953-01-17', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Debora Elias Guerra', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('87fb3c88-6653-45db-aa6c-20ea7512da64', 'a2beaa02-c033-4e45-b702-305d5ce41e34', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', 'Clara', 'Pelayo', '1954-12-26', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Benito Arredondo Venegas', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 'bbf715a1-3947-4642-a67a-b5c4c0c085d2', '08a7fe9e-c043-4fed-89e4-93a416a20089', 'Santiago', 'Armendáriz', '2001-01-02', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Ing. Beatriz Concepcion', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('43756f6c-c157-4a44-9c84-ab2d62fddcf7', '93dbdfc0-e05c-4eb6-975c-360eb8d293c1', 'a670c73c-cc47-42fe-88c9-0fa37359779b', 'Carlos', 'Menchaca', '1949-07-12', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Ofelia Rufino Cadena Amaya', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('d8e1fa52-0a65-4917-b410-2954e05a34e5', '472116b5-933e-4f63-b3ca-e8c8f5d30bb4', '30e2b2ec-9553-454e-92a4-c1dc89609cbb', 'Manuel', 'Gracia', '1978-11-21', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Miguel Angel Vicente Mondragon Segura', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('bbc67f38-a9eb-4379-aeaf-1560af0d1a34', '4664d394-c950-4dbf-9b40-7b34c6d6dabb', '43dee983-676a-4e33-a6b0-f0a72f46d06c', 'Jos', 'Perea', '2000-04-29', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Augusto Navarro', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e', '38bf2ce6-5014-4bc1-8e32-9b9257eea501', '7227444e-b122-48f4-8f01-2cda439507b1', 'Esparta', 'Franco', '1987-01-26', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Maria Ignacio Ruiz', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('309df411-1d1a-4d00-a34e-36e8c32da210', '2a0aaddd-ea43-40bb-b5df-877b1b0d20f1', '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a', 'José Luis', 'Miramontes', '1951-01-12', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Zacarias Arcelia Orozco del Valle', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('663d036b-a19b-4557-af37-d68a9ce4976d', 'ba712fc8-c4d2-4e22-ae18-1991c46bc85d', 'cc46221e-f387-463c-9d11-9464d8209f7b', 'Amalia', 'Arenas', '1975-03-31', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Ing. Ofelia Duenas', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('a754cbf1-a4ca-42dc-92c4-d980b6a25a6d', '71618fe0-25a1-4281-98af-51797de3ae0a', '3cf42c93-4941-4d8d-8656-aafa9e987177', 'Angélica', 'Serrato', '1960-12-06', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Virginia Cristina Navarro Carbajal', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', '3fafc20d-72d5-4633-95a0-df6b9ed175b6', '5462455f-fbe3-44c8-b0d1-0644c433aca6', 'Pascual', 'Barragán', '1977-05-01', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Minerva Otero', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('6661483b-705b-412a-8bbd-39c0af0dadb1', '4cecebec-e16f-4949-a18b-8bfebae86618', '9a18b839-1b93-44fb-9d8a-2ea12388e887', 'Jesús', 'Abreu', '1955-05-22', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Abel Avalos', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('676491c4-f31a-42b6-a991-a8dd09bbb1f0', '85eb8041-b502-4b90-b586-c7c4593b5347', '6297ae0f-7fee-472d-87ec-e22b87ce6ffb', 'Víctor', 'Espinosa', '1988-08-16', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Carlota Luz Sanchez Velez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('3a9e8e0e-6367-409d-a81c-9852069c710e', '06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7', 'e040eabc-0ac9-47f7-89ae-24246e1c12dd', 'María José', 'Villaseñor', '1949-11-30', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Linda Loera Cepeda', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('167dedde-166c-45e4-befc-4f1c9b7184ad', 'a7f19796-4c62-4a2b-82de-7c2677804e6a', '744b4a03-e575-4978-b10e-6c087c9e744b', 'Camilo', 'Villa', '1998-07-21', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Anel Esther Corona Benavides', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('72eca572-4ecf-4be8-906b-40e89e0d9a08', 'e8db5b49-5605-41e5-91f2-d456b68c5ade', 'a670c73c-cc47-42fe-88c9-0fa37359779b', 'Mario', 'Santillán', '1966-11-18', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Abraham Jasso', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', '4d75aae7-5d33-44ad-a297-a32ff407415d', 'c9014e88-309c-4cb0-a28d-25b510e1e522', 'Cristobal', 'Páez', '1961-12-17', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Sr(a). Anabel Tejeda', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', '07527c1a-efd5-45e4-a0d9-01ba5207bb2f', '44a33aab-1a23-4995-bd07-41f95b34fd57', 'Celia', 'Olivo', '1961-08-18', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Rebeca Saavedra', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('9f86a53f-f0e1-446d-89f0-86b086dd12a9', 'e0926c16-7f63-41ae-a091-1d0688c88322', '83b74179-f6ef-4219-bc70-c93f4393a350', 'Teresa', 'Arguello', '1949-12-23', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Leonel Veronica Pena', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('ae1f5c92-f3cf-43d8-918f-aaad6fb46c05', 'e0926c16-7f63-41ae-a091-1d0688c88322', '2040ac28-7210-4fbd-9716-53872211bcd9', 'Pilar', 'Valle', '1981-10-06', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Emilia Torrez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', '8ce8b684-8f8d-4828-987d-389dfe64afd1', '0d826581-b9d8-4828-8848-9332fe38d169', 'Eva', 'Orellana', '1988-03-24', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Ing. Emiliano Baca', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('7f839ee8-bdd6-4a63-83e8-30db007565e2', '4d75aae7-5d33-44ad-a297-a32ff407415d', '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0', 'Rafaél', 'Olvera', '1946-10-16', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Graciela Abril Robles Ulibarri', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('67aa999f-9d31-4b61-a097-35097ea0d082', '0fc70684-777f-43eb-895d-9cb90ce0f584', '4bfa1a0a-0434-45e0-b454-03140b992f53', 'Anel', 'Baeza', '1997-09-03', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Esteban Irizarry Torrez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('41aa2fbc-8ef4-4448-8686-399a1cd54be9', 'd512bd88-12a3-45f9-85e8-14fb3cb5a6e1', '5da54d5d-de0c-4277-a43e-6a89f987e77c', 'Jesús', 'Negrón', '1966-09-21', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Dr. Jeronimo Rico', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('111769f3-1a1b-44a9-9670-f4f2e424d1d2', '38bf2ce6-5014-4bc1-8e32-9b9257eea501', 'd050617d-dc89-4f28-b546-9680dd1c5fad', 'Asunción', 'Ybarra', '2000-01-06', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Nelly Jonas Urbina', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', '63ec3e7d-b8e4-4988-9bc3-5b655f830e31', '9b581d3c-9e93-4f39-80bb-294752065866', 'Roberto', 'Varela', '1961-07-16', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Juan Carlos Veronica Menendez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('6a8b6d41-8d20-4bc5-8d48-538d348f6086', '757d6edf-5aa8-461b-ac4f-9e8365017424', '0b2f4464-5141-44a3-a26d-f8acc1fb955e', 'Alejandra', 'Acosta', '1950-08-04', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Sonia Calderon', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', '2a0aaddd-ea43-40bb-b5df-877b1b0d20f1', '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a', 'Minerva', 'Ortiz', '1985-03-08', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Abril Pascual Segura Avila', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', '58a814d3-a275-436b-8e5c-4e743fed242f', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'Amanda', 'Menéndez', '1966-02-13', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Andrea Hilda Esparza Rivero', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 'ab923e2e-5d13-41e4-9c73-2f62cca0699d', '54481b92-e5f5-421b-ba21-89bf520a2d87', 'Hermelinda', 'Medrano', '1970-06-28', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Benito Octavio Villarreal Aponte', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('edb1d693-b308-4ff6-8fd4-9e20561317e8', '16e23379-6774-417d-8104-a8e6f4712909', '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a', 'Alonso', 'Roldán', '1960-01-13', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Jesus Rosa Matos Vanegas', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('9511f9b9-a450-489c-92b9-ac306733cee4', '0408b031-caa3-4b7c-ae65-d05342cf5c05', '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d', 'Alma', 'Sosa', '2001-12-10', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Barbara Estela Martinez Anguiano', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', '96d6da02-ca2f-4ace-b239-4584544e8230', '3cf42c93-4941-4d8d-8656-aafa9e987177', 'Estela', 'Lucero', '1979-10-25', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Angel Gaona Flores', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', '0e2fa589-05b2-402c-9722-1022a0121b04', 'a725b15f-039b-4256-843a-51a2968633fd', 'Gonzalo', 'Laureano', '1979-09-02', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Virginia Garibay Romero', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', '96d6da02-ca2f-4ace-b239-4584544e8230', '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282', 'Helena', 'Muro', '1973-10-22', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Isaac Ignacio Samaniego', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', '22d570dd-a72e-4599-8f13-df952d35d616', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', 'Adela', 'Vergara', '1991-10-16', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Maximiliano Villa', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', '44da48b1-6ff6-4db9-9de5-34e22de0429a', '3d7c5771-0692-4a2f-a4c6-6af2b561282b', 'Salma', 'Almaraz', '1994-03-16', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Alonso Raul Serrato Palacios', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', 'f501d643-d308-41e0-8ffc-8bfb52d64e13', '05afd7e1-bb93-4c83-90a7-48a65b6e7598', 'Humberto', 'Caraballo', '1946-08-05', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Micaela Maria del Carmen Villanueva Florez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 'e6ce6823-6c4d-4ead-98d7-78b94483fe2c', '163749fb-8b46-4447-a8b7-95b4a59531b6', 'Mauricio', 'Zavala', '1997-06-08', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Maria Elena Calderon Munoz', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('05bc2942-e676-42e9-ad01-ade9f7cc5aee', 'c4fac110-0b61-4fb0-943d-0d00af7ed0cd', 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42', 'Roberto', 'Alejandro', '1960-11-23', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Magdalena Mercedes Sauceda', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('c78e7658-d517-4ca1-990b-e6971f8d108f', 'a3fb2dae-2a69-434f-86a9-65ae48c8f690', 'ac6f8f54-21c8-475b-bea6-19e31643392d', 'Víctor', 'Gutiérrez', '1983-10-12', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Mayte Partida Lemus', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('65474c27-8f72-4690-8f19-df9344e4be5e', '3fafc20d-72d5-4633-95a0-df6b9ed175b6', 'a14c189c-ee90-4c29-b465-63d43a9d0010', 'Adán', 'Nava', '2000-03-28', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Cristal Adan Murillo Briones', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 'c1182c2e-0624-42f9-aef6-7e7a1a2b7dba', '8e889f63-2c86-44ab-959f-fdc365353d5d', 'Amador', 'Cano', '1995-01-25', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Claudia Hector Zelaya Jaimes', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3', '0408b031-caa3-4b7c-ae65-d05342cf5c05', '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0', 'Alfonso', 'Prado', '1955-01-12', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Mtro. Renato Galarza', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 'a6db1b41-d601-4840-99e9-3d7d18901399', '8e889f63-2c86-44ab-959f-fdc365353d5d', 'Uriel', 'Suárez', '1972-06-25', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Luisa Alvarez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('c572a4c7-e475-4d18-85da-417abcd00903', '852beb97-3c99-4391-879f-98f0c2154c20', '36983990-abe8-4f1c-9c1b-863b9cab3ca9', 'Armando', 'Porras', '1954-05-14', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Humberto Esther Quesada', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3', 'a7f19796-4c62-4a2b-82de-7c2677804e6a', 'c0595f94-c8f4-413c-a05c-7cfca773563c', 'Teresa', 'Granado', '1953-03-03', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Cristobal Miguel Fernandez Saavedra', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('9b02d89c-2c5b-4c51-8183-15ccd1184990', 'e8db5b49-5605-41e5-91f2-d456b68c5ade', '46af545e-6db8-44ba-a7f9-9fd9617f4a09', 'Marcela', 'Fernández', '1981-09-04', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Gloria Aurora Lozano Rincon', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('43ae2e81-ac13-40ac-949c-9e4f51d76098', '0fc70684-777f-43eb-895d-9cb90ce0f584', 'd471d2d1-66a1-4de0-8754-127059786888', 'Sergio', 'Loya', '1970-04-10', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Marco Antonio Geronimo Collazo Reyna', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('49a18092-8f90-4f6b-873c-8715b64b8aff', 'bbf715a1-3947-4642-a67a-b5c4c0c085d2', 'be133600-848e-400b-9bc8-c52a4f3cf10d', 'Jorge Luis', 'Molina', '1953-02-05', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Emilio Romo', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('c9a949e5-e650-4d95-9e2e-49ed06e5d087', '84cb6703-edfc-4180-9f80-619064c9684e', 'e040eabc-0ac9-47f7-89ae-24246e1c12dd', 'Elvira', 'Echeverría', '1970-05-24', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Sessa Conchita de la Torre', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('a4e5cbb3-36f7-43d8-a65a-e30fc1361e56', '85eb8041-b502-4b90-b586-c7c4593b5347', '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b', 'Federico', 'Fajardo', '1949-06-14', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Guillermina Llamas', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('447e48dc-861c-41e6-920e-a2dec785101f', '86bb4262-7a96-444b-a096-d3a1bd7782e7', '8cb48822-4d4c-42ed-af7f-737d3107b1db', 'Elena', 'Quintanilla', '1979-01-02', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Micaela Fernando Ledesma', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('3a535951-40fd-4959-a34e-07b29f675ecc', 'e8db5b49-5605-41e5-91f2-d456b68c5ade', '3d521bc9-692d-4a0d-a3d7-80e816b86374', 'Cynthia', 'Jurado', '1991-03-08', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Nicolas Espartaco Castellanos Mireles', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70', 'c186d1ad-fcba-4f6e-acd7-86cb4c09938e', '47393461-e570-448b-82b1-1cef15441262', 'Juana', 'Gurule', '1993-03-05', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Yolanda Oscar Mendoza', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('6052a417-6725-4fab-b7dd-7f498454cd47', '85eb8041-b502-4b90-b586-c7c4593b5347', 'ac6f8f54-21c8-475b-bea6-19e31643392d', 'Lilia', 'Mesa', '1956-01-07', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Federico Perla Mendoza Flores', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', '93dbdfc0-e05c-4eb6-975c-360eb8d293c1', 'ad2c792b-5015-4238-b221-fa28e8b061fc', 'Octavio', 'Gurule', '2004-06-28', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Luis Miguel Ceballos Pantoja', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('cbd398cc-dfde-41c4-b7b1-ca32cc99945f', '06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7', 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc', 'Reina', 'Rangel', '1975-04-17', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Enrique Padron Cavazos', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('f740b251-4264-4220-8400-706331f650af', 'e0926c16-7f63-41ae-a091-1d0688c88322', '0e3821a8-80d6-4fa9-8313-3ed45b83c28b', 'Estefanía', 'Vanegas', '1946-07-16', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Ing. Carolina Godinez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', 'df863eba-f0b8-4b1a-bdd1-71ed2f816ed7', 'd050617d-dc89-4f28-b546-9680dd1c5fad', 'Alfredo', 'Holguín', '1963-03-03', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Felipe Sofia Padilla', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('97d5d278-c876-4078-9dba-2940edfed9a0', '57031194-3c31-4320-86c4-fd370789efac', '373769ab-b720-4269-bfb9-02546401ce99', 'Reynaldo', 'Meza', '1997-05-25', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Carla Candelaria Mota', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('a329242d-9e38-4178-aa8e-5b7497209897', '22128ae9-ba6e-4e99-821a-dc445e76d641', 'a56b6787-94e9-49f0-8b3a-6ff5979773fc', 'Daniel', 'Cabán', '1964-03-09', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Blanca Aurelio Beltran Navarrete', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('fe2cc660-dd15-4d31-ac72-56114bdb6b92', '28958f29-28c6-405a-acf5-949ffcaec286', '8cfdeaad-c727-4a4d-b5d5-b69dd43c0854', 'Graciela', 'Bonilla', '1997-08-04', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Augusto Diana Ramos Palomino', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('fd01c50f-f3dd-4517-96c0-c0e65330a692', 'c0d54a00-2ee9-4827-a7fb-6196ef15bdee', 'eb602cae-423a-455d-a22e-d47aea5eb650', 'Jaqueline', 'Olivas', '1950-01-18', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Jose Emilio Camarillo Escobedo', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('f56cc0bc-1765-4334-9594-73dcc9deac8e', 'bbf715a1-3947-4642-a67a-b5c4c0c085d2', '3d521bc9-692d-4a0d-a3d7-80e816b86374', 'Leonardo', 'Mateo', '1966-11-16', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Mauricio Alonso Olvera', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('1c861cbf-991d-4820-b3f0-98538fb0d454', 'a7ada88a-7935-4dd5-8a4f-935c4b7c0bab', '0e3821a8-80d6-4fa9-8313-3ed45b83c28b', 'Antonio', 'Sosa', '1959-10-11', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Martha Torres', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', '14abdfde-e4c9-460c-9ce2-17886600b20d', '0d826581-b9d8-4828-8848-9332fe38d169', 'Cristobal', 'Chávez', '2006-04-22', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Yuridia Peres', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('d1ec4069-41a0-4317-a6c6-84914d108257', '6c711a31-c752-44f2-b6cb-480f9bf6af1f', 'a14c189c-ee90-4c29-b465-63d43a9d0010', 'Jaqueline', 'Negrete', '1973-10-23', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Esmeralda Saenz', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', '06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7', '0d826581-b9d8-4828-8848-9332fe38d169', 'Esteban', 'Ríos', '1991-11-04', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Micaela Rosa Botello', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('0deef39b-719e-4f3a-a84f-2072803b2548', '5879ec30-c291-476d-a48c-284fadf5f98a', 'a725b15f-039b-4256-843a-51a2968633fd', 'Zoé', 'Gaona', '1953-01-20', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Olga Marisol Beltran', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('5156864c-fa59-4e48-b357-477838800efc', '57031194-3c31-4320-86c4-fd370789efac', '44a33aab-1a23-4995-bd07-41f95b34fd57', 'Ana', 'Sáenz', '1967-10-22', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Dario Santiago Peres', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('d911f0a5-9268-4eb4-87e9-508d7c99b753', '852beb97-3c99-4391-879f-98f0c2154c20', '9c8636c9-015b-4c18-a641-f5da698b6fd8', 'Vanesa', 'Nava', '1996-10-22', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Eloisa Chacon', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 'e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c', '67787f7c-fdee-4e30-80bd-89008ebfe419', 'Diana', 'Ceja', '1969-09-11', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Eric Regalado Olivo', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('b2eef54b-21a7-45ec-a693-bc60f1d6e293', 'c4fac110-0b61-4fb0-943d-0d00af7ed0cd', '44a33aab-1a23-4995-bd07-41f95b34fd57', 'Emilio', 'de la Rosa', '1946-08-04', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Tania Moya', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('3854a76e-ee29-4976-b630-1d7e18fb9887', 'a3fb2dae-2a69-434f-86a9-65ae48c8f690', '1926fa2a-dab7-420e-861b-c2b6dfe0174e', 'Mónica', 'de la Rosa', '1978-12-21', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Esperanza Eloisa Torres', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 'b5a04df6-baea-460f-a946-f7b7606c9982', '3d7c5771-0692-4a2f-a4c6-6af2b561282b', 'Reynaldo', 'García', '1966-02-04', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Agustin Baez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', '4cecebec-e16f-4949-a18b-8bfebae86618', '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0', 'Gerónimo', 'Pedraza', '1972-11-13', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Zacarias Ochoa Torres', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 'bbf715a1-3947-4642-a67a-b5c4c0c085d2', '9b581d3c-9e93-4f39-80bb-294752065866', 'Abelardo', 'Barraza', '1981-03-11', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Tania Reina Urena', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd', 'b7dd043b-953f-4e04-8a80-1c613d3c6675', 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc', 'Noelia', 'Toro', '1948-04-16', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Elsa Marin', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('bc6e7a77-d709-401c-bea7-82715eeb1a29', 'b6994d45-b80e-4260-834c-facdf3ea8eee', 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa', 'Inés', 'Téllez', '2001-07-07', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Isaac Rolando Apodaca Valle', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('d54d7239-e49a-4185-8875-4f71af08b789', 'a2beaa02-c033-4e45-b702-305d5ce41e34', '08a7fe9e-c043-4fed-89e4-93a416a20089', 'Héctor', 'Maldonado', '1974-05-05', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Yeni Rosario Colunga', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('8370857e-7e69-43a6-be63-78fc270c5fd5', 'c0d54a00-2ee9-4827-a7fb-6196ef15bdee', '373769ab-b720-4269-bfb9-02546401ce99', 'Jonás', 'Segura', '1969-09-21', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Clemente Antonia Orellana', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('e8813bf8-7bbb-4370-a181-880c0c959aa1', '58a814d3-a275-436b-8e5c-4e743fed242f', '06c71356-e038-4c3d-bfea-7865acacb684', 'José Luis', 'Gómez', '2003-03-23', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Noemi Zoe Aparicio', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a', 'dc42b779-4b49-418b-ab0a-92caa2a8d6de', 'b654860f-ec74-42d6-955e-eeedde2df0dd', 'Fernando', 'Gil', '1947-02-19', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Ing. Homero Duran', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 'f501d643-d308-41e0-8ffc-8bfb52d64e13', '44a33aab-1a23-4995-bd07-41f95b34fd57', 'Ángela', 'Montañez', '1974-10-26', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Alvaro Sofia Rojas', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('44e4c099-cf6e-4926-85f1-ab5cb34c59a1', '2937cc2f-22b7-4488-b9f8-a0795800a840', 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0', 'Leonor', 'Olivera', '1953-12-23', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Abel Correa', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('a0c3c815-c664-4931-927f-e4109a545603', 'b441c98a-1075-4013-9fc2-9242d910713f', '7b96a7bb-041f-4331-be05-e97cab7dafc0', 'Gabino', 'Aguirre', '1951-06-03', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Daniel Villasenor Robles', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('5c1862f6-f802-41ae-a6fb-87dbc5555fb3', 'ab923e2e-5d13-41e4-9c73-2f62cca0699d', '7b96a7bb-041f-4331-be05-e97cab7dafc0', 'Judith', 'Alemán', '1976-05-31', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Israel Mojica', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 'c1182c2e-0624-42f9-aef6-7e7a1a2b7dba', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', 'Oswaldo', 'Fuentes', '1989-06-16', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Lic. Mayte Abreu', TRUE, TRUE)
ON CONFLICT DO NOTHING;

-- =============================================
-- HEALTH PROFILES
-- =============================================

INSERT INTO health_profiles (patient_id, height_cm, weight_kg, blood_type_id, is_smoker, smoking_years, consumes_alcohol, alcohol_frequency, physical_activity_minutes_weekly, notes)
VALUES
    ('2f5622af-8528-4c85-8e16-3d175a4f2d15'::uuid, 177.2, 113.8, (SELECT id FROM blood_types WHERE name = 'O-'), True, 7, True, 'rarely', 220, 'Buen familia reunión explicó.'),
    ('fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c'::uuid, 150.4, 88.9, (SELECT id FROM blood_types WHERE name = 'O-'), True, 10, False, 'never', 502, 'Diez último parte hubo deben pasa hechos música.'),
    ('959aa1dd-346b-4542-8f99-0d5e75301249'::uuid, 184.5, 73.7, (SELECT id FROM blood_types WHERE name = 'O-'), False, 0, True, 'never', 146, 'Actual madrid ya.'),
    ('59402562-ce5f-450e-8e6c-9630514fe164'::uuid, 169.5, 115.2, (SELECT id FROM blood_types WHERE name = 'AB-'), False, 0, False, 'never', 566, 'Animales mismo comenzó aire pasar.'),
    ('f81c87d6-32f1-4c79-993a-18db4734ef65'::uuid, 199.7, 55.3, (SELECT id FROM blood_types WHERE name = 'A-'), False, 0, False, 'never', 389, 'Alto has maría conciencia médico señaló proceso peso.'),
    ('0b6b8229-4027-4ec7-8bce-c805de96ced3'::uuid, 153.4, 82.5, (SELECT id FROM blood_types WHERE name = 'B+'), True, 22, True, 'daily', 204, 'Larga negro particular.'),
    ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb'::uuid, 185.1, 75.3, (SELECT id FROM blood_types WHERE name = 'A-'), True, 30, False, 'never', 107, 'Eso boca todavía palabra así.'),
    ('f2a1f62a-8030-4f65-b82d-ce7376b955bd'::uuid, 179.9, 81.3, (SELECT id FROM blood_types WHERE name = 'AB-'), False, 0, False, 'never', 35, 'Muerte aunque buscar necesidad.'),
    ('0104fea2-d27c-4611-8414-da6c898b6944'::uuid, 187.6, 68.5, (SELECT id FROM blood_types WHERE name = 'A+'), False, 0, True, 'regularly', 539, 'No puntos i junto poner.'),
    ('cd0c2f0c-de08-439c-93c9-0feab1d433cc'::uuid, 180.7, 84.0, (SELECT id FROM blood_types WHERE name = 'AB+'), False, 0, True, 'regularly', 256, 'España pueblo barcelona económica asunto.'),
    ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545'::uuid, 188.3, 118.4, (SELECT id FROM blood_types WHERE name = 'A-'), False, 0, True, 'daily', 546, 'Aumento garcía creo conocimiento capital país valor.'),
    ('7893292b-965a-41da-896a-d0780c91fdd5'::uuid, 192.1, 67.7, (SELECT id FROM blood_types WHERE name = 'O-'), True, 9, False, 'never', 240, 'Momento blanco mañana diferentes civil importantes papel.'),
    ('87fb3c88-6653-45db-aa6c-20ea7512da64'::uuid, 158.7, 81.6, (SELECT id FROM blood_types WHERE name = 'AB+'), False, 0, True, 'regularly', 462, 'Dejar rosa empresas lejos españoles.'),
    ('05e42aed-c457-4579-904f-d397be3075f7'::uuid, 168.1, 55.6, (SELECT id FROM blood_types WHERE name = 'B+'), False, 0, True, 'regularly', 449, 'Adelante personas hija fondo radio.'),
    ('43756f6c-c157-4a44-9c84-ab2d62fddcf7'::uuid, 155.5, 54.6, (SELECT id FROM blood_types WHERE name = 'AB-'), False, 0, True, 'occasionally', 385, 'Actual autor puedo suerte hijos grupos existen.'),
    ('d8e1fa52-0a65-4917-b410-2954e05a34e5'::uuid, 199.6, 87.8, (SELECT id FROM blood_types WHERE name = 'AB+'), False, 0, False, 'never', 468, 'Favor través francia negro campo fácil.'),
    ('bbc67f38-a9eb-4379-aeaf-1560af0d1a34'::uuid, 177.7, 54.5, (SELECT id FROM blood_types WHERE name = 'A+'), False, 0, False, 'never', 60, 'Suerte próximo r suerte.'),
    ('b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e'::uuid, 191.5, 99.9, (SELECT id FROM blood_types WHERE name = 'A-'), True, 13, True, 'occasionally', 458, 'Diversos trabajadores cuestión precio veces valores horas.'),
    ('309df411-1d1a-4d00-a34e-36e8c32da210'::uuid, 150.4, 70.4, (SELECT id FROM blood_types WHERE name = 'AB-'), False, 0, False, 'never', 276, 'Modo los propia hacen aparece.'),
    ('663d036b-a19b-4557-af37-d68a9ce4976d'::uuid, 159.3, 54.1, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 16, False, 'never', 309, 'Claro septiembre nadie manera ideas.'),
    ('a754cbf1-a4ca-42dc-92c4-d980b6a25a6d'::uuid, 170.4, 118.2, (SELECT id FROM blood_types WHERE name = 'O+'), False, 0, True, 'daily', 410, 'Nuestras proyectos blanca campaña tenido volvió.'),
    ('d5b1779e-21f2-4252-a421-f2aaf9998916'::uuid, 173.2, 83.1, (SELECT id FROM blood_types WHERE name = 'AB+'), True, 18, True, 'regularly', 6, 'Alguien pie española ley viejo conciencia.'),
    ('6661483b-705b-412a-8bbd-39c0af0dadb1'::uuid, 170.8, 76.4, (SELECT id FROM blood_types WHERE name = 'A-'), True, 9, False, 'never', 176, 'Estados queda diario libertad.'),
    ('676491c4-f31a-42b6-a991-a8dd09bbb1f0'::uuid, 183.0, 87.8, (SELECT id FROM blood_types WHERE name = 'A+'), True, 9, True, 'occasionally', 27, 'Veces estados verdad de instituto unidad vista juicio.'),
    ('3a9e8e0e-6367-409d-a81c-9852069c710e'::uuid, 199.5, 78.8, (SELECT id FROM blood_types WHERE name = 'O+'), False, 0, True, 'rarely', 389, 'Pasó maría objeto apoyo tu rodríguez llama.'),
    ('167dedde-166c-45e4-befc-4f1c9b7184ad'::uuid, 160.1, 59.3, (SELECT id FROM blood_types WHERE name = 'AB+'), False, 0, True, 'occasionally', 441, 'Música hubo persona ahora somos.'),
    ('72eca572-4ecf-4be8-906b-40e89e0d9a08'::uuid, 182.2, 64.2, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, True, 'never', 421, 'Volvió mundo cabo tuvo.'),
    ('d5bec069-a317-4a40-b3e8-ea80220d75de'::uuid, 190.1, 87.7, (SELECT id FROM blood_types WHERE name = 'A+'), False, 0, True, 'daily', 66, 'Fecha incluso miedo esa grado.'),
    ('0e97294d-78cc-4428-a172-e4e1fd4efa72'::uuid, 170.0, 56.1, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 104, 'Diciembre través cosas cuarto u hechos.'),
    ('9f86a53f-f0e1-446d-89f0-86b086dd12a9'::uuid, 192.2, 101.4, (SELECT id FROM blood_types WHERE name = 'B+'), True, 25, False, 'never', 50, 'Estudio nuestro posible lenguaje.'),
    ('ae1f5c92-f3cf-43d8-918f-aaad6fb46c05'::uuid, 156.3, 55.7, (SELECT id FROM blood_types WHERE name = 'A+'), False, 0, True, 'rarely', 262, 'Hechos acuerdo considera cuba ii.'),
    ('d28440a6-3bd9-4a48-8a72-d700ae0971e4'::uuid, 162.9, 109.6, (SELECT id FROM blood_types WHERE name = 'AB+'), False, 0, False, 'never', 563, 'Naturaleza respuesta boca grupo.'),
    ('7f839ee8-bdd6-4a63-83e8-30db007565e2'::uuid, 194.1, 95.4, (SELECT id FROM blood_types WHERE name = 'O+'), True, 15, False, 'never', 562, 'Pequeña asimismo cuestión área.'),
    ('67aa999f-9d31-4b61-a097-35097ea0d082'::uuid, 152.0, 70.0, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 4, 'Música centros viejo pasa hecho.'),
    ('41aa2fbc-8ef4-4448-8686-399a1cd54be9'::uuid, 175.5, 85.7, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 0, 'Industria dado perdido ojos si.'),
    ('111769f3-1a1b-44a9-9670-f4f2e424d1d2'::uuid, 182.4, 86.3, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 391, 'Puerta produce puso cambios esto práctica suelo.'),
    ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1'::uuid, 154.4, 85.1, (SELECT id FROM blood_types WHERE name = 'O-'), False, 0, True, 'never', 289, 'Precios hubiera buena suelo comunicación.'),
    ('6a8b6d41-8d20-4bc5-8d48-538d348f6086'::uuid, 178.1, 86.0, (SELECT id FROM blood_types WHERE name = 'A+'), True, 29, False, 'never', 506, 'Queda acciones vio lenguaje u más.'),
    ('89657c95-84c0-4bd0-80c6-70a2c4721276'::uuid, 173.5, 119.6, (SELECT id FROM blood_types WHERE name = 'O+'), True, 14, True, 'occasionally', 96, 'Muchos francisco juez hombres cerca.'),
    ('b6658dac-0ee1-415c-95ad-28c6acea85bd'::uuid, 170.3, 114.2, (SELECT id FROM blood_types WHERE name = 'A+'), True, 30, True, 'occasionally', 227, 'Amor encontrar n mayor europea unos juicio.'),
    ('56564104-6009-466c-9134-c15d3175613b'::uuid, 184.9, 92.3, (SELECT id FROM blood_types WHERE name = 'A+'), False, 0, True, 'occasionally', 337, 'Intereses siglo diferencia dar.'),
    ('edb1d693-b308-4ff6-8fd4-9e20561317e8'::uuid, 184.1, 53.5, (SELECT id FROM blood_types WHERE name = 'A-'), True, 1, False, 'never', 307, 'Principio imágenes común r mayo.'),
    ('9511f9b9-a450-489c-92b9-ac306733cee4'::uuid, 191.6, 57.1, (SELECT id FROM blood_types WHERE name = 'AB+'), True, 9, False, 'never', 30, 'Padre orden menos después aparece carne.'),
    ('004ce58b-6a0d-4646-92c3-4508deb6b354'::uuid, 175.1, 79.0, (SELECT id FROM blood_types WHERE name = 'O-'), True, 7, True, 'daily', 286, 'Unos dicen nuevos participación destino.'),
    ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be'::uuid, 193.8, 98.1, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 153, 'Buscar comunidad parís según puedo constitución méxico fácil.'),
    ('38000dbb-417f-43ca-a60e-5812796420f7'::uuid, 189.4, 60.2, (SELECT id FROM blood_types WHERE name = 'A+'), True, 21, True, 'regularly', 379, 'Título mientras años precio.'),
    ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8'::uuid, 186.7, 67.3, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 471, 'Ante llevar uno estudios poner organización millones calle.'),
    ('561c313d-2c15-41b1-b965-a38c8e0f6c42'::uuid, 180.4, 89.5, (SELECT id FROM blood_types WHERE name = 'O+'), False, 0, True, 'never', 468, 'Recuerdo especie nombre características.'),
    ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28'::uuid, 155.1, 107.8, (SELECT id FROM blood_types WHERE name = 'B-'), True, 14, True, 'never', 569, 'Análisis quiero cosas llegado unidos importante iba.'),
    ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20'::uuid, 151.3, 86.9, (SELECT id FROM blood_types WHERE name = 'O-'), True, 23, True, 'occasionally', 279, 'Habla d francisco alto consejo consecuencia alto.'),
    ('05bc2942-e676-42e9-ad01-ade9f7cc5aee'::uuid, 197.8, 74.3, (SELECT id FROM blood_types WHERE name = 'A+'), False, 0, False, 'never', 29, 'Banco alta es vida momento claro militar.'),
    ('c78e7658-d517-4ca1-990b-e6971f8d108f'::uuid, 158.2, 75.9, (SELECT id FROM blood_types WHERE name = 'B+'), False, 0, True, 'never', 164, 'D pública j medidas.'),
    ('65474c27-8f72-4690-8f19-df9344e4be5e'::uuid, 152.5, 50.7, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 29, False, 'never', 76, 'Libertad pese estamos ambos fútbol.'),
    ('c1b6fa98-203a-4321-96cd-e80e7a1c9461'::uuid, 180.6, 103.3, (SELECT id FROM blood_types WHERE name = 'O-'), False, 0, False, 'never', 4, 'Tipos medios sueño mi siendo.'),
    ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3'::uuid, 166.8, 63.9, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 156, 'Escuela empresas violencia varias.'),
    ('eb2e55f6-4738-4352-a59a-860909f1932c'::uuid, 174.1, 104.5, (SELECT id FROM blood_types WHERE name = 'O-'), True, 30, False, 'never', 61, 'Durante historia aquella consejo pie.'),
    ('c572a4c7-e475-4d18-85da-417abcd00903'::uuid, 153.9, 63.5, (SELECT id FROM blood_types WHERE name = 'A+'), False, 0, True, 'occasionally', 101, 'Electoral calidad i cargo dijo.'),
    ('5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3'::uuid, 171.9, 73.3, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, True, 'never', 58, 'Cuadro niño pone esos.'),
    ('9b02d89c-2c5b-4c51-8183-15ccd1184990'::uuid, 192.6, 107.5, (SELECT id FROM blood_types WHERE name = 'B+'), False, 0, False, 'never', 205, 'Persona policía embargo.'),
    ('43ae2e81-ac13-40ac-949c-9e4f51d76098'::uuid, 193.2, 84.1, (SELECT id FROM blood_types WHERE name = 'A+'), True, 3, True, 'rarely', 207, 'Demasiado miguel junio ocasión.'),
    ('49a18092-8f90-4f6b-873c-8715b64b8aff'::uuid, 159.3, 89.7, (SELECT id FROM blood_types WHERE name = 'O-'), True, 24, False, 'never', 174, 'San encuentran cual ser doctor crisis.'),
    ('c9a949e5-e650-4d95-9e2e-49ed06e5d087'::uuid, 155.1, 52.5, (SELECT id FROM blood_types WHERE name = 'AB+'), False, 0, False, 'never', 304, 'Dice parece nueva donde septiembre estructura.'),
    ('a4e5cbb3-36f7-43d8-a65a-e30fc1361e56'::uuid, 164.8, 90.8, (SELECT id FROM blood_types WHERE name = 'B+'), False, 0, False, 'never', 593, 'Gran seguro rodríguez era buscar violencia políticas.'),
    ('447e48dc-861c-41e6-920e-a2dec785101f'::uuid, 175.3, 95.3, (SELECT id FROM blood_types WHERE name = 'AB-'), False, 0, True, 'daily', 130, 'Pp las hombre alrededor educación características hijo democracia.'),
    ('3a535951-40fd-4959-a34e-07b29f675ecc'::uuid, 176.9, 102.5, (SELECT id FROM blood_types WHERE name = 'B+'), False, 0, False, 'never', 232, 'Cerca son pone muerto acuerdo centro.'),
    ('d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70'::uuid, 192.9, 68.1, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 11, False, 'never', 368, 'Difícil ejército asociación ellas.'),
    ('6052a417-6725-4fab-b7dd-7f498454cd47'::uuid, 193.9, 116.4, (SELECT id FROM blood_types WHERE name = 'A+'), False, 0, True, 'regularly', 402, 'Afirmó minutos sobre lucha eso ir.'),
    ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7'::uuid, 199.7, 108.8, (SELECT id FROM blood_types WHERE name = 'O+'), False, 0, True, 'rarely', 404, 'Medio hacer diario creo baja.'),
    ('cbd398cc-dfde-41c4-b7b1-ca32cc99945f'::uuid, 173.6, 79.6, (SELECT id FROM blood_types WHERE name = 'O-'), True, 13, False, 'never', 518, 'Algún programas varias final tras.'),
    ('f740b251-4264-4220-8400-706331f650af'::uuid, 169.5, 57.8, (SELECT id FROM blood_types WHERE name = 'AB+'), True, 30, False, 'never', 215, 'Veces hijos primeras meses razón actividad bien había.'),
    ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7'::uuid, 156.3, 107.8, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 29, True, 'regularly', 226, 'Política cuando niños servicios sé.'),
    ('97d5d278-c876-4078-9dba-2940edfed9a0'::uuid, 184.8, 106.1, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 27, True, 'daily', 259, 'República mejores internacional máximo has francia muchos.'),
    ('a329242d-9e38-4178-aa8e-5b7497209897'::uuid, 193.9, 94.0, (SELECT id FROM blood_types WHERE name = 'B+'), True, 17, False, 'never', 64, 'Aunque ella lópez relación debe ayuda aquellas.'),
    ('fe2cc660-dd15-4d31-ac72-56114bdb6b92'::uuid, 160.9, 113.0, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 26, 'Grupo partido dirección usted mitad necesidad.'),
    ('fd01c50f-f3dd-4517-96c0-c0e65330a692'::uuid, 174.3, 93.2, (SELECT id FROM blood_types WHERE name = 'AB+'), True, 21, True, 'regularly', 376, 'I unos apenas mí presencia vivir fin.'),
    ('f56cc0bc-1765-4334-9594-73dcc9deac8e'::uuid, 183.4, 79.3, (SELECT id FROM blood_types WHERE name = 'B+'), True, 25, True, 'never', 135, 'Civil premio podría.'),
    ('1c861cbf-991d-4820-b3f0-98538fb0d454'::uuid, 156.6, 82.3, (SELECT id FROM blood_types WHERE name = 'B-'), True, 21, False, 'never', 394, 'Silencio edad atrás muy común.'),
    ('70f066e1-fc10-4b37-92ea-0de96307793b'::uuid, 159.2, 83.7, (SELECT id FROM blood_types WHERE name = 'B+'), True, 12, False, 'never', 495, 'Son estar habría entonces piel rey junto.'),
    ('d1ec4069-41a0-4317-a6c6-84914d108257'::uuid, 188.6, 108.5, (SELECT id FROM blood_types WHERE name = 'B+'), False, 0, True, 'rarely', 368, 'Programas hablar todas el.'),
    ('04239007-edaa-4c74-95dd-4ba4df226b0f'::uuid, 161.5, 89.4, (SELECT id FROM blood_types WHERE name = 'O-'), False, 0, False, 'never', 589, 'Teatro hora importantes.'),
    ('0deef39b-719e-4f3a-a84f-2072803b2548'::uuid, 188.0, 76.3, (SELECT id FROM blood_types WHERE name = 'A-'), False, 0, False, 'never', 508, 'Diferencia baja julio paciente quién.'),
    ('5156864c-fa59-4e48-b357-477838800efc'::uuid, 191.5, 92.3, (SELECT id FROM blood_types WHERE name = 'AB-'), False, 0, True, 'never', 189, 'Duda ella santiago decía voy obras frente nuevas.'),
    ('d911f0a5-9268-4eb4-87e9-508d7c99b753'::uuid, 181.3, 101.2, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 24, False, 'never', 282, 'Hermano miguel presenta peor cuerpo pie hemos.'),
    ('c3e065c2-c0a9-440f-98f3-1c5463949056'::uuid, 192.6, 88.6, (SELECT id FROM blood_types WHERE name = 'AB+'), True, 20, True, 'never', 254, 'Mayor encuentran datos teoría gracias viene.'),
    ('b2eef54b-21a7-45ec-a693-bc60f1d6e293'::uuid, 153.5, 112.8, (SELECT id FROM blood_types WHERE name = 'O-'), True, 15, False, 'never', 81, 'Acto razones elecciones resulta.'),
    ('3854a76e-ee29-4976-b630-1d7e18fb9887'::uuid, 181.1, 68.0, (SELECT id FROM blood_types WHERE name = 'O-'), True, 11, False, 'never', 147, 'Calidad antonio industria encuentran base eso claro.'),
    ('6b2e25e9-ebcb-4150-a594-c5742cd42121'::uuid, 182.7, 117.2, (SELECT id FROM blood_types WHERE name = 'AB-'), False, 0, False, 'never', 53, 'Sido líder seguridad entrada animales antonio.'),
    ('cc38cb13-51a5-4539-99c2-894cd2b207f1'::uuid, 176.2, 78.5, (SELECT id FROM blood_types WHERE name = 'B+'), True, 4, True, 'daily', 172, 'Sería sociales zona mitad pasa lo.'),
    ('6af409b5-c8b8-4664-97cd-d419eedcc932'::uuid, 161.8, 79.3, (SELECT id FROM blood_types WHERE name = 'A+'), True, 24, False, 'never', 465, 'Contra armas varias grupo tampoco o.'),
    ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd'::uuid, 179.4, 75.5, (SELECT id FROM blood_types WHERE name = 'A+'), True, 28, True, 'regularly', 259, 'Blanco victoria efectos consejo.'),
    ('bc6e7a77-d709-401c-bea7-82715eeb1a29'::uuid, 186.5, 51.9, (SELECT id FROM blood_types WHERE name = 'AB+'), False, 0, False, 'never', 538, 'Al señor situación última vivir unos d.'),
    ('d54d7239-e49a-4185-8875-4f71af08b789'::uuid, 194.6, 85.9, (SELECT id FROM blood_types WHERE name = 'AB-'), False, 0, True, 'daily', 23, 'Psoe duda destino.'),
    ('8370857e-7e69-43a6-be63-78fc270c5fd5'::uuid, 180.3, 117.5, (SELECT id FROM blood_types WHERE name = 'A-'), False, 0, True, 'daily', 211, 'Teatro artículo constitución varios fernando están.'),
    ('e8813bf8-7bbb-4370-a181-880c0c959aa1'::uuid, 178.6, 52.7, (SELECT id FROM blood_types WHERE name = 'A-'), False, 0, False, 'never', 266, 'Orden ambos escuela electoral.'),
    ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a'::uuid, 198.5, 84.2, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 20, True, 'never', 202, 'Están otra común puedo.'),
    ('517958b1-f860-4a42-965b-15a796055981'::uuid, 150.2, 100.8, (SELECT id FROM blood_types WHERE name = 'B-'), False, 0, False, 'never', 26, 'Pasa solamente siete sangre actividad menor afirmó santiago.'),
    ('44e4c099-cf6e-4926-85f1-ab5cb34c59a1'::uuid, 162.2, 105.0, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 30, False, 'never', 117, 'Sean conciencia democracia viejo.'),
    ('a0c3c815-c664-4931-927f-e4109a545603'::uuid, 162.5, 118.1, (SELECT id FROM blood_types WHERE name = 'O+'), False, 0, True, 'rarely', 522, 'Construcción decía piel revolución decisión.'),
    ('5c1862f6-f802-41ae-a6fb-87dbc5555fb3'::uuid, 198.7, 58.9, (SELECT id FROM blood_types WHERE name = 'AB-'), True, 14, True, 'occasionally', 316, 'Niños dado asimismo prensa fuerte carrera unos.'),
    ('11d31cb4-1dfb-479e-9329-8b8b35920b98'::uuid, 193.2, 115.5, (SELECT id FROM blood_types WHERE name = 'AB+'), False, 0, False, 'never', 97, 'Quiere interior segundo pregunta.')
ON CONFLICT (patient_id) DO NOTHING;

-- =============================================
-- PATIENT CONDITIONS
-- =============================================

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 18, '2020-04-24', 'Conocer trata servicios diciembre presente él mantener.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 11, '2020-03-07', 'Instituciones también doctor económica política.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 14, '2024-11-01', 'Da están pacientes.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c', 10, '2016-10-23', 'Tema no incluso semanas semanas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('959aa1dd-346b-4542-8f99-0d5e75301249', 4, '2017-07-09', 'Social pensar policía mil siete sectores estaba.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('959aa1dd-346b-4542-8f99-0d5e75301249', 16, '2025-08-28', 'Pasa grande dado.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('959aa1dd-346b-4542-8f99-0d5e75301249', 10, '2017-03-01', 'Música número principio sin maría volver miedo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('59402562-ce5f-450e-8e6c-9630514fe164', 4, '2025-03-22', 'Amigos arte gobierno sus seis nacional del.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f81c87d6-32f1-4c79-993a-18db4734ef65', 20, '2015-11-03', 'Mucha boca carácter dolor deseo ellos grado.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0b6b8229-4027-4ec7-8bce-c805de96ced3', 12, '2021-02-08', 'Vuelve considera junio debía nuestros.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 15, '2023-11-22', 'Riesgo oro dicen oposición mientras grandes esas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 2, '2025-03-09', 'Niños señor españoles diversas dado esa acerca.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 11, '2023-04-06', 'Uso puedo oposición anterior participación entre última.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 14, '2023-06-15', 'Organización comisión estudio norte opinión relación.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 8, '2018-04-28', 'Siglo futuro ir usted ocasión.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 11, '2024-02-20', 'Espacio ministro entrada guerra.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 8, '2021-12-07', 'Cuales oficial precisamente deja deseo fiscal.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 9, '2023-12-21', 'Hechos más investigación están partir río fin.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 1, '2017-09-09', 'Nuevas iglesia calle central club jefe.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cd0c2f0c-de08-439c-93c9-0feab1d433cc', 5, '2020-08-24', 'Fuerzas habrá análisis algo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', 3, '2024-04-13', 'Larga tratamiento alta primeros nueva con solamente e.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', 11, '2024-08-27', 'A uno debe orden natural pese ojos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', 17, '2016-06-01', 'Algunos cuanto ocho estar.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('7893292b-965a-41da-896a-d0780c91fdd5', 16, '2024-11-06', 'Deja hermano fuerza.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('7893292b-965a-41da-896a-d0780c91fdd5', 4, '2016-08-18', 'Con compañía pasado será ocho ésta.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('87fb3c88-6653-45db-aa6c-20ea7512da64', 19, '2021-08-17', 'París título el tiene llega.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 20, '2021-02-01', 'Problemas aquella volver país pregunta r hemos claro.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 10, '2024-03-17', 'Futuro volvió llevar cultura mal ahí.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('43756f6c-c157-4a44-9c84-ab2d62fddcf7', 14, '2025-06-13', 'Esto cambio adelante estos ha.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('43756f6c-c157-4a44-9c84-ab2d62fddcf7', 8, '2018-11-18', 'Igual pesar mientras.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('43756f6c-c157-4a44-9c84-ab2d62fddcf7', 4, '2025-03-06', 'Flores aun plaza julio peor operación partir.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d8e1fa52-0a65-4917-b410-2954e05a34e5', 6, '2025-02-22', 'Quiero queda campo estas has.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d8e1fa52-0a65-4917-b410-2954e05a34e5', 8, '2017-08-22', 'Poco ésta primer mano electoral estaba llevar.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('bbc67f38-a9eb-4379-aeaf-1560af0d1a34', 4, '2024-12-04', 'Don millones busca tengo bien pasar sigue poder.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('bbc67f38-a9eb-4379-aeaf-1560af0d1a34', 19, '2017-04-13', 'Posición cuando hasta semana central bueno bajo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e', 2, '2017-02-12', 'Voy mañana libros ser josé.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('309df411-1d1a-4d00-a34e-36e8c32da210', 16, '2023-07-21', 'Luego existe quiere suerte.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('309df411-1d1a-4d00-a34e-36e8c32da210', 14, '2020-07-08', 'Julio puso pacientes.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('663d036b-a19b-4557-af37-d68a9ce4976d', 8, '2019-06-10', 'Cantidad otra deja humanos imágenes.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('663d036b-a19b-4557-af37-d68a9ce4976d', 5, '2019-08-10', 'Francia pone operación consecuencia esos domingo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('663d036b-a19b-4557-af37-d68a9ce4976d', 17, '2022-04-30', 'Propuesta afirmó mediante industria aquellas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('a754cbf1-a4ca-42dc-92c4-d980b6a25a6d', 19, '2019-05-17', 'Paciente final cual.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('a754cbf1-a4ca-42dc-92c4-d980b6a25a6d', 20, '2019-07-03', 'Cuya proyecto santa través van.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 11, '2023-10-06', 'Julio aquel dios vivir premio porque.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 12, '2019-01-21', 'Baja josé nuevo área.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 8, '2018-09-26', 'En cerca rodríguez poder autoridades apoyo bastante figura.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6661483b-705b-412a-8bbd-39c0af0dadb1', 3, '2017-10-11', 'Luz barcelona partidos defensa largo esto.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('676491c4-f31a-42b6-a991-a8dd09bbb1f0', 13, '2019-06-21', 'Través éxito acuerdo partido pesetas lado martín.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('676491c4-f31a-42b6-a991-a8dd09bbb1f0', 10, '2023-08-18', 'Medio todos tales práctica podía.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('676491c4-f31a-42b6-a991-a8dd09bbb1f0', 6, '2016-09-20', 'Pedro pese luz estamos demasiado cuenta.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('3a9e8e0e-6367-409d-a81c-9852069c710e', 14, '2019-01-23', 'Rafael tales conocimiento actual.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('167dedde-166c-45e4-befc-4f1c9b7184ad', 15, '2018-03-12', 'Primeras sentido tal segundo dicen.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('167dedde-166c-45e4-befc-4f1c9b7184ad', 3, '2021-08-12', 'Año es están cinco película pensar.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('72eca572-4ecf-4be8-906b-40e89e0d9a08', 17, '2023-07-27', 'Podemos diversos unas cambios minutos aumento.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('72eca572-4ecf-4be8-906b-40e89e0d9a08', 6, '2017-11-16', 'Puesto partidos problema elementos salir.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('72eca572-4ecf-4be8-906b-40e89e0d9a08', 8, '2017-07-01', 'Muerto puesto n mismos propuesta resto mundo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', 20, '2025-10-07', 'Segundo sobre administración.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', 7, '2024-04-14', 'Papel europa habla color gobierno profesional.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', 11, '2018-07-09', 'Llamado juicio sólo méxico.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', 8, '2023-10-31', 'Habían acción tuvo posible pero tratamiento.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', 16, '2023-11-17', 'Buena con mar nuevos agua aquel.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('9f86a53f-f0e1-446d-89f0-86b086dd12a9', 3, '2025-01-27', 'U principales negro.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('9f86a53f-f0e1-446d-89f0-86b086dd12a9', 7, '2021-11-16', 'Local explicó felipe todos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('9f86a53f-f0e1-446d-89f0-86b086dd12a9', 15, '2022-08-08', 'Próximo tuvo igual poder saber hijos sala.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('ae1f5c92-f3cf-43d8-918f-aaad6fb46c05', 2, '2019-07-12', 'Éxito actitud obra tomar fuentes como.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', 10, '2020-01-03', 'Españoles tiene congreso estos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', 16, '2018-07-14', 'Jóvenes quien político n.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', 18, '2019-01-08', 'Razón reunión pensar esta tuvo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('7f839ee8-bdd6-4a63-83e8-30db007565e2', 19, '2022-12-06', 'Segundo considera civil distintos público.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('7f839ee8-bdd6-4a63-83e8-30db007565e2', 13, '2024-10-01', 'Origen como últimos llega muerte.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('67aa999f-9d31-4b61-a097-35097ea0d082', 17, '2020-02-22', 'Españoles tema comercio arte.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('67aa999f-9d31-4b61-a097-35097ea0d082', 11, '2017-12-23', 'Pablo tendrá elementos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('67aa999f-9d31-4b61-a097-35097ea0d082', 8, '2020-10-10', 'Presenta después puesto tu sería.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('41aa2fbc-8ef4-4448-8686-399a1cd54be9', 19, '2018-08-29', 'Mesa solo pasar importancia artículo encima cámara.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('111769f3-1a1b-44a9-9670-f4f2e424d1d2', 13, '2016-08-20', 'Señora grandes mercado grupo era máximo peso.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('111769f3-1a1b-44a9-9670-f4f2e424d1d2', 11, '2022-08-21', 'He voluntad electoral mis.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', 1, '2022-03-04', 'Vuelta estaba crisis.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6a8b6d41-8d20-4bc5-8d48-538d348f6086', 4, '2017-07-11', 'Le poco acción tratamiento deja mil.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 6, '2022-08-15', 'Asimismo términos nunca nuestro realizar cómo mil varias.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 10, '2016-05-23', 'Desarrollo comisión instituto saber hablar sentido médico.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 1, '2019-07-30', 'Estos u martín.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 5, '2017-10-06', 'Doctor fueron padre en arte económica.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 1, '2021-06-11', 'Lleva centros última jóvenes.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 13, '2019-04-03', 'Derechos hacer fácil blanca época tampoco.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 11, '2019-11-12', 'Años ella estas según conocimiento allá nadie.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 10, '2017-01-30', 'Gente interés estaba jóvenes diversos revolución.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 20, '2018-02-17', 'Iba estados cerca pequeño seguridad esfuerzo sigue.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('edb1d693-b308-4ff6-8fd4-9e20561317e8', 11, '2022-03-04', 'Pese producción las buena creación.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('edb1d693-b308-4ff6-8fd4-9e20561317e8', 1, '2018-02-08', 'Junto arriba guerra estudios muerto ejército partir.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('9511f9b9-a450-489c-92b9-ac306733cee4', 3, '2017-12-27', 'Agua toda última están nuestra participación.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('9511f9b9-a450-489c-92b9-ac306733cee4', 7, '2021-11-01', 'Mismos habrá san única mes forma muestra luego.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 15, '2022-05-28', 'Enfermedad dar me sean.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 14, '2021-07-12', 'García proyecto historia voluntad dios oposición agua silencio.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 19, '2024-08-27', 'Precisamente ocasión costa cabeza podría.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 1, '2018-10-26', 'Mejores alguien oro propia pequeña.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 17, '2018-01-11', 'Principales algo r mano valores atrás enfermedad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 20, '2018-09-21', 'Título ello social puntos ayer sino ningún.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', 3, '2017-04-28', 'Domingo suelo resultados propuesta me autoridades.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', 5, '2022-08-09', 'Pasar iba nivel otra concepto autor alrededor.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', 20, '2019-07-19', 'Decía fernando obra habla.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', 15, '2022-11-09', 'Tratamiento cerca su interior habían enfermedad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', 8, '2023-06-16', 'He primeras el el muestra atrás.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', 16, '2024-04-02', 'Conseguir causa llega fuerte.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', 10, '2016-04-02', 'Embargo segundo diversas serie resultados aire presencia.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', 2, '2015-12-08', 'Sociedad arte peso naturaleza.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', 6, '2021-07-19', 'Relaciones dónde país difícil nuevas ministerio expresión.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', 5, '2023-12-21', 'Diez minutos veces santa gonzález.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 15, '2022-04-06', 'Existe lugar real todas solamente.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 18, '2016-01-16', 'Octubre ocasión intereses región cuba solamente.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 13, '2022-09-08', 'Estado administración empresas tienen corte dice dicen.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('05bc2942-e676-42e9-ad01-ade9f7cc5aee', 9, '2023-11-04', 'Precios seis distintas segundo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c78e7658-d517-4ca1-990b-e6971f8d108f', 19, '2020-03-20', 'Plan m respuesta memoria todo juan nuevo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('65474c27-8f72-4690-8f19-df9344e4be5e', 6, '2021-10-16', 'Relación del favor.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('65474c27-8f72-4690-8f19-df9344e4be5e', 14, '2024-06-13', 'Central perdido interés enfermedad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('65474c27-8f72-4690-8f19-df9344e4be5e', 16, '2024-08-24', 'Zonas incluso congreso edad boca deja congreso ellos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 7, '2021-02-15', 'Producción república crisis semana.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 4, '2023-02-14', 'Crisis radio momento juicio realidad a formas estudio.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3', 9, '2024-06-22', 'Comenzó tenido llevar zonas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 19, '2019-06-16', 'Favor tendrá algo abril toma algo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 6, '2018-03-08', 'Pequeña difícil importante.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 3, '2017-05-21', 'Pública es afirmó.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c572a4c7-e475-4d18-85da-417abcd00903', 16, '2019-08-20', 'Hacia unidos aquellas espacio organización antes nuestras.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3', 3, '2022-12-03', 'Produce vio electoral queda libertad primero.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3', 17, '2022-01-14', 'En escuela grande iba algún hacia.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('9b02d89c-2c5b-4c51-8183-15ccd1184990', 4, '2024-10-16', 'Julio mes izquierda personal lleva cerca.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('43ae2e81-ac13-40ac-949c-9e4f51d76098', 2, '2022-02-11', 'Violencia habla mañana electoral interior.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('43ae2e81-ac13-40ac-949c-9e4f51d76098', 20, '2022-12-16', 'Técnica éxito llegar estos dice unas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('49a18092-8f90-4f6b-873c-8715b64b8aff', 9, '2016-08-10', 'Acuerdo lópez importante violencia.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('49a18092-8f90-4f6b-873c-8715b64b8aff', 1, '2023-12-23', 'Única semanas más peso principales existe.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c9a949e5-e650-4d95-9e2e-49ed06e5d087', 19, '2020-01-17', 'Hay cultura siquiera supuesto gran.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c9a949e5-e650-4d95-9e2e-49ed06e5d087', 7, '2025-07-07', 'Amigo viaje acto común.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('a4e5cbb3-36f7-43d8-a65a-e30fc1361e56', 20, '2023-03-29', 'Ninguna si muerto datos pie vez.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('447e48dc-861c-41e6-920e-a2dec785101f', 16, '2020-06-01', 'Otra mí lópez realidad jamás.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('447e48dc-861c-41e6-920e-a2dec785101f', 15, '2021-05-05', 'Países primeros entrada capacidad vida.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('3a535951-40fd-4959-a34e-07b29f675ecc', 18, '2018-07-14', 'Sabía salud habría precios serie piel.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70', 13, '2019-10-10', 'Secretario energía autoridades.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70', 1, '2016-02-29', 'Sólo si presente aquellas mañana.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6052a417-6725-4fab-b7dd-7f498454cd47', 15, '2018-04-18', 'Siquiera sido acuerdo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6052a417-6725-4fab-b7dd-7f498454cd47', 5, '2017-03-14', 'Precisamente algunas después un sería.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 9, '2025-06-16', 'Mal pregunta está señor.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 17, '2021-07-18', 'Norte en comunidad vivir.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 20, '2023-06-28', 'República deja importante en siguientes unidad fiscal.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cbd398cc-dfde-41c4-b7b1-ca32cc99945f', 14, '2016-03-19', 'Se presidente lópez camino sí izquierda.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cbd398cc-dfde-41c4-b7b1-ca32cc99945f', 18, '2021-09-23', 'También apoyo tema tuvo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f740b251-4264-4220-8400-706331f650af', 11, '2022-11-16', 'Cosas estamos fuera una está.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f740b251-4264-4220-8400-706331f650af', 19, '2024-05-02', 'Ésta arte tomar informe.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', 10, '2016-06-04', 'Suelo técnica región tampoco.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', 2, '2023-12-12', 'Local cuatro dónde pudo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('97d5d278-c876-4078-9dba-2940edfed9a0', 14, '2017-10-21', 'Últimos algún encuentran puesto hechos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('97d5d278-c876-4078-9dba-2940edfed9a0', 13, '2022-09-22', 'Son hacia nuestros sur.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('a329242d-9e38-4178-aa8e-5b7497209897', 11, '2018-01-08', 'Podemos siete estaban internacional.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('fe2cc660-dd15-4d31-ac72-56114bdb6b92', 10, '2020-02-29', 'Dicho tenemos sistema algunos dio.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('fd01c50f-f3dd-4517-96c0-c0e65330a692', 1, '2016-11-10', 'Siguientes análisis formación miembros actitud cuenta he.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('fd01c50f-f3dd-4517-96c0-c0e65330a692', 10, '2021-04-22', 'Suerte producción entrar capaz.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f56cc0bc-1765-4334-9594-73dcc9deac8e', 5, '2022-08-27', 'Me pregunta c abril anterior partir razón.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('f56cc0bc-1765-4334-9594-73dcc9deac8e', 7, '2015-11-03', 'Puso unidad pequeño producto.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('1c861cbf-991d-4820-b3f0-98538fb0d454', 19, '2018-08-08', 'Español niveles niño señora cómo piel estoy.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 12, '2018-03-25', 'Industria carne había realizar.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 6, '2025-09-18', 'Derechos visto o realizar tras vivir imagen.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 2, '2017-11-09', 'Posible precios práctica importancia podía.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d1ec4069-41a0-4317-a6c6-84914d108257', 7, '2025-06-30', 'Uso decisión europea más somos es sociedad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d1ec4069-41a0-4317-a6c6-84914d108257', 8, '2021-03-08', 'Larga estados me causa claro septiembre les análisis.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 12, '2020-09-17', 'Máximo importancia permite argentina.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 17, '2021-01-10', 'Lugar congreso figura estaban.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 15, '2024-11-30', 'Ii asimismo amigo humana.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0deef39b-719e-4f3a-a84f-2072803b2548', 18, '2024-08-20', 'Sino comunicación popular estamos será mayoría recuerdo además.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0deef39b-719e-4f3a-a84f-2072803b2548', 7, '2019-12-20', 'Crisis grande sur tu ministerio premio sólo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('0deef39b-719e-4f3a-a84f-2072803b2548', 15, '2016-11-19', 'Región van propia quizá días.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5156864c-fa59-4e48-b357-477838800efc', 12, '2021-10-31', 'Compañía fecha ciudad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5156864c-fa59-4e48-b357-477838800efc', 1, '2018-09-28', 'Mí personal momento sean todo campaña propios.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d911f0a5-9268-4eb4-87e9-508d7c99b753', 5, '2025-07-13', 'Modo obra en hora.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 14, '2022-01-31', 'Ya pesetas sistemas unos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 15, '2018-08-18', 'Posibilidad perdido términos pasa.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 17, '2023-11-13', 'Ve entrada plaza universidad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('b2eef54b-21a7-45ec-a693-bc60f1d6e293', 20, '2023-09-04', 'Favor hermano televisión cosas teoría fuego cultural señaló.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('b2eef54b-21a7-45ec-a693-bc60f1d6e293', 9, '2023-06-17', 'Dar situación uno voy principio de.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('b2eef54b-21a7-45ec-a693-bc60f1d6e293', 8, '2017-05-29', 'Organización blanca actitud.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('3854a76e-ee29-4976-b630-1d7e18fb9887', 15, '2015-12-22', 'Joven torno política intereses.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 13, '2023-06-13', 'Formas nuestras momento decir.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 10, '2019-08-04', 'Común vida pie propia único presente valores.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 16, '2017-10-09', 'Cinco presenta principios durante hospital con alrededor.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 11, '2024-11-10', 'Estilo jorge francisco cargo alto dan pacientes.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 9, '2017-02-15', 'Política hijos sean policía hacia allá evitar cuenta.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 10, '2018-11-17', 'Quién movimiento a siempre.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 4, '2016-06-06', 'Ser ellos enfermedad dirección.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 3, '2021-08-19', 'Población esta el aún guerra acerca.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd', 15, '2015-12-01', 'Fueron ideas mayo boca país.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd', 13, '2025-06-21', 'Riesgo concepto vez puede.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('bc6e7a77-d709-401c-bea7-82715eeb1a29', 16, '2020-03-24', 'Mejores europea calle estaba aún congreso.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d54d7239-e49a-4185-8875-4f71af08b789', 15, '2020-04-07', 'Ambos bien expresión siglo constitución.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('d54d7239-e49a-4185-8875-4f71af08b789', 4, '2022-09-04', 'Aspecto reforma algo rosa través ministro mí.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('8370857e-7e69-43a6-be63-78fc270c5fd5', 12, '2018-02-03', 'Paso amigo mujeres llamado.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('e8813bf8-7bbb-4370-a181-880c0c959aa1', 2, '2024-10-18', 'Blanca términos da bien hizo revolución.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a', 14, '2017-10-04', 'Mayoría finalmente españa valor origen pesar.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 11, '2025-10-04', 'I tres atrás informe dio noviembre peso antonio.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 1, '2022-01-28', 'Expresión podrá idea experiencia esto.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('44e4c099-cf6e-4926-85f1-ab5cb34c59a1', 10, '2020-12-01', 'Control deja ellos les casi resulta.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('a0c3c815-c664-4931-927f-e4109a545603', 7, '2019-01-02', 'Gente respuesta realidad mano servicio necesario.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5c1862f6-f802-41ae-a6fb-87dbc5555fb3', 20, '2018-03-31', 'Metros cierto tiene comisión industria población.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('5c1862f6-f802-41ae-a6fb-87dbc5555fb3', 7, '2022-12-21', 'Siempre marcha hubo expresión marco.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 16, '2018-12-08', 'Aquel mi noche.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 5, '2019-10-23', 'Máximo intereses grado siquiera producto.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 9, '2015-12-28', 'Pública pequeño hemos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

-- =============================================
-- PATIENT FAMILY HISTORY
-- =============================================

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 18, 'Sibling', 'Ocho humano ha nuestra ayer primeros voy.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c', 10, 'Father', 'Zonas a larga aumento profesional jefe poder.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('959aa1dd-346b-4542-8f99-0d5e75301249', 10, 'Grandparent', 'Misma semana a color unas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('f81c87d6-32f1-4c79-993a-18db4734ef65', 20, 'Mother', 'Sabía eran estuvo como.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 15, 'Sibling', 'Octubre oposición grupos volver humanos viejo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 2, 'Mother', 'Pp población hasta.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 14, 'Unspecified', 'Estructura marco siglo quien seguir.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 8, 'Father', 'Señor momentos recursos maría puede.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 9, 'Father', 'Popular hombre mis manos cerca tierra lejos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 1, 'Sibling', 'Propia elementos policía uno.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', 17, 'Unspecified', 'Santiago hospital tiempos no s tal padre importantes.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('7893292b-965a-41da-896a-d0780c91fdd5', 4, 'Sibling', 'Texto estaba servicios.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('87fb3c88-6653-45db-aa6c-20ea7512da64', 19, 'Mother', 'Ojos estuvo operación madrid día saber.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 10, 'Sibling', 'Hay aspecto acerca.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('43756f6c-c157-4a44-9c84-ab2d62fddcf7', 14, 'Unspecified', 'Tiempo deben peor.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('bbc67f38-a9eb-4379-aeaf-1560af0d1a34', 4, 'Sibling', 'Hablar sola corte algunas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('a754cbf1-a4ca-42dc-92c4-d980b6a25a6d', 19, 'Father', 'Tener peor siguientes nos escuela autoridades rey.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 12, 'Mother', 'Alta carlos habrá sobre casa existencia importancia.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('167dedde-166c-45e4-befc-4f1c9b7184ad', 3, 'Unspecified', 'Hasta sean ejemplo cual habrá contrario persona.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('72eca572-4ecf-4be8-906b-40e89e0d9a08', 17, 'Sibling', 'Espacio modo única militar mira alrededor.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', 20, 'Unspecified', 'Mujeres esa aunque estas desarrollo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', 7, 'Father', 'Sectores mayo político decir.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', 18, 'Sibling', 'Aquella tenía hablar.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 10, 'Grandparent', 'Radio santiago secretario club en ejemplo sociedad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 5, 'Father', 'Podrá dio buenos volver.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 1, 'Unspecified', 'Este hemos quizá encontrar valor.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 20, 'Unspecified', 'Dónde gonzález proyecto.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('edb1d693-b308-4ff6-8fd4-9e20561317e8', 11, 'Unspecified', 'Zonas clase luz fútbol mantener.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 19, 'Father', 'Efecto comunicación puerto grandes plaza régimen cada creo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', 3, 'Sibling', 'Allá siete aún gracias.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', 8, 'Sibling', 'Haber se veces niños ya uno.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', 16, 'Mother', 'Quería gran españa estar has.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', 2, 'Unspecified', 'Don nuestros tener tema soy sectores cabeza.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 4, 'Mother', 'Haciendo grupo el común libertad oro eso.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3', 9, 'Unspecified', 'Muchos consecuencia méxico deseo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 19, 'Father', 'Puntos m atrás pues encuentran fiscal ocasión conseguir.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 6, 'Grandparent', 'Llegado empresa si pensar carne ante siendo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('c572a4c7-e475-4d18-85da-417abcd00903', 16, 'Grandparent', 'Atrás niños estudio todavía elementos obstante.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('43ae2e81-ac13-40ac-949c-9e4f51d76098', 20, 'Grandparent', 'Voluntad izquierda enfermedad hacía.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('a4e5cbb3-36f7-43d8-a65a-e30fc1361e56', 20, 'Sibling', 'Argentina santa rey quizá metros menos posibilidades.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('6052a417-6725-4fab-b7dd-7f498454cd47', 15, 'Father', 'Encontrar precisamente carlos educación programas y.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('f740b251-4264-4220-8400-706331f650af', 19, 'Mother', 'Ya ha ayuda parte tierra noche estado.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', 2, 'Unspecified', 'País partidos juego mismos desde.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('fe2cc660-dd15-4d31-ac72-56114bdb6b92', 10, 'Sibling', 'Servicio rafael tarde tenemos.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('fd01c50f-f3dd-4517-96c0-c0e65330a692', 1, 'Grandparent', 'R unos historia necesidad también proceso mitad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('1c861cbf-991d-4820-b3f0-98538fb0d454', 19, 'Grandparent', 'Ojos social lejos nuevas quería.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 12, 'Mother', 'Sistemas sur económico todo menos encontrar estaban reunión.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 6, 'Sibling', 'Aun sabe tenían segundo compañía cosas esa capaz.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 2, 'Mother', 'Hablar problema sería quedó fuerza tiempo don.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 12, 'Grandparent', 'Personal propios modo peor libertad.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 17, 'Father', 'Capaz pacientes fuerza luego.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 17, 'Unspecified', 'Siguiente visto ese esas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 10, 'Unspecified', 'Voy finalmente diversas.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 16, 'Mother', 'Metros posición han con fueron felipe noche.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 9, 'Mother', 'Grupos tanto habla partidos pasar primeras vida todavía.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 3, 'Mother', 'Socialista d lucha francia natural voz.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('d54d7239-e49a-4185-8875-4f71af08b789', 4, 'Mother', 'Soy norte salud tengo estoy.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 11, 'Father', 'Capital considera primeros civil contra energía tres va.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('44e4c099-cf6e-4926-85f1-ab5cb34c59a1', 10, 'Mother', 'Oficial mí zonas existen estar mundial precisamente.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('5c1862f6-f802-41ae-a6fb-87dbc5555fb3', 7, 'Unspecified', 'Produce total tipo próximo.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 16, 'Mother', 'Medio momentos así político muerte amor.')
ON CONFLICT (patient_id, condition_id) DO NOTHING;

-- =============================================
-- PATIENT MEDICATIONS
-- =============================================

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 5, '216mcg', 'twice daily', '2025-07-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 3, '360mcg', 'daily', '2023-11-28')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 16, '413ml', 'twice daily', '2023-08-11')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c', 17, '423ml', 'three times daily', '2021-01-22')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('959aa1dd-346b-4542-8f99-0d5e75301249', 12, '430ml', 'weekly', '2022-12-03')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('59402562-ce5f-450e-8e6c-9630514fe164', 1, '361mg', 'weekly', '2023-10-01')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('59402562-ce5f-450e-8e6c-9630514fe164', 19, '228mg', 'three times daily', '2024-07-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f81c87d6-32f1-4c79-993a-18db4734ef65', 18, '231mg', 'three times daily', '2021-10-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f81c87d6-32f1-4c79-993a-18db4734ef65', 11, '108mcg', 'weekly', '2022-09-09')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0b6b8229-4027-4ec7-8bce-c805de96ced3', 18, '300mcg', 'as needed', '2025-10-15')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0b6b8229-4027-4ec7-8bce-c805de96ced3', 20, '47mcg', 'as needed', '2024-02-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0b6b8229-4027-4ec7-8bce-c805de96ced3', 12, '344ml', 'weekly', '2023-09-16')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 10, '62ml', 'daily', '2023-10-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 18, '432mcg', 'three times daily', '2023-07-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 14, '466ml', 'as needed', '2024-12-14')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 3, '318mg', 'twice daily', '2025-04-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 9, '144mg', 'twice daily', '2024-03-26')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 14, '56mcg', 'twice daily', '2021-10-15')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 6, '492ml', 'twice daily', '2025-06-01')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 1, '336mg', 'weekly', '2025-08-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cd0c2f0c-de08-439c-93c9-0feab1d433cc', 3, '460mcg', 'three times daily', '2023-04-06')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cd0c2f0c-de08-439c-93c9-0feab1d433cc', 6, '455ml', 'weekly', '2022-03-04')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', 2, '370ml', 'twice daily', '2021-09-01')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', 1, '369mcg', 'weekly', '2023-11-22')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('7893292b-965a-41da-896a-d0780c91fdd5', 17, '275ml', 'twice daily', '2025-01-08')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('7893292b-965a-41da-896a-d0780c91fdd5', 9, '121ml', 'three times daily', '2024-01-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('7893292b-965a-41da-896a-d0780c91fdd5', 5, '378ml', 'as needed', '2022-08-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('87fb3c88-6653-45db-aa6c-20ea7512da64', 4, '370mg', 'twice daily', '2023-08-09')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('87fb3c88-6653-45db-aa6c-20ea7512da64', 17, '32mcg', 'weekly', '2022-07-08')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 8, '425ml', 'as needed', '2023-06-14')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 17, '118mg', 'twice daily', '2022-11-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('43756f6c-c157-4a44-9c84-ab2d62fddcf7', 13, '116mcg', 'twice daily', '2022-12-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('43756f6c-c157-4a44-9c84-ab2d62fddcf7', 5, '35mg', 'twice daily', '2024-08-17')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d8e1fa52-0a65-4917-b410-2954e05a34e5', 12, '453ml', 'twice daily', '2023-01-18')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d8e1fa52-0a65-4917-b410-2954e05a34e5', 11, '166mg', 'twice daily', '2023-05-03')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d8e1fa52-0a65-4917-b410-2954e05a34e5', 6, '365ml', 'daily', '2023-11-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('bbc67f38-a9eb-4379-aeaf-1560af0d1a34', 10, '58mg', 'daily', '2021-01-19')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e', 10, '9mcg', 'daily', '2023-10-25')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('309df411-1d1a-4d00-a34e-36e8c32da210', 15, '119ml', 'daily', '2021-05-05')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('309df411-1d1a-4d00-a34e-36e8c32da210', 11, '71mg', 'three times daily', '2023-10-13')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('663d036b-a19b-4557-af37-d68a9ce4976d', 15, '391mg', 'as needed', '2025-02-17')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('663d036b-a19b-4557-af37-d68a9ce4976d', 9, '50ml', 'three times daily', '2020-11-01')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('663d036b-a19b-4557-af37-d68a9ce4976d', 8, '184mcg', 'weekly', '2025-09-29')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a754cbf1-a4ca-42dc-92c4-d980b6a25a6d', 6, '496ml', 'as needed', '2025-07-28')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a754cbf1-a4ca-42dc-92c4-d980b6a25a6d', 18, '99ml', 'three times daily', '2022-05-24')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 10, '290mg', 'weekly', '2022-11-27')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 7, '349mcg', 'twice daily', '2023-11-01')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 6, '397mg', 'three times daily', '2021-11-30')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6661483b-705b-412a-8bbd-39c0af0dadb1', 18, '148mg', 'three times daily', '2024-05-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('676491c4-f31a-42b6-a991-a8dd09bbb1f0', 10, '89mcg', 'daily', '2023-08-08')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('3a9e8e0e-6367-409d-a81c-9852069c710e', 7, '206ml', 'twice daily', '2025-05-22')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('3a9e8e0e-6367-409d-a81c-9852069c710e', 17, '49mcg', 'as needed', '2022-03-06')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('3a9e8e0e-6367-409d-a81c-9852069c710e', 8, '442mcg', 'twice daily', '2025-05-02')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('167dedde-166c-45e4-befc-4f1c9b7184ad', 6, '85ml', 'daily', '2023-03-13')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('72eca572-4ecf-4be8-906b-40e89e0d9a08', 11, '495mcg', 'three times daily', '2022-11-27')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('72eca572-4ecf-4be8-906b-40e89e0d9a08', 18, '24ml', 'three times daily', '2022-09-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', 13, '202mg', 'twice daily', '2022-10-26')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', 2, '359mcg', 'daily', '2025-06-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', 17, '69mg', 'daily', '2024-11-02')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', 8, '84mg', 'twice daily', '2022-01-25')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', 5, '456mg', 'three times daily', '2024-05-09')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', 18, '6mg', 'daily', '2020-11-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('9f86a53f-f0e1-446d-89f0-86b086dd12a9', 9, '461mcg', 'daily', '2023-11-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('9f86a53f-f0e1-446d-89f0-86b086dd12a9', 20, '287mcg', 'daily', '2022-03-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('ae1f5c92-f3cf-43d8-918f-aaad6fb46c05', 13, '13mcg', 'as needed', '2021-03-30')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('ae1f5c92-f3cf-43d8-918f-aaad6fb46c05', 4, '177ml', 'twice daily', '2023-06-27')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('ae1f5c92-f3cf-43d8-918f-aaad6fb46c05', 16, '152mcg', 'weekly', '2023-12-26')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', 16, '149ml', 'twice daily', '2023-12-01')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', 1, '134mg', 'as needed', '2021-05-11')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('7f839ee8-bdd6-4a63-83e8-30db007565e2', 5, '443ml', 'three times daily', '2024-10-16')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('7f839ee8-bdd6-4a63-83e8-30db007565e2', 20, '494mcg', 'weekly', '2024-07-16')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('67aa999f-9d31-4b61-a097-35097ea0d082', 18, '233mcg', 'twice daily', '2022-11-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('41aa2fbc-8ef4-4448-8686-399a1cd54be9', 16, '163ml', 'as needed', '2024-07-06')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('111769f3-1a1b-44a9-9670-f4f2e424d1d2', 1, '12ml', 'as needed', '2025-09-25')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('111769f3-1a1b-44a9-9670-f4f2e424d1d2', 19, '317mcg', 'weekly', '2021-04-04')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', 14, '457mg', 'three times daily', '2025-08-26')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', 16, '251mcg', 'as needed', '2023-03-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', 2, '52ml', 'three times daily', '2022-09-03')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6a8b6d41-8d20-4bc5-8d48-538d348f6086', 2, '137mg', 'weekly', '2021-03-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6a8b6d41-8d20-4bc5-8d48-538d348f6086', 9, '337mg', 'twice daily', '2023-10-16')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 2, '483mg', 'as needed', '2021-03-17')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 13, '171ml', 'three times daily', '2023-03-18')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 19, '36mcg', 'as needed', '2021-10-03')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 5, '341mcg', 'three times daily', '2023-11-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 6, '266mg', 'weekly', '2023-08-27')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 9, '269ml', 'three times daily', '2023-08-27')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 11, '363mg', 'twice daily', '2023-10-19')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 16, '174mcg', 'as needed', '2021-01-01')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('edb1d693-b308-4ff6-8fd4-9e20561317e8', 13, '305ml', 'as needed', '2022-04-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('9511f9b9-a450-489c-92b9-ac306733cee4', 18, '392ml', 'three times daily', '2021-04-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('9511f9b9-a450-489c-92b9-ac306733cee4', 15, '461mcg', 'daily', '2023-03-19')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 16, '300mg', 'twice daily', '2023-07-11')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 1, '334mcg', 'daily', '2021-03-22')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 17, '94mg', 'three times daily', '2024-04-22')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 13, '320ml', 'weekly', '2021-05-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 4, '394mcg', 'daily', '2023-10-30')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 8, '143mcg', 'three times daily', '2022-02-28')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', 7, '91mcg', 'weekly', '2022-08-05')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', 12, '66mg', 'daily', '2021-03-26')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', 5, '205mcg', 'twice daily', '2024-01-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', 13, '391mcg', 'weekly', '2023-05-28')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', 4, '382mg', 'weekly', '2025-01-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', 7, '303mg', 'three times daily', '2022-04-19')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', 16, '314ml', 'weekly', '2023-11-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 1, '207mcg', 'three times daily', '2022-01-14')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 8, '431mcg', 'three times daily', '2021-07-21')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('05bc2942-e676-42e9-ad01-ade9f7cc5aee', 7, '79ml', 'three times daily', '2021-04-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c78e7658-d517-4ca1-990b-e6971f8d108f', 5, '147ml', 'daily', '2020-12-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c78e7658-d517-4ca1-990b-e6971f8d108f', 8, '190ml', 'twice daily', '2022-03-11')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c78e7658-d517-4ca1-990b-e6971f8d108f', 13, '463ml', 'as needed', '2022-04-13')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('65474c27-8f72-4690-8f19-df9344e4be5e', 8, '309mcg', 'twice daily', '2024-04-05')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 15, '349ml', 'twice daily', '2024-06-02')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 5, '60ml', 'three times daily', '2022-02-28')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 3, '303mcg', 'daily', '2022-04-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3', 15, '59mcg', 'weekly', '2023-08-22')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3', 11, '430mcg', 'twice daily', '2023-07-24')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3', 16, '435mcg', 'three times daily', '2022-12-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 10, '149mg', 'three times daily', '2022-11-05')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 16, '118mcg', 'daily', '2022-05-06')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c572a4c7-e475-4d18-85da-417abcd00903', 18, '366mg', 'as needed', '2021-03-25')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3', 2, '253mg', 'weekly', '2022-10-16')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3', 4, '449mcg', 'weekly', '2024-03-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('9b02d89c-2c5b-4c51-8183-15ccd1184990', 4, '411mcg', 'twice daily', '2023-04-25')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('43ae2e81-ac13-40ac-949c-9e4f51d76098', 12, '246mcg', 'three times daily', '2024-10-06')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('43ae2e81-ac13-40ac-949c-9e4f51d76098', 7, '299ml', 'weekly', '2021-09-11')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('49a18092-8f90-4f6b-873c-8715b64b8aff', 19, '238ml', 'daily', '2020-12-15')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c9a949e5-e650-4d95-9e2e-49ed06e5d087', 18, '352ml', 'twice daily', '2023-10-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a4e5cbb3-36f7-43d8-a65a-e30fc1361e56', 11, '84mg', 'three times daily', '2025-03-17')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('447e48dc-861c-41e6-920e-a2dec785101f', 16, '403ml', 'weekly', '2024-09-27')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('447e48dc-861c-41e6-920e-a2dec785101f', 1, '178mcg', 'as needed', '2022-01-09')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('447e48dc-861c-41e6-920e-a2dec785101f', 20, '197mcg', 'weekly', '2021-02-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('3a535951-40fd-4959-a34e-07b29f675ecc', 19, '196mcg', 'twice daily', '2024-02-25')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70', 7, '433mg', 'twice daily', '2023-12-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6052a417-6725-4fab-b7dd-7f498454cd47', 20, '57ml', 'daily', '2025-06-19')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 4, '462mg', 'weekly', '2022-05-03')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 6, '26mg', 'as needed', '2025-04-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 16, '102mcg', 'daily', '2022-08-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cbd398cc-dfde-41c4-b7b1-ca32cc99945f', 3, '360mcg', 'as needed', '2025-02-17')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cbd398cc-dfde-41c4-b7b1-ca32cc99945f', 17, '33ml', 'weekly', '2024-07-02')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cbd398cc-dfde-41c4-b7b1-ca32cc99945f', 14, '40mcg', 'daily', '2023-06-26')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f740b251-4264-4220-8400-706331f650af', 3, '487mg', 'as needed', '2021-09-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f740b251-4264-4220-8400-706331f650af', 9, '101mcg', 'as needed', '2023-01-13')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', 13, '464ml', 'daily', '2022-03-22')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', 12, '237mg', 'three times daily', '2021-08-28')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('97d5d278-c876-4078-9dba-2940edfed9a0', 20, '46mcg', 'daily', '2023-04-26')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('97d5d278-c876-4078-9dba-2940edfed9a0', 19, '404mcg', 'twice daily', '2025-04-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('97d5d278-c876-4078-9dba-2940edfed9a0', 14, '364ml', 'daily', '2023-09-16')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a329242d-9e38-4178-aa8e-5b7497209897', 9, '101mcg', 'as needed', '2022-07-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a329242d-9e38-4178-aa8e-5b7497209897', 17, '65mcg', 'daily', '2025-05-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a329242d-9e38-4178-aa8e-5b7497209897', 13, '332ml', 'weekly', '2023-12-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('fe2cc660-dd15-4d31-ac72-56114bdb6b92', 2, '311mg', 'three times daily', '2025-01-01')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('fe2cc660-dd15-4d31-ac72-56114bdb6b92', 13, '424mcg', 'twice daily', '2023-09-19')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('fd01c50f-f3dd-4517-96c0-c0e65330a692', 8, '358mcg', 'twice daily', '2025-08-24')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f56cc0bc-1765-4334-9594-73dcc9deac8e', 20, '417mcg', 'weekly', '2024-04-06')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f56cc0bc-1765-4334-9594-73dcc9deac8e', 8, '368ml', 'weekly', '2024-04-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('f56cc0bc-1765-4334-9594-73dcc9deac8e', 14, '8mg', 'as needed', '2024-06-11')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('1c861cbf-991d-4820-b3f0-98538fb0d454', 12, '184mcg', 'daily', '2021-02-14')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 5, '149mg', 'weekly', '2021-10-28')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 1, '352mg', 'weekly', '2023-03-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 14, '485mcg', 'daily', '2023-01-05')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d1ec4069-41a0-4317-a6c6-84914d108257', 10, '157ml', 'twice daily', '2024-09-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d1ec4069-41a0-4317-a6c6-84914d108257', 20, '232mg', 'as needed', '2022-02-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 12, '130ml', 'daily', '2021-01-30')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 16, '256ml', 'as needed', '2024-03-06')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 17, '217mg', 'three times daily', '2022-08-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0deef39b-719e-4f3a-a84f-2072803b2548', 12, '20mcg', 'weekly', '2022-04-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('0deef39b-719e-4f3a-a84f-2072803b2548', 20, '178mcg', 'daily', '2025-06-19')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('5156864c-fa59-4e48-b357-477838800efc', 13, '262mg', 'three times daily', '2022-11-05')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('5156864c-fa59-4e48-b357-477838800efc', 18, '496mg', 'weekly', '2023-01-12')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d911f0a5-9268-4eb4-87e9-508d7c99b753', 16, '125ml', 'weekly', '2021-04-13')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 4, '162ml', 'as needed', '2023-02-04')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 9, '97mcg', 'three times daily', '2023-10-03')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 5, '156ml', 'twice daily', '2023-03-13')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('b2eef54b-21a7-45ec-a693-bc60f1d6e293', 20, '239mcg', 'twice daily', '2024-05-17')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('3854a76e-ee29-4976-b630-1d7e18fb9887', 18, '186mg', 'three times daily', '2021-09-12')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 7, '458mg', 'twice daily', '2021-02-25')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 6, '165mg', 'three times daily', '2022-05-11')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 9, '49mcg', 'three times daily', '2021-02-08')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 11, '431mg', 'as needed', '2023-12-20')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 3, '22mcg', 'three times daily', '2024-01-25')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 10, '47ml', 'daily', '2021-01-17')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 18, '158ml', 'as needed', '2025-09-29')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 3, '43mcg', 'as needed', '2024-04-12')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 9, '139mg', 'weekly', '2025-03-22')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd', 1, '36mcg', 'daily', '2025-03-17')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd', 13, '139mg', 'twice daily', '2025-04-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('bc6e7a77-d709-401c-bea7-82715eeb1a29', 5, '48mg', 'three times daily', '2025-04-08')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('bc6e7a77-d709-401c-bea7-82715eeb1a29', 3, '175ml', 'as needed', '2020-11-02')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('bc6e7a77-d709-401c-bea7-82715eeb1a29', 2, '20mg', 'daily', '2021-05-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('d54d7239-e49a-4185-8875-4f71af08b789', 14, '251mcg', 'daily', '2025-06-16')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('8370857e-7e69-43a6-be63-78fc270c5fd5', 18, '150ml', 'three times daily', '2020-11-18')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('e8813bf8-7bbb-4370-a181-880c0c959aa1', 7, '151ml', 'daily', '2021-04-02')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a', 1, '72mg', 'weekly', '2021-07-09')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a', 7, '138mcg', 'weekly', '2022-02-27')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a', 4, '70ml', 'twice daily', '2024-06-30')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 5, '399ml', 'three times daily', '2022-07-12')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 16, '232mg', 'three times daily', '2023-05-26')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 7, '445ml', 'three times daily', '2024-04-11')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('44e4c099-cf6e-4926-85f1-ab5cb34c59a1', 3, '225mcg', 'weekly', '2023-10-23')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a0c3c815-c664-4931-927f-e4109a545603', 10, '21mcg', 'as needed', '2020-11-27')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a0c3c815-c664-4931-927f-e4109a545603', 20, '358ml', 'daily', '2022-05-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('a0c3c815-c664-4931-927f-e4109a545603', 16, '415mcg', 'three times daily', '2024-08-08')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('5c1862f6-f802-41ae-a6fb-87dbc5555fb3', 3, '183mcg', 'as needed', '2025-09-14')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 13, '291mg', 'as needed', '2024-07-10')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 7, '379mg', 'weekly', '2023-10-03')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 5, '381ml', 'three times daily', '2024-04-07')
ON CONFLICT (patient_id, medication_id) DO NOTHING;

-- =============================================
-- PATIENT ALLERGIES
-- =============================================

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 19, 'moderate', 'Modo electoral actitud mira d.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 15, 'mild', 'Unas estaban m pueda violencia realizar suelo ellos.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c', 11, 'mild', 'Se mujer ya ya luz lópez.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c', 9, 'mild', 'Desarrollo empresa época humanos varias unión don tengo.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('59402562-ce5f-450e-8e6c-9630514fe164', 4, 'severe', 'Podemos actividades esa realidad.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('0b6b8229-4027-4ec7-8bce-c805de96ced3', 11, 'moderate', 'Dijo antonio tipo siquiera razones datos.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('0b6b8229-4027-4ec7-8bce-c805de96ced3', 20, 'severe', 'Uso serie blanca régimen cuenta electoral material.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 14, 'severe', 'Podía américa dado año fuera mitad.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 20, 'mild', 'Atención proyectos entre bien.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('cd0c2f0c-de08-439c-93c9-0feab1d433cc', 14, 'mild', 'Familia socialista mantener san.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('cd0c2f0c-de08-439c-93c9-0feab1d433cc', 7, 'mild', 'Está mejor posición miguel chile ejército práctica.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', 17, 'mild', 'Propios muchos niños cuenta siglo peso llegado hacen.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('87fb3c88-6653-45db-aa6c-20ea7512da64', 17, 'severe', 'Contenido hora porque ya tratamiento.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 8, 'mild', 'Tarde plan otra ambiente usted guerra características.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 11, 'moderate', 'Diversos existen conocimiento hospital ocho.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e', 9, 'mild', 'Industria camino carta.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e', 10, 'moderate', 'Jorge manera mes hacía.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('309df411-1d1a-4d00-a34e-36e8c32da210', 9, 'severe', 'Manos efecto padres.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('309df411-1d1a-4d00-a34e-36e8c32da210', 15, 'severe', 'Pone aquellas derecho nombre mano zona países.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 13, 'severe', 'Deja información casos grupo ahora.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('6661483b-705b-412a-8bbd-39c0af0dadb1', 1, 'moderate', 'Color club política silencio puerta.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('676491c4-f31a-42b6-a991-a8dd09bbb1f0', 8, 'severe', 'Conciencia solamente ello mil muerte.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('3a9e8e0e-6367-409d-a81c-9852069c710e', 15, 'moderate', 'Su problemas primero ahí.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('3a9e8e0e-6367-409d-a81c-9852069c710e', 9, 'moderate', 'Rosa sólo máximo g.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', 5, 'mild', 'Naturaleza hermano presenta.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('9f86a53f-f0e1-446d-89f0-86b086dd12a9', 11, 'mild', 'Mismos vez nuestra cargo.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', 9, 'moderate', 'Pregunta comunicación más primeras pedro premio.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('7f839ee8-bdd6-4a63-83e8-30db007565e2', 15, 'severe', 'Yo pasó tenían visita.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', 9, 'mild', 'Lado gran libros viejo figura francisco programas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', 6, 'moderate', 'Aire hubiera político resulta debido esa propuesta.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 8, 'moderate', 'Actual obras produce realizar comenzó diversos miedo da.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 11, 'mild', 'Mismo torno interior afirmó.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 6, 'mild', 'Conocimiento área conjunto iba.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 15, 'mild', 'Resto dicen llegó llevar lucha color.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 9, 'moderate', 'Tres hacen respecto voluntad materia paz.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('edb1d693-b308-4ff6-8fd4-9e20561317e8', 12, 'moderate', 'Respecto mujer estas suficiente.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('edb1d693-b308-4ff6-8fd4-9e20561317e8', 5, 'moderate', 'Mañana demasiado puerto.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('9511f9b9-a450-489c-92b9-ac306733cee4', 12, 'severe', 'Comercio mayores joven estoy podemos.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('9511f9b9-a450-489c-92b9-ac306733cee4', 16, 'severe', 'Corte hubiera mitad salud desde valores cosa.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 16, 'moderate', 'Hora año demasiado muy.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 13, 'mild', 'Visita pues salir trata.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 20, 'severe', 'Diez lado tales realidad junio he.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 18, 'severe', 'Española período algo políticas atención esa.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', 16, 'severe', 'Podemos pequeño aquellas buscar millones siempre.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', 3, 'severe', 'Te ley están precisamente particular estos.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', 10, 'moderate', 'He programas habrá sólo.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', 1, 'severe', 'Libre seguir vamos universidad.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', 17, 'severe', 'S quien octubre ciencia mucha posibilidad oro problemas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 16, 'mild', 'Bien mirada sala dejar quien expresión formas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 1, 'moderate', 'Llegar políticos empresas fue hospital buen.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('05bc2942-e676-42e9-ad01-ade9f7cc5aee', 7, 'mild', 'Color presencia donde dólares.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('65474c27-8f72-4690-8f19-df9344e4be5e', 12, 'severe', 'Población posibilidad medio esos.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('65474c27-8f72-4690-8f19-df9344e4be5e', 17, 'moderate', 'Nuevas hacia natural peso junto tener.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 3, 'moderate', 'Ésta somos humano natural.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3', 11, 'severe', 'Según presenta me político ellas corte.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 10, 'mild', 'Llegado yo autoridades juicio hospital empresas ver.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 19, 'moderate', 'Movimiento pueda momento corazón.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('c572a4c7-e475-4d18-85da-417abcd00903', 18, 'moderate', 'Toma así muchas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3', 7, 'severe', 'Energía cuya marco diez.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('49a18092-8f90-4f6b-873c-8715b64b8aff', 13, 'mild', 'Principales unión director tribunal sido prueba.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('49a18092-8f90-4f6b-873c-8715b64b8aff', 19, 'moderate', 'Calidad persona capacidad acto dejar realizar había posición.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('c9a949e5-e650-4d95-9e2e-49ed06e5d087', 17, 'severe', 'Campaña miembros allí entre en crecimiento eso pueda.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('a4e5cbb3-36f7-43d8-a65a-e30fc1361e56', 10, 'mild', 'Gobierno este jefe dan época el encuentro precisamente.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('a4e5cbb3-36f7-43d8-a65a-e30fc1361e56', 1, 'moderate', 'Sus vino primera aún.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('3a535951-40fd-4959-a34e-07b29f675ecc', 3, 'severe', 'Hijo estuvo adelante proyectos.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70', 17, 'moderate', 'Electoral sea decía casos sería conocimiento hermano libros.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70', 16, 'mild', 'Tenido tener humano ha necesario paz.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 7, 'moderate', 'Aquellos principio cómo mujeres del.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 11, 'severe', 'Quiere bien u hemos sistema rey salir.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('f740b251-4264-4220-8400-706331f650af', 8, 'mild', 'Edad distintas marzo podemos personal.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', 14, 'moderate', 'Pesar mesa habría socialista nombre pedro.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('97d5d278-c876-4078-9dba-2940edfed9a0', 17, 'moderate', 'Santa misma sociedad personas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('a329242d-9e38-4178-aa8e-5b7497209897', 7, 'mild', 'Verdad zona teoría condiciones acerca.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('a329242d-9e38-4178-aa8e-5b7497209897', 14, 'mild', 'Nuevas boca unos piel espera carne vamos.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('fe2cc660-dd15-4d31-ac72-56114bdb6b92', 4, 'severe', 'Quién derecha intereses santa.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('fe2cc660-dd15-4d31-ac72-56114bdb6b92', 8, 'severe', 'Supuesto éxito caso aun.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('fd01c50f-f3dd-4517-96c0-c0e65330a692', 12, 'moderate', 'Forma éste mejores vuelta persona puerto mientras.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 19, 'mild', 'Hubo punto hora mano entre esas hijos te.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d1ec4069-41a0-4317-a6c6-84914d108257', 18, 'mild', 'Último octubre principal elementos debido mejor metros nuestros.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d1ec4069-41a0-4317-a6c6-84914d108257', 7, 'moderate', 'Mundo mira junio ii pequeña deseo educación persona.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 4, 'severe', 'Como santa universidad derecha agua mano.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('0deef39b-719e-4f3a-a84f-2072803b2548', 16, 'severe', 'Consumo pedro trabajar persona allá adelante movimiento hace.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('5156864c-fa59-4e48-b357-477838800efc', 14, 'mild', 'Algunos asociación vía concepto comunicación g.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d911f0a5-9268-4eb4-87e9-508d7c99b753', 5, 'moderate', 'Nosotros decisión ayer términos.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d911f0a5-9268-4eb4-87e9-508d7c99b753', 13, 'moderate', 'Propio justicia tendrá r hijo precios.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 18, 'severe', 'Poner formas dice poco cama operación porque.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 12, 'severe', 'Volver capital he costa problema origen viejo.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('b2eef54b-21a7-45ec-a693-bc60f1d6e293', 8, 'moderate', 'Trabajadores club especie línea américa.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('3854a76e-ee29-4976-b630-1d7e18fb9887', 6, 'mild', 'Explicó cabo asimismo comisión da animales mano sistemas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 15, 'severe', 'Llega encontrar plaza sangre.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 13, 'severe', 'Marzo centro rosa zonas pública.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 18, 'mild', 'M centro efecto peso.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 16, 'severe', 'Control nuevas hora ideas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd', 16, 'severe', 'Ese deben hijo primero industria características ejemplo.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd', 15, 'mild', 'Paz finalmente mil trabajadores pequeña particular.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('bc6e7a77-d709-401c-bea7-82715eeb1a29', 17, 'moderate', 'Primeras decía resultados consecuencia.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d54d7239-e49a-4185-8875-4f71af08b789', 11, 'severe', 'Grandes mucho distintas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('d54d7239-e49a-4185-8875-4f71af08b789', 3, 'severe', 'Público servicio español nuevas.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('e8813bf8-7bbb-4370-a181-880c0c959aa1', 10, 'moderate', 'Muestra partidos deben joven grandes.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a', 3, 'severe', 'Vino miedo sentido justicia comercio teoría.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a', 12, 'mild', 'Tanto espacio campaña.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 7, 'severe', 'Podría rosa sabía.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('44e4c099-cf6e-4926-85f1-ab5cb34c59a1', 17, 'moderate', 'Cabeza próximo favor julio dinero miembros metros.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)
VALUES ('44e4c099-cf6e-4926-85f1-ab5cb34c59a1', 18, 'mild', 'Toda pasado varios eran.')
ON CONFLICT (patient_id, allergy_id) DO NOTHING;

-- =============================================
-- INSTITUTION EMAILS
-- =============================================

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '163749fb-8b46-4447-a8b7-95b4a59531b6'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@despacho-grijalva-mascarenas-y-parra.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '163749fb-8b46-4447-a8b7-95b4a59531b6'::uuid AND email_address = 'contacto@despacho-grijalva-mascarenas-y-parra.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '83b74179-f6ef-4219-bc70-c93f4393a350'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@laboratorios-saldivar-santillan-y-villanueva.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '83b74179-f6ef-4219-bc70-c93f4393a350'::uuid AND email_address = 'contacto@laboratorios-saldivar-santillan-y-villanueva.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '50503414-ca6d-4c1a-a34f-18719e2fd555'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@trejo-vigil-e-hijos.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '50503414-ca6d-4c1a-a34f-18719e2fd555'::uuid AND email_address = 'contacto@trejo-vigil-e-hijos.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '9b581d3c-9e93-4f39-80bb-294752065866'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-barajas-del-valle-y-carrero.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '9b581d3c-9e93-4f39-80bb-294752065866'::uuid AND email_address = 'contacto@club-barajas-del-valle-y-carrero.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'e0e34926-8d48-4db0-afb9-b20b6eeb1ecb'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@collazo-barrientos.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'e0e34926-8d48-4db0-afb9-b20b6eeb1ecb'::uuid AND email_address = 'contacto@collazo-barrientos.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '81941e1d-820a-4313-8177-e44278d9a981'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@corporacin-prado-davila-y-noriega.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '81941e1d-820a-4313-8177-e44278d9a981'::uuid AND email_address = 'contacto@corporacin-prado-davila-y-noriega.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'a725b15f-039b-4256-843a-51a2968633fd'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@corporacin-navarro-collado.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'a725b15f-039b-4256-843a-51a2968633fd'::uuid AND email_address = 'contacto@corporacin-navarro-collado.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@iglesias-soria-y-chacon.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d'::uuid AND email_address = 'contacto@iglesias-soria-y-chacon.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'd471d2d1-66a1-4de0-8754-127059786888'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@castillo-zayas.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'd471d2d1-66a1-4de0-8754-127059786888'::uuid AND email_address = 'contacto@castillo-zayas.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '8fd698b3-084d-4248-a28e-2708a5862e27'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-mesa-y-riojas.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '8fd698b3-084d-4248-a28e-2708a5862e27'::uuid AND email_address = 'contacto@club-mesa-y-riojas.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '7b96a7bb-041f-4331-be05-e97cab7dafc0'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@ojeda-y-baca-s-r-l-de-c-v.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '7b96a7bb-041f-4331-be05-e97cab7dafc0'::uuid AND email_address = 'contacto@ojeda-y-baca-s-r-l-de-c-v.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '5da54d5d-de0c-4277-a43e-6a89f987e77c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@murillo-y-quintanilla-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '5da54d5d-de0c-4277-a43e-6a89f987e77c'::uuid AND email_address = 'contacto@murillo-y-quintanilla-s-a.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'c9014e88-309c-4cb0-a28d-25b510e1e522'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@grupo-collazo-hinojosa-y-valdes.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'c9014e88-309c-4cb0-a28d-25b510e1e522'::uuid AND email_address = 'contacto@grupo-collazo-hinojosa-y-valdes.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '8e889f63-2c86-44ab-959f-fdc365353d5d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-verdugo-y-tejeda.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '8e889f63-2c86-44ab-959f-fdc365353d5d'::uuid AND email_address = 'contacto@club-verdugo-y-tejeda.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '67787f7c-fdee-4e30-80bd-89008ebfe419'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@zaragoza-e-hijos.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '67787f7c-fdee-4e30-80bd-89008ebfe419'::uuid AND email_address = 'contacto@zaragoza-e-hijos.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '4721cb90-8fb0-4fd6-b19e-160b4ac0c744'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@ceballos-tello.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '4721cb90-8fb0-4fd6-b19e-160b4ac0c744'::uuid AND email_address = 'contacto@ceballos-tello.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '09c54a60-6267-4439-9c8b-8c9012842942'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@banuelos-e-hijos.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '09c54a60-6267-4439-9c8b-8c9012842942'::uuid AND email_address = 'contacto@banuelos-e-hijos.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'a670c73c-cc47-42fe-88c9-0fa37359779b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@despacho-jaramillo-salas-y-carrero.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'a670c73c-cc47-42fe-88c9-0fa37359779b'::uuid AND email_address = 'contacto@despacho-jaramillo-salas-y-carrero.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '373769ab-b720-4269-bfb9-02546401ce99'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@paez-navarro-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '373769ab-b720-4269-bfb9-02546401ce99'::uuid AND email_address = 'contacto@paez-navarro-s-a.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@proyectos-mata-y-jurado.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75'::uuid AND email_address = 'contacto@proyectos-mata-y-jurado.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@laboratorios-trejo-garcia-y-lucero.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0'::uuid AND email_address = 'contacto@laboratorios-trejo-garcia-y-lucero.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '6c287a0e-9d4c-4574-932f-7d499aa4146c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@industrias-valverde-y-leal.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '6c287a0e-9d4c-4574-932f-7d499aa4146c'::uuid AND email_address = 'contacto@industrias-valverde-y-leal.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'a14c189c-ee90-4c29-b465-63d43a9d0010'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@castillo-lugo-y-zamora.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'a14c189c-ee90-4c29-b465-63d43a9d0010'::uuid AND email_address = 'contacto@castillo-lugo-y-zamora.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'e040eabc-0ac9-47f7-89ae-24246e1c12dd'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@montenegro-alcala-y-nieves.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'e040eabc-0ac9-47f7-89ae-24246e1c12dd'::uuid AND email_address = 'contacto@montenegro-alcala-y-nieves.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '9c8636c9-015b-4c18-a641-f5da698b6fd8'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@montenegro-y-pichardo-s-a-de-c-v.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '9c8636c9-015b-4c18-a641-f5da698b6fd8'::uuid AND email_address = 'contacto@montenegro-y-pichardo-s-a-de-c-v.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@lucio-marrero-y-asociados.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa'::uuid AND email_address = 'contacto@lucio-marrero-y-asociados.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '146a692b-6d46-4c26-a165-092fe771400e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@proyectos-iglesias-verdugo.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '146a692b-6d46-4c26-a165-092fe771400e'::uuid AND email_address = 'contacto@proyectos-iglesias-verdugo.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '6297ae0f-7fee-472d-87ec-e22b87ce6ffb'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@duenas-esquivel-s-r-l-de-c-v.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '6297ae0f-7fee-472d-87ec-e22b87ce6ffb'::uuid AND email_address = 'contacto@duenas-esquivel-s-r-l-de-c-v.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '66e6aa6c-596c-442e-85fb-b143875d0dfc'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@valencia-toro.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '66e6aa6c-596c-442e-85fb-b143875d0dfc'::uuid AND email_address = 'contacto@valencia-toro.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '46af545e-6db8-44ba-a7f9-9fd9617f4a09'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@solano-rodrigez.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '46af545e-6db8-44ba-a7f9-9fd9617f4a09'::uuid AND email_address = 'contacto@solano-rodrigez.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'a56b6787-94e9-49f0-8b3a-6ff5979773fc'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@laboratorios-vasquez-zepeda.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'a56b6787-94e9-49f0-8b3a-6ff5979773fc'::uuid AND email_address = 'contacto@laboratorios-vasquez-zepeda.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-montanez-almaraz.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf'::uuid AND email_address = 'contacto@club-montanez-almaraz.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '4bfa1a0a-0434-45e0-b454-03140b992f53'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@proyectos-alvarez-godinez-y-estevez.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '4bfa1a0a-0434-45e0-b454-03140b992f53'::uuid AND email_address = 'contacto@proyectos-alvarez-godinez-y-estevez.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '33ba98b9-c46a-47c1-b266-d8a4fe557290'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@grupo-carvajal-murillo-y-regalado.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '33ba98b9-c46a-47c1-b266-d8a4fe557290'::uuid AND email_address = 'contacto@grupo-carvajal-murillo-y-regalado.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'f4764cd3-47e9-4408-b0ee-9b9001c5459d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@industrias-bahena-nieto-y-acosta.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'f4764cd3-47e9-4408-b0ee-9b9001c5459d'::uuid AND email_address = 'contacto@industrias-bahena-nieto-y-acosta.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@villagomez-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8'::uuid AND email_address = 'contacto@villagomez-s-a.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@lucero-fajardo-e-hijos.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d'::uuid AND email_address = 'contacto@lucero-fajardo-e-hijos.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '8be78aaa-c408-452e-bf01-8e831ab5c63a'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@laboratorios-arellano-rosas.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '8be78aaa-c408-452e-bf01-8e831ab5c63a'::uuid AND email_address = 'contacto@laboratorios-arellano-rosas.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '8fb0899c-732e-4f03-8209-d52ef41a6a76'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@alba-casas.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '8fb0899c-732e-4f03-8209-d52ef41a6a76'::uuid AND email_address = 'contacto@alba-casas.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '3a9084e7-74c5-4e0b-b786-2c93d9cd39ee'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-zambrano-arredondo-y-guerra.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '3a9084e7-74c5-4e0b-b786-2c93d9cd39ee'::uuid AND email_address = 'contacto@club-zambrano-arredondo-y-guerra.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '54481b92-e5f5-421b-ba21-89bf520a2d87'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-ballesteros-cornejo.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '54481b92-e5f5-421b-ba21-89bf520a2d87'::uuid AND email_address = 'contacto@club-ballesteros-cornejo.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '68f1a02a-d348-4d1e-99ee-733d832a3f43'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@espinoza-y-villegas-a-c.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '68f1a02a-d348-4d1e-99ee-733d832a3f43'::uuid AND email_address = 'contacto@espinoza-y-villegas-a-c.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '36983990-abe8-4f1c-9c1b-863b9cab3ca9'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@alfaro-pacheco-y-villalpando.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '36983990-abe8-4f1c-9c1b-863b9cab3ca9'::uuid AND email_address = 'contacto@alfaro-pacheco-y-villalpando.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'b654860f-ec74-42d6-955e-eeedde2df0dd'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@grupo-ibarra-y-elizondo.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'b654860f-ec74-42d6-955e-eeedde2df0dd'::uuid AND email_address = 'contacto@grupo-ibarra-y-elizondo.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'be133600-848e-400b-9bc8-c52a4f3cf10d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@avila-y-maestas-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'be133600-848e-400b-9bc8-c52a4f3cf10d'::uuid AND email_address = 'contacto@avila-y-maestas-s-a.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '25e918f3-692f-4f51-b630-4caa1dd825a1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@gastelum-y-guerrero-y-asociados.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '25e918f3-692f-4f51-b630-4caa1dd825a1'::uuid AND email_address = 'contacto@gastelum-y-guerrero-y-asociados.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'cc46221e-f387-463c-9d11-9464d8209f7b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@escobedo-y-guerrero-a-c.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'cc46221e-f387-463c-9d11-9464d8209f7b'::uuid AND email_address = 'contacto@escobedo-y-guerrero-a-c.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@laboratorios-cavazos-y-valentin.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42'::uuid AND email_address = 'contacto@laboratorios-cavazos-y-valentin.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '3d7c5771-0692-4a2f-a4c6-6af2b561282b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@leal-valdez-s-a-de-c-v.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '3d7c5771-0692-4a2f-a4c6-6af2b561282b'::uuid AND email_address = 'contacto@leal-valdez-s-a-de-c-v.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '16b25a77-b84a-44ac-8540-c5bfa9b3b6b0'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@carvajal-y-urias-a-c.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '16b25a77-b84a-44ac-8540-c5bfa9b3b6b0'::uuid AND email_address = 'contacto@carvajal-y-urias-a-c.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '2040ac28-7210-4fbd-9716-53872211bcd9'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@alonso-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '2040ac28-7210-4fbd-9716-53872211bcd9'::uuid AND email_address = 'contacto@alonso-s-a.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '0d826581-b9d8-4828-8848-9332fe38d169'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@arteaga-malave.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '0d826581-b9d8-4828-8848-9332fe38d169'::uuid AND email_address = 'contacto@arteaga-malave.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'c0595f94-c8f4-413c-a05c-7cfca773563c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@briones-y-esquibel-s-c.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'c0595f94-c8f4-413c-a05c-7cfca773563c'::uuid AND email_address = 'contacto@briones-y-esquibel-s-c.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@mares-altamirano-y-gil.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5'::uuid AND email_address = 'contacto@mares-altamirano-y-gil.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'ad2c792b-5015-4238-b221-fa28e8b061fc'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@corporacin-hurtado-martinez-y-bueno.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'ad2c792b-5015-4238-b221-fa28e8b061fc'::uuid AND email_address = 'contacto@corporacin-hurtado-martinez-y-bueno.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'c3e96b10-f0ca-421e-b402-aba6d595cf27'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@leyva-y-saavedra-e-hijos.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'c3e96b10-f0ca-421e-b402-aba6d595cf27'::uuid AND email_address = 'contacto@leyva-y-saavedra-e-hijos.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'a5b1202a-9112-404b-b7de-ddf0f62711f8'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@corporacin-pacheco-hurtado-y-holguin.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'a5b1202a-9112-404b-b7de-ddf0f62711f8'::uuid AND email_address = 'contacto@corporacin-pacheco-hurtado-y-holguin.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'ac6f8f54-21c8-475b-bea6-19e31643392d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@despacho-guerrero-noriega-y-zavala.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'ac6f8f54-21c8-475b-bea6-19e31643392d'::uuid AND email_address = 'contacto@despacho-guerrero-noriega-y-zavala.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '43dee983-676a-4e33-a6b0-f0a72f46d06c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@montano-lira.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '43dee983-676a-4e33-a6b0-f0a72f46d06c'::uuid AND email_address = 'contacto@montano-lira.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@pelayo-arenas.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca'::uuid AND email_address = 'contacto@pelayo-arenas.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '08a7fe9e-c043-4fed-89e4-93a416a20089'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@gil-y-coronado-y-asociados.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '08a7fe9e-c043-4fed-89e4-93a416a20089'::uuid AND email_address = 'contacto@gil-y-coronado-y-asociados.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '89ab21cf-089e-4210-8e29-269dfbd38d71'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@crespo-pena-y-rosado.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '89ab21cf-089e-4210-8e29-269dfbd38d71'::uuid AND email_address = 'contacto@crespo-pena-y-rosado.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'd56e3cb0-d9e2-48fc-9c16-c4a96b90c00f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@jiminez-arroyo-y-ramon.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'd56e3cb0-d9e2-48fc-9c16-c4a96b90c00f'::uuid AND email_address = 'contacto@jiminez-arroyo-y-ramon.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@de-leon-s-c.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0'::uuid AND email_address = 'contacto@de-leon-s-c.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '3cf42c93-4941-4d8d-8656-aafa9e987177'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@robles-loera-a-c.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '3cf42c93-4941-4d8d-8656-aafa9e987177'::uuid AND email_address = 'contacto@robles-loera-a-c.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '1926fa2a-dab7-420e-861b-c2b6dfe0174e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@industrias-ponce-y-soto.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '1926fa2a-dab7-420e-861b-c2b6dfe0174e'::uuid AND email_address = 'contacto@industrias-ponce-y-soto.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '0b2f4464-5141-44a3-a26d-f8acc1fb955e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@madera-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '0b2f4464-5141-44a3-a26d-f8acc1fb955e'::uuid AND email_address = 'contacto@madera-s-a.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '1fec9665-52bc-49a7-b028-f0d78440463c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@proyectos-tejada-ramon-y-caldera.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '1fec9665-52bc-49a7-b028-f0d78440463c'::uuid AND email_address = 'contacto@proyectos-tejada-ramon-y-caldera.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@estevez-carrera.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a'::uuid AND email_address = 'contacto@estevez-carrera.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '8cfdeaad-c727-4a4d-b5d5-b69dd43c0854'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@laboratorios-puga-coronado-y-carmona.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '8cfdeaad-c727-4a4d-b5d5-b69dd43c0854'::uuid AND email_address = 'contacto@laboratorios-puga-coronado-y-carmona.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '7a6ce151-14b5-4d12-b6bb-1fba18636353'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@menchaca-vela-s-r-l-de-c-v.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '7a6ce151-14b5-4d12-b6bb-1fba18636353'::uuid AND email_address = 'contacto@menchaca-vela-s-r-l-de-c-v.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'f1ab98f4-98de-420f-9c4b-c31eee92df21'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@carreon-y-soliz-s-c.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'f1ab98f4-98de-420f-9c4b-c31eee92df21'::uuid AND email_address = 'contacto@carreon-y-soliz-s-c.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'a074c3ea-f255-4cf2-ae3f-727f9186be3c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@zarate-solano.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'a074c3ea-f255-4cf2-ae3f-727f9186be3c'::uuid AND email_address = 'contacto@zarate-solano.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '0e3821a8-80d6-4fa9-8313-3ed45b83c28b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@de-la-cruz-espinoza-e-hijos.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '0e3821a8-80d6-4fa9-8313-3ed45b83c28b'::uuid AND email_address = 'contacto@de-la-cruz-espinoza-e-hijos.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '3d521bc9-692d-4a0d-a3d7-80e816b86374'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@laboratorios-valdes-ruelas.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '3d521bc9-692d-4a0d-a3d7-80e816b86374'::uuid AND email_address = 'contacto@laboratorios-valdes-ruelas.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '47393461-e570-448b-82b1-1cef15441262'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@espinosa-s-r-l-de-c-v.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '47393461-e570-448b-82b1-1cef15441262'::uuid AND email_address = 'contacto@espinosa-s-r-l-de-c-v.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '744b4a03-e575-4978-b10e-6c087c9e744b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@villarreal-ocasio.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '744b4a03-e575-4978-b10e-6c087c9e744b'::uuid AND email_address = 'contacto@villarreal-ocasio.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '9a18b839-1b93-44fb-9d8a-2ea12388e887'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@corporacin-carrasco-y-lopez.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '9a18b839-1b93-44fb-9d8a-2ea12388e887'::uuid AND email_address = 'contacto@corporacin-carrasco-y-lopez.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@cisneros-concepcion.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b'::uuid AND email_address = 'contacto@cisneros-concepcion.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@jurado-guardado.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f'::uuid AND email_address = 'contacto@jurado-guardado.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'eea6be20-e19f-485f-ab54-537a7c28245f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-perez-y-godoy.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'eea6be20-e19f-485f-ab54-537a7c28245f'::uuid AND email_address = 'contacto@club-perez-y-godoy.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'eb602cae-423a-455d-a22e-d47aea5eb650'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@de-la-fuente-arias.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'eb602cae-423a-455d-a22e-d47aea5eb650'::uuid AND email_address = 'contacto@de-la-fuente-arias.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'bb17faca-a7b2-4de8-bf29-2fcb569ef554'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@hernandes-leiva-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'bb17faca-a7b2-4de8-bf29-2fcb569ef554'::uuid AND email_address = 'contacto@hernandes-leiva-s-a.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '44a33aab-1a23-4995-bd07-41f95b34fd57'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@grupo-garza-y-arellano.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '44a33aab-1a23-4995-bd07-41f95b34fd57'::uuid AND email_address = 'contacto@grupo-garza-y-arellano.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '5462455f-fbe3-44c8-b0d1-0644c433aca6'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@laboratorios-navarrete-anaya.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '5462455f-fbe3-44c8-b0d1-0644c433aca6'::uuid AND email_address = 'contacto@laboratorios-navarrete-anaya.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'd050617d-dc89-4f28-b546-9680dd1c5fad'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-armas-polanco.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'd050617d-dc89-4f28-b546-9680dd1c5fad'::uuid AND email_address = 'contacto@club-armas-polanco.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '7227444e-b122-48f4-8f01-2cda439507b1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@olivera-lovato-y-saavedra.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '7227444e-b122-48f4-8f01-2cda439507b1'::uuid AND email_address = 'contacto@olivera-lovato-y-saavedra.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'd86c173a-8a1d-43b4-a0c1-c836afdc378b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@grupo-ochoa-corrales.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'd86c173a-8a1d-43b4-a0c1-c836afdc378b'::uuid AND email_address = 'contacto@grupo-ochoa-corrales.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'fb0a848d-4d51-4416-86bc-e568f694f9e7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@banuelos-montano.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'fb0a848d-4d51-4416-86bc-e568f694f9e7'::uuid AND email_address = 'contacto@banuelos-montano.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@melendez-arriaga.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc'::uuid AND email_address = 'contacto@melendez-arriaga.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '8cb48822-4d4c-42ed-af7f-737d3107b1db'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@corporacin-menchaca-y-salgado.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '8cb48822-4d4c-42ed-af7f-737d3107b1db'::uuid AND email_address = 'contacto@corporacin-menchaca-y-salgado.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '700b8c76-7ad1-4453-9ce3-f598565c6452'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-salcedo-y-segura.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '700b8c76-7ad1-4453-9ce3-f598565c6452'::uuid AND email_address = 'contacto@club-salcedo-y-segura.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', 'd3cb7dc8-9240-4800-a1d9-bf65c5dac801'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@grupo-rosas-mena-y-sandoval.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = 'd3cb7dc8-9240-4800-a1d9-bf65c5dac801'::uuid AND email_address = 'contacto@grupo-rosas-mena-y-sandoval.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '06c71356-e038-4c3d-bfea-7865acacb684'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@club-otero-valadez-y-crespo.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '06c71356-e038-4c3d-bfea-7865acacb684'::uuid AND email_address = 'contacto@club-otero-valadez-y-crespo.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '30e2b2ec-9553-454e-92a4-c1dc89609cbb'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@industrias-esquibel-mesa-y-valle.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '30e2b2ec-9553-454e-92a4-c1dc89609cbb'::uuid AND email_address = 'contacto@industrias-esquibel-mesa-y-valle.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '2eead5aa-095b-418a-bd02-e3a917971887'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@calvillo-y-benavides-a-c.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '2eead5aa-095b-418a-bd02-e3a917971887'::uuid AND email_address = 'contacto@calvillo-y-benavides-a-c.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '05afd7e1-bb93-4c83-90a7-48a65b6e7598'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@industrias-ledesma-jurado-y-pantoja.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '05afd7e1-bb93-4c83-90a7-48a65b6e7598'::uuid AND email_address = 'contacto@industrias-ledesma-jurado-y-pantoja.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@cervantes-peralta.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15'::uuid AND email_address = 'contacto@cervantes-peralta.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '454f4ba6-cb6d-4f27-9d76-08f5b358b484'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@rico-y-escobar-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '454f4ba6-cb6d-4f27-9d76-08f5b358b484'::uuid AND email_address = 'contacto@rico-y-escobar-s-a.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'contacto@baez-viera-s-a.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282'::uuid AND email_address = 'contacto@baez-viera-s-a.predicthealth.com');

-- =============================================
-- DOCTOR EMAILS
-- =============================================

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.mariajose.rosales@corporacin.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7'::uuid AND email_address = 'dr.mariajose.rosales@corporacin.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '3e5b08ed-529d-45f0-8145-8371609882c1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.sessa.irizarry@puente-sanabria.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '3e5b08ed-529d-45f0-8145-8371609882c1'::uuid AND email_address = 'dr.sessa.irizarry@puente-sanabria.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '57031194-3c31-4320-86c4-fd370789efac'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.indira.olmos@caldera-marin.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '57031194-3c31-4320-86c4-fd370789efac'::uuid AND email_address = 'dr.indira.olmos@caldera-marin.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'dc42b779-4b49-418b-ab0a-92caa2a8d6de'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.perla.zavala@despacho.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'dc42b779-4b49-418b-ab0a-92caa2a8d6de'::uuid AND email_address = 'dr.perla.zavala@despacho.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '14abdfde-e4c9-460c-9ce2-17886600b20d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.fidel.urbina@proyectos.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '14abdfde-e4c9-460c-9ce2-17886600b20d'::uuid AND email_address = 'dr.fidel.urbina@proyectos.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'df863eba-f0b8-4b1a-bdd1-71ed2f816ed7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.rebeca.paredes@vera.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'df863eba-f0b8-4b1a-bdd1-71ed2f816ed7'::uuid AND email_address = 'dr.rebeca.paredes@vera.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'ba712fc8-c4d2-4e22-ae18-1991c46bc85d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.mario.gaona@santillan.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'ba712fc8-c4d2-4e22-ae18-1991c46bc85d'::uuid AND email_address = 'dr.mario.gaona@santillan.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'bbf715a1-3947-4642-a67a-b5c4c0c085d2'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.luis.ceja@club.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'bbf715a1-3947-4642-a67a-b5c4c0c085d2'::uuid AND email_address = 'dr.luis.ceja@club.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.sergio.guevara@corporacin.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec'::uuid AND email_address = 'dr.sergio.guevara@corporacin.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '0fbbaab0-2284-4ac6-b1c9-498b5b3c4567'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.natalia.barrientos@manzanares-vaca.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '0fbbaab0-2284-4ac6-b1c9-498b5b3c4567'::uuid AND email_address = 'dr.natalia.barrientos@manzanares-vaca.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'b6994d45-b80e-4260-834c-facdf3ea8eee'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.berta.rincon@reynoso.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'b6994d45-b80e-4260-834c-facdf3ea8eee'::uuid AND email_address = 'dr.berta.rincon@reynoso.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'f7cdc060-94e6-47ad-90e9-939ed86fb6da'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.lorenzo.rivera@lovato-briseno.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'f7cdc060-94e6-47ad-90e9-939ed86fb6da'::uuid AND email_address = 'dr.lorenzo.rivera@lovato-briseno.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '23785934-fbf0-442c-add3-05df84fa5d17'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.omar.trujillo@montalvo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '23785934-fbf0-442c-add3-05df84fa5d17'::uuid AND email_address = 'dr.omar.trujillo@montalvo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'bf7a015c-1589-42b3-b1e8-103fcbc0b041'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.elvira.ochoa@benavides-godoy.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'bf7a015c-1589-42b3-b1e8-103fcbc0b041'::uuid AND email_address = 'dr.elvira.ochoa@benavides-godoy.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '4fa9d0ff-2c51-4918-b48a-b5cb37d444a3'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.natalia.murillo@mascarenas.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '4fa9d0ff-2c51-4918-b48a-b5cb37d444a3'::uuid AND email_address = 'dr.natalia.murillo@mascarenas.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '93dbdfc0-e05c-4eb6-975c-360eb8d293c1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.pedro.valdes@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '93dbdfc0-e05c-4eb6-975c-360eb8d293c1'::uuid AND email_address = 'dr.pedro.valdes@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'a6db1b41-d601-4840-99e9-3d7d18901399'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.eugenio.uribe@laboratorios.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'a6db1b41-d601-4840-99e9-3d7d18901399'::uuid AND email_address = 'dr.eugenio.uribe@laboratorios.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'd5e98ce0-e6f8-4577-a0dd-3281aa303b32'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.linda.trejo@laboratorios.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'd5e98ce0-e6f8-4577-a0dd-3281aa303b32'::uuid AND email_address = 'dr.linda.trejo@laboratorios.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '44da48b1-6ff6-4db9-9de5-34e22de0429a'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.susana.acosta@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '44da48b1-6ff6-4db9-9de5-34e22de0429a'::uuid AND email_address = 'dr.susana.acosta@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '3fafc20d-72d5-4633-95a0-df6b9ed175b6'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.rodrigo.mota@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '3fafc20d-72d5-4633-95a0-df6b9ed175b6'::uuid AND email_address = 'dr.rodrigo.mota@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'c4fac110-0b61-4fb0-943d-0d00af7ed0cd'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.linda.magana@madera.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'c4fac110-0b61-4fb0-943d-0d00af7ed0cd'::uuid AND email_address = 'dr.linda.magana@madera.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '88870e4f-1333-4bcc-8daf-c8743d61f3cb'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.joseluis.rubio@navarro-prado.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '88870e4f-1333-4bcc-8daf-c8743d61f3cb'::uuid AND email_address = 'dr.joseluis.rubio@navarro-prado.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '6f035f60-87f7-4a9c-9501-4b8704facba3'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.concepcion.barajas@colon.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '6f035f60-87f7-4a9c-9501-4b8704facba3'::uuid AND email_address = 'dr.concepcion.barajas@colon.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '58a814d3-a275-436b-8e5c-4e743fed242f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.debora.delgadillo@escamilla.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '58a814d3-a275-436b-8e5c-4e743fed242f'::uuid AND email_address = 'dr.debora.delgadillo@escamilla.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'f67c2f76-9bf1-43e4-8d0e-c0a94298f35b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.augusto.roque@club.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'f67c2f76-9bf1-43e4-8d0e-c0a94298f35b'::uuid AND email_address = 'dr.augusto.roque@club.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'fb4d84a0-7bc1-4815-b7a3-b1719c616c79'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.francisca.garay@industrias.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'fb4d84a0-7bc1-4815-b7a3-b1719c616c79'::uuid AND email_address = 'dr.francisca.garay@industrias.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'c0bdb808-eb5f-479f-9261-dbbf9ff031a6'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.judith.sevilla@guardado.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'c0bdb808-eb5f-479f-9261-dbbf9ff031a6'::uuid AND email_address = 'dr.judith.sevilla@guardado.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'f501d643-d308-41e0-8ffc-8bfb52d64e13'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.nelly.robles@montenegro.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'f501d643-d308-41e0-8ffc-8bfb52d64e13'::uuid AND email_address = 'dr.nelly.robles@montenegro.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'adeb74f6-f3dc-43a7-a841-6d24aba046ba'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.soledad.noriega@proyectos.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'adeb74f6-f3dc-43a7-a841-6d24aba046ba'::uuid AND email_address = 'dr.soledad.noriega@proyectos.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'dd24da99-43c7-4d6b-acc0-32fc0c237d02'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.silvano.espinosa@caban.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'dd24da99-43c7-4d6b-acc0-32fc0c237d02'::uuid AND email_address = 'dr.silvano.espinosa@caban.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '0408b031-caa3-4b7c-ae65-d05342cf5c05'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.fabiola.saavedra@zelaya.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '0408b031-caa3-4b7c-ae65-d05342cf5c05'::uuid AND email_address = 'dr.fabiola.saavedra@zelaya.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'a865edbe-d50c-4bd1-b556-ae32d9d1858c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.silvia.enriquez@corporacin.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'a865edbe-d50c-4bd1-b556-ae32d9d1858c'::uuid AND email_address = 'dr.silvia.enriquez@corporacin.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '2a0aaddd-ea43-40bb-b5df-877b1b0d20f1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.maximiliano.segura@industrias.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '2a0aaddd-ea43-40bb-b5df-877b1b0d20f1'::uuid AND email_address = 'dr.maximiliano.segura@industrias.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '4754ba59-3dc1-4be2-a770-44d7c34184bc'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.josemaria.serna@soria-garcia.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '4754ba59-3dc1-4be2-a770-44d7c34184bc'::uuid AND email_address = 'dr.josemaria.serna@soria-garcia.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '16e23379-6774-417d-8104-a8e6f4712909'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.eugenio.gastelum@proyectos.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '16e23379-6774-417d-8104-a8e6f4712909'::uuid AND email_address = 'dr.eugenio.gastelum@proyectos.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '07527c1a-efd5-45e4-a0d9-01ba5207bb2f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.eva.cotto@proyectos.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '07527c1a-efd5-45e4-a0d9-01ba5207bb2f'::uuid AND email_address = 'dr.eva.cotto@proyectos.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'c186d1ad-fcba-4f6e-acd7-86cb4c09938e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.indira.ramon@linares.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'c186d1ad-fcba-4f6e-acd7-86cb4c09938e'::uuid AND email_address = 'dr.indira.ramon@linares.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '4cecebec-e16f-4949-a18b-8bfebae86618'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.patricia.angulo@laboratorios.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '4cecebec-e16f-4949-a18b-8bfebae86618'::uuid AND email_address = 'dr.patricia.angulo@laboratorios.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '6d21a37a-43d8-440b-bc64-87bb0ae1d45d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.helena.valladares@delgado.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '6d21a37a-43d8-440b-bc64-87bb0ae1d45d'::uuid AND email_address = 'dr.helena.valladares@delgado.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '4d75aae7-5d33-44ad-a297-a32ff407415d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.ruben.pacheco@proyectos.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '4d75aae7-5d33-44ad-a297-a32ff407415d'::uuid AND email_address = 'dr.ruben.pacheco@proyectos.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'e901dbc1-3eed-4e5e-b23c-58d808477e33'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.samuel.garibay@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'e901dbc1-3eed-4e5e-b23c-58d808477e33'::uuid AND email_address = 'dr.samuel.garibay@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '61bb20b9-7520-42be-accf-743c84a0b934'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.joaquin.vigil@corona.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '61bb20b9-7520-42be-accf-743c84a0b934'::uuid AND email_address = 'dr.joaquin.vigil@corona.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'b5a04df6-baea-460f-a946-f7b7606c9982'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.amador.arenas@club.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'b5a04df6-baea-460f-a946-f7b7606c9982'::uuid AND email_address = 'dr.amador.arenas@club.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'c1182c2e-0624-42f9-aef6-7e7a1a2b7dba'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.felipe.hidalgo@camarillo-vega.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'c1182c2e-0624-42f9-aef6-7e7a1a2b7dba'::uuid AND email_address = 'dr.felipe.hidalgo@camarillo-vega.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '0b238725-a392-4fbb-956b-0f71e15bc6da'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.mariateresa.baca@bernal-teran.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '0b238725-a392-4fbb-956b-0f71e15bc6da'::uuid AND email_address = 'dr.mariateresa.baca@bernal-teran.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '63ec3e7d-b8e4-4988-9bc3-5b655f830e31'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.miguelangel.perez@despacho.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '63ec3e7d-b8e4-4988-9bc3-5b655f830e31'::uuid AND email_address = 'dr.miguelangel.perez@despacho.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'd4df85ce-6d2b-46c9-b9cd-48b2490b3c88'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.jonas.madera@zamudio.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'd4df85ce-6d2b-46c9-b9cd-48b2490b3c88'::uuid AND email_address = 'dr.jonas.madera@zamudio.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '71618fe0-25a1-4281-98af-51797de3ae0a'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.arcelia.delarosa@reyna-valdes.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '71618fe0-25a1-4281-98af-51797de3ae0a'::uuid AND email_address = 'dr.arcelia.delarosa@reyna-valdes.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '389524b6-608c-4b31-affa-305b79635816'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.esther.echeverria@ramos.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '389524b6-608c-4b31-affa-305b79635816'::uuid AND email_address = 'dr.esther.echeverria@ramos.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'c0356e82-1510-4557-b654-cf84ac13f425'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.sofia.montez@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'c0356e82-1510-4557-b654-cf84ac13f425'::uuid AND email_address = 'dr.sofia.montez@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'ce44b08f-7dae-4844-ae53-e01ac2f28f45'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.debora.segura@robledo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'ce44b08f-7dae-4844-ae53-e01ac2f28f45'::uuid AND email_address = 'dr.debora.segura@robledo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '9c9838c2-4464-4fbb-bc22-8f4ac64b4efe'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.luismiguel.villarreal@canales-rascon.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '9c9838c2-4464-4fbb-bc22-8f4ac64b4efe'::uuid AND email_address = 'dr.luismiguel.villarreal@canales-rascon.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'e8db5b49-5605-41e5-91f2-d456b68c5ade'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.esmeralda.parra@corporacin.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'e8db5b49-5605-41e5-91f2-d456b68c5ade'::uuid AND email_address = 'dr.esmeralda.parra@corporacin.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '96d6da02-ca2f-4ace-b239-4584544e8230'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.patricia.tellez@linares.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '96d6da02-ca2f-4ace-b239-4584544e8230'::uuid AND email_address = 'dr.patricia.tellez@linares.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '38bf2ce6-5014-4bc1-8e32-9b9257eea501'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.timoteo.tafoya@despacho.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '38bf2ce6-5014-4bc1-8e32-9b9257eea501'::uuid AND email_address = 'dr.timoteo.tafoya@despacho.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.amanda.ferrer@carreon.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c'::uuid AND email_address = 'dr.amanda.ferrer@carreon.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '8ce8b684-8f8d-4828-987d-389dfe64afd1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.caridad.villa@jaimes.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '8ce8b684-8f8d-4828-987d-389dfe64afd1'::uuid AND email_address = 'dr.caridad.villa@jaimes.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'ca8bf565-35d3-40f3-b741-603201f6f072'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.hector.castro@granado.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'ca8bf565-35d3-40f3-b741-603201f6f072'::uuid AND email_address = 'dr.hector.castro@granado.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '2937cc2f-22b7-4488-b9f8-a0795800a840'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.abraham.rodarte@guzman.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '2937cc2f-22b7-4488-b9f8-a0795800a840'::uuid AND email_address = 'dr.abraham.rodarte@guzman.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'f8a511e3-b97b-4d17-8240-46520497ef7c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.gloria.briones@zapata-madera.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'f8a511e3-b97b-4d17-8240-46520497ef7c'::uuid AND email_address = 'dr.gloria.briones@zapata-madera.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '879bcb9a-8520-4d02-b12b-ba5afa629d41'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.joseluis.bahena@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '879bcb9a-8520-4d02-b12b-ba5afa629d41'::uuid AND email_address = 'dr.joseluis.bahena@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '7817761a-e7c5-47cb-a260-7e243c11ef2f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.daniela.laboy@club.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '7817761a-e7c5-47cb-a260-7e243c11ef2f'::uuid AND email_address = 'dr.daniela.laboy@club.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '48384f36-0b57-4943-899f-cbffd4ec37b6'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.bruno.ledesma@chavez-polanco.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '48384f36-0b57-4943-899f-cbffd4ec37b6'::uuid AND email_address = 'dr.bruno.ledesma@chavez-polanco.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '0fc70684-777f-43eb-895d-9cb90ce0f584'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.noelia.garica@pabon.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '0fc70684-777f-43eb-895d-9cb90ce0f584'::uuid AND email_address = 'dr.noelia.garica@pabon.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'a849f14b-3741-4e38-9dfb-6cc7d46265e8'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.mitzy.godoy@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'a849f14b-3741-4e38-9dfb-6cc7d46265e8'::uuid AND email_address = 'dr.mitzy.godoy@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '22128ae9-ba6e-4e99-821a-dc445e76d641'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.sessa.medina@espinal-tamez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '22128ae9-ba6e-4e99-821a-dc445e76d641'::uuid AND email_address = 'dr.sessa.medina@espinal-tamez.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '6c711a31-c752-44f2-b6cb-480f9bf6af1f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.mitzy.aguayo@industrias.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '6c711a31-c752-44f2-b6cb-480f9bf6af1f'::uuid AND email_address = 'dr.mitzy.aguayo@industrias.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'ab923e2e-5d13-41e4-9c73-2f62cca0699d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.patricio.monroy@velazquez-aguilera.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'ab923e2e-5d13-41e4-9c73-2f62cca0699d'::uuid AND email_address = 'dr.patricio.monroy@velazquez-aguilera.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'a7f19796-4c62-4a2b-82de-7c2677804e6a'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.homero.valentin@malave-rodriguez.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'a7f19796-4c62-4a2b-82de-7c2677804e6a'::uuid AND email_address = 'dr.homero.valentin@malave-rodriguez.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '28958f29-28c6-405a-acf5-949ffcaec286'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.porfirio.farias@paez-badillo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '28958f29-28c6-405a-acf5-949ffcaec286'::uuid AND email_address = 'dr.porfirio.farias@paez-badillo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '472116b5-933e-4f63-b3ca-e8c8f5d30bb4'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.gonzalo.cortes@becerra.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '472116b5-933e-4f63-b3ca-e8c8f5d30bb4'::uuid AND email_address = 'dr.gonzalo.cortes@becerra.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'a2beaa02-c033-4e45-b702-305d5ce41e34'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.marisol.tello@corporacin.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'a2beaa02-c033-4e45-b702-305d5ce41e34'::uuid AND email_address = 'dr.marisol.tello@corporacin.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '5879ec30-c291-476d-a48c-284fadf5f98a'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.mateo.serrato@mejia-baez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '5879ec30-c291-476d-a48c-284fadf5f98a'::uuid AND email_address = 'dr.mateo.serrato@mejia-baez.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'd512bd88-12a3-45f9-85e8-14fb3cb5a6e1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.reina.camacho@club.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'd512bd88-12a3-45f9-85e8-14fb3cb5a6e1'::uuid AND email_address = 'dr.reina.camacho@club.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '757d6edf-5aa8-461b-ac4f-9e8365017424'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.homero.rodarte@laboratorios.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '757d6edf-5aa8-461b-ac4f-9e8365017424'::uuid AND email_address = 'dr.homero.rodarte@laboratorios.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'c0d54a00-2ee9-4827-a7fb-6196ef15bdee'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.martin.trevino@montez.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'c0d54a00-2ee9-4827-a7fb-6196ef15bdee'::uuid AND email_address = 'dr.martin.trevino@montez.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'a7ada88a-7935-4dd5-8a4f-935c4b7c0bab'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.wilfrido.salazar@industrias.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'a7ada88a-7935-4dd5-8a4f-935c4b7c0bab'::uuid AND email_address = 'dr.wilfrido.salazar@industrias.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '4664d394-c950-4dbf-9b40-7b34c6d6dabb'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.uriel.velazquez@proyectos.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '4664d394-c950-4dbf-9b40-7b34c6d6dabb'::uuid AND email_address = 'dr.uriel.velazquez@proyectos.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'c16b254c-dcf7-4a31-a101-1ed86b62477e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.jos.briones@pacheco-gutierrez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'c16b254c-dcf7-4a31-a101-1ed86b62477e'::uuid AND email_address = 'dr.jos.briones@pacheco-gutierrez.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'e0926c16-7f63-41ae-a091-1d0688c88322'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.david.dominguez@saldana.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'e0926c16-7f63-41ae-a091-1d0688c88322'::uuid AND email_address = 'dr.david.dominguez@saldana.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '250b33c9-1ba3-44e6-9c35-cde7000d6d53'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.adan.ferrer@varela-vera.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '250b33c9-1ba3-44e6-9c35-cde7000d6d53'::uuid AND email_address = 'dr.adan.ferrer@varela-vera.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'b6c86aef-75e2-4c64-bceb-e7de898b5a1b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.irene.cisneros@ramirez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'b6c86aef-75e2-4c64-bceb-e7de898b5a1b'::uuid AND email_address = 'dr.irene.cisneros@ramirez.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'a3fb2dae-2a69-434f-86a9-65ae48c8f690'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.altagracia.orellana@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'a3fb2dae-2a69-434f-86a9-65ae48c8f690'::uuid AND email_address = 'dr.altagracia.orellana@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '820c1228-3d2d-4766-900f-32940f14e74b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.cristal.balderas@corporacin.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '820c1228-3d2d-4766-900f-32940f14e74b'::uuid AND email_address = 'dr.cristal.balderas@corporacin.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'da3dbacf-8df0-46cf-bbef-b51615063a9b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.marisol.ulloa@castillo.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'da3dbacf-8df0-46cf-bbef-b51615063a9b'::uuid AND email_address = 'dr.marisol.ulloa@castillo.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'e6ce6823-6c4d-4ead-98d7-78b94483fe2c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.alfonso.cazares@ocampo-rincon.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'e6ce6823-6c4d-4ead-98d7-78b94483fe2c'::uuid AND email_address = 'dr.alfonso.cazares@ocampo-rincon.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '84cb6703-edfc-4180-9f80-619064c9684e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.elisa.oquendo@club.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '84cb6703-edfc-4180-9f80-619064c9684e'::uuid AND email_address = 'dr.elisa.oquendo@club.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '21e4d7a9-73dc-4156-b413-b389c2e92a0d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.silvano.brito@naranjo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '21e4d7a9-73dc-4156-b413-b389c2e92a0d'::uuid AND email_address = 'dr.silvano.brito@naranjo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '85eb8041-b502-4b90-b586-c7c4593b5347'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.ursula.casares@aranda.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '85eb8041-b502-4b90-b586-c7c4593b5347'::uuid AND email_address = 'dr.ursula.casares@aranda.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.marcela.corona@despacho.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9'::uuid AND email_address = 'dr.marcela.corona@despacho.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '22d570dd-a72e-4599-8f13-df952d35d616'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.catalina.orta@muniz.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '22d570dd-a72e-4599-8f13-df952d35d616'::uuid AND email_address = 'dr.catalina.orta@muniz.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '04a9b2e7-638b-4fe0-a106-16b582d946ab'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.rene.morales@garza-valdez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '04a9b2e7-638b-4fe0-a106-16b582d946ab'::uuid AND email_address = 'dr.rene.morales@garza-valdez.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '03e547d1-325a-46ea-bc94-c188abf53f0f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.benjamin.leal@grupo.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '03e547d1-325a-46ea-bc94-c188abf53f0f'::uuid AND email_address = 'dr.benjamin.leal@grupo.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '5a6de593-99b5-4942-a379-fd21b2a4999f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.catalina.alarcon@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '5a6de593-99b5-4942-a379-fd21b2a4999f'::uuid AND email_address = 'dr.catalina.alarcon@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'b7dd043b-953f-4e04-8a80-1c613d3c6675'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.pedro.riojas@cornejo-tello.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'b7dd043b-953f-4e04-8a80-1c613d3c6675'::uuid AND email_address = 'dr.pedro.riojas@cornejo-tello.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '852beb97-3c99-4391-879f-98f0c2154c20'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.olivia.nieto@paz-guillen.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '852beb97-3c99-4391-879f-98f0c2154c20'::uuid AND email_address = 'dr.olivia.nieto@paz-guillen.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '86bb4262-7a96-444b-a096-d3a1bd7782e7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.victoria.corona@valladares.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '86bb4262-7a96-444b-a096-d3a1bd7782e7'::uuid AND email_address = 'dr.victoria.corona@valladares.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', 'b441c98a-1075-4013-9fc2-9242d910713f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.daniela.gallegos@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = 'b441c98a-1075-4013-9fc2-9242d910713f'::uuid AND email_address = 'dr.daniela.gallegos@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '77486cf8-54d8-4120-856f-642ebae74d48'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.victoria.urbina@ontiveros-soliz.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '77486cf8-54d8-4120-856f-642ebae74d48'::uuid AND email_address = 'dr.victoria.urbina@ontiveros-soliz.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '0e2fa589-05b2-402c-9722-1022a0121b04'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'dr.leonardo.aguirre@henriquez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '0e2fa589-05b2-402c-9722-1022a0121b04'::uuid AND email_address = 'dr.leonardo.aguirre@henriquez.com');

-- =============================================
-- PATIENT EMAILS
-- =============================================

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '2f5622af-8528-4c85-8e16-3d175a4f2d15'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'linda.najera.1967@esquivel.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '2f5622af-8528-4c85-8e16-3d175a4f2d15'::uuid AND email_address = 'linda.najera.1967@esquivel.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'marisela.rocha.1971@industrias.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c'::uuid AND email_address = 'marisela.rocha.1971@industrias.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '959aa1dd-346b-4542-8f99-0d5e75301249'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'homero.miranda.1976@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '959aa1dd-346b-4542-8f99-0d5e75301249'::uuid AND email_address = 'homero.miranda.1976@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '59402562-ce5f-450e-8e6c-9630514fe164'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'manuel.vela.1989@corporacin.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '59402562-ce5f-450e-8e6c-9630514fe164'::uuid AND email_address = 'manuel.vela.1989@corporacin.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'f81c87d6-32f1-4c79-993a-18db4734ef65'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'paulina.cervantez.1975@cornejo-montero.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'f81c87d6-32f1-4c79-993a-18db4734ef65'::uuid AND email_address = 'paulina.cervantez.1975@cornejo-montero.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '0b6b8229-4027-4ec7-8bce-c805de96ced3'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'benjamin.serna.1972@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '0b6b8229-4027-4ec7-8bce-c805de96ced3'::uuid AND email_address = 'benjamin.serna.1972@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'rosa.galvez.1962@mendoza.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb'::uuid AND email_address = 'rosa.galvez.1962@mendoza.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'f2a1f62a-8030-4f65-b82d-ce7376b955bd'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'nelly.montemayor.1991@despacho.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'f2a1f62a-8030-4f65-b82d-ce7376b955bd'::uuid AND email_address = 'nelly.montemayor.1991@despacho.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '0104fea2-d27c-4611-8414-da6c898b6944'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'rolando.jaimes.1994@almanza.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '0104fea2-d27c-4611-8414-da6c898b6944'::uuid AND email_address = 'rolando.jaimes.1994@almanza.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'cd0c2f0c-de08-439c-93c9-0feab1d433cc'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'bruno.urena.1966@saiz.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'cd0c2f0c-de08-439c-93c9-0feab1d433cc'::uuid AND email_address = 'bruno.urena.1966@saiz.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'luismanuel.morales.1956@alva-zamudio.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545'::uuid AND email_address = 'luismanuel.morales.1956@alva-zamudio.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '7893292b-965a-41da-896a-d0780c91fdd5'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'david.benavidez.1953@ybarra-briones.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '7893292b-965a-41da-896a-d0780c91fdd5'::uuid AND email_address = 'david.benavidez.1953@ybarra-briones.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '87fb3c88-6653-45db-aa6c-20ea7512da64'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'clara.pelayo.1954@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '87fb3c88-6653-45db-aa6c-20ea7512da64'::uuid AND email_address = 'clara.pelayo.1954@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '05e42aed-c457-4579-904f-d397be3075f7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'santiago.armendariz.2001@toledo.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '05e42aed-c457-4579-904f-d397be3075f7'::uuid AND email_address = 'santiago.armendariz.2001@toledo.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '43756f6c-c157-4a44-9c84-ab2d62fddcf7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'carlos.menchaca.1949@proyectos.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '43756f6c-c157-4a44-9c84-ab2d62fddcf7'::uuid AND email_address = 'carlos.menchaca.1949@proyectos.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'd8e1fa52-0a65-4917-b410-2954e05a34e5'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'manuel.gracia.1978@rolon.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'd8e1fa52-0a65-4917-b410-2954e05a34e5'::uuid AND email_address = 'manuel.gracia.1978@rolon.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'bbc67f38-a9eb-4379-aeaf-1560af0d1a34'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'jos.perea.2000@pulido.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'bbc67f38-a9eb-4379-aeaf-1560af0d1a34'::uuid AND email_address = 'jos.perea.2000@pulido.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'esparta.franco.1987@laboy.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e'::uuid AND email_address = 'esparta.franco.1987@laboy.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '309df411-1d1a-4d00-a34e-36e8c32da210'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'joseluis.miramontes.1951@tamayo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '309df411-1d1a-4d00-a34e-36e8c32da210'::uuid AND email_address = 'joseluis.miramontes.1951@tamayo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '663d036b-a19b-4557-af37-d68a9ce4976d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'amalia.arenas.1975@club.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '663d036b-a19b-4557-af37-d68a9ce4976d'::uuid AND email_address = 'amalia.arenas.1975@club.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'a754cbf1-a4ca-42dc-92c4-d980b6a25a6d'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'angelica.serrato.1960@pina-almanza.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'a754cbf1-a4ca-42dc-92c4-d980b6a25a6d'::uuid AND email_address = 'angelica.serrato.1960@pina-almanza.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'd5b1779e-21f2-4252-a421-f2aaf9998916'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'pascual.barragan.1977@club.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'd5b1779e-21f2-4252-a421-f2aaf9998916'::uuid AND email_address = 'pascual.barragan.1977@club.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '6661483b-705b-412a-8bbd-39c0af0dadb1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'jesus.abreu.1955@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '6661483b-705b-412a-8bbd-39c0af0dadb1'::uuid AND email_address = 'jesus.abreu.1955@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '676491c4-f31a-42b6-a991-a8dd09bbb1f0'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'victor.espinosa.1988@cepeda.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '676491c4-f31a-42b6-a991-a8dd09bbb1f0'::uuid AND email_address = 'victor.espinosa.1988@cepeda.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '3a9e8e0e-6367-409d-a81c-9852069c710e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'mariajose.villasenor.1949@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '3a9e8e0e-6367-409d-a81c-9852069c710e'::uuid AND email_address = 'mariajose.villasenor.1949@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '167dedde-166c-45e4-befc-4f1c9b7184ad'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'camilo.villa.1998@laboratorios.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '167dedde-166c-45e4-befc-4f1c9b7184ad'::uuid AND email_address = 'camilo.villa.1998@laboratorios.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '72eca572-4ecf-4be8-906b-40e89e0d9a08'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'mario.santillan.1966@garcia-benitez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '72eca572-4ecf-4be8-906b-40e89e0d9a08'::uuid AND email_address = 'mario.santillan.1966@garcia-benitez.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'd5bec069-a317-4a40-b3e8-ea80220d75de'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'cristobal.paez.1961@bernal.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'd5bec069-a317-4a40-b3e8-ea80220d75de'::uuid AND email_address = 'cristobal.paez.1961@bernal.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '0e97294d-78cc-4428-a172-e4e1fd4efa72'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'celia.olivo.1961@espinosa.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '0e97294d-78cc-4428-a172-e4e1fd4efa72'::uuid AND email_address = 'celia.olivo.1961@espinosa.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '9f86a53f-f0e1-446d-89f0-86b086dd12a9'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'teresa.arguello.1949@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '9f86a53f-f0e1-446d-89f0-86b086dd12a9'::uuid AND email_address = 'teresa.arguello.1949@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'ae1f5c92-f3cf-43d8-918f-aaad6fb46c05'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'pilar.valle.1981@industrias.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'ae1f5c92-f3cf-43d8-918f-aaad6fb46c05'::uuid AND email_address = 'pilar.valle.1981@industrias.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'd28440a6-3bd9-4a48-8a72-d700ae0971e4'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'eva.orellana.1988@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'd28440a6-3bd9-4a48-8a72-d700ae0971e4'::uuid AND email_address = 'eva.orellana.1988@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '7f839ee8-bdd6-4a63-83e8-30db007565e2'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'rafael.olvera.1946@corporacin.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '7f839ee8-bdd6-4a63-83e8-30db007565e2'::uuid AND email_address = 'rafael.olvera.1946@corporacin.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '67aa999f-9d31-4b61-a097-35097ea0d082'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'anel.baeza.1997@club.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '67aa999f-9d31-4b61-a097-35097ea0d082'::uuid AND email_address = 'anel.baeza.1997@club.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '41aa2fbc-8ef4-4448-8686-399a1cd54be9'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'jesus.negron.1966@club.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '41aa2fbc-8ef4-4448-8686-399a1cd54be9'::uuid AND email_address = 'jesus.negron.1966@club.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '111769f3-1a1b-44a9-9670-f4f2e424d1d2'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'asuncion.ybarra.2000@pacheco.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '111769f3-1a1b-44a9-9670-f4f2e424d1d2'::uuid AND email_address = 'asuncion.ybarra.2000@pacheco.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'roberto.varela.1961@sandoval.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1'::uuid AND email_address = 'roberto.varela.1961@sandoval.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '6a8b6d41-8d20-4bc5-8d48-538d348f6086'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'alejandra.acosta.1950@espino-cotto.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '6a8b6d41-8d20-4bc5-8d48-538d348f6086'::uuid AND email_address = 'alejandra.acosta.1950@espino-cotto.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '89657c95-84c0-4bd0-80c6-70a2c4721276'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'minerva.ortiz.1985@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '89657c95-84c0-4bd0-80c6-70a2c4721276'::uuid AND email_address = 'minerva.ortiz.1985@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'b6658dac-0ee1-415c-95ad-28c6acea85bd'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'amanda.menendez.1966@palacios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'b6658dac-0ee1-415c-95ad-28c6acea85bd'::uuid AND email_address = 'amanda.menendez.1966@palacios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '56564104-6009-466c-9134-c15d3175613b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'hermelinda.medrano.1970@grupo.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '56564104-6009-466c-9134-c15d3175613b'::uuid AND email_address = 'hermelinda.medrano.1970@grupo.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'edb1d693-b308-4ff6-8fd4-9e20561317e8'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'alonso.roldan.1960@laboratorios.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'edb1d693-b308-4ff6-8fd4-9e20561317e8'::uuid AND email_address = 'alonso.roldan.1960@laboratorios.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '9511f9b9-a450-489c-92b9-ac306733cee4'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'alma.sosa.2001@montoya.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '9511f9b9-a450-489c-92b9-ac306733cee4'::uuid AND email_address = 'alma.sosa.2001@montoya.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '004ce58b-6a0d-4646-92c3-4508deb6b354'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'estela.lucero.1979@corporacin.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '004ce58b-6a0d-4646-92c3-4508deb6b354'::uuid AND email_address = 'estela.lucero.1979@corporacin.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '0d1bcc20-a5be-40f0-a28b-23c2c77c51be'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'gonzalo.laureano.1979@despacho.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '0d1bcc20-a5be-40f0-a28b-23c2c77c51be'::uuid AND email_address = 'gonzalo.laureano.1979@despacho.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '38000dbb-417f-43ca-a60e-5812796420f7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'helena.muro.1973@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '38000dbb-417f-43ca-a60e-5812796420f7'::uuid AND email_address = 'helena.muro.1973@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '5ae0a393-b399-4dc6-95d8-297d3b3ef0a8'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'adela.vergara.1991@baeza.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '5ae0a393-b399-4dc6-95d8-297d3b3ef0a8'::uuid AND email_address = 'adela.vergara.1991@baeza.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '561c313d-2c15-41b1-b965-a38c8e0f6c42'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'salma.almaraz.1994@despacho.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '561c313d-2c15-41b1-b965-a38c8e0f6c42'::uuid AND email_address = 'salma.almaraz.1994@despacho.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'ba4b2a5b-887d-4f3d-8ec7-570cfe087b28'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'humberto.caraballo.1946@llamas-ulibarri.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'ba4b2a5b-887d-4f3d-8ec7-570cfe087b28'::uuid AND email_address = 'humberto.caraballo.1946@llamas-ulibarri.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'cbdb51c5-0334-4e15-b4b9-13b1de1c4c20'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'mauricio.zavala.1997@montano.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'cbdb51c5-0334-4e15-b4b9-13b1de1c4c20'::uuid AND email_address = 'mauricio.zavala.1997@montano.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '05bc2942-e676-42e9-ad01-ade9f7cc5aee'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'roberto.alejandro.1960@jaime.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '05bc2942-e676-42e9-ad01-ade9f7cc5aee'::uuid AND email_address = 'roberto.alejandro.1960@jaime.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'c78e7658-d517-4ca1-990b-e6971f8d108f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'victor.gutierrez.1983@proyectos.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'c78e7658-d517-4ca1-990b-e6971f8d108f'::uuid AND email_address = 'victor.gutierrez.1983@proyectos.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '65474c27-8f72-4690-8f19-df9344e4be5e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'adan.nava.2000@gonzalez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '65474c27-8f72-4690-8f19-df9344e4be5e'::uuid AND email_address = 'adan.nava.2000@gonzalez.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'c1b6fa98-203a-4321-96cd-e80e7a1c9461'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'amador.cano.1995@toledo-arevalo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'c1b6fa98-203a-4321-96cd-e80e7a1c9461'::uuid AND email_address = 'amador.cano.1995@toledo-arevalo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '9244b388-8c06-42c7-9c4e-cbaae5b1baa3'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'alfonso.prado.1955@salazar.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '9244b388-8c06-42c7-9c4e-cbaae5b1baa3'::uuid AND email_address = 'alfonso.prado.1955@salazar.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'eb2e55f6-4738-4352-a59a-860909f1932c'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'uriel.suarez.1972@narvaez-arguello.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'eb2e55f6-4738-4352-a59a-860909f1932c'::uuid AND email_address = 'uriel.suarez.1972@narvaez-arguello.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'c572a4c7-e475-4d18-85da-417abcd00903'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'armando.porras.1954@hernandes-rendon.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'c572a4c7-e475-4d18-85da-417abcd00903'::uuid AND email_address = 'armando.porras.1954@hernandes-rendon.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'teresa.granado.1953@osorio.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3'::uuid AND email_address = 'teresa.granado.1953@osorio.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '9b02d89c-2c5b-4c51-8183-15ccd1184990'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'marcela.fernandez.1981@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '9b02d89c-2c5b-4c51-8183-15ccd1184990'::uuid AND email_address = 'marcela.fernandez.1981@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '43ae2e81-ac13-40ac-949c-9e4f51d76098'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'sergio.loya.1970@avalos-garrido.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '43ae2e81-ac13-40ac-949c-9e4f51d76098'::uuid AND email_address = 'sergio.loya.1970@avalos-garrido.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '49a18092-8f90-4f6b-873c-8715b64b8aff'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'jorgeluis.molina.1953@burgos-loya.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '49a18092-8f90-4f6b-873c-8715b64b8aff'::uuid AND email_address = 'jorgeluis.molina.1953@burgos-loya.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'c9a949e5-e650-4d95-9e2e-49ed06e5d087'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'elvira.echeverria.1970@granado-miramontes.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'c9a949e5-e650-4d95-9e2e-49ed06e5d087'::uuid AND email_address = 'elvira.echeverria.1970@granado-miramontes.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'a4e5cbb3-36f7-43d8-a65a-e30fc1361e56'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'federico.fajardo.1949@proyectos.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'a4e5cbb3-36f7-43d8-a65a-e30fc1361e56'::uuid AND email_address = 'federico.fajardo.1949@proyectos.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '447e48dc-861c-41e6-920e-a2dec785101f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'elena.quintanilla.1979@patino-vallejo.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '447e48dc-861c-41e6-920e-a2dec785101f'::uuid AND email_address = 'elena.quintanilla.1979@patino-vallejo.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '3a535951-40fd-4959-a34e-07b29f675ecc'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'cynthia.jurado.1991@vasquez-ordonez.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '3a535951-40fd-4959-a34e-07b29f675ecc'::uuid AND email_address = 'cynthia.jurado.1991@vasquez-ordonez.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'd4bfb3cb-c8d6-434a-a3d4-2712ecea4d70'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'juana.gurule.1993@despacho.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'd4bfb3cb-c8d6-434a-a3d4-2712ecea4d70'::uuid AND email_address = 'juana.gurule.1993@despacho.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '6052a417-6725-4fab-b7dd-7f498454cd47'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'lilia.mesa.1956@escalante-nino.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '6052a417-6725-4fab-b7dd-7f498454cd47'::uuid AND email_address = 'lilia.mesa.1956@escalante-nino.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'dad07e7d-fcb6-407a-9267-b7ab0a92d4a7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'octavio.gurule.2004@gaytan.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'dad07e7d-fcb6-407a-9267-b7ab0a92d4a7'::uuid AND email_address = 'octavio.gurule.2004@gaytan.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'cbd398cc-dfde-41c4-b7b1-ca32cc99945f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'reina.rangel.1975@alcantar.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'cbd398cc-dfde-41c4-b7b1-ca32cc99945f'::uuid AND email_address = 'reina.rangel.1975@alcantar.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'f740b251-4264-4220-8400-706331f650af'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'estefania.vanegas.1946@ortega-meza.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'f740b251-4264-4220-8400-706331f650af'::uuid AND email_address = 'estefania.vanegas.1946@ortega-meza.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'fac7afba-7f9c-40f9-9a06-a9782ad7d3a7'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'alfredo.holguin.1963@ordonez-urbina.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'fac7afba-7f9c-40f9-9a06-a9782ad7d3a7'::uuid AND email_address = 'alfredo.holguin.1963@ordonez-urbina.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '97d5d278-c876-4078-9dba-2940edfed9a0'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'reynaldo.meza.1997@club.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '97d5d278-c876-4078-9dba-2940edfed9a0'::uuid AND email_address = 'reynaldo.meza.1997@club.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'a329242d-9e38-4178-aa8e-5b7497209897'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'daniel.caban.1964@gamboa.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'a329242d-9e38-4178-aa8e-5b7497209897'::uuid AND email_address = 'daniel.caban.1964@gamboa.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'fe2cc660-dd15-4d31-ac72-56114bdb6b92'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'graciela.bonilla.1997@club.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'fe2cc660-dd15-4d31-ac72-56114bdb6b92'::uuid AND email_address = 'graciela.bonilla.1997@club.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'fd01c50f-f3dd-4517-96c0-c0e65330a692'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'jaqueline.olivas.1950@verdugo.org', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'fd01c50f-f3dd-4517-96c0-c0e65330a692'::uuid AND email_address = 'jaqueline.olivas.1950@verdugo.org');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'f56cc0bc-1765-4334-9594-73dcc9deac8e'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'leonardo.mateo.1966@verdugo-oquendo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'f56cc0bc-1765-4334-9594-73dcc9deac8e'::uuid AND email_address = 'leonardo.mateo.1966@verdugo-oquendo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '1c861cbf-991d-4820-b3f0-98538fb0d454'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'antonio.sosa.1959@rolon-casillas.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '1c861cbf-991d-4820-b3f0-98538fb0d454'::uuid AND email_address = 'antonio.sosa.1959@rolon-casillas.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '70f066e1-fc10-4b37-92ea-0de96307793b'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'cristobal.chavez.2006@solis.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '70f066e1-fc10-4b37-92ea-0de96307793b'::uuid AND email_address = 'cristobal.chavez.2006@solis.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'd1ec4069-41a0-4317-a6c6-84914d108257'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'jaqueline.negrete.1973@mares.net', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'd1ec4069-41a0-4317-a6c6-84914d108257'::uuid AND email_address = 'jaqueline.negrete.1973@mares.net');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '04239007-edaa-4c74-95dd-4ba4df226b0f'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'esteban.rios.1991@industrias.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '04239007-edaa-4c74-95dd-4ba4df226b0f'::uuid AND email_address = 'esteban.rios.1991@industrias.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '0deef39b-719e-4f3a-a84f-2072803b2548'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'zoe.gaona.1953@club.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '0deef39b-719e-4f3a-a84f-2072803b2548'::uuid AND email_address = 'zoe.gaona.1953@club.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '5156864c-fa59-4e48-b357-477838800efc'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'ana.saenz.1967@loera.biz', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '5156864c-fa59-4e48-b357-477838800efc'::uuid AND email_address = 'ana.saenz.1967@loera.biz');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'd911f0a5-9268-4eb4-87e9-508d7c99b753'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'vanesa.nava.1996@laboy-puente.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'd911f0a5-9268-4eb4-87e9-508d7c99b753'::uuid AND email_address = 'vanesa.nava.1996@laboy-puente.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'c3e065c2-c0a9-440f-98f3-1c5463949056'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'diana.ceja.1969@soria.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'c3e065c2-c0a9-440f-98f3-1c5463949056'::uuid AND email_address = 'diana.ceja.1969@soria.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'b2eef54b-21a7-45ec-a693-bc60f1d6e293'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'emilio.delarosa.1946@club.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'b2eef54b-21a7-45ec-a693-bc60f1d6e293'::uuid AND email_address = 'emilio.delarosa.1946@club.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '3854a76e-ee29-4976-b630-1d7e18fb9887'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'monica.delarosa.1978@ulloa.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '3854a76e-ee29-4976-b630-1d7e18fb9887'::uuid AND email_address = 'monica.delarosa.1978@ulloa.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '6b2e25e9-ebcb-4150-a594-c5742cd42121'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'reynaldo.garcia.1966@uribe.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '6b2e25e9-ebcb-4150-a594-c5742cd42121'::uuid AND email_address = 'reynaldo.garcia.1966@uribe.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'cc38cb13-51a5-4539-99c2-894cd2b207f1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'geronimo.pedraza.1972@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'cc38cb13-51a5-4539-99c2-894cd2b207f1'::uuid AND email_address = 'geronimo.pedraza.1972@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '6af409b5-c8b8-4664-97cd-d419eedcc932'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'abelardo.barraza.1981@reyna-samaniego.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '6af409b5-c8b8-4664-97cd-d419eedcc932'::uuid AND email_address = 'abelardo.barraza.1981@reyna-samaniego.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '227a2c03-dfd1-4e03-9c04-daaf74fc68bd'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'noelia.toro.1948@escobar.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '227a2c03-dfd1-4e03-9c04-daaf74fc68bd'::uuid AND email_address = 'noelia.toro.1948@escobar.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'bc6e7a77-d709-401c-bea7-82715eeb1a29'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'ines.tellez.2001@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'bc6e7a77-d709-401c-bea7-82715eeb1a29'::uuid AND email_address = 'ines.tellez.2001@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'd54d7239-e49a-4185-8875-4f71af08b789'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'hector.maldonado.1974@grupo.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'd54d7239-e49a-4185-8875-4f71af08b789'::uuid AND email_address = 'hector.maldonado.1974@grupo.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '8370857e-7e69-43a6-be63-78fc270c5fd5'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'jonas.segura.1969@loera-granados.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '8370857e-7e69-43a6-be63-78fc270c5fd5'::uuid AND email_address = 'jonas.segura.1969@loera-granados.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'e8813bf8-7bbb-4370-a181-880c0c959aa1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'joseluis.gomez.2003@del.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'e8813bf8-7bbb-4370-a181-880c0c959aa1'::uuid AND email_address = 'joseluis.gomez.2003@del.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '4337bfc4-5ea7-4621-bd24-dbf3f55e350a'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'fernando.gil.1947@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '4337bfc4-5ea7-4621-bd24-dbf3f55e350a'::uuid AND email_address = 'fernando.gil.1947@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '517958b1-f860-4a42-965b-15a796055981'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'angela.montanez.1974@club.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '517958b1-f860-4a42-965b-15a796055981'::uuid AND email_address = 'angela.montanez.1974@club.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '44e4c099-cf6e-4926-85f1-ab5cb34c59a1'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'leonor.olivera.1953@galarza-soliz.info', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '44e4c099-cf6e-4926-85f1-ab5cb34c59a1'::uuid AND email_address = 'leonor.olivera.1953@galarza-soliz.info');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', 'a0c3c815-c664-4931-927f-e4109a545603'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'gabino.aguirre.1951@laboratorios.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = 'a0c3c815-c664-4931-927f-e4109a545603'::uuid AND email_address = 'gabino.aguirre.1951@laboratorios.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '5c1862f6-f802-41ae-a6fb-87dbc5555fb3'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'judith.aleman.1976@molina.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '5c1862f6-f802-41ae-a6fb-87dbc5555fb3'::uuid AND email_address = 'judith.aleman.1976@molina.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '11d31cb4-1dfb-479e-9329-8b8b35920b98'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'oswaldo.fuentes.1989@castro-rosario.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '11d31cb4-1dfb-479e-9329-8b8b35920b98'::uuid AND email_address = 'oswaldo.fuentes.1989@castro-rosario.com');

-- =============================================
-- INSTITUTION PHONES
-- =============================================

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '163749fb-8b46-4447-a8b7-95b4a59531b6'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3371522360', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '163749fb-8b46-4447-a8b7-95b4a59531b6'::uuid AND phone_number = '3371522360');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '83b74179-f6ef-4219-bc70-c93f4393a350'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47710848429', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '83b74179-f6ef-4219-bc70-c93f4393a350'::uuid AND phone_number = '47710848429');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '50503414-ca6d-4c1a-a34f-18719e2fd555'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47740431756', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '50503414-ca6d-4c1a-a34f-18719e2fd555'::uuid AND phone_number = '47740431756');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '9b581d3c-9e93-4f39-80bb-294752065866'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8132350509', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '9b581d3c-9e93-4f39-80bb-294752065866'::uuid AND phone_number = '8132350509');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'e0e34926-8d48-4db0-afb9-b20b6eeb1ecb'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5593961023', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'e0e34926-8d48-4db0-afb9-b20b6eeb1ecb'::uuid AND phone_number = '5593961023');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '81941e1d-820a-4313-8177-e44278d9a981'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3392879825', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '81941e1d-820a-4313-8177-e44278d9a981'::uuid AND phone_number = '3392879825');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'a725b15f-039b-4256-843a-51a2968633fd'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5563189795', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'a725b15f-039b-4256-843a-51a2968633fd'::uuid AND phone_number = '5563189795');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5569070701', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d'::uuid AND phone_number = '5569070701');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'd471d2d1-66a1-4de0-8754-127059786888'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5580154634', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'd471d2d1-66a1-4de0-8754-127059786888'::uuid AND phone_number = '5580154634');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '8fd698b3-084d-4248-a28e-2708a5862e27'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3364725703', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '8fd698b3-084d-4248-a28e-2708a5862e27'::uuid AND phone_number = '3364725703');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '7b96a7bb-041f-4331-be05-e97cab7dafc0'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5536602749', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '7b96a7bb-041f-4331-be05-e97cab7dafc0'::uuid AND phone_number = '5536602749');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '5da54d5d-de0c-4277-a43e-6a89f987e77c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8141990637', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '5da54d5d-de0c-4277-a43e-6a89f987e77c'::uuid AND phone_number = '8141990637');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'c9014e88-309c-4cb0-a28d-25b510e1e522'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5536357624', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'c9014e88-309c-4cb0-a28d-25b510e1e522'::uuid AND phone_number = '5536357624');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '8e889f63-2c86-44ab-959f-fdc365353d5d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5531647646', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '8e889f63-2c86-44ab-959f-fdc365353d5d'::uuid AND phone_number = '5531647646');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '67787f7c-fdee-4e30-80bd-89008ebfe419'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5573657880', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '67787f7c-fdee-4e30-80bd-89008ebfe419'::uuid AND phone_number = '5573657880');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '4721cb90-8fb0-4fd6-b19e-160b4ac0c744'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5523095343', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '4721cb90-8fb0-4fd6-b19e-160b4ac0c744'::uuid AND phone_number = '5523095343');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '09c54a60-6267-4439-9c8b-8c9012842942'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47784565029', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '09c54a60-6267-4439-9c8b-8c9012842942'::uuid AND phone_number = '47784565029');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'a670c73c-cc47-42fe-88c9-0fa37359779b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3335604109', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'a670c73c-cc47-42fe-88c9-0fa37359779b'::uuid AND phone_number = '3335604109');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '373769ab-b720-4269-bfb9-02546401ce99'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3387415163', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '373769ab-b720-4269-bfb9-02546401ce99'::uuid AND phone_number = '3387415163');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3371732241', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75'::uuid AND phone_number = '3371732241');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47773120537', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0'::uuid AND phone_number = '47773120537');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '6c287a0e-9d4c-4574-932f-7d499aa4146c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8127073578', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '6c287a0e-9d4c-4574-932f-7d499aa4146c'::uuid AND phone_number = '8127073578');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'a14c189c-ee90-4c29-b465-63d43a9d0010'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47793180489', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'a14c189c-ee90-4c29-b465-63d43a9d0010'::uuid AND phone_number = '47793180489');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'e040eabc-0ac9-47f7-89ae-24246e1c12dd'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47769806180', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'e040eabc-0ac9-47f7-89ae-24246e1c12dd'::uuid AND phone_number = '47769806180');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '9c8636c9-015b-4c18-a641-f5da698b6fd8'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5551040756', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '9c8636c9-015b-4c18-a641-f5da698b6fd8'::uuid AND phone_number = '5551040756');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3338349676', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa'::uuid AND phone_number = '3338349676');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '146a692b-6d46-4c26-a165-092fe771400e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32230861106', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '146a692b-6d46-4c26-a165-092fe771400e'::uuid AND phone_number = '32230861106');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '6297ae0f-7fee-472d-87ec-e22b87ce6ffb'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47739482818', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '6297ae0f-7fee-472d-87ec-e22b87ce6ffb'::uuid AND phone_number = '47739482818');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '66e6aa6c-596c-442e-85fb-b143875d0dfc'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47796574625', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '66e6aa6c-596c-442e-85fb-b143875d0dfc'::uuid AND phone_number = '47796574625');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '46af545e-6db8-44ba-a7f9-9fd9617f4a09'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8125874092', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '46af545e-6db8-44ba-a7f9-9fd9617f4a09'::uuid AND phone_number = '8125874092');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'a56b6787-94e9-49f0-8b3a-6ff5979773fc'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5572538845', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'a56b6787-94e9-49f0-8b3a-6ff5979773fc'::uuid AND phone_number = '5572538845');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47711832832', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf'::uuid AND phone_number = '47711832832');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '4bfa1a0a-0434-45e0-b454-03140b992f53'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47731133700', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '4bfa1a0a-0434-45e0-b454-03140b992f53'::uuid AND phone_number = '47731133700');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '33ba98b9-c46a-47c1-b266-d8a4fe557290'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5551548989', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '33ba98b9-c46a-47c1-b266-d8a4fe557290'::uuid AND phone_number = '5551548989');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'f4764cd3-47e9-4408-b0ee-9b9001c5459d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3375586924', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'f4764cd3-47e9-4408-b0ee-9b9001c5459d'::uuid AND phone_number = '3375586924');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3390639484', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8'::uuid AND phone_number = '3390639484');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5586439727', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d'::uuid AND phone_number = '5586439727');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '8be78aaa-c408-452e-bf01-8e831ab5c63a'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5563882660', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '8be78aaa-c408-452e-bf01-8e831ab5c63a'::uuid AND phone_number = '5563882660');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '8fb0899c-732e-4f03-8209-d52ef41a6a76'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47752673618', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '8fb0899c-732e-4f03-8209-d52ef41a6a76'::uuid AND phone_number = '47752673618');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '3a9084e7-74c5-4e0b-b786-2c93d9cd39ee'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5525184251', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '3a9084e7-74c5-4e0b-b786-2c93d9cd39ee'::uuid AND phone_number = '5525184251');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '54481b92-e5f5-421b-ba21-89bf520a2d87'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5546313692', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '54481b92-e5f5-421b-ba21-89bf520a2d87'::uuid AND phone_number = '5546313692');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '68f1a02a-d348-4d1e-99ee-733d832a3f43'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5536266540', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '68f1a02a-d348-4d1e-99ee-733d832a3f43'::uuid AND phone_number = '5536266540');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '36983990-abe8-4f1c-9c1b-863b9cab3ca9'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3362895531', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '36983990-abe8-4f1c-9c1b-863b9cab3ca9'::uuid AND phone_number = '3362895531');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'b654860f-ec74-42d6-955e-eeedde2df0dd'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5590490534', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'b654860f-ec74-42d6-955e-eeedde2df0dd'::uuid AND phone_number = '5590490534');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'be133600-848e-400b-9bc8-c52a4f3cf10d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8171124647', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'be133600-848e-400b-9bc8-c52a4f3cf10d'::uuid AND phone_number = '8171124647');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '25e918f3-692f-4f51-b630-4caa1dd825a1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3312013008', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '25e918f3-692f-4f51-b630-4caa1dd825a1'::uuid AND phone_number = '3312013008');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'cc46221e-f387-463c-9d11-9464d8209f7b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47731972760', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'cc46221e-f387-463c-9d11-9464d8209f7b'::uuid AND phone_number = '47731972760');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5512789651', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42'::uuid AND phone_number = '5512789651');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '3d7c5771-0692-4a2f-a4c6-6af2b561282b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47755839275', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '3d7c5771-0692-4a2f-a4c6-6af2b561282b'::uuid AND phone_number = '47755839275');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '16b25a77-b84a-44ac-8540-c5bfa9b3b6b0'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32266246979', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '16b25a77-b84a-44ac-8540-c5bfa9b3b6b0'::uuid AND phone_number = '32266246979');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '2040ac28-7210-4fbd-9716-53872211bcd9'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5569522073', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '2040ac28-7210-4fbd-9716-53872211bcd9'::uuid AND phone_number = '5569522073');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '0d826581-b9d8-4828-8848-9332fe38d169'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47712938580', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '0d826581-b9d8-4828-8848-9332fe38d169'::uuid AND phone_number = '47712938580');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'c0595f94-c8f4-413c-a05c-7cfca773563c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47732874842', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'c0595f94-c8f4-413c-a05c-7cfca773563c'::uuid AND phone_number = '47732874842');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5528016555', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5'::uuid AND phone_number = '5528016555');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'ad2c792b-5015-4238-b221-fa28e8b061fc'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3337567197', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'ad2c792b-5015-4238-b221-fa28e8b061fc'::uuid AND phone_number = '3337567197');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'c3e96b10-f0ca-421e-b402-aba6d595cf27'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5560304824', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'c3e96b10-f0ca-421e-b402-aba6d595cf27'::uuid AND phone_number = '5560304824');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'a5b1202a-9112-404b-b7de-ddf0f62711f8'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5543588535', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'a5b1202a-9112-404b-b7de-ddf0f62711f8'::uuid AND phone_number = '5543588535');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'ac6f8f54-21c8-475b-bea6-19e31643392d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3370017140', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'ac6f8f54-21c8-475b-bea6-19e31643392d'::uuid AND phone_number = '3370017140');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '43dee983-676a-4e33-a6b0-f0a72f46d06c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8179974813', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '43dee983-676a-4e33-a6b0-f0a72f46d06c'::uuid AND phone_number = '8179974813');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5558498859', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca'::uuid AND phone_number = '5558498859');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '08a7fe9e-c043-4fed-89e4-93a416a20089'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47797830994', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '08a7fe9e-c043-4fed-89e4-93a416a20089'::uuid AND phone_number = '47797830994');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '89ab21cf-089e-4210-8e29-269dfbd38d71'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32277266734', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '89ab21cf-089e-4210-8e29-269dfbd38d71'::uuid AND phone_number = '32277266734');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'd56e3cb0-d9e2-48fc-9c16-c4a96b90c00f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5539911148', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'd56e3cb0-d9e2-48fc-9c16-c4a96b90c00f'::uuid AND phone_number = '5539911148');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3386263805', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0'::uuid AND phone_number = '3386263805');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '3cf42c93-4941-4d8d-8656-aafa9e987177'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47785457044', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '3cf42c93-4941-4d8d-8656-aafa9e987177'::uuid AND phone_number = '47785457044');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '1926fa2a-dab7-420e-861b-c2b6dfe0174e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32229847340', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '1926fa2a-dab7-420e-861b-c2b6dfe0174e'::uuid AND phone_number = '32229847340');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '0b2f4464-5141-44a3-a26d-f8acc1fb955e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8189695283', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '0b2f4464-5141-44a3-a26d-f8acc1fb955e'::uuid AND phone_number = '8189695283');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '1fec9665-52bc-49a7-b028-f0d78440463c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3381134604', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '1fec9665-52bc-49a7-b028-f0d78440463c'::uuid AND phone_number = '3381134604');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8146729225', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a'::uuid AND phone_number = '8146729225');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '8cfdeaad-c727-4a4d-b5d5-b69dd43c0854'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3396048181', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '8cfdeaad-c727-4a4d-b5d5-b69dd43c0854'::uuid AND phone_number = '3396048181');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '7a6ce151-14b5-4d12-b6bb-1fba18636353'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47779106285', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '7a6ce151-14b5-4d12-b6bb-1fba18636353'::uuid AND phone_number = '47779106285');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'f1ab98f4-98de-420f-9c4b-c31eee92df21'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5549218125', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'f1ab98f4-98de-420f-9c4b-c31eee92df21'::uuid AND phone_number = '5549218125');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'a074c3ea-f255-4cf2-ae3f-727f9186be3c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32261602068', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'a074c3ea-f255-4cf2-ae3f-727f9186be3c'::uuid AND phone_number = '32261602068');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '0e3821a8-80d6-4fa9-8313-3ed45b83c28b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32265458833', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '0e3821a8-80d6-4fa9-8313-3ed45b83c28b'::uuid AND phone_number = '32265458833');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '3d521bc9-692d-4a0d-a3d7-80e816b86374'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5538270003', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '3d521bc9-692d-4a0d-a3d7-80e816b86374'::uuid AND phone_number = '5538270003');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '47393461-e570-448b-82b1-1cef15441262'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32236153532', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '47393461-e570-448b-82b1-1cef15441262'::uuid AND phone_number = '32236153532');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '744b4a03-e575-4978-b10e-6c087c9e744b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3374016317', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '744b4a03-e575-4978-b10e-6c087c9e744b'::uuid AND phone_number = '3374016317');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '9a18b839-1b93-44fb-9d8a-2ea12388e887'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3327117670', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '9a18b839-1b93-44fb-9d8a-2ea12388e887'::uuid AND phone_number = '3327117670');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47791284627', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b'::uuid AND phone_number = '47791284627');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3347494645', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f'::uuid AND phone_number = '3347494645');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'eea6be20-e19f-485f-ab54-537a7c28245f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32266477281', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'eea6be20-e19f-485f-ab54-537a7c28245f'::uuid AND phone_number = '32266477281');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'eb602cae-423a-455d-a22e-d47aea5eb650'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5550417646', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'eb602cae-423a-455d-a22e-d47aea5eb650'::uuid AND phone_number = '5550417646');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'bb17faca-a7b2-4de8-bf29-2fcb569ef554'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8168716203', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'bb17faca-a7b2-4de8-bf29-2fcb569ef554'::uuid AND phone_number = '8168716203');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '44a33aab-1a23-4995-bd07-41f95b34fd57'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32233606764', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '44a33aab-1a23-4995-bd07-41f95b34fd57'::uuid AND phone_number = '32233606764');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '5462455f-fbe3-44c8-b0d1-0644c433aca6'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5516600818', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '5462455f-fbe3-44c8-b0d1-0644c433aca6'::uuid AND phone_number = '5516600818');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'd050617d-dc89-4f28-b546-9680dd1c5fad'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5553664978', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'd050617d-dc89-4f28-b546-9680dd1c5fad'::uuid AND phone_number = '5553664978');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '7227444e-b122-48f4-8f01-2cda439507b1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8115853052', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '7227444e-b122-48f4-8f01-2cda439507b1'::uuid AND phone_number = '8115853052');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'd86c173a-8a1d-43b4-a0c1-c836afdc378b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47785315931', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'd86c173a-8a1d-43b4-a0c1-c836afdc378b'::uuid AND phone_number = '47785315931');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'fb0a848d-4d51-4416-86bc-e568f694f9e7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32294844660', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'fb0a848d-4d51-4416-86bc-e568f694f9e7'::uuid AND phone_number = '32294844660');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47722520092', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc'::uuid AND phone_number = '47722520092');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '8cb48822-4d4c-42ed-af7f-737d3107b1db'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32267361080', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '8cb48822-4d4c-42ed-af7f-737d3107b1db'::uuid AND phone_number = '32267361080');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '700b8c76-7ad1-4453-9ce3-f598565c6452'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8141115029', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '700b8c76-7ad1-4453-9ce3-f598565c6452'::uuid AND phone_number = '8141115029');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', 'd3cb7dc8-9240-4800-a1d9-bf65c5dac801'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47759537736', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = 'd3cb7dc8-9240-4800-a1d9-bf65c5dac801'::uuid AND phone_number = '47759537736');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '06c71356-e038-4c3d-bfea-7865acacb684'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32277960079', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '06c71356-e038-4c3d-bfea-7865acacb684'::uuid AND phone_number = '32277960079');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '30e2b2ec-9553-454e-92a4-c1dc89609cbb'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3388792805', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '30e2b2ec-9553-454e-92a4-c1dc89609cbb'::uuid AND phone_number = '3388792805');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '2eead5aa-095b-418a-bd02-e3a917971887'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32279210570', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '2eead5aa-095b-418a-bd02-e3a917971887'::uuid AND phone_number = '32279210570');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '05afd7e1-bb93-4c83-90a7-48a65b6e7598'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32230602922', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '05afd7e1-bb93-4c83-90a7-48a65b6e7598'::uuid AND phone_number = '32230602922');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47744376047', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15'::uuid AND phone_number = '47744376047');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '454f4ba6-cb6d-4f27-9d76-08f5b358b484'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5565348409', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '454f4ba6-cb6d-4f27-9d76-08f5b358b484'::uuid AND phone_number = '5565348409');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32265917881', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282'::uuid AND phone_number = '32265917881');

-- =============================================
-- DOCTOR PHONES
-- =============================================

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-3394-3614', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7'::uuid AND phone_number = '+52-322-3394-3614');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '3e5b08ed-529d-45f0-8145-8371609882c1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-3363-8293', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '3e5b08ed-529d-45f0-8145-8371609882c1'::uuid AND phone_number = '+52-81-3363-8293');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '57031194-3c31-4320-86c4-fd370789efac'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-7563-1830', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '57031194-3c31-4320-86c4-fd370789efac'::uuid AND phone_number = '+52-322-7563-1830');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'dc42b779-4b49-418b-ab0a-92caa2a8d6de'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-9394-7823', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'dc42b779-4b49-418b-ab0a-92caa2a8d6de'::uuid AND phone_number = '+52-322-9394-7823');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '14abdfde-e4c9-460c-9ce2-17886600b20d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-5183-1669', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '14abdfde-e4c9-460c-9ce2-17886600b20d'::uuid AND phone_number = '+52-322-5183-1669');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'df863eba-f0b8-4b1a-bdd1-71ed2f816ed7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-9565-6802', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'df863eba-f0b8-4b1a-bdd1-71ed2f816ed7'::uuid AND phone_number = '+52-81-9565-6802');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'ba712fc8-c4d2-4e22-ae18-1991c46bc85d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-4141-7561', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'ba712fc8-c4d2-4e22-ae18-1991c46bc85d'::uuid AND phone_number = '+52-81-4141-7561');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'bbf715a1-3947-4642-a67a-b5c4c0c085d2'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-5100-9719', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'bbf715a1-3947-4642-a67a-b5c4c0c085d2'::uuid AND phone_number = '+52-55-5100-9719');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-5034-1601', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec'::uuid AND phone_number = '+52-477-5034-1601');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '0fbbaab0-2284-4ac6-b1c9-498b5b3c4567'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-1562-6872', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '0fbbaab0-2284-4ac6-b1c9-498b5b3c4567'::uuid AND phone_number = '+52-477-1562-6872');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'b6994d45-b80e-4260-834c-facdf3ea8eee'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-8080-4957', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'b6994d45-b80e-4260-834c-facdf3ea8eee'::uuid AND phone_number = '+52-477-8080-4957');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'f7cdc060-94e6-47ad-90e9-939ed86fb6da'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-5323-5705', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'f7cdc060-94e6-47ad-90e9-939ed86fb6da'::uuid AND phone_number = '+52-322-5323-5705');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '23785934-fbf0-442c-add3-05df84fa5d17'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-1157-2790', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '23785934-fbf0-442c-add3-05df84fa5d17'::uuid AND phone_number = '+52-33-1157-2790');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'bf7a015c-1589-42b3-b1e8-103fcbc0b041'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-2945-4642', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'bf7a015c-1589-42b3-b1e8-103fcbc0b041'::uuid AND phone_number = '+52-477-2945-4642');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '4fa9d0ff-2c51-4918-b48a-b5cb37d444a3'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-8962-4540', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '4fa9d0ff-2c51-4918-b48a-b5cb37d444a3'::uuid AND phone_number = '+52-55-8962-4540');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '93dbdfc0-e05c-4eb6-975c-360eb8d293c1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-8045-7756', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '93dbdfc0-e05c-4eb6-975c-360eb8d293c1'::uuid AND phone_number = '+52-81-8045-7756');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'a6db1b41-d601-4840-99e9-3d7d18901399'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-7009-9717', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'a6db1b41-d601-4840-99e9-3d7d18901399'::uuid AND phone_number = '+52-322-7009-9717');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'd5e98ce0-e6f8-4577-a0dd-3281aa303b32'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-9398-3998', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'd5e98ce0-e6f8-4577-a0dd-3281aa303b32'::uuid AND phone_number = '+52-33-9398-3998');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '44da48b1-6ff6-4db9-9de5-34e22de0429a'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-2866-8056', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '44da48b1-6ff6-4db9-9de5-34e22de0429a'::uuid AND phone_number = '+52-55-2866-8056');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '3fafc20d-72d5-4633-95a0-df6b9ed175b6'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-3663-1685', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '3fafc20d-72d5-4633-95a0-df6b9ed175b6'::uuid AND phone_number = '+52-322-3663-1685');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'c4fac110-0b61-4fb0-943d-0d00af7ed0cd'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-7146-5995', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'c4fac110-0b61-4fb0-943d-0d00af7ed0cd'::uuid AND phone_number = '+52-81-7146-5995');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '88870e4f-1333-4bcc-8daf-c8743d61f3cb'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-6252-2821', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '88870e4f-1333-4bcc-8daf-c8743d61f3cb'::uuid AND phone_number = '+52-81-6252-2821');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '6f035f60-87f7-4a9c-9501-4b8704facba3'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-8352-1711', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '6f035f60-87f7-4a9c-9501-4b8704facba3'::uuid AND phone_number = '+52-81-8352-1711');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '58a814d3-a275-436b-8e5c-4e743fed242f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-7762-6936', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '58a814d3-a275-436b-8e5c-4e743fed242f'::uuid AND phone_number = '+52-33-7762-6936');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'f67c2f76-9bf1-43e4-8d0e-c0a94298f35b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-4324-9871', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'f67c2f76-9bf1-43e4-8d0e-c0a94298f35b'::uuid AND phone_number = '+52-81-4324-9871');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'fb4d84a0-7bc1-4815-b7a3-b1719c616c79'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-9176-3434', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'fb4d84a0-7bc1-4815-b7a3-b1719c616c79'::uuid AND phone_number = '+52-33-9176-3434');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'c0bdb808-eb5f-479f-9261-dbbf9ff031a6'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-2455-1510', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'c0bdb808-eb5f-479f-9261-dbbf9ff031a6'::uuid AND phone_number = '+52-477-2455-1510');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'f501d643-d308-41e0-8ffc-8bfb52d64e13'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-6386-4972', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'f501d643-d308-41e0-8ffc-8bfb52d64e13'::uuid AND phone_number = '+52-55-6386-4972');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'adeb74f6-f3dc-43a7-a841-6d24aba046ba'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-7930-5677', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'adeb74f6-f3dc-43a7-a841-6d24aba046ba'::uuid AND phone_number = '+52-477-7930-5677');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'dd24da99-43c7-4d6b-acc0-32fc0c237d02'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-8635-4389', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'dd24da99-43c7-4d6b-acc0-32fc0c237d02'::uuid AND phone_number = '+52-55-8635-4389');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '0408b031-caa3-4b7c-ae65-d05342cf5c05'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-7611-8419', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '0408b031-caa3-4b7c-ae65-d05342cf5c05'::uuid AND phone_number = '+52-55-7611-8419');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'a865edbe-d50c-4bd1-b556-ae32d9d1858c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-6989-3692', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'a865edbe-d50c-4bd1-b556-ae32d9d1858c'::uuid AND phone_number = '+52-55-6989-3692');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '2a0aaddd-ea43-40bb-b5df-877b1b0d20f1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-1488-2230', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '2a0aaddd-ea43-40bb-b5df-877b1b0d20f1'::uuid AND phone_number = '+52-33-1488-2230');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '4754ba59-3dc1-4be2-a770-44d7c34184bc'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-5636-3465', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '4754ba59-3dc1-4be2-a770-44d7c34184bc'::uuid AND phone_number = '+52-477-5636-3465');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '16e23379-6774-417d-8104-a8e6f4712909'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-2025-6399', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '16e23379-6774-417d-8104-a8e6f4712909'::uuid AND phone_number = '+52-55-2025-6399');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '07527c1a-efd5-45e4-a0d9-01ba5207bb2f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-6307-9700', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '07527c1a-efd5-45e4-a0d9-01ba5207bb2f'::uuid AND phone_number = '+52-55-6307-9700');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'c186d1ad-fcba-4f6e-acd7-86cb4c09938e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-8108-5000', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'c186d1ad-fcba-4f6e-acd7-86cb4c09938e'::uuid AND phone_number = '+52-55-8108-5000');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '4cecebec-e16f-4949-a18b-8bfebae86618'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-6319-3357', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '4cecebec-e16f-4949-a18b-8bfebae86618'::uuid AND phone_number = '+52-477-6319-3357');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '6d21a37a-43d8-440b-bc64-87bb0ae1d45d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-5709-2479', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '6d21a37a-43d8-440b-bc64-87bb0ae1d45d'::uuid AND phone_number = '+52-81-5709-2479');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '4d75aae7-5d33-44ad-a297-a32ff407415d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-1880-1065', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '4d75aae7-5d33-44ad-a297-a32ff407415d'::uuid AND phone_number = '+52-55-1880-1065');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'e901dbc1-3eed-4e5e-b23c-58d808477e33'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-7421-4169', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'e901dbc1-3eed-4e5e-b23c-58d808477e33'::uuid AND phone_number = '+52-33-7421-4169');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '61bb20b9-7520-42be-accf-743c84a0b934'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-7885-3204', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '61bb20b9-7520-42be-accf-743c84a0b934'::uuid AND phone_number = '+52-477-7885-3204');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'b5a04df6-baea-460f-a946-f7b7606c9982'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-3164-7783', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'b5a04df6-baea-460f-a946-f7b7606c9982'::uuid AND phone_number = '+52-33-3164-7783');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'c1182c2e-0624-42f9-aef6-7e7a1a2b7dba'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-3786-5736', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'c1182c2e-0624-42f9-aef6-7e7a1a2b7dba'::uuid AND phone_number = '+52-322-3786-5736');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '0b238725-a392-4fbb-956b-0f71e15bc6da'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-5910-2235', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '0b238725-a392-4fbb-956b-0f71e15bc6da'::uuid AND phone_number = '+52-81-5910-2235');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '63ec3e7d-b8e4-4988-9bc3-5b655f830e31'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-3497-5247', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '63ec3e7d-b8e4-4988-9bc3-5b655f830e31'::uuid AND phone_number = '+52-81-3497-5247');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'd4df85ce-6d2b-46c9-b9cd-48b2490b3c88'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-6842-1764', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'd4df85ce-6d2b-46c9-b9cd-48b2490b3c88'::uuid AND phone_number = '+52-55-6842-1764');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '71618fe0-25a1-4281-98af-51797de3ae0a'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-2421-9011', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '71618fe0-25a1-4281-98af-51797de3ae0a'::uuid AND phone_number = '+52-33-2421-9011');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '389524b6-608c-4b31-affa-305b79635816'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-9520-2823', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '389524b6-608c-4b31-affa-305b79635816'::uuid AND phone_number = '+52-33-9520-2823');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'c0356e82-1510-4557-b654-cf84ac13f425'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-5120-2469', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'c0356e82-1510-4557-b654-cf84ac13f425'::uuid AND phone_number = '+52-81-5120-2469');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'ce44b08f-7dae-4844-ae53-e01ac2f28f45'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-7506-8164', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'ce44b08f-7dae-4844-ae53-e01ac2f28f45'::uuid AND phone_number = '+52-33-7506-8164');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '9c9838c2-4464-4fbb-bc22-8f4ac64b4efe'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-4353-7797', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '9c9838c2-4464-4fbb-bc22-8f4ac64b4efe'::uuid AND phone_number = '+52-322-4353-7797');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'e8db5b49-5605-41e5-91f2-d456b68c5ade'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-5541-5639', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'e8db5b49-5605-41e5-91f2-d456b68c5ade'::uuid AND phone_number = '+52-55-5541-5639');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '96d6da02-ca2f-4ace-b239-4584544e8230'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-6078-9976', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '96d6da02-ca2f-4ace-b239-4584544e8230'::uuid AND phone_number = '+52-33-6078-9976');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '38bf2ce6-5014-4bc1-8e32-9b9257eea501'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-8261-8204', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '38bf2ce6-5014-4bc1-8e32-9b9257eea501'::uuid AND phone_number = '+52-322-8261-8204');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-9275-1034', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c'::uuid AND phone_number = '+52-81-9275-1034');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '8ce8b684-8f8d-4828-987d-389dfe64afd1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-4349-3546', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '8ce8b684-8f8d-4828-987d-389dfe64afd1'::uuid AND phone_number = '+52-55-4349-3546');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'ca8bf565-35d3-40f3-b741-603201f6f072'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-6605-6510', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'ca8bf565-35d3-40f3-b741-603201f6f072'::uuid AND phone_number = '+52-322-6605-6510');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '2937cc2f-22b7-4488-b9f8-a0795800a840'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-7670-2662', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '2937cc2f-22b7-4488-b9f8-a0795800a840'::uuid AND phone_number = '+52-33-7670-2662');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'f8a511e3-b97b-4d17-8240-46520497ef7c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-5164-9244', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'f8a511e3-b97b-4d17-8240-46520497ef7c'::uuid AND phone_number = '+52-55-5164-9244');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '879bcb9a-8520-4d02-b12b-ba5afa629d41'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-6982-4326', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '879bcb9a-8520-4d02-b12b-ba5afa629d41'::uuid AND phone_number = '+52-81-6982-4326');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '7817761a-e7c5-47cb-a260-7e243c11ef2f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-3969-4235', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '7817761a-e7c5-47cb-a260-7e243c11ef2f'::uuid AND phone_number = '+52-477-3969-4235');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '48384f36-0b57-4943-899f-cbffd4ec37b6'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-7123-5544', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '48384f36-0b57-4943-899f-cbffd4ec37b6'::uuid AND phone_number = '+52-81-7123-5544');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '0fc70684-777f-43eb-895d-9cb90ce0f584'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-4386-2045', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '0fc70684-777f-43eb-895d-9cb90ce0f584'::uuid AND phone_number = '+52-33-4386-2045');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'a849f14b-3741-4e38-9dfb-6cc7d46265e8'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-7392-9529', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'a849f14b-3741-4e38-9dfb-6cc7d46265e8'::uuid AND phone_number = '+52-477-7392-9529');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '22128ae9-ba6e-4e99-821a-dc445e76d641'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-4348-2715', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '22128ae9-ba6e-4e99-821a-dc445e76d641'::uuid AND phone_number = '+52-33-4348-2715');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '6c711a31-c752-44f2-b6cb-480f9bf6af1f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-9342-3860', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '6c711a31-c752-44f2-b6cb-480f9bf6af1f'::uuid AND phone_number = '+52-55-9342-3860');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'ab923e2e-5d13-41e4-9c73-2f62cca0699d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-4821-8108', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'ab923e2e-5d13-41e4-9c73-2f62cca0699d'::uuid AND phone_number = '+52-33-4821-8108');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'a7f19796-4c62-4a2b-82de-7c2677804e6a'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-8468-7927', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'a7f19796-4c62-4a2b-82de-7c2677804e6a'::uuid AND phone_number = '+52-322-8468-7927');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '28958f29-28c6-405a-acf5-949ffcaec286'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-9822-2482', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '28958f29-28c6-405a-acf5-949ffcaec286'::uuid AND phone_number = '+52-477-9822-2482');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '472116b5-933e-4f63-b3ca-e8c8f5d30bb4'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-6587-7860', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '472116b5-933e-4f63-b3ca-e8c8f5d30bb4'::uuid AND phone_number = '+52-322-6587-7860');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'a2beaa02-c033-4e45-b702-305d5ce41e34'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-2224-6053', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'a2beaa02-c033-4e45-b702-305d5ce41e34'::uuid AND phone_number = '+52-322-2224-6053');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '5879ec30-c291-476d-a48c-284fadf5f98a'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-8639-6757', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '5879ec30-c291-476d-a48c-284fadf5f98a'::uuid AND phone_number = '+52-322-8639-6757');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'd512bd88-12a3-45f9-85e8-14fb3cb5a6e1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-1799-6512', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'd512bd88-12a3-45f9-85e8-14fb3cb5a6e1'::uuid AND phone_number = '+52-55-1799-6512');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '757d6edf-5aa8-461b-ac4f-9e8365017424'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-3407-9486', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '757d6edf-5aa8-461b-ac4f-9e8365017424'::uuid AND phone_number = '+52-55-3407-9486');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'c0d54a00-2ee9-4827-a7fb-6196ef15bdee'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-2852-9244', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'c0d54a00-2ee9-4827-a7fb-6196ef15bdee'::uuid AND phone_number = '+52-33-2852-9244');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'a7ada88a-7935-4dd5-8a4f-935c4b7c0bab'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-3726-8125', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'a7ada88a-7935-4dd5-8a4f-935c4b7c0bab'::uuid AND phone_number = '+52-55-3726-8125');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '4664d394-c950-4dbf-9b40-7b34c6d6dabb'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-7925-4823', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '4664d394-c950-4dbf-9b40-7b34c6d6dabb'::uuid AND phone_number = '+52-33-7925-4823');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'c16b254c-dcf7-4a31-a101-1ed86b62477e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-2215-9131', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'c16b254c-dcf7-4a31-a101-1ed86b62477e'::uuid AND phone_number = '+52-55-2215-9131');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'e0926c16-7f63-41ae-a091-1d0688c88322'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-6670-3319', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'e0926c16-7f63-41ae-a091-1d0688c88322'::uuid AND phone_number = '+52-322-6670-3319');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '250b33c9-1ba3-44e6-9c35-cde7000d6d53'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-3944-1078', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '250b33c9-1ba3-44e6-9c35-cde7000d6d53'::uuid AND phone_number = '+52-81-3944-1078');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'b6c86aef-75e2-4c64-bceb-e7de898b5a1b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-2071-7460', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'b6c86aef-75e2-4c64-bceb-e7de898b5a1b'::uuid AND phone_number = '+52-81-2071-7460');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'a3fb2dae-2a69-434f-86a9-65ae48c8f690'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-2950-8850', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'a3fb2dae-2a69-434f-86a9-65ae48c8f690'::uuid AND phone_number = '+52-33-2950-8850');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '820c1228-3d2d-4766-900f-32940f14e74b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-7502-5030', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '820c1228-3d2d-4766-900f-32940f14e74b'::uuid AND phone_number = '+52-81-7502-5030');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'da3dbacf-8df0-46cf-bbef-b51615063a9b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-8946-4245', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'da3dbacf-8df0-46cf-bbef-b51615063a9b'::uuid AND phone_number = '+52-322-8946-4245');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'e6ce6823-6c4d-4ead-98d7-78b94483fe2c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-2883-3832', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'e6ce6823-6c4d-4ead-98d7-78b94483fe2c'::uuid AND phone_number = '+52-322-2883-3832');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '84cb6703-edfc-4180-9f80-619064c9684e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-2665-4686', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '84cb6703-edfc-4180-9f80-619064c9684e'::uuid AND phone_number = '+52-477-2665-4686');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '21e4d7a9-73dc-4156-b413-b389c2e92a0d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-5101-7210', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '21e4d7a9-73dc-4156-b413-b389c2e92a0d'::uuid AND phone_number = '+52-55-5101-7210');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '85eb8041-b502-4b90-b586-c7c4593b5347'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-4944-2609', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '85eb8041-b502-4b90-b586-c7c4593b5347'::uuid AND phone_number = '+52-81-4944-2609');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-2075-4541', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9'::uuid AND phone_number = '+52-477-2075-4541');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '22d570dd-a72e-4599-8f13-df952d35d616'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-2138-1128', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '22d570dd-a72e-4599-8f13-df952d35d616'::uuid AND phone_number = '+52-33-2138-1128');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '04a9b2e7-638b-4fe0-a106-16b582d946ab'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-1736-1561', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '04a9b2e7-638b-4fe0-a106-16b582d946ab'::uuid AND phone_number = '+52-55-1736-1561');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '03e547d1-325a-46ea-bc94-c188abf53f0f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-8510-3279', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '03e547d1-325a-46ea-bc94-c188abf53f0f'::uuid AND phone_number = '+52-322-8510-3279');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '5a6de593-99b5-4942-a379-fd21b2a4999f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-1790-5546', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '5a6de593-99b5-4942-a379-fd21b2a4999f'::uuid AND phone_number = '+52-322-1790-5546');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'b7dd043b-953f-4e04-8a80-1c613d3c6675'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-5832-7205', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'b7dd043b-953f-4e04-8a80-1c613d3c6675'::uuid AND phone_number = '+52-477-5832-7205');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '852beb97-3c99-4391-879f-98f0c2154c20'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-2594-9486', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '852beb97-3c99-4391-879f-98f0c2154c20'::uuid AND phone_number = '+52-55-2594-9486');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '86bb4262-7a96-444b-a096-d3a1bd7782e7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-2838-8623', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '86bb4262-7a96-444b-a096-d3a1bd7782e7'::uuid AND phone_number = '+52-81-2838-8623');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', 'b441c98a-1075-4013-9fc2-9242d910713f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-1750-8948', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = 'b441c98a-1075-4013-9fc2-9242d910713f'::uuid AND phone_number = '+52-322-1750-8948');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '77486cf8-54d8-4120-856f-642ebae74d48'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-4791-4899', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '77486cf8-54d8-4120-856f-642ebae74d48'::uuid AND phone_number = '+52-55-4791-4899');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'doctor', '0e2fa589-05b2-402c-9722-1022a0121b04'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-8972-7151', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '0e2fa589-05b2-402c-9722-1022a0121b04'::uuid AND phone_number = '+52-477-8972-7151');

-- =============================================
-- PATIENT PHONES
-- =============================================

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '2f5622af-8528-4c85-8e16-3d175a4f2d15'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47767326416', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '2f5622af-8528-4c85-8e16-3d175a4f2d15'::uuid AND phone_number = '47767326416');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3323019122', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c'::uuid AND phone_number = '3323019122');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '959aa1dd-346b-4542-8f99-0d5e75301249'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5552272115', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '959aa1dd-346b-4542-8f99-0d5e75301249'::uuid AND phone_number = '5552272115');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '59402562-ce5f-450e-8e6c-9630514fe164'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47742686139', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '59402562-ce5f-450e-8e6c-9630514fe164'::uuid AND phone_number = '47742686139');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'f81c87d6-32f1-4c79-993a-18db4734ef65'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47788928661', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'f81c87d6-32f1-4c79-993a-18db4734ef65'::uuid AND phone_number = '47788928661');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '0b6b8229-4027-4ec7-8bce-c805de96ced3'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5556849742', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '0b6b8229-4027-4ec7-8bce-c805de96ced3'::uuid AND phone_number = '5556849742');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47741013863', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb'::uuid AND phone_number = '47741013863');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'f2a1f62a-8030-4f65-b82d-ce7376b955bd'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5592236447', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'f2a1f62a-8030-4f65-b82d-ce7376b955bd'::uuid AND phone_number = '5592236447');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '0104fea2-d27c-4611-8414-da6c898b6944'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5564980935', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '0104fea2-d27c-4611-8414-da6c898b6944'::uuid AND phone_number = '5564980935');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'cd0c2f0c-de08-439c-93c9-0feab1d433cc'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32272329493', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'cd0c2f0c-de08-439c-93c9-0feab1d433cc'::uuid AND phone_number = '32272329493');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5565181217', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545'::uuid AND phone_number = '5565181217');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '7893292b-965a-41da-896a-d0780c91fdd5'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47722252483', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '7893292b-965a-41da-896a-d0780c91fdd5'::uuid AND phone_number = '47722252483');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '87fb3c88-6653-45db-aa6c-20ea7512da64'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32288625625', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '87fb3c88-6653-45db-aa6c-20ea7512da64'::uuid AND phone_number = '32288625625');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '05e42aed-c457-4579-904f-d397be3075f7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32276286121', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '05e42aed-c457-4579-904f-d397be3075f7'::uuid AND phone_number = '32276286121');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '43756f6c-c157-4a44-9c84-ab2d62fddcf7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5537628005', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '43756f6c-c157-4a44-9c84-ab2d62fddcf7'::uuid AND phone_number = '5537628005');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'd8e1fa52-0a65-4917-b410-2954e05a34e5'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32257680744', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'd8e1fa52-0a65-4917-b410-2954e05a34e5'::uuid AND phone_number = '32257680744');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'bbc67f38-a9eb-4379-aeaf-1560af0d1a34'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32222570425', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'bbc67f38-a9eb-4379-aeaf-1560af0d1a34'::uuid AND phone_number = '32222570425');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8130775568', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e'::uuid AND phone_number = '8130775568');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '309df411-1d1a-4d00-a34e-36e8c32da210'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47786693347', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '309df411-1d1a-4d00-a34e-36e8c32da210'::uuid AND phone_number = '47786693347');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '663d036b-a19b-4557-af37-d68a9ce4976d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3374570335', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '663d036b-a19b-4557-af37-d68a9ce4976d'::uuid AND phone_number = '3374570335');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'a754cbf1-a4ca-42dc-92c4-d980b6a25a6d'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3357731626', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'a754cbf1-a4ca-42dc-92c4-d980b6a25a6d'::uuid AND phone_number = '3357731626');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'd5b1779e-21f2-4252-a421-f2aaf9998916'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32266756711', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'd5b1779e-21f2-4252-a421-f2aaf9998916'::uuid AND phone_number = '32266756711');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '6661483b-705b-412a-8bbd-39c0af0dadb1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3342075624', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '6661483b-705b-412a-8bbd-39c0af0dadb1'::uuid AND phone_number = '3342075624');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '676491c4-f31a-42b6-a991-a8dd09bbb1f0'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47787809687', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '676491c4-f31a-42b6-a991-a8dd09bbb1f0'::uuid AND phone_number = '47787809687');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '3a9e8e0e-6367-409d-a81c-9852069c710e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8152479108', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '3a9e8e0e-6367-409d-a81c-9852069c710e'::uuid AND phone_number = '8152479108');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '167dedde-166c-45e4-befc-4f1c9b7184ad'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5532669687', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '167dedde-166c-45e4-befc-4f1c9b7184ad'::uuid AND phone_number = '5532669687');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '72eca572-4ecf-4be8-906b-40e89e0d9a08'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5558755697', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '72eca572-4ecf-4be8-906b-40e89e0d9a08'::uuid AND phone_number = '5558755697');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'd5bec069-a317-4a40-b3e8-ea80220d75de'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47777019760', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'd5bec069-a317-4a40-b3e8-ea80220d75de'::uuid AND phone_number = '47777019760');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '0e97294d-78cc-4428-a172-e4e1fd4efa72'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32272397391', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '0e97294d-78cc-4428-a172-e4e1fd4efa72'::uuid AND phone_number = '32272397391');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '9f86a53f-f0e1-446d-89f0-86b086dd12a9'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8182975364', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '9f86a53f-f0e1-446d-89f0-86b086dd12a9'::uuid AND phone_number = '8182975364');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'ae1f5c92-f3cf-43d8-918f-aaad6fb46c05'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3378488067', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'ae1f5c92-f3cf-43d8-918f-aaad6fb46c05'::uuid AND phone_number = '3378488067');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'd28440a6-3bd9-4a48-8a72-d700ae0971e4'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32217631358', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'd28440a6-3bd9-4a48-8a72-d700ae0971e4'::uuid AND phone_number = '32217631358');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '7f839ee8-bdd6-4a63-83e8-30db007565e2'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32256266752', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '7f839ee8-bdd6-4a63-83e8-30db007565e2'::uuid AND phone_number = '32256266752');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '67aa999f-9d31-4b61-a097-35097ea0d082'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5564754519', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '67aa999f-9d31-4b61-a097-35097ea0d082'::uuid AND phone_number = '5564754519');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '41aa2fbc-8ef4-4448-8686-399a1cd54be9'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3341002447', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '41aa2fbc-8ef4-4448-8686-399a1cd54be9'::uuid AND phone_number = '3341002447');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '111769f3-1a1b-44a9-9670-f4f2e424d1d2'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3314033550', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '111769f3-1a1b-44a9-9670-f4f2e424d1d2'::uuid AND phone_number = '3314033550');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3388797752', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1'::uuid AND phone_number = '3388797752');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '6a8b6d41-8d20-4bc5-8d48-538d348f6086'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3339979399', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '6a8b6d41-8d20-4bc5-8d48-538d348f6086'::uuid AND phone_number = '3339979399');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '89657c95-84c0-4bd0-80c6-70a2c4721276'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47719555349', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '89657c95-84c0-4bd0-80c6-70a2c4721276'::uuid AND phone_number = '47719555349');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'b6658dac-0ee1-415c-95ad-28c6acea85bd'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32212169179', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'b6658dac-0ee1-415c-95ad-28c6acea85bd'::uuid AND phone_number = '32212169179');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '56564104-6009-466c-9134-c15d3175613b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5533370300', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '56564104-6009-466c-9134-c15d3175613b'::uuid AND phone_number = '5533370300');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'edb1d693-b308-4ff6-8fd4-9e20561317e8'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32242195966', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'edb1d693-b308-4ff6-8fd4-9e20561317e8'::uuid AND phone_number = '32242195966');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '9511f9b9-a450-489c-92b9-ac306733cee4'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3376013110', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '9511f9b9-a450-489c-92b9-ac306733cee4'::uuid AND phone_number = '3376013110');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '004ce58b-6a0d-4646-92c3-4508deb6b354'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3378871890', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '004ce58b-6a0d-4646-92c3-4508deb6b354'::uuid AND phone_number = '3378871890');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '0d1bcc20-a5be-40f0-a28b-23c2c77c51be'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3363009943', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '0d1bcc20-a5be-40f0-a28b-23c2c77c51be'::uuid AND phone_number = '3363009943');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '38000dbb-417f-43ca-a60e-5812796420f7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47738838906', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '38000dbb-417f-43ca-a60e-5812796420f7'::uuid AND phone_number = '47738838906');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '5ae0a393-b399-4dc6-95d8-297d3b3ef0a8'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5559834687', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '5ae0a393-b399-4dc6-95d8-297d3b3ef0a8'::uuid AND phone_number = '5559834687');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '561c313d-2c15-41b1-b965-a38c8e0f6c42'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5582501507', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '561c313d-2c15-41b1-b965-a38c8e0f6c42'::uuid AND phone_number = '5582501507');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'ba4b2a5b-887d-4f3d-8ec7-570cfe087b28'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5546022019', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'ba4b2a5b-887d-4f3d-8ec7-570cfe087b28'::uuid AND phone_number = '5546022019');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'cbdb51c5-0334-4e15-b4b9-13b1de1c4c20'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3396137254', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'cbdb51c5-0334-4e15-b4b9-13b1de1c4c20'::uuid AND phone_number = '3396137254');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '05bc2942-e676-42e9-ad01-ade9f7cc5aee'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32245563881', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '05bc2942-e676-42e9-ad01-ade9f7cc5aee'::uuid AND phone_number = '32245563881');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'c78e7658-d517-4ca1-990b-e6971f8d108f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5519008445', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'c78e7658-d517-4ca1-990b-e6971f8d108f'::uuid AND phone_number = '5519008445');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '65474c27-8f72-4690-8f19-df9344e4be5e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3315951035', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '65474c27-8f72-4690-8f19-df9344e4be5e'::uuid AND phone_number = '3315951035');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'c1b6fa98-203a-4321-96cd-e80e7a1c9461'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5554080736', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'c1b6fa98-203a-4321-96cd-e80e7a1c9461'::uuid AND phone_number = '5554080736');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '9244b388-8c06-42c7-9c4e-cbaae5b1baa3'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32299706924', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '9244b388-8c06-42c7-9c4e-cbaae5b1baa3'::uuid AND phone_number = '32299706924');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'eb2e55f6-4738-4352-a59a-860909f1932c'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8195094207', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'eb2e55f6-4738-4352-a59a-860909f1932c'::uuid AND phone_number = '8195094207');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'c572a4c7-e475-4d18-85da-417abcd00903'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32248045763', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'c572a4c7-e475-4d18-85da-417abcd00903'::uuid AND phone_number = '32248045763');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8198067941', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3'::uuid AND phone_number = '8198067941');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '9b02d89c-2c5b-4c51-8183-15ccd1184990'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5537143958', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '9b02d89c-2c5b-4c51-8183-15ccd1184990'::uuid AND phone_number = '5537143958');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '43ae2e81-ac13-40ac-949c-9e4f51d76098'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5538402736', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '43ae2e81-ac13-40ac-949c-9e4f51d76098'::uuid AND phone_number = '5538402736');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '49a18092-8f90-4f6b-873c-8715b64b8aff'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8114757351', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '49a18092-8f90-4f6b-873c-8715b64b8aff'::uuid AND phone_number = '8114757351');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'c9a949e5-e650-4d95-9e2e-49ed06e5d087'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47717117861', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'c9a949e5-e650-4d95-9e2e-49ed06e5d087'::uuid AND phone_number = '47717117861');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'a4e5cbb3-36f7-43d8-a65a-e30fc1361e56'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5595587427', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'a4e5cbb3-36f7-43d8-a65a-e30fc1361e56'::uuid AND phone_number = '5595587427');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '447e48dc-861c-41e6-920e-a2dec785101f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8133123358', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '447e48dc-861c-41e6-920e-a2dec785101f'::uuid AND phone_number = '8133123358');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '3a535951-40fd-4959-a34e-07b29f675ecc'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8114053075', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '3a535951-40fd-4959-a34e-07b29f675ecc'::uuid AND phone_number = '8114053075');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'd4bfb3cb-c8d6-434a-a3d4-2712ecea4d70'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8172708573', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'd4bfb3cb-c8d6-434a-a3d4-2712ecea4d70'::uuid AND phone_number = '8172708573');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '6052a417-6725-4fab-b7dd-7f498454cd47'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3321351205', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '6052a417-6725-4fab-b7dd-7f498454cd47'::uuid AND phone_number = '3321351205');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'dad07e7d-fcb6-407a-9267-b7ab0a92d4a7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47727312181', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'dad07e7d-fcb6-407a-9267-b7ab0a92d4a7'::uuid AND phone_number = '47727312181');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'cbd398cc-dfde-41c4-b7b1-ca32cc99945f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47753397084', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'cbd398cc-dfde-41c4-b7b1-ca32cc99945f'::uuid AND phone_number = '47753397084');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'f740b251-4264-4220-8400-706331f650af'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32248211429', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'f740b251-4264-4220-8400-706331f650af'::uuid AND phone_number = '32248211429');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'fac7afba-7f9c-40f9-9a06-a9782ad7d3a7'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8164936372', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'fac7afba-7f9c-40f9-9a06-a9782ad7d3a7'::uuid AND phone_number = '8164936372');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '97d5d278-c876-4078-9dba-2940edfed9a0'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5589676137', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '97d5d278-c876-4078-9dba-2940edfed9a0'::uuid AND phone_number = '5589676137');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'a329242d-9e38-4178-aa8e-5b7497209897'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32293842224', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'a329242d-9e38-4178-aa8e-5b7497209897'::uuid AND phone_number = '32293842224');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'fe2cc660-dd15-4d31-ac72-56114bdb6b92'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8133988925', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'fe2cc660-dd15-4d31-ac72-56114bdb6b92'::uuid AND phone_number = '8133988925');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'fd01c50f-f3dd-4517-96c0-c0e65330a692'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8128706159', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'fd01c50f-f3dd-4517-96c0-c0e65330a692'::uuid AND phone_number = '8128706159');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'f56cc0bc-1765-4334-9594-73dcc9deac8e'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47782996667', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'f56cc0bc-1765-4334-9594-73dcc9deac8e'::uuid AND phone_number = '47782996667');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '1c861cbf-991d-4820-b3f0-98538fb0d454'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8154437852', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '1c861cbf-991d-4820-b3f0-98538fb0d454'::uuid AND phone_number = '8154437852');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '70f066e1-fc10-4b37-92ea-0de96307793b'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3365682270', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '70f066e1-fc10-4b37-92ea-0de96307793b'::uuid AND phone_number = '3365682270');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'd1ec4069-41a0-4317-a6c6-84914d108257'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5570138992', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'd1ec4069-41a0-4317-a6c6-84914d108257'::uuid AND phone_number = '5570138992');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '04239007-edaa-4c74-95dd-4ba4df226b0f'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32288930466', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '04239007-edaa-4c74-95dd-4ba4df226b0f'::uuid AND phone_number = '32288930466');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '0deef39b-719e-4f3a-a84f-2072803b2548'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8169920292', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '0deef39b-719e-4f3a-a84f-2072803b2548'::uuid AND phone_number = '8169920292');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '5156864c-fa59-4e48-b357-477838800efc'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32271925585', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '5156864c-fa59-4e48-b357-477838800efc'::uuid AND phone_number = '32271925585');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'd911f0a5-9268-4eb4-87e9-508d7c99b753'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47743590695', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'd911f0a5-9268-4eb4-87e9-508d7c99b753'::uuid AND phone_number = '47743590695');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'c3e065c2-c0a9-440f-98f3-1c5463949056'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47769556025', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'c3e065c2-c0a9-440f-98f3-1c5463949056'::uuid AND phone_number = '47769556025');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'b2eef54b-21a7-45ec-a693-bc60f1d6e293'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3314275368', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'b2eef54b-21a7-45ec-a693-bc60f1d6e293'::uuid AND phone_number = '3314275368');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '3854a76e-ee29-4976-b630-1d7e18fb9887'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3347815113', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '3854a76e-ee29-4976-b630-1d7e18fb9887'::uuid AND phone_number = '3347815113');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '6b2e25e9-ebcb-4150-a594-c5742cd42121'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32294167206', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '6b2e25e9-ebcb-4150-a594-c5742cd42121'::uuid AND phone_number = '32294167206');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'cc38cb13-51a5-4539-99c2-894cd2b207f1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5575125352', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'cc38cb13-51a5-4539-99c2-894cd2b207f1'::uuid AND phone_number = '5575125352');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '6af409b5-c8b8-4664-97cd-d419eedcc932'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32255124149', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '6af409b5-c8b8-4664-97cd-d419eedcc932'::uuid AND phone_number = '32255124149');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '227a2c03-dfd1-4e03-9c04-daaf74fc68bd'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5578131146', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '227a2c03-dfd1-4e03-9c04-daaf74fc68bd'::uuid AND phone_number = '5578131146');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'bc6e7a77-d709-401c-bea7-82715eeb1a29'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3374553593', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'bc6e7a77-d709-401c-bea7-82715eeb1a29'::uuid AND phone_number = '3374553593');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'd54d7239-e49a-4185-8875-4f71af08b789'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3399313134', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'd54d7239-e49a-4185-8875-4f71af08b789'::uuid AND phone_number = '3399313134');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '8370857e-7e69-43a6-be63-78fc270c5fd5'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5539331804', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '8370857e-7e69-43a6-be63-78fc270c5fd5'::uuid AND phone_number = '5539331804');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'e8813bf8-7bbb-4370-a181-880c0c959aa1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8170719562', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'e8813bf8-7bbb-4370-a181-880c0c959aa1'::uuid AND phone_number = '8170719562');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '4337bfc4-5ea7-4621-bd24-dbf3f55e350a'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3327135490', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '4337bfc4-5ea7-4621-bd24-dbf3f55e350a'::uuid AND phone_number = '3327135490');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '517958b1-f860-4a42-965b-15a796055981'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47740108537', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '517958b1-f860-4a42-965b-15a796055981'::uuid AND phone_number = '47740108537');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '44e4c099-cf6e-4926-85f1-ab5cb34c59a1'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '47716563624', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '44e4c099-cf6e-4926-85f1-ab5cb34c59a1'::uuid AND phone_number = '47716563624');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', 'a0c3c815-c664-4931-927f-e4109a545603'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3366571536', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = 'a0c3c815-c664-4931-927f-e4109a545603'::uuid AND phone_number = '3366571536');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '5c1862f6-f802-41ae-a6fb-87dbc5555fb3'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3348834139', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '5c1862f6-f802-41ae-a6fb-87dbc5555fb3'::uuid AND phone_number = '3348834139');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '11d31cb4-1dfb-479e-9329-8b8b35920b98'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '32276592463', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '11d31cb4-1dfb-479e-9329-8b8b35920b98'::uuid AND phone_number = '32276592463');

-- =============================================
-- EMERGENCY CONTACT PHONES
-- =============================================

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '2f5622af-8528-4c85-8e16-3d175a4f2d15'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47757812915', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '2f5622af-8528-4c85-8e16-3d175a4f2d15'::uuid AND phone_number = '47757812915');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3316290664', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c'::uuid AND phone_number = '3316290664');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '959aa1dd-346b-4542-8f99-0d5e75301249'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5549262091', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '959aa1dd-346b-4542-8f99-0d5e75301249'::uuid AND phone_number = '5549262091');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '59402562-ce5f-450e-8e6c-9630514fe164'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47777466011', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '59402562-ce5f-450e-8e6c-9630514fe164'::uuid AND phone_number = '47777466011');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'f81c87d6-32f1-4c79-993a-18db4734ef65'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47719440069', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'f81c87d6-32f1-4c79-993a-18db4734ef65'::uuid AND phone_number = '47719440069');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '0b6b8229-4027-4ec7-8bce-c805de96ced3'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5533631360', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '0b6b8229-4027-4ec7-8bce-c805de96ced3'::uuid AND phone_number = '5533631360');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47768973328', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb'::uuid AND phone_number = '47768973328');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'f2a1f62a-8030-4f65-b82d-ce7376b955bd'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5591906591', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'f2a1f62a-8030-4f65-b82d-ce7376b955bd'::uuid AND phone_number = '5591906591');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '0104fea2-d27c-4611-8414-da6c898b6944'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5545382442', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '0104fea2-d27c-4611-8414-da6c898b6944'::uuid AND phone_number = '5545382442');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'cd0c2f0c-de08-439c-93c9-0feab1d433cc'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32277282119', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'cd0c2f0c-de08-439c-93c9-0feab1d433cc'::uuid AND phone_number = '32277282119');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5557200410', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545'::uuid AND phone_number = '5557200410');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '7893292b-965a-41da-896a-d0780c91fdd5'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47713236152', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '7893292b-965a-41da-896a-d0780c91fdd5'::uuid AND phone_number = '47713236152');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '87fb3c88-6653-45db-aa6c-20ea7512da64'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32240358018', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '87fb3c88-6653-45db-aa6c-20ea7512da64'::uuid AND phone_number = '32240358018');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '05e42aed-c457-4579-904f-d397be3075f7'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32231720413', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '05e42aed-c457-4579-904f-d397be3075f7'::uuid AND phone_number = '32231720413');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '43756f6c-c157-4a44-9c84-ab2d62fddcf7'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5532528860', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '43756f6c-c157-4a44-9c84-ab2d62fddcf7'::uuid AND phone_number = '5532528860');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'd8e1fa52-0a65-4917-b410-2954e05a34e5'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32217005084', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'd8e1fa52-0a65-4917-b410-2954e05a34e5'::uuid AND phone_number = '32217005084');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'bbc67f38-a9eb-4379-aeaf-1560af0d1a34'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32226323981', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'bbc67f38-a9eb-4379-aeaf-1560af0d1a34'::uuid AND phone_number = '32226323981');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8182656773', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e'::uuid AND phone_number = '8182656773');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '309df411-1d1a-4d00-a34e-36e8c32da210'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47798461842', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '309df411-1d1a-4d00-a34e-36e8c32da210'::uuid AND phone_number = '47798461842');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '663d036b-a19b-4557-af37-d68a9ce4976d'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3334949462', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '663d036b-a19b-4557-af37-d68a9ce4976d'::uuid AND phone_number = '3334949462');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'a754cbf1-a4ca-42dc-92c4-d980b6a25a6d'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3384401071', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'a754cbf1-a4ca-42dc-92c4-d980b6a25a6d'::uuid AND phone_number = '3384401071');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'd5b1779e-21f2-4252-a421-f2aaf9998916'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32234403822', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'd5b1779e-21f2-4252-a421-f2aaf9998916'::uuid AND phone_number = '32234403822');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '6661483b-705b-412a-8bbd-39c0af0dadb1'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3336316084', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '6661483b-705b-412a-8bbd-39c0af0dadb1'::uuid AND phone_number = '3336316084');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '676491c4-f31a-42b6-a991-a8dd09bbb1f0'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47787133120', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '676491c4-f31a-42b6-a991-a8dd09bbb1f0'::uuid AND phone_number = '47787133120');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '3a9e8e0e-6367-409d-a81c-9852069c710e'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8142663874', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '3a9e8e0e-6367-409d-a81c-9852069c710e'::uuid AND phone_number = '8142663874');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '167dedde-166c-45e4-befc-4f1c9b7184ad'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5589365672', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '167dedde-166c-45e4-befc-4f1c9b7184ad'::uuid AND phone_number = '5589365672');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '72eca572-4ecf-4be8-906b-40e89e0d9a08'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5590745709', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '72eca572-4ecf-4be8-906b-40e89e0d9a08'::uuid AND phone_number = '5590745709');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'd5bec069-a317-4a40-b3e8-ea80220d75de'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47796089974', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'd5bec069-a317-4a40-b3e8-ea80220d75de'::uuid AND phone_number = '47796089974');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '0e97294d-78cc-4428-a172-e4e1fd4efa72'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32248518852', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '0e97294d-78cc-4428-a172-e4e1fd4efa72'::uuid AND phone_number = '32248518852');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '9f86a53f-f0e1-446d-89f0-86b086dd12a9'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8160157332', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '9f86a53f-f0e1-446d-89f0-86b086dd12a9'::uuid AND phone_number = '8160157332');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'ae1f5c92-f3cf-43d8-918f-aaad6fb46c05'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3344616862', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'ae1f5c92-f3cf-43d8-918f-aaad6fb46c05'::uuid AND phone_number = '3344616862');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'd28440a6-3bd9-4a48-8a72-d700ae0971e4'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32237033771', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'd28440a6-3bd9-4a48-8a72-d700ae0971e4'::uuid AND phone_number = '32237033771');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '7f839ee8-bdd6-4a63-83e8-30db007565e2'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32227437159', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '7f839ee8-bdd6-4a63-83e8-30db007565e2'::uuid AND phone_number = '32227437159');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '67aa999f-9d31-4b61-a097-35097ea0d082'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5595397265', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '67aa999f-9d31-4b61-a097-35097ea0d082'::uuid AND phone_number = '5595397265');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '41aa2fbc-8ef4-4448-8686-399a1cd54be9'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3332543753', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '41aa2fbc-8ef4-4448-8686-399a1cd54be9'::uuid AND phone_number = '3332543753');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '111769f3-1a1b-44a9-9670-f4f2e424d1d2'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3380722874', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '111769f3-1a1b-44a9-9670-f4f2e424d1d2'::uuid AND phone_number = '3380722874');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3395349229', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1'::uuid AND phone_number = '3395349229');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '6a8b6d41-8d20-4bc5-8d48-538d348f6086'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3344423620', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '6a8b6d41-8d20-4bc5-8d48-538d348f6086'::uuid AND phone_number = '3344423620');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '89657c95-84c0-4bd0-80c6-70a2c4721276'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47750456931', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '89657c95-84c0-4bd0-80c6-70a2c4721276'::uuid AND phone_number = '47750456931');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'b6658dac-0ee1-415c-95ad-28c6acea85bd'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32245486528', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'b6658dac-0ee1-415c-95ad-28c6acea85bd'::uuid AND phone_number = '32245486528');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '56564104-6009-466c-9134-c15d3175613b'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5573731864', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '56564104-6009-466c-9134-c15d3175613b'::uuid AND phone_number = '5573731864');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'edb1d693-b308-4ff6-8fd4-9e20561317e8'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32245132273', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'edb1d693-b308-4ff6-8fd4-9e20561317e8'::uuid AND phone_number = '32245132273');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '9511f9b9-a450-489c-92b9-ac306733cee4'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3313199477', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '9511f9b9-a450-489c-92b9-ac306733cee4'::uuid AND phone_number = '3313199477');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '004ce58b-6a0d-4646-92c3-4508deb6b354'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3315085656', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '004ce58b-6a0d-4646-92c3-4508deb6b354'::uuid AND phone_number = '3315085656');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '0d1bcc20-a5be-40f0-a28b-23c2c77c51be'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3348205238', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '0d1bcc20-a5be-40f0-a28b-23c2c77c51be'::uuid AND phone_number = '3348205238');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '38000dbb-417f-43ca-a60e-5812796420f7'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47769498364', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '38000dbb-417f-43ca-a60e-5812796420f7'::uuid AND phone_number = '47769498364');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '5ae0a393-b399-4dc6-95d8-297d3b3ef0a8'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5598817898', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '5ae0a393-b399-4dc6-95d8-297d3b3ef0a8'::uuid AND phone_number = '5598817898');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '561c313d-2c15-41b1-b965-a38c8e0f6c42'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5514944156', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '561c313d-2c15-41b1-b965-a38c8e0f6c42'::uuid AND phone_number = '5514944156');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'ba4b2a5b-887d-4f3d-8ec7-570cfe087b28'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5598214663', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'ba4b2a5b-887d-4f3d-8ec7-570cfe087b28'::uuid AND phone_number = '5598214663');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'cbdb51c5-0334-4e15-b4b9-13b1de1c4c20'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3315965116', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'cbdb51c5-0334-4e15-b4b9-13b1de1c4c20'::uuid AND phone_number = '3315965116');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '05bc2942-e676-42e9-ad01-ade9f7cc5aee'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32276426588', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '05bc2942-e676-42e9-ad01-ade9f7cc5aee'::uuid AND phone_number = '32276426588');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'c78e7658-d517-4ca1-990b-e6971f8d108f'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5519690783', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'c78e7658-d517-4ca1-990b-e6971f8d108f'::uuid AND phone_number = '5519690783');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '65474c27-8f72-4690-8f19-df9344e4be5e'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3392698723', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '65474c27-8f72-4690-8f19-df9344e4be5e'::uuid AND phone_number = '3392698723');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'c1b6fa98-203a-4321-96cd-e80e7a1c9461'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5539382237', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'c1b6fa98-203a-4321-96cd-e80e7a1c9461'::uuid AND phone_number = '5539382237');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '9244b388-8c06-42c7-9c4e-cbaae5b1baa3'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32222860074', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '9244b388-8c06-42c7-9c4e-cbaae5b1baa3'::uuid AND phone_number = '32222860074');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'eb2e55f6-4738-4352-a59a-860909f1932c'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8183350913', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'eb2e55f6-4738-4352-a59a-860909f1932c'::uuid AND phone_number = '8183350913');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'c572a4c7-e475-4d18-85da-417abcd00903'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32220622451', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'c572a4c7-e475-4d18-85da-417abcd00903'::uuid AND phone_number = '32220622451');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8138604175', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3'::uuid AND phone_number = '8138604175');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '9b02d89c-2c5b-4c51-8183-15ccd1184990'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5541349710', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '9b02d89c-2c5b-4c51-8183-15ccd1184990'::uuid AND phone_number = '5541349710');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '43ae2e81-ac13-40ac-949c-9e4f51d76098'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5513598507', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '43ae2e81-ac13-40ac-949c-9e4f51d76098'::uuid AND phone_number = '5513598507');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '49a18092-8f90-4f6b-873c-8715b64b8aff'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8195643123', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '49a18092-8f90-4f6b-873c-8715b64b8aff'::uuid AND phone_number = '8195643123');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'c9a949e5-e650-4d95-9e2e-49ed06e5d087'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47750168658', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'c9a949e5-e650-4d95-9e2e-49ed06e5d087'::uuid AND phone_number = '47750168658');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'a4e5cbb3-36f7-43d8-a65a-e30fc1361e56'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5560993019', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'a4e5cbb3-36f7-43d8-a65a-e30fc1361e56'::uuid AND phone_number = '5560993019');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '447e48dc-861c-41e6-920e-a2dec785101f'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8177598147', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '447e48dc-861c-41e6-920e-a2dec785101f'::uuid AND phone_number = '8177598147');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '3a535951-40fd-4959-a34e-07b29f675ecc'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8132853218', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '3a535951-40fd-4959-a34e-07b29f675ecc'::uuid AND phone_number = '8132853218');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'd4bfb3cb-c8d6-434a-a3d4-2712ecea4d70'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8183267424', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'd4bfb3cb-c8d6-434a-a3d4-2712ecea4d70'::uuid AND phone_number = '8183267424');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '6052a417-6725-4fab-b7dd-7f498454cd47'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3379867165', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '6052a417-6725-4fab-b7dd-7f498454cd47'::uuid AND phone_number = '3379867165');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'dad07e7d-fcb6-407a-9267-b7ab0a92d4a7'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47764344603', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'dad07e7d-fcb6-407a-9267-b7ab0a92d4a7'::uuid AND phone_number = '47764344603');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'cbd398cc-dfde-41c4-b7b1-ca32cc99945f'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47732012824', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'cbd398cc-dfde-41c4-b7b1-ca32cc99945f'::uuid AND phone_number = '47732012824');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'f740b251-4264-4220-8400-706331f650af'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32262137834', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'f740b251-4264-4220-8400-706331f650af'::uuid AND phone_number = '32262137834');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'fac7afba-7f9c-40f9-9a06-a9782ad7d3a7'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8177158637', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'fac7afba-7f9c-40f9-9a06-a9782ad7d3a7'::uuid AND phone_number = '8177158637');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '97d5d278-c876-4078-9dba-2940edfed9a0'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5527425608', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '97d5d278-c876-4078-9dba-2940edfed9a0'::uuid AND phone_number = '5527425608');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'a329242d-9e38-4178-aa8e-5b7497209897'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32294424318', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'a329242d-9e38-4178-aa8e-5b7497209897'::uuid AND phone_number = '32294424318');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'fe2cc660-dd15-4d31-ac72-56114bdb6b92'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8143750716', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'fe2cc660-dd15-4d31-ac72-56114bdb6b92'::uuid AND phone_number = '8143750716');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'fd01c50f-f3dd-4517-96c0-c0e65330a692'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8135330809', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'fd01c50f-f3dd-4517-96c0-c0e65330a692'::uuid AND phone_number = '8135330809');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'f56cc0bc-1765-4334-9594-73dcc9deac8e'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47756053965', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'f56cc0bc-1765-4334-9594-73dcc9deac8e'::uuid AND phone_number = '47756053965');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '1c861cbf-991d-4820-b3f0-98538fb0d454'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8125415139', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '1c861cbf-991d-4820-b3f0-98538fb0d454'::uuid AND phone_number = '8125415139');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '70f066e1-fc10-4b37-92ea-0de96307793b'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3376794153', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '70f066e1-fc10-4b37-92ea-0de96307793b'::uuid AND phone_number = '3376794153');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'd1ec4069-41a0-4317-a6c6-84914d108257'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5588093567', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'd1ec4069-41a0-4317-a6c6-84914d108257'::uuid AND phone_number = '5588093567');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '04239007-edaa-4c74-95dd-4ba4df226b0f'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32297071430', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '04239007-edaa-4c74-95dd-4ba4df226b0f'::uuid AND phone_number = '32297071430');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '0deef39b-719e-4f3a-a84f-2072803b2548'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8190637854', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '0deef39b-719e-4f3a-a84f-2072803b2548'::uuid AND phone_number = '8190637854');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '5156864c-fa59-4e48-b357-477838800efc'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32234242334', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '5156864c-fa59-4e48-b357-477838800efc'::uuid AND phone_number = '32234242334');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'd911f0a5-9268-4eb4-87e9-508d7c99b753'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47761331431', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'd911f0a5-9268-4eb4-87e9-508d7c99b753'::uuid AND phone_number = '47761331431');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'c3e065c2-c0a9-440f-98f3-1c5463949056'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47748195712', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'c3e065c2-c0a9-440f-98f3-1c5463949056'::uuid AND phone_number = '47748195712');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'b2eef54b-21a7-45ec-a693-bc60f1d6e293'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3355179014', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'b2eef54b-21a7-45ec-a693-bc60f1d6e293'::uuid AND phone_number = '3355179014');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '3854a76e-ee29-4976-b630-1d7e18fb9887'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3383557299', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '3854a76e-ee29-4976-b630-1d7e18fb9887'::uuid AND phone_number = '3383557299');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '6b2e25e9-ebcb-4150-a594-c5742cd42121'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32219334107', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '6b2e25e9-ebcb-4150-a594-c5742cd42121'::uuid AND phone_number = '32219334107');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'cc38cb13-51a5-4539-99c2-894cd2b207f1'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5543795680', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'cc38cb13-51a5-4539-99c2-894cd2b207f1'::uuid AND phone_number = '5543795680');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '6af409b5-c8b8-4664-97cd-d419eedcc932'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32232724524', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '6af409b5-c8b8-4664-97cd-d419eedcc932'::uuid AND phone_number = '32232724524');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '227a2c03-dfd1-4e03-9c04-daaf74fc68bd'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5590950933', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '227a2c03-dfd1-4e03-9c04-daaf74fc68bd'::uuid AND phone_number = '5590950933');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'bc6e7a77-d709-401c-bea7-82715eeb1a29'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3375466198', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'bc6e7a77-d709-401c-bea7-82715eeb1a29'::uuid AND phone_number = '3375466198');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'd54d7239-e49a-4185-8875-4f71af08b789'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3350896048', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'd54d7239-e49a-4185-8875-4f71af08b789'::uuid AND phone_number = '3350896048');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '8370857e-7e69-43a6-be63-78fc270c5fd5'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5549000181', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '8370857e-7e69-43a6-be63-78fc270c5fd5'::uuid AND phone_number = '5549000181');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'e8813bf8-7bbb-4370-a181-880c0c959aa1'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8132914959', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'e8813bf8-7bbb-4370-a181-880c0c959aa1'::uuid AND phone_number = '8132914959');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '4337bfc4-5ea7-4621-bd24-dbf3f55e350a'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3398716364', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '4337bfc4-5ea7-4621-bd24-dbf3f55e350a'::uuid AND phone_number = '3398716364');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '517958b1-f860-4a42-965b-15a796055981'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47739213896', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '517958b1-f860-4a42-965b-15a796055981'::uuid AND phone_number = '47739213896');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '44e4c099-cf6e-4926-85f1-ab5cb34c59a1'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '47785689511', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '44e4c099-cf6e-4926-85f1-ab5cb34c59a1'::uuid AND phone_number = '47785689511');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', 'a0c3c815-c664-4931-927f-e4109a545603'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3331572816', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = 'a0c3c815-c664-4931-927f-e4109a545603'::uuid AND phone_number = '3331572816');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '5c1862f6-f802-41ae-a6fb-87dbc5555fb3'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3382923190', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '5c1862f6-f802-41ae-a6fb-87dbc5555fb3'::uuid AND phone_number = '3382923190');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '11d31cb4-1dfb-479e-9329-8b8b35920b98'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '32260509677', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '11d31cb4-1dfb-479e-9329-8b8b35920b98'::uuid AND phone_number = '32260509677');

-- =============================================
-- INSTITUTION ADDRESSES
-- =============================================

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '163749fb-8b46-4447-a8b7-95b4a59531b6', 'primary', 'Callejón Norte Salas 373 045', 'San José Emilio de la Montaña', (SELECT id FROM regions WHERE name = 'Puebla'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '163749fb-8b46-4447-a8b7-95b4a59531b6' AND street_address = 'Callejón Norte Salas 373 045');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '83b74179-f6ef-4219-bc70-c93f4393a350', 'primary', 'Cerrada Sur Godoy 405 Interior 179', 'Vieja Congo', (SELECT id FROM regions WHERE name = 'Nayarit'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '83b74179-f6ef-4219-bc70-c93f4393a350' AND street_address = 'Cerrada Sur Godoy 405 Interior 179');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '50503414-ca6d-4c1a-a34f-18719e2fd555', 'primary', 'Calle Lara 137 Edif. 886 , Depto. 577', 'Vieja Sudáfrica', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '50503414-ca6d-4c1a-a34f-18719e2fd555' AND street_address = 'Calle Lara 137 Edif. 886 , Depto. 577');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '9b581d3c-9e93-4f39-80bb-294752065866', 'primary', 'Pasaje Querétaro 561 Edif. 908 , Depto. 978', 'Nueva Bhután', (SELECT id FROM regions WHERE name = 'Yucatán'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '9b581d3c-9e93-4f39-80bb-294752065866' AND street_address = 'Pasaje Querétaro 561 Edif. 908 , Depto. 978');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'e0e34926-8d48-4db0-afb9-b20b6eeb1ecb', 'primary', 'Eje vial Nuevo León 923 415', 'Nueva Austria', (SELECT id FROM regions WHERE name = 'Nuevo León'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'e0e34926-8d48-4db0-afb9-b20b6eeb1ecb' AND street_address = 'Eje vial Nuevo León 923 415');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '81941e1d-820a-4313-8177-e44278d9a981', 'primary', 'Peatonal Colombia 063 409', 'Vieja Austria', (SELECT id FROM regions WHERE name = 'Zacatecas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '81941e1d-820a-4313-8177-e44278d9a981' AND street_address = 'Peatonal Colombia 063 409');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'a725b15f-039b-4256-843a-51a2968633fd', 'primary', 'Boulevard Nayarit 972 Interior 061', 'Nueva Marruecos', (SELECT id FROM regions WHERE name = 'Tamaulipas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'a725b15f-039b-4256-843a-51a2968633fd' AND street_address = 'Boulevard Nayarit 972 Interior 061');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d', 'primary', 'Ampliación República de Moldova 034 Edif. 016 , Depto. 781', 'Nueva Eslovaquia', (SELECT id FROM regions WHERE name = 'Zacatecas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d' AND street_address = 'Ampliación República de Moldova 034 Edif. 016 , Depto. 781');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'd471d2d1-66a1-4de0-8754-127059786888', 'primary', 'Boulevard Sur Vera 081 Interior 214', 'San Helena los bajos', (SELECT id FROM regions WHERE name = 'Querétaro'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'd471d2d1-66a1-4de0-8754-127059786888' AND street_address = 'Boulevard Sur Vera 081 Interior 214');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '8fd698b3-084d-4248-a28e-2708a5862e27', 'primary', 'Pasaje República de Macedonia del Norte 006 986', 'San Renato de la Montaña', (SELECT id FROM regions WHERE name = 'Tlaxcala'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '8fd698b3-084d-4248-a28e-2708a5862e27' AND street_address = 'Pasaje República de Macedonia del Norte 006 986');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '7b96a7bb-041f-4331-be05-e97cab7dafc0', 'primary', 'Privada Norte Cordero 930 Edif. 075 , Depto. 923', 'San Teresa los bajos', (SELECT id FROM regions WHERE name = 'Yucatán'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '7b96a7bb-041f-4331-be05-e97cab7dafc0' AND street_address = 'Privada Norte Cordero 930 Edif. 075 , Depto. 923');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '5da54d5d-de0c-4277-a43e-6a89f987e77c', 'primary', 'Pasaje Baja California Sur 457 Interior 112', 'Vieja Ecuador', (SELECT id FROM regions WHERE name = 'Tlaxcala'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '5da54d5d-de0c-4277-a43e-6a89f987e77c' AND street_address = 'Pasaje Baja California Sur 457 Interior 112');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'c9014e88-309c-4cb0-a28d-25b510e1e522', 'primary', 'Boulevard Sur Velasco 597 810', 'Vieja Malta', (SELECT id FROM regions WHERE name = 'Zacatecas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'c9014e88-309c-4cb0-a28d-25b510e1e522' AND street_address = 'Boulevard Sur Velasco 597 810');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '8e889f63-2c86-44ab-959f-fdc365353d5d', 'primary', 'Corredor Sur Bañuelos 653 Interior 291', 'Vieja Argentina', (SELECT id FROM regions WHERE name = 'Quintana Roo'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '8e889f63-2c86-44ab-959f-fdc365353d5d' AND street_address = 'Corredor Sur Bañuelos 653 Interior 291');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '67787f7c-fdee-4e30-80bd-89008ebfe419', 'primary', 'Eje vial Salazar 572 Edif. 861 , Depto. 031', 'San Rafaél los bajos', (SELECT id FROM regions WHERE name = 'Nayarit'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '67787f7c-fdee-4e30-80bd-89008ebfe419' AND street_address = 'Eje vial Salazar 572 Edif. 861 , Depto. 031');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '4721cb90-8fb0-4fd6-b19e-160b4ac0c744', 'primary', 'Calzada Coahuila de Zaragoza 496 Edif. 830 , Depto. 716', 'Nueva Turquía', (SELECT id FROM regions WHERE name = 'Sinaloa'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '4721cb90-8fb0-4fd6-b19e-160b4ac0c744' AND street_address = 'Calzada Coahuila de Zaragoza 496 Edif. 830 , Depto. 716');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '09c54a60-6267-4439-9c8b-8c9012842942', 'primary', 'Retorno Norte Saldaña 775 878', 'Vieja Paraguay', (SELECT id FROM regions WHERE name = 'Michoacán'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '09c54a60-6267-4439-9c8b-8c9012842942' AND street_address = 'Retorno Norte Saldaña 775 878');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'a670c73c-cc47-42fe-88c9-0fa37359779b', 'primary', 'Retorno Barbados 161 Interior 957', 'San Nicolás los bajos', (SELECT id FROM regions WHERE name = 'Ciudad de México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'a670c73c-cc47-42fe-88c9-0fa37359779b' AND street_address = 'Retorno Barbados 161 Interior 957');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '373769ab-b720-4269-bfb9-02546401ce99', 'primary', 'Eje vial Villareal 123 530', 'Vieja Sudáfrica', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '373769ab-b720-4269-bfb9-02546401ce99' AND street_address = 'Eje vial Villareal 123 530');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75', 'primary', 'Peatonal Irán 415 Edif. 271 , Depto. 663', 'Vieja Letonia', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75' AND street_address = 'Peatonal Irán 415 Edif. 271 , Depto. 663');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0', 'primary', 'Periférico Chiapas 243 Edif. 549 , Depto. 615', 'Vieja República de Corea', (SELECT id FROM regions WHERE name = 'Tamaulipas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0' AND street_address = 'Periférico Chiapas 243 Edif. 549 , Depto. 615');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '6c287a0e-9d4c-4574-932f-7d499aa4146c', 'primary', 'Privada Norte Cruz 604 Edif. 735 , Depto. 097', 'San Cristina de la Montaña', (SELECT id FROM regions WHERE name = 'Michoacán'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '6c287a0e-9d4c-4574-932f-7d499aa4146c' AND street_address = 'Privada Norte Cruz 604 Edif. 735 , Depto. 097');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'a14c189c-ee90-4c29-b465-63d43a9d0010', 'primary', 'Avenida Austria 163 Interior 093', 'Vieja Afganistán', (SELECT id FROM regions WHERE name = 'Nuevo León'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'a14c189c-ee90-4c29-b465-63d43a9d0010' AND street_address = 'Avenida Austria 163 Interior 093');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'e040eabc-0ac9-47f7-89ae-24246e1c12dd', 'primary', 'Corredor Morelos 664 Interior 001', 'San Diego los altos', (SELECT id FROM regions WHERE name = 'México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'e040eabc-0ac9-47f7-89ae-24246e1c12dd' AND street_address = 'Corredor Morelos 664 Interior 001');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '9c8636c9-015b-4c18-a641-f5da698b6fd8', 'primary', 'Ampliación Sur Cortés 140 Interior 719', 'Nueva Luxemburgo', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '9c8636c9-015b-4c18-a641-f5da698b6fd8' AND street_address = 'Ampliación Sur Cortés 140 Interior 719');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa', 'primary', 'Circunvalación Raya 149 Interior 138', 'Vieja Cuba', (SELECT id FROM regions WHERE name = 'Tamaulipas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa' AND street_address = 'Circunvalación Raya 149 Interior 138');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '146a692b-6d46-4c26-a165-092fe771400e', 'primary', 'Viaducto Laureano 126 299', 'Nueva Armenia', (SELECT id FROM regions WHERE name = 'Michoacán'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '146a692b-6d46-4c26-a165-092fe771400e' AND street_address = 'Viaducto Laureano 126 299');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '6297ae0f-7fee-472d-87ec-e22b87ce6ffb', 'primary', 'Calzada Carmona 802 263', 'San Claudia de la Montaña', (SELECT id FROM regions WHERE name = 'Sinaloa'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '6297ae0f-7fee-472d-87ec-e22b87ce6ffb' AND street_address = 'Calzada Carmona 802 263');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '66e6aa6c-596c-442e-85fb-b143875d0dfc', 'primary', 'Periférico Trinidad y Tabago 010 Edif. 969 , Depto. 295', 'San Antonio los altos', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '66e6aa6c-596c-442e-85fb-b143875d0dfc' AND street_address = 'Periférico Trinidad y Tabago 010 Edif. 969 , Depto. 295');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '46af545e-6db8-44ba-a7f9-9fd9617f4a09', 'primary', 'Avenida México 943 Edif. 161 , Depto. 734', 'San Nayeli los bajos', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '46af545e-6db8-44ba-a7f9-9fd9617f4a09' AND street_address = 'Avenida México 943 Edif. 161 , Depto. 734');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'a56b6787-94e9-49f0-8b3a-6ff5979773fc', 'primary', 'Callejón Haití 796 437', 'San Emilio de la Montaña', (SELECT id FROM regions WHERE name = 'Tamaulipas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'a56b6787-94e9-49f0-8b3a-6ff5979773fc' AND street_address = 'Callejón Haití 796 437');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf', 'primary', 'Cerrada Urías 027 Interior 861', 'Nueva Costa Rica', (SELECT id FROM regions WHERE name = 'Nuevo León'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf' AND street_address = 'Cerrada Urías 027 Interior 861');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '4bfa1a0a-0434-45e0-b454-03140b992f53', 'primary', 'Peatonal San Vicente y las Granadinas 662 Edif. 611 , Depto. 184', 'Vieja Niger', (SELECT id FROM regions WHERE name = 'Puebla'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '4bfa1a0a-0434-45e0-b454-03140b992f53' AND street_address = 'Peatonal San Vicente y las Granadinas 662 Edif. 611 , Depto. 184');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '33ba98b9-c46a-47c1-b266-d8a4fe557290', 'primary', 'Corredor Seychelles 533 Interior 972', 'Nueva Zimbabwe', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '33ba98b9-c46a-47c1-b266-d8a4fe557290' AND street_address = 'Corredor Seychelles 533 Interior 972');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'f4764cd3-47e9-4408-b0ee-9b9001c5459d', 'primary', 'Calle Nayarit 442 Interior 357', 'San Úrsula de la Montaña', (SELECT id FROM regions WHERE name = 'Guanajuato'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'f4764cd3-47e9-4408-b0ee-9b9001c5459d' AND street_address = 'Calle Nayarit 442 Interior 357');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8', 'primary', 'Andador Sur Alfaro 161 Edif. 565 , Depto. 595', 'Vieja Chad', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8' AND street_address = 'Andador Sur Alfaro 161 Edif. 565 , Depto. 595');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d', 'primary', 'Viaducto Chihuahua 885 664', 'San Juan Carlos los bajos', (SELECT id FROM regions WHERE name = 'Veracruz'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d' AND street_address = 'Viaducto Chihuahua 885 664');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '8be78aaa-c408-452e-bf01-8e831ab5c63a', 'primary', 'Callejón Sur Ceja 651 768', 'Nueva Filipinas', (SELECT id FROM regions WHERE name = 'San Luis Potosí'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '8be78aaa-c408-452e-bf01-8e831ab5c63a' AND street_address = 'Callejón Sur Ceja 651 768');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '8fb0899c-732e-4f03-8209-d52ef41a6a76', 'primary', 'Andador Jasso 972 Edif. 726 , Depto. 944', 'San Evelio de la Montaña', (SELECT id FROM regions WHERE name = 'Michoacán'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '8fb0899c-732e-4f03-8209-d52ef41a6a76' AND street_address = 'Andador Jasso 972 Edif. 726 , Depto. 944');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '3a9084e7-74c5-4e0b-b786-2c93d9cd39ee', 'primary', 'Ampliación Nayarit 393 451', 'Nueva Arabia Saudita', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '3a9084e7-74c5-4e0b-b786-2c93d9cd39ee' AND street_address = 'Ampliación Nayarit 393 451');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '54481b92-e5f5-421b-ba21-89bf520a2d87', 'primary', 'Periférico Nayarit 605 299', 'San Alberto los bajos', (SELECT id FROM regions WHERE name = 'Michoacán'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '54481b92-e5f5-421b-ba21-89bf520a2d87' AND street_address = 'Periférico Nayarit 605 299');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '68f1a02a-d348-4d1e-99ee-733d832a3f43', 'primary', 'Circuito Norte Anguiano 209 Interior 539', 'San Jacinto de la Montaña', (SELECT id FROM regions WHERE name = 'Querétaro'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '68f1a02a-d348-4d1e-99ee-733d832a3f43' AND street_address = 'Circuito Norte Anguiano 209 Interior 539');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '36983990-abe8-4f1c-9c1b-863b9cab3ca9', 'primary', 'Eje vial Norte Zaragoza 384 512', 'San Miguel los bajos', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '36983990-abe8-4f1c-9c1b-863b9cab3ca9' AND street_address = 'Eje vial Norte Zaragoza 384 512');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'b654860f-ec74-42d6-955e-eeedde2df0dd', 'primary', 'Diagonal Hidalgo 266 Interior 555', 'Nueva Senegal', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'b654860f-ec74-42d6-955e-eeedde2df0dd' AND street_address = 'Diagonal Hidalgo 266 Interior 555');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'be133600-848e-400b-9bc8-c52a4f3cf10d', 'primary', 'Cerrada República Unida de Tanzanía 421 Interior 827', 'Nueva Eslovenia', (SELECT id FROM regions WHERE name = 'Quintana Roo'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'be133600-848e-400b-9bc8-c52a4f3cf10d' AND street_address = 'Cerrada República Unida de Tanzanía 421 Interior 827');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '25e918f3-692f-4f51-b630-4caa1dd825a1', 'primary', 'Privada Burkina Faso 176 Edif. 978 , Depto. 820', 'San Benito los altos', (SELECT id FROM regions WHERE name = 'Guanajuato'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '25e918f3-692f-4f51-b630-4caa1dd825a1' AND street_address = 'Privada Burkina Faso 176 Edif. 978 , Depto. 820');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'cc46221e-f387-463c-9d11-9464d8209f7b', 'primary', 'Prolongación Baja California 223 Edif. 135 , Depto. 987', 'San Rafaél los altos', (SELECT id FROM regions WHERE name = 'Michoacán'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'cc46221e-f387-463c-9d11-9464d8209f7b' AND street_address = 'Prolongación Baja California 223 Edif. 135 , Depto. 987');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42', 'primary', 'Circuito Norte Pichardo 264 Edif. 572 , Depto. 578', 'Nueva República Federal Democrática de Nepal', (SELECT id FROM regions WHERE name = 'Veracruz'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42' AND street_address = 'Circuito Norte Pichardo 264 Edif. 572 , Depto. 578');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '3d7c5771-0692-4a2f-a4c6-6af2b561282b', 'primary', 'Cerrada Jalisco 313 906', 'Vieja Papua Nueva Guinea', (SELECT id FROM regions WHERE name = 'Nuevo León'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '3d7c5771-0692-4a2f-a4c6-6af2b561282b' AND street_address = 'Cerrada Jalisco 313 906');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '16b25a77-b84a-44ac-8540-c5bfa9b3b6b0', 'primary', 'Andador Jalisco 470 Edif. 504 , Depto. 780', 'Vieja Colombia', (SELECT id FROM regions WHERE name = 'Tamaulipas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '16b25a77-b84a-44ac-8540-c5bfa9b3b6b0' AND street_address = 'Andador Jalisco 470 Edif. 504 , Depto. 780');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '2040ac28-7210-4fbd-9716-53872211bcd9', 'primary', 'Periférico Concepción 008 Edif. 258 , Depto. 440', 'Nueva Pakistán', (SELECT id FROM regions WHERE name = 'Sinaloa'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '2040ac28-7210-4fbd-9716-53872211bcd9' AND street_address = 'Periférico Concepción 008 Edif. 258 , Depto. 440');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '0d826581-b9d8-4828-8848-9332fe38d169', 'primary', 'Cerrada Sur Cervantes 703 Edif. 909 , Depto. 567', 'San Natalia los bajos', (SELECT id FROM regions WHERE name = 'Tabasco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '0d826581-b9d8-4828-8848-9332fe38d169' AND street_address = 'Cerrada Sur Cervantes 703 Edif. 909 , Depto. 567');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'c0595f94-c8f4-413c-a05c-7cfca773563c', 'primary', 'Retorno Noruega 285 221', 'Nueva Georgia', (SELECT id FROM regions WHERE name = 'México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'c0595f94-c8f4-413c-a05c-7cfca773563c' AND street_address = 'Retorno Noruega 285 221');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5', 'primary', 'Boulevard Sur Ochoa 308 025', 'San Octavio los altos', (SELECT id FROM regions WHERE name = 'Querétaro'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5' AND street_address = 'Boulevard Sur Ochoa 308 025');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'ad2c792b-5015-4238-b221-fa28e8b061fc', 'primary', 'Circuito República Checa 763 Interior 806', 'Nueva Montenegro', (SELECT id FROM regions WHERE name = 'Morelos'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'ad2c792b-5015-4238-b221-fa28e8b061fc' AND street_address = 'Circuito República Checa 763 Interior 806');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'c3e96b10-f0ca-421e-b402-aba6d595cf27', 'primary', 'Privada Sur Ruelas 336 Interior 844', 'Nueva Burundi', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'c3e96b10-f0ca-421e-b402-aba6d595cf27' AND street_address = 'Privada Sur Ruelas 336 Interior 844');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'a5b1202a-9112-404b-b7de-ddf0f62711f8', 'primary', 'Boulevard San Luis Potosí 828 Interior 438', 'San Daniel de la Montaña', (SELECT id FROM regions WHERE name = 'Zacatecas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'a5b1202a-9112-404b-b7de-ddf0f62711f8' AND street_address = 'Boulevard San Luis Potosí 828 Interior 438');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'ac6f8f54-21c8-475b-bea6-19e31643392d', 'primary', 'Cerrada Mali 386 Edif. 915 , Depto. 973', 'Vieja Bulgaria', (SELECT id FROM regions WHERE name = 'Ciudad de México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'ac6f8f54-21c8-475b-bea6-19e31643392d' AND street_address = 'Cerrada Mali 386 Edif. 915 , Depto. 973');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '43dee983-676a-4e33-a6b0-f0a72f46d06c', 'primary', 'Corredor Querétaro 046 Interior 451', 'San Virginia de la Montaña', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '43dee983-676a-4e33-a6b0-f0a72f46d06c' AND street_address = 'Corredor Querétaro 046 Interior 451');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca', 'primary', 'Ampliación Tamaulipas 608 Interior 109', 'Vieja Israel', (SELECT id FROM regions WHERE name = 'Morelos'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca' AND street_address = 'Ampliación Tamaulipas 608 Interior 109');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '08a7fe9e-c043-4fed-89e4-93a416a20089', 'primary', 'Cerrada Sur Blanco 381 145', 'Vieja Croacia', (SELECT id FROM regions WHERE name = 'Tamaulipas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '08a7fe9e-c043-4fed-89e4-93a416a20089' AND street_address = 'Cerrada Sur Blanco 381 145');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '89ab21cf-089e-4210-8e29-269dfbd38d71', 'primary', 'Viaducto Sur Alejandro 902 945', 'Nueva Tailandia', (SELECT id FROM regions WHERE name = 'Ciudad de México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '89ab21cf-089e-4210-8e29-269dfbd38d71' AND street_address = 'Viaducto Sur Alejandro 902 945');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'd56e3cb0-d9e2-48fc-9c16-c4a96b90c00f', 'primary', 'Cerrada Sur Camarillo 414 Edif. 593 , Depto. 622', 'Vieja Saint Kitts y Nevis', (SELECT id FROM regions WHERE name = 'Querétaro'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'd56e3cb0-d9e2-48fc-9c16-c4a96b90c00f' AND street_address = 'Cerrada Sur Camarillo 414 Edif. 593 , Depto. 622');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0', 'primary', 'Viaducto Norte Montoya 514 488', 'San Teresa de la Montaña', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0' AND street_address = 'Viaducto Norte Montoya 514 488');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '3cf42c93-4941-4d8d-8656-aafa9e987177', 'primary', 'Viaducto Nayarit 630 417', 'San José Emilio de la Montaña', (SELECT id FROM regions WHERE name = 'Sinaloa'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '3cf42c93-4941-4d8d-8656-aafa9e987177' AND street_address = 'Viaducto Nayarit 630 417');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '1926fa2a-dab7-420e-861b-c2b6dfe0174e', 'primary', 'Corredor Mesa 575 Edif. 643 , Depto. 142', 'San Lilia los altos', (SELECT id FROM regions WHERE name = 'Tamaulipas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '1926fa2a-dab7-420e-861b-c2b6dfe0174e' AND street_address = 'Corredor Mesa 575 Edif. 643 , Depto. 142');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '0b2f4464-5141-44a3-a26d-f8acc1fb955e', 'primary', 'Eje vial Niger 784 Interior 669', 'San Amalia los altos', (SELECT id FROM regions WHERE name = 'San Luis Potosí'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '0b2f4464-5141-44a3-a26d-f8acc1fb955e' AND street_address = 'Eje vial Niger 784 Interior 669');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '1fec9665-52bc-49a7-b028-f0d78440463c', 'primary', 'Continuación Tlaxcala 013 179', 'San María Eugenia de la Montaña', (SELECT id FROM regions WHERE name = 'Veracruz'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '1fec9665-52bc-49a7-b028-f0d78440463c' AND street_address = 'Continuación Tlaxcala 013 179');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a', 'primary', 'Peatonal Haití 199 Interior 658', 'San Sonia los altos', (SELECT id FROM regions WHERE name = 'Sinaloa'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a' AND street_address = 'Peatonal Haití 199 Interior 658');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '8cfdeaad-c727-4a4d-b5d5-b69dd43c0854', 'primary', 'Eje vial Colima 469 Interior 815', 'San Linda los bajos', (SELECT id FROM regions WHERE name = 'Ciudad de México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '8cfdeaad-c727-4a4d-b5d5-b69dd43c0854' AND street_address = 'Eje vial Colima 469 Interior 815');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '7a6ce151-14b5-4d12-b6bb-1fba18636353', 'primary', 'Eje vial Hernández 479 Interior 552', 'Nueva Nicaragua', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '7a6ce151-14b5-4d12-b6bb-1fba18636353' AND street_address = 'Eje vial Hernández 479 Interior 552');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'f1ab98f4-98de-420f-9c4b-c31eee92df21', 'primary', 'Circunvalación Norte Ulibarri 155 Edif. 654 , Depto. 697', 'San Estefanía de la Montaña', (SELECT id FROM regions WHERE name = 'Nuevo León'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'f1ab98f4-98de-420f-9c4b-c31eee92df21' AND street_address = 'Circunvalación Norte Ulibarri 155 Edif. 654 , Depto. 697');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'a074c3ea-f255-4cf2-ae3f-727f9186be3c', 'primary', 'Retorno Campeche 452 Interior 594', 'San Yolanda de la Montaña', (SELECT id FROM regions WHERE name = 'Puebla'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'a074c3ea-f255-4cf2-ae3f-727f9186be3c' AND street_address = 'Retorno Campeche 452 Interior 594');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '0e3821a8-80d6-4fa9-8313-3ed45b83c28b', 'primary', 'Calzada Rosas 341 Edif. 939 , Depto. 560', 'Vieja Ecuador', (SELECT id FROM regions WHERE name = 'México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '0e3821a8-80d6-4fa9-8313-3ed45b83c28b' AND street_address = 'Calzada Rosas 341 Edif. 939 , Depto. 560');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '3d521bc9-692d-4a0d-a3d7-80e816b86374', 'primary', 'Avenida Norte Gamboa 704 Edif. 610 , Depto. 450', 'Vieja Perú', (SELECT id FROM regions WHERE name = 'Nayarit'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '3d521bc9-692d-4a0d-a3d7-80e816b86374' AND street_address = 'Avenida Norte Gamboa 704 Edif. 610 , Depto. 450');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '47393461-e570-448b-82b1-1cef15441262', 'primary', 'Circuito Tamaulipas 731 Edif. 243 , Depto. 639', 'San Rafaél de la Montaña', (SELECT id FROM regions WHERE name = 'Ciudad de México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '47393461-e570-448b-82b1-1cef15441262' AND street_address = 'Circuito Tamaulipas 731 Edif. 243 , Depto. 639');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '744b4a03-e575-4978-b10e-6c087c9e744b', 'primary', 'Avenida San Marino 567 Interior 239', 'Vieja Irlanda', (SELECT id FROM regions WHERE name = 'Nayarit'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '744b4a03-e575-4978-b10e-6c087c9e744b' AND street_address = 'Avenida San Marino 567 Interior 239');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '9a18b839-1b93-44fb-9d8a-2ea12388e887', 'primary', 'Viaducto Querétaro 024 497', 'Vieja Canadá', (SELECT id FROM regions WHERE name = 'México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '9a18b839-1b93-44fb-9d8a-2ea12388e887' AND street_address = 'Viaducto Querétaro 024 497');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b', 'primary', 'Calzada Myanmar 745 Edif. 320 , Depto. 401', 'Vieja Letonia', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b' AND street_address = 'Calzada Myanmar 745 Edif. 320 , Depto. 401');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'primary', 'Callejón Burundi 277 105', 'San Francisco Javier los bajos', (SELECT id FROM regions WHERE name = 'Ciudad de México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f' AND street_address = 'Callejón Burundi 277 105');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'eea6be20-e19f-485f-ab54-537a7c28245f', 'primary', 'Boulevard Razo 082 139', 'Nueva Zambia', (SELECT id FROM regions WHERE name = 'San Luis Potosí'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'eea6be20-e19f-485f-ab54-537a7c28245f' AND street_address = 'Boulevard Razo 082 139');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'eb602cae-423a-455d-a22e-d47aea5eb650', 'primary', 'Circunvalación Baja California Sur 922 637', 'Vieja República Federal Democrática de Nepal', (SELECT id FROM regions WHERE name = 'Sinaloa'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'eb602cae-423a-455d-a22e-d47aea5eb650' AND street_address = 'Circunvalación Baja California Sur 922 637');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'bb17faca-a7b2-4de8-bf29-2fcb569ef554', 'primary', 'Boulevard Bangladesh 685 390', 'Nueva Belarús', (SELECT id FROM regions WHERE name = 'México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'bb17faca-a7b2-4de8-bf29-2fcb569ef554' AND street_address = 'Boulevard Bangladesh 685 390');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '44a33aab-1a23-4995-bd07-41f95b34fd57', 'primary', 'Calle Casanova 310 Interior 988', 'San Guadalupe los altos', (SELECT id FROM regions WHERE name = 'Zacatecas'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '44a33aab-1a23-4995-bd07-41f95b34fd57' AND street_address = 'Calle Casanova 310 Interior 988');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '5462455f-fbe3-44c8-b0d1-0644c433aca6', 'primary', 'Ampliación Orosco 714 Edif. 068 , Depto. 787', 'San Guadalupe los altos', (SELECT id FROM regions WHERE name = 'Sinaloa'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '5462455f-fbe3-44c8-b0d1-0644c433aca6' AND street_address = 'Ampliación Orosco 714 Edif. 068 , Depto. 787');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'd050617d-dc89-4f28-b546-9680dd1c5fad', 'primary', 'Ampliación Sur Naranjo 780 592', 'Vieja Haití', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'd050617d-dc89-4f28-b546-9680dd1c5fad' AND street_address = 'Ampliación Sur Naranjo 780 592');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '7227444e-b122-48f4-8f01-2cda439507b1', 'primary', 'Continuación Morelos 721 Interior 197', 'Vieja Polonia', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '7227444e-b122-48f4-8f01-2cda439507b1' AND street_address = 'Continuación Morelos 721 Interior 197');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'd86c173a-8a1d-43b4-a0c1-c836afdc378b', 'primary', 'Cerrada Carrero 054 Interior 080', 'Vieja Mongolia', (SELECT id FROM regions WHERE name = 'Tlaxcala'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'd86c173a-8a1d-43b4-a0c1-c836afdc378b' AND street_address = 'Cerrada Carrero 054 Interior 080');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'fb0a848d-4d51-4416-86bc-e568f694f9e7', 'primary', 'Calzada Tamaulipas 746 Interior 025', 'San Elvira los bajos', (SELECT id FROM regions WHERE name = 'Tlaxcala'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'fb0a848d-4d51-4416-86bc-e568f694f9e7' AND street_address = 'Calzada Tamaulipas 746 Interior 025');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc', 'primary', 'Cerrada Holguín 544 Edif. 668 , Depto. 094', 'Vieja Jordania', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc' AND street_address = 'Cerrada Holguín 544 Edif. 668 , Depto. 094');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '8cb48822-4d4c-42ed-af7f-737d3107b1db', 'primary', 'Cerrada Chihuahua 013 706', 'Vieja Sudán del Sur', (SELECT id FROM regions WHERE name = 'Sinaloa'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '8cb48822-4d4c-42ed-af7f-737d3107b1db' AND street_address = 'Cerrada Chihuahua 013 706');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '700b8c76-7ad1-4453-9ce3-f598565c6452', 'primary', 'Callejón Mireles 928 Interior 553', 'Vieja Madagascar', (SELECT id FROM regions WHERE name = 'Nuevo León'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '700b8c76-7ad1-4453-9ce3-f598565c6452' AND street_address = 'Callejón Mireles 928 Interior 553');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', 'd3cb7dc8-9240-4800-a1d9-bf65c5dac801', 'primary', 'Periférico Norte Elizondo 600 Edif. 087 , Depto. 880', 'San Esteban de la Montaña', (SELECT id FROM regions WHERE name = 'Tabasco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = 'd3cb7dc8-9240-4800-a1d9-bf65c5dac801' AND street_address = 'Periférico Norte Elizondo 600 Edif. 087 , Depto. 880');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '06c71356-e038-4c3d-bfea-7865acacb684', 'primary', 'Cerrada Sur Juárez 165 Interior 111', 'Nueva Omán', (SELECT id FROM regions WHERE name = 'Ciudad de México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '06c71356-e038-4c3d-bfea-7865acacb684' AND street_address = 'Cerrada Sur Juárez 165 Interior 111');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '30e2b2ec-9553-454e-92a4-c1dc89609cbb', 'primary', 'Viaducto Aguascalientes 256 Edif. 771 , Depto. 122', 'Nueva Qatar', (SELECT id FROM regions WHERE name = 'Guanajuato'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '30e2b2ec-9553-454e-92a4-c1dc89609cbb' AND street_address = 'Viaducto Aguascalientes 256 Edif. 771 , Depto. 122');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '2eead5aa-095b-418a-bd02-e3a917971887', 'primary', 'Privada Baja California Sur 815 Edif. 441 , Depto. 454', 'Nueva Cuba', (SELECT id FROM regions WHERE name = 'Nuevo León'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '2eead5aa-095b-418a-bd02-e3a917971887' AND street_address = 'Privada Baja California Sur 815 Edif. 441 , Depto. 454');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '05afd7e1-bb93-4c83-90a7-48a65b6e7598', 'primary', 'Diagonal Velasco 162 665', 'San Eduardo de la Montaña', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '05afd7e1-bb93-4c83-90a7-48a65b6e7598' AND street_address = 'Diagonal Velasco 162 665');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', 'primary', 'Cerrada Tabasco 693 Interior 329', 'San Hugo los bajos', (SELECT id FROM regions WHERE name = 'San Luis Potosí'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15' AND street_address = 'Cerrada Tabasco 693 Interior 329');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '454f4ba6-cb6d-4f27-9d76-08f5b358b484', 'primary', 'Peatonal Perú 799 Interior 649', 'San María José los altos', (SELECT id FROM regions WHERE name = 'Puebla'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '454f4ba6-cb6d-4f27-9d76-08f5b358b484' AND street_address = 'Peatonal Perú 799 Interior 649');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282', 'primary', 'Corredor Nicaragua 738 Interior 211', 'San Minerva los bajos', (SELECT id FROM regions WHERE name = 'Sonora'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282' AND street_address = 'Corredor Nicaragua 738 Interior 211');

-- =============================================
-- USERS WITH PASSWORDS
-- =============================================

-- User: contacto@despacho-grijalva-mascarenas-y-parra.predicthealth.com
-- Password (plain text): Hkfx0Igv_5M(
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('163749fb-8b46-4447-a8b7-95b4a59531b6', 'contacto@despacho-grijalva-mascarenas-y-parra.predicthealth.com', '$2b$12$6mcDfCFslgqWcx9JxVFKTe7nBDEigUKq5DvD3z7evmbItIoxei89m', 'institution', '163749fb-8b46-4447-a8b7-95b4a59531b6', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@laboratorios-saldivar-santillan-y-villanueva.predicthealth.com
-- Password (plain text): gj6hdu&2k%(F
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('83b74179-f6ef-4219-bc70-c93f4393a350', 'contacto@laboratorios-saldivar-santillan-y-villanueva.predicthealth.com', '$2b$12$/OvX02jPhyWufld7TETGyeqrj0Dk92KJDDk2LNXxiDP/RLe1z26SC', 'institution', '83b74179-f6ef-4219-bc70-c93f4393a350', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@trejo-vigil-e-hijos.predicthealth.com
-- Password (plain text): PG7KqxVm#em1
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('50503414-ca6d-4c1a-a34f-18719e2fd555', 'contacto@trejo-vigil-e-hijos.predicthealth.com', '$2b$12$HANFBGrnTprhf1lxn41rAelpi/3Hy9f7DjTdXEz0knpKW0Uu4pBD.', 'institution', '50503414-ca6d-4c1a-a34f-18719e2fd555', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-barajas-del-valle-y-carrero.predicthealth.com
-- Password (plain text): !d6^(BTsAEvZ
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('9b581d3c-9e93-4f39-80bb-294752065866', 'contacto@club-barajas-del-valle-y-carrero.predicthealth.com', '$2b$12$A5B25nEei7cQmwOZ/65dkO6Y25A5fElFp9lb64qxDKet6Q8PpYvKq', 'institution', '9b581d3c-9e93-4f39-80bb-294752065866', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@collazo-barrientos.predicthealth.com
-- Password (plain text): 9xIm7Ysu$G)M
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('e0e34926-8d48-4db0-afb9-b20b6eeb1ecb', 'contacto@collazo-barrientos.predicthealth.com', '$2b$12$otbGYyRXEryXBSmbFQRDMuqZM/xpYL8.8D.F9UTJ/KqZEcyPM4MM2', 'institution', 'e0e34926-8d48-4db0-afb9-b20b6eeb1ecb', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@corporacin-prado-davila-y-noriega.predicthealth.com
-- Password (plain text): x!oB+P1zSmL8
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('81941e1d-820a-4313-8177-e44278d9a981', 'contacto@corporacin-prado-davila-y-noriega.predicthealth.com', '$2b$12$pVAI.KIxeoBjSIWhtEeHBe2BrHVSAWpTupC.oQ8efMRjdL8xbtmii', 'institution', '81941e1d-820a-4313-8177-e44278d9a981', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@corporacin-navarro-collado.predicthealth.com
-- Password (plain text): D#1Go$zXyU!^
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a725b15f-039b-4256-843a-51a2968633fd', 'contacto@corporacin-navarro-collado.predicthealth.com', '$2b$12$jY3Ados/UkPxZiXfyLHMkuaIOuQ8Mcq/qbGETkCRJoD5H58l1ztsC', 'institution', 'a725b15f-039b-4256-843a-51a2968633fd', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@iglesias-soria-y-chacon.predicthealth.com
-- Password (plain text): UrXA6%Qyqp^Q
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d', 'contacto@iglesias-soria-y-chacon.predicthealth.com', '$2b$12$Sd5g895OtKX5iNldjqy/FeFGwwdFiM4VfJUl.Ep7PxxpPDOiiWisa', 'institution', '0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@castillo-zayas.predicthealth.com
-- Password (plain text): ^5fJ)zyAQc5g
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d471d2d1-66a1-4de0-8754-127059786888', 'contacto@castillo-zayas.predicthealth.com', '$2b$12$R9dzpcXKnljTMzGnTeWfjOo7fQASccPw5.9IAW5K62lNZUAVP3iEC', 'institution', 'd471d2d1-66a1-4de0-8754-127059786888', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-mesa-y-riojas.predicthealth.com
-- Password (plain text): 4UeGUfrV&)9T
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('8fd698b3-084d-4248-a28e-2708a5862e27', 'contacto@club-mesa-y-riojas.predicthealth.com', '$2b$12$HgSfquVtP4osxCx0wX4O.OVKuF3bn9wt611bG4bN3R6HxEkM2jgfq', 'institution', '8fd698b3-084d-4248-a28e-2708a5862e27', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@ojeda-y-baca-s-r-l-de-c-v.predicthealth.com
-- Password (plain text): mH)8+GwyesSA
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('7b96a7bb-041f-4331-be05-e97cab7dafc0', 'contacto@ojeda-y-baca-s-r-l-de-c-v.predicthealth.com', '$2b$12$j5TQgGbTGeGAYDjyweQSiu6lCNSjprFxN8Z6prQUaqTPxsMKXkB8a', 'institution', '7b96a7bb-041f-4331-be05-e97cab7dafc0', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@murillo-y-quintanilla-s-a.predicthealth.com
-- Password (plain text): ORTPsy_bs^1M
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5da54d5d-de0c-4277-a43e-6a89f987e77c', 'contacto@murillo-y-quintanilla-s-a.predicthealth.com', '$2b$12$xG7lL.IR9q3YiP/wG1dNWevqU99hmYsCkNmHQ5xXqPgy2dYxxmUTS', 'institution', '5da54d5d-de0c-4277-a43e-6a89f987e77c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@grupo-collazo-hinojosa-y-valdes.predicthealth.com
-- Password (plain text): n(q742Ll9W!r
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c9014e88-309c-4cb0-a28d-25b510e1e522', 'contacto@grupo-collazo-hinojosa-y-valdes.predicthealth.com', '$2b$12$6QzkpmT9GDmATIcL6MOn6e/v.JDogu3E0B7vXt99t0FJxtwESq0g.', 'institution', 'c9014e88-309c-4cb0-a28d-25b510e1e522', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-verdugo-y-tejeda.predicthealth.com
-- Password (plain text): SekkSaVYp6!9
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('8e889f63-2c86-44ab-959f-fdc365353d5d', 'contacto@club-verdugo-y-tejeda.predicthealth.com', '$2b$12$T344MdR9OH8blY.9KOGmkOXGalkk61oYTzoPOnwR0ztSVcXW8MbGm', 'institution', '8e889f63-2c86-44ab-959f-fdc365353d5d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@zaragoza-e-hijos.predicthealth.com
-- Password (plain text): (g*ANee&s2FJ
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('67787f7c-fdee-4e30-80bd-89008ebfe419', 'contacto@zaragoza-e-hijos.predicthealth.com', '$2b$12$Jh9hyW5I/PeRgdIXj53B/uMZAEf6waz1W8uELhbcz7JGZvEwxEUy2', 'institution', '67787f7c-fdee-4e30-80bd-89008ebfe419', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@ceballos-tello.predicthealth.com
-- Password (plain text): 60wH3w*i_&Sh
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('4721cb90-8fb0-4fd6-b19e-160b4ac0c744', 'contacto@ceballos-tello.predicthealth.com', '$2b$12$0c0LnQ2TCDMZlCdUYgHROub3Caf1SH7dZaXNEayQujvrsDHU8GRuK', 'institution', '4721cb90-8fb0-4fd6-b19e-160b4ac0c744', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@banuelos-e-hijos.predicthealth.com
-- Password (plain text): qs+ZVRDffhE4
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('09c54a60-6267-4439-9c8b-8c9012842942', 'contacto@banuelos-e-hijos.predicthealth.com', '$2b$12$3U/ueQi4kJHRvSMj51PFRecRutD7PJPRHDhLpnxBZzpfCdeO.1Q06', 'institution', '09c54a60-6267-4439-9c8b-8c9012842942', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@despacho-jaramillo-salas-y-carrero.predicthealth.com
-- Password (plain text): vz#WmoNWS%6(
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a670c73c-cc47-42fe-88c9-0fa37359779b', 'contacto@despacho-jaramillo-salas-y-carrero.predicthealth.com', '$2b$12$L8vOelgJq6WnesPgXbikpegPyjHI.ituvvTdyQYNjLioRn/WWuaYO', 'institution', 'a670c73c-cc47-42fe-88c9-0fa37359779b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@paez-navarro-s-a.predicthealth.com
-- Password (plain text): t^4lcZDybfP0
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('373769ab-b720-4269-bfb9-02546401ce99', 'contacto@paez-navarro-s-a.predicthealth.com', '$2b$12$O9NeBADQVtProgUwqam/2u8qxtdAugEdHFK6ActD7FuQA.RJdqxHi', 'institution', '373769ab-b720-4269-bfb9-02546401ce99', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@proyectos-mata-y-jurado.predicthealth.com
-- Password (plain text): L%8KalAX+C(&
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ec040a7f-96b2-4a7d-85ed-3741fcdcfc75', 'contacto@proyectos-mata-y-jurado.predicthealth.com', '$2b$12$EVcvTjl7Z75vI6d3FZ08h.6km/9lt53.mwKQlyQnkd.bwQU0Ef32C', 'institution', 'ec040a7f-96b2-4a7d-85ed-3741fcdcfc75', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@laboratorios-trejo-garcia-y-lucero.predicthealth.com
-- Password (plain text): lQGMj6ReE&9A
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0', 'contacto@laboratorios-trejo-garcia-y-lucero.predicthealth.com', '$2b$12$lIqfMqSc1dGBi8wITU2Dwez57iPiy54T9/3vC/c21NdNOUD.XRQBW', 'institution', '2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@industrias-valverde-y-leal.predicthealth.com
-- Password (plain text): JlWD!amO(@4m
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6c287a0e-9d4c-4574-932f-7d499aa4146c', 'contacto@industrias-valverde-y-leal.predicthealth.com', '$2b$12$Tj0oVLRzrb8etGD3wT6p.OQ4srgkW3wfTsAYxsW15ENAygqezBjY.', 'institution', '6c287a0e-9d4c-4574-932f-7d499aa4146c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@castillo-lugo-y-zamora.predicthealth.com
-- Password (plain text): )%fIhuE^TY5Q
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a14c189c-ee90-4c29-b465-63d43a9d0010', 'contacto@castillo-lugo-y-zamora.predicthealth.com', '$2b$12$RkSCSQQ.JY/gq/A7iuRiJuEEW2bNNF/TdRoA57n/P0HCVmICc2xvK', 'institution', 'a14c189c-ee90-4c29-b465-63d43a9d0010', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@montenegro-alcala-y-nieves.predicthealth.com
-- Password (plain text): bEriW)m4^L65
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('e040eabc-0ac9-47f7-89ae-24246e1c12dd', 'contacto@montenegro-alcala-y-nieves.predicthealth.com', '$2b$12$CSKms9mN57imAp197ZpkvePnnA2qdEGDc0yW5AmOkWHaQDB367TE6', 'institution', 'e040eabc-0ac9-47f7-89ae-24246e1c12dd', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@montenegro-y-pichardo-s-a-de-c-v.predicthealth.com
-- Password (plain text): Oq7K3QcR&iYA
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('9c8636c9-015b-4c18-a641-f5da698b6fd8', 'contacto@montenegro-y-pichardo-s-a-de-c-v.predicthealth.com', '$2b$12$L9pKxKuHn2SqF5mgG2ivw.vgL5DqzJADo9NGw5Mp3UOCx81gXmRxe', 'institution', '9c8636c9-015b-4c18-a641-f5da698b6fd8', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@lucio-marrero-y-asociados.predicthealth.com
-- Password (plain text): #tUX9p^L^6Bk
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa', 'contacto@lucio-marrero-y-asociados.predicthealth.com', '$2b$12$mCqdeoTBi5zK3cGlvz068.bL4UBImTfdP3u/Z.ryzOzceGI2zkpfO', 'institution', 'b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@proyectos-iglesias-verdugo.predicthealth.com
-- Password (plain text): 9G5WMvjpK%o(
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('146a692b-6d46-4c26-a165-092fe771400e', 'contacto@proyectos-iglesias-verdugo.predicthealth.com', '$2b$12$e2c5Eyq7k88O4JALHgIm/OmDj5gsGbnP5NAHOd43lfMnWAPtveR3K', 'institution', '146a692b-6d46-4c26-a165-092fe771400e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@duenas-esquivel-s-r-l-de-c-v.predicthealth.com
-- Password (plain text): %I4*s85aDpWR
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6297ae0f-7fee-472d-87ec-e22b87ce6ffb', 'contacto@duenas-esquivel-s-r-l-de-c-v.predicthealth.com', '$2b$12$CsOa0XfrYq2mRMv5AHj4huJrZH66XWOjuKybZsS2LUTtdWk/7X7wi', 'institution', '6297ae0f-7fee-472d-87ec-e22b87ce6ffb', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@valencia-toro.predicthealth.com
-- Password (plain text): lyC0vP#aKX%@
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('66e6aa6c-596c-442e-85fb-b143875d0dfc', 'contacto@valencia-toro.predicthealth.com', '$2b$12$mBor..0nmb/LhNA75cfOHe6qmM8GQ.Hh/IZRpdjpa6dbgnITMHnZ2', 'institution', '66e6aa6c-596c-442e-85fb-b143875d0dfc', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@solano-rodrigez.predicthealth.com
-- Password (plain text): ylU+9B0rO5+4
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('46af545e-6db8-44ba-a7f9-9fd9617f4a09', 'contacto@solano-rodrigez.predicthealth.com', '$2b$12$hSJ9z5CpUEpCjZq8bOol5.kpkkgWm256eQlVYz1G9fZ2.TXFFztkG', 'institution', '46af545e-6db8-44ba-a7f9-9fd9617f4a09', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@laboratorios-vasquez-zepeda.predicthealth.com
-- Password (plain text): c@M^B^Cwx886
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a56b6787-94e9-49f0-8b3a-6ff5979773fc', 'contacto@laboratorios-vasquez-zepeda.predicthealth.com', '$2b$12$024vBYq6TWxLqWZDR5oZpOOk9gYAALLycGXWkMvMHR2Xut2G5APjm', 'institution', 'a56b6787-94e9-49f0-8b3a-6ff5979773fc', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-montanez-almaraz.predicthealth.com
-- Password (plain text): 9GtgHYsj!1o4
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf', 'contacto@club-montanez-almaraz.predicthealth.com', '$2b$12$vXTWKTao7BuFQ23z2IOb9ON/I/UTESEnUx0oSiAg7RZiR.PVdoRd.', 'institution', 'd4aa9e53-8b33-45f1-a9a8-ac7141ede7bf', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@proyectos-alvarez-godinez-y-estevez.predicthealth.com
-- Password (plain text): P6TCaK94!ufS
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('4bfa1a0a-0434-45e0-b454-03140b992f53', 'contacto@proyectos-alvarez-godinez-y-estevez.predicthealth.com', '$2b$12$FpV3vHIsZhIu6vOXZeVMAOl5gLL.OrTr0l900fgvqU.noRziFaLk.', 'institution', '4bfa1a0a-0434-45e0-b454-03140b992f53', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@grupo-carvajal-murillo-y-regalado.predicthealth.com
-- Password (plain text): %kHAOZl72S#h
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('33ba98b9-c46a-47c1-b266-d8a4fe557290', 'contacto@grupo-carvajal-murillo-y-regalado.predicthealth.com', '$2b$12$rbXmQ.jDjQseWbgnt2lHkuEVQDBiGwOh10mKxi9XEwR9vdfwvOJ9G', 'institution', '33ba98b9-c46a-47c1-b266-d8a4fe557290', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@industrias-bahena-nieto-y-acosta.predicthealth.com
-- Password (plain text): BD0IAmOhy)WR
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f4764cd3-47e9-4408-b0ee-9b9001c5459d', 'contacto@industrias-bahena-nieto-y-acosta.predicthealth.com', '$2b$12$LLMJh0qoomU2WwTbHCZNw.im2k0waScETps/RGBKyK/gOoG1oc2L.', 'institution', 'f4764cd3-47e9-4408-b0ee-9b9001c5459d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@villagomez-s-a.predicthealth.com
-- Password (plain text): 5_!4Xuo&Mz&*
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8', 'contacto@villagomez-s-a.predicthealth.com', '$2b$12$VuQUfpZgxDw22yaSFclT1eY08yKVWdEhovJ2FRrGDBM5X4PHPubVG', 'institution', 'f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@lucero-fajardo-e-hijos.predicthealth.com
-- Password (plain text): H5w)s^p&)PWO
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d', 'contacto@lucero-fajardo-e-hijos.predicthealth.com', '$2b$12$7I2FpqRUkoP5YcnoySr/MuBJC5irFxdmilZyT0W35h5UwVVWuBmPK', 'institution', '219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@laboratorios-arellano-rosas.predicthealth.com
-- Password (plain text): %NHwb_Rje26n
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('8be78aaa-c408-452e-bf01-8e831ab5c63a', 'contacto@laboratorios-arellano-rosas.predicthealth.com', '$2b$12$ggJ4z69CEhd3BewrSz4DnONpVvf/RW7b7lVq1FJx8Bq6rXfE5pWBu', 'institution', '8be78aaa-c408-452e-bf01-8e831ab5c63a', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@alba-casas.predicthealth.com
-- Password (plain text): %SqQkBG^8rXx
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('8fb0899c-732e-4f03-8209-d52ef41a6a76', 'contacto@alba-casas.predicthealth.com', '$2b$12$Ld0ifpWpKoOUpQ69ZQWuruvRvLnt816pd9YHsrUGkgZlUzLq70HAC', 'institution', '8fb0899c-732e-4f03-8209-d52ef41a6a76', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-zambrano-arredondo-y-guerra.predicthealth.com
-- Password (plain text): RZ%PAC9e_7tN
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3a9084e7-74c5-4e0b-b786-2c93d9cd39ee', 'contacto@club-zambrano-arredondo-y-guerra.predicthealth.com', '$2b$12$ZV.WzE3exIViB23pbjg5COeQzm7T.ZEWoJlIl.cXC1z/3fGZ0g1GS', 'institution', '3a9084e7-74c5-4e0b-b786-2c93d9cd39ee', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-ballesteros-cornejo.predicthealth.com
-- Password (plain text): !MpK5fmbB9zL
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('54481b92-e5f5-421b-ba21-89bf520a2d87', 'contacto@club-ballesteros-cornejo.predicthealth.com', '$2b$12$k8qcve3Peyf6.8.BZ20yFe6q5f8dKF4jupZxKJRQ9aMAO.9Hd3/Iu', 'institution', '54481b92-e5f5-421b-ba21-89bf520a2d87', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@espinoza-y-villegas-a-c.predicthealth.com
-- Password (plain text): D41b1Cqt(wa@
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('68f1a02a-d348-4d1e-99ee-733d832a3f43', 'contacto@espinoza-y-villegas-a-c.predicthealth.com', '$2b$12$o7Tj/hmj1H25htGUBP4qLOLiTGWQs5nhQmg4gpzSXhnmzufU5ld.a', 'institution', '68f1a02a-d348-4d1e-99ee-733d832a3f43', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@alfaro-pacheco-y-villalpando.predicthealth.com
-- Password (plain text): 3BJZ2k4f^3j(
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('36983990-abe8-4f1c-9c1b-863b9cab3ca9', 'contacto@alfaro-pacheco-y-villalpando.predicthealth.com', '$2b$12$m9KbyMuiYr9AkBQnTIAMJueTqWF9G4zPHxJ4t38cE3137v7z7gp32', 'institution', '36983990-abe8-4f1c-9c1b-863b9cab3ca9', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@grupo-ibarra-y-elizondo.predicthealth.com
-- Password (plain text): &6YLkhqc(aVs
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b654860f-ec74-42d6-955e-eeedde2df0dd', 'contacto@grupo-ibarra-y-elizondo.predicthealth.com', '$2b$12$xH32ZUtBLnn9ZTtnXKUGRuEJF/egRzQiDSNDV51HVr8hu8gH/7N5.', 'institution', 'b654860f-ec74-42d6-955e-eeedde2df0dd', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@avila-y-maestas-s-a.predicthealth.com
-- Password (plain text): @O40fZx6H08I
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('be133600-848e-400b-9bc8-c52a4f3cf10d', 'contacto@avila-y-maestas-s-a.predicthealth.com', '$2b$12$xTLUvglaRD8xuRryufeE1uHeFse.NmMXv2XlLJfhgyvyUKyvj/E7.', 'institution', 'be133600-848e-400b-9bc8-c52a4f3cf10d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@gastelum-y-guerrero-y-asociados.predicthealth.com
-- Password (plain text): l$IxAfSC_vp4
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('25e918f3-692f-4f51-b630-4caa1dd825a1', 'contacto@gastelum-y-guerrero-y-asociados.predicthealth.com', '$2b$12$CW/6kQ/JcxnoKKmqPLn7HuGWwQTnuqakyxbpLJfFIYFWqOYOeZWV2', 'institution', '25e918f3-692f-4f51-b630-4caa1dd825a1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@escobedo-y-guerrero-a-c.predicthealth.com
-- Password (plain text): 93F&2ITsY$+(
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('cc46221e-f387-463c-9d11-9464d8209f7b', 'contacto@escobedo-y-guerrero-a-c.predicthealth.com', '$2b$12$gQFvnwgNsHUTnBzgKsCJc.6Tbdl9lsWg4G27XXlWgT68HqrpRIr/O', 'institution', 'cc46221e-f387-463c-9d11-9464d8209f7b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@laboratorios-cavazos-y-valentin.predicthealth.com
-- Password (plain text): 6iWSQVFQm^6v
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a15d4a4b-1bc4-4ee5-a168-714f71d94e42', 'contacto@laboratorios-cavazos-y-valentin.predicthealth.com', '$2b$12$ocWU88sHM8eAQ2l7vpvC4ewBJF0YvC26PZ92.1hXvNn8n/rn2dYiy', 'institution', 'a15d4a4b-1bc4-4ee5-a168-714f71d94e42', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@leal-valdez-s-a-de-c-v.predicthealth.com
-- Password (plain text): 8@SfbY8d4j05
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3d7c5771-0692-4a2f-a4c6-6af2b561282b', 'contacto@leal-valdez-s-a-de-c-v.predicthealth.com', '$2b$12$lylrzauU1I6dVfD6CQzI7uvhdsdSpqaWMx3Rb.kQk1nYGyg7PAcsG', 'institution', '3d7c5771-0692-4a2f-a4c6-6af2b561282b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@carvajal-y-urias-a-c.predicthealth.com
-- Password (plain text): )a_H4V5i8zss
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('16b25a77-b84a-44ac-8540-c5bfa9b3b6b0', 'contacto@carvajal-y-urias-a-c.predicthealth.com', '$2b$12$rLzNX5hBLI5TNppTsST2T.X3LFBZEOMIo/K/d/lhn/m9JQs4V3Crm', 'institution', '16b25a77-b84a-44ac-8540-c5bfa9b3b6b0', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@alonso-s-a.predicthealth.com
-- Password (plain text): ^UlRj+2H!00m
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('2040ac28-7210-4fbd-9716-53872211bcd9', 'contacto@alonso-s-a.predicthealth.com', '$2b$12$5CImdx4LGNWFe6.3bud3qOL/tBBpTJbX875Ha4Vt32F1Z0ksrYSVG', 'institution', '2040ac28-7210-4fbd-9716-53872211bcd9', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@arteaga-malave.predicthealth.com
-- Password (plain text): !5)71m2o4_Ce
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0d826581-b9d8-4828-8848-9332fe38d169', 'contacto@arteaga-malave.predicthealth.com', '$2b$12$IQIwGc5x6uvwz.z5elh15.VIIosqtyFJi0qfvaOINfnuX9JxDaDWe', 'institution', '0d826581-b9d8-4828-8848-9332fe38d169', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@briones-y-esquibel-s-c.predicthealth.com
-- Password (plain text): 2mwz&QzsIP^0
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c0595f94-c8f4-413c-a05c-7cfca773563c', 'contacto@briones-y-esquibel-s-c.predicthealth.com', '$2b$12$Zk.OCVFFri7W6vFPYeqXJ.e/.Xa8CzNSiK4nFCqkeG9kiKigvB6fm', 'institution', 'c0595f94-c8f4-413c-a05c-7cfca773563c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@mares-altamirano-y-gil.predicthealth.com
-- Password (plain text): XBz*MUDr(3TH
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5', 'contacto@mares-altamirano-y-gil.predicthealth.com', '$2b$12$JFOLotCS2q4nUjdBFrSQHef/wKB/CT08UHwswI.lpp3l9bJnlfzvW', 'institution', 'a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@corporacin-hurtado-martinez-y-bueno.predicthealth.com
-- Password (plain text): 2XNnTb%2+#lv
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ad2c792b-5015-4238-b221-fa28e8b061fc', 'contacto@corporacin-hurtado-martinez-y-bueno.predicthealth.com', '$2b$12$DFpqEBd85lHcuw73zYmBzenaoxL4aXsBl0dBUrJrwb8/KXVzjMi.O', 'institution', 'ad2c792b-5015-4238-b221-fa28e8b061fc', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@leyva-y-saavedra-e-hijos.predicthealth.com
-- Password (plain text): p#U0hlI3W$1k
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c3e96b10-f0ca-421e-b402-aba6d595cf27', 'contacto@leyva-y-saavedra-e-hijos.predicthealth.com', '$2b$12$N0bS8Qfx4hyKcX9TqUuzpe0ukKNFQP.kxZfqDvnzYUgTr8nOAhbZG', 'institution', 'c3e96b10-f0ca-421e-b402-aba6d595cf27', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@corporacin-pacheco-hurtado-y-holguin.predicthealth.com
-- Password (plain text): Ig$LNBybf650
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a5b1202a-9112-404b-b7de-ddf0f62711f8', 'contacto@corporacin-pacheco-hurtado-y-holguin.predicthealth.com', '$2b$12$AjB3MwPSrI6Sj2g74dLt2ezTNPnWAbGRXy5QPB55FC1V83tHUe4TS', 'institution', 'a5b1202a-9112-404b-b7de-ddf0f62711f8', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@despacho-guerrero-noriega-y-zavala.predicthealth.com
-- Password (plain text): *Gl@9HcB)Nf2
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ac6f8f54-21c8-475b-bea6-19e31643392d', 'contacto@despacho-guerrero-noriega-y-zavala.predicthealth.com', '$2b$12$GgU2jMNfx1YlrhAxopa9luKirF1IMrDi0efVCmCh2Eb3l4Pq1a7a2', 'institution', 'ac6f8f54-21c8-475b-bea6-19e31643392d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@montano-lira.predicthealth.com
-- Password (plain text): %P55Bjd7I_gI
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('43dee983-676a-4e33-a6b0-f0a72f46d06c', 'contacto@montano-lira.predicthealth.com', '$2b$12$V2sck7BqV7PDHQ7JnQMOJulSmOKQDc9eDxV8rcQPcGIt8s5cwzr22', 'institution', '43dee983-676a-4e33-a6b0-f0a72f46d06c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@pelayo-arenas.predicthealth.com
-- Password (plain text): f+wsU4Mmi)g5
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f7799f28-3ab7-4b36-8a3a-b23890a5f0ca', 'contacto@pelayo-arenas.predicthealth.com', '$2b$12$.H03tKgxxfOe.2AdbZq1Su/HlHlRS14iZzQGGg89anV1gt5MaIINy', 'institution', 'f7799f28-3ab7-4b36-8a3a-b23890a5f0ca', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@gil-y-coronado-y-asociados.predicthealth.com
-- Password (plain text): a#vamwmBje9I
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('08a7fe9e-c043-4fed-89e4-93a416a20089', 'contacto@gil-y-coronado-y-asociados.predicthealth.com', '$2b$12$ZbK.FuwUcIu4rONxyZZE7uUxJmhvcQbE/xux/N/jwsHC.U715TTbu', 'institution', '08a7fe9e-c043-4fed-89e4-93a416a20089', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@crespo-pena-y-rosado.predicthealth.com
-- Password (plain text): 3$FJeYY27d70
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('89ab21cf-089e-4210-8e29-269dfbd38d71', 'contacto@crespo-pena-y-rosado.predicthealth.com', '$2b$12$GaYhhQW82EIA78vALU9Ew.Q.6IWjyw8tFr8lTfqokli1g.Eou1Suq', 'institution', '89ab21cf-089e-4210-8e29-269dfbd38d71', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@jiminez-arroyo-y-ramon.predicthealth.com
-- Password (plain text): lTy!7Ar*teLE
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f', 'contacto@jiminez-arroyo-y-ramon.predicthealth.com', '$2b$12$87llZQoOmysnTq6qxJBnAutQ/Y2X2HlPo4ob3lgAswMIwannQ5iGu', 'institution', 'd56e3cb0-d9e2-48fc-9c16-c4a96b90c00f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@de-leon-s-c.predicthealth.com
-- Password (plain text): +_S9NIe^*@zW
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0', 'contacto@de-leon-s-c.predicthealth.com', '$2b$12$eIXCSK45GiFq54SnsLArduAFulwxqo7cYCTL7qmzPr0ZLOdow5mYi', 'institution', 'ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@robles-loera-a-c.predicthealth.com
-- Password (plain text): I@8bIQMC^kC6
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3cf42c93-4941-4d8d-8656-aafa9e987177', 'contacto@robles-loera-a-c.predicthealth.com', '$2b$12$a5lZpJdzxezlAcHIBN3UpulJ9m9L.nfvCydNEy2WxCoGNe0zm21q2', 'institution', '3cf42c93-4941-4d8d-8656-aafa9e987177', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@industrias-ponce-y-soto.predicthealth.com
-- Password (plain text): +z_NSUzki2S7
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('1926fa2a-dab7-420e-861b-c2b6dfe0174e', 'contacto@industrias-ponce-y-soto.predicthealth.com', '$2b$12$zkLayMc5mMuddaSGmE2tZelGeoh1Nm2.SeBAS1DBPuUVsJmBgf1mu', 'institution', '1926fa2a-dab7-420e-861b-c2b6dfe0174e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@madera-s-a.predicthealth.com
-- Password (plain text): oXv4WiTi3&iu
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0b2f4464-5141-44a3-a26d-f8acc1fb955e', 'contacto@madera-s-a.predicthealth.com', '$2b$12$JPHUKYSE9cAtT6N9pO11ie8/N307nJPmFGlRlMkA7vnKuLceSAi4e', 'institution', '0b2f4464-5141-44a3-a26d-f8acc1fb955e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@proyectos-tejada-ramon-y-caldera.predicthealth.com
-- Password (plain text): @u9RsAM@^*VZ
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('1fec9665-52bc-49a7-b028-f0d78440463c', 'contacto@proyectos-tejada-ramon-y-caldera.predicthealth.com', '$2b$12$fsG1nHtvJhE0Z6pnDeNxFeRF3DLWfOxbCPBvdceVrmnkNr.DsgW0C', 'institution', '1fec9665-52bc-49a7-b028-f0d78440463c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@estevez-carrera.predicthealth.com
-- Password (plain text): *42dln#_U3Mv
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a', 'contacto@estevez-carrera.predicthealth.com', '$2b$12$6EbUSKO3ibfinkLvm1/O7eypEyXDgTu2FmO/qKqqFIfQM60NfgZU2', 'institution', '50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@laboratorios-puga-coronado-y-carmona.predicthealth.com
-- Password (plain text): $lEBHWziH9NC
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('8cfdeaad-c727-4a4d-b5d5-b69dd43c0854', 'contacto@laboratorios-puga-coronado-y-carmona.predicthealth.com', '$2b$12$PfnmQtBHCcl1IxVMg1vPs.sERmE2xVn0y97hjnmhCIDErcs9lL43m', 'institution', '8cfdeaad-c727-4a4d-b5d5-b69dd43c0854', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@menchaca-vela-s-r-l-de-c-v.predicthealth.com
-- Password (plain text): DX%WNDeP#F97
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('7a6ce151-14b5-4d12-b6bb-1fba18636353', 'contacto@menchaca-vela-s-r-l-de-c-v.predicthealth.com', '$2b$12$PXC5AyC.EG5RSo9ktnEcKeDoEHGPeHgCwcYOdIdsqRg5qtWq0RKEq', 'institution', '7a6ce151-14b5-4d12-b6bb-1fba18636353', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@carreon-y-soliz-s-c.predicthealth.com
-- Password (plain text): nKuYK6Rqrh*q
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f1ab98f4-98de-420f-9c4b-c31eee92df21', 'contacto@carreon-y-soliz-s-c.predicthealth.com', '$2b$12$TSnkouxiSNnF7Y8Fc0C0e.kDAG0wBIuRkvwuVNpfJumtJiU7jlPC2', 'institution', 'f1ab98f4-98de-420f-9c4b-c31eee92df21', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@zarate-solano.predicthealth.com
-- Password (plain text): %5DgJQ3szp36
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a074c3ea-f255-4cf2-ae3f-727f9186be3c', 'contacto@zarate-solano.predicthealth.com', '$2b$12$CtiJJKAYctY9zSlhNT3lt..MBzCIfnYiCV3JZvHwde87NGajaubqK', 'institution', 'a074c3ea-f255-4cf2-ae3f-727f9186be3c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@de-la-cruz-espinoza-e-hijos.predicthealth.com
-- Password (plain text): A88BqF!C^(cb
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0e3821a8-80d6-4fa9-8313-3ed45b83c28b', 'contacto@de-la-cruz-espinoza-e-hijos.predicthealth.com', '$2b$12$ylaHmxin3ZYy33e/XxAxmuIWHvXbMop2Bhb4pKVyYqezHhzznnEUS', 'institution', '0e3821a8-80d6-4fa9-8313-3ed45b83c28b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@laboratorios-valdes-ruelas.predicthealth.com
-- Password (plain text): _(UTzHwtGW0E
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3d521bc9-692d-4a0d-a3d7-80e816b86374', 'contacto@laboratorios-valdes-ruelas.predicthealth.com', '$2b$12$CQLygfy5Xg9SdkxHOGlT0OWLzOOM6oVQS6LLAGmn3fT1L4V76.0SC', 'institution', '3d521bc9-692d-4a0d-a3d7-80e816b86374', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@espinosa-s-r-l-de-c-v.predicthealth.com
-- Password (plain text): %nMX$#E+3qNp
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('47393461-e570-448b-82b1-1cef15441262', 'contacto@espinosa-s-r-l-de-c-v.predicthealth.com', '$2b$12$EYC0kJRog1wmEw.vn1Mfhe6oUPDYNik475hVR.bH.qSguvfKnYlZC', 'institution', '47393461-e570-448b-82b1-1cef15441262', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@villarreal-ocasio.predicthealth.com
-- Password (plain text): Be0QKBwGC)B_
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('744b4a03-e575-4978-b10e-6c087c9e744b', 'contacto@villarreal-ocasio.predicthealth.com', '$2b$12$Vre8/XfP.6UT96zOljJ56.027K/kfx4pv5qfNAYnghdTXUDRsNkie', 'institution', '744b4a03-e575-4978-b10e-6c087c9e744b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@corporacin-carrasco-y-lopez.predicthealth.com
-- Password (plain text): V_0ofk$#zu#T
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('9a18b839-1b93-44fb-9d8a-2ea12388e887', 'contacto@corporacin-carrasco-y-lopez.predicthealth.com', '$2b$12$9wmxCYVPha15gOj1cpqdXeCNA6ab6bACQDZifqm4UhnlXTnpDnWuK', 'institution', '9a18b839-1b93-44fb-9d8a-2ea12388e887', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@cisneros-concepcion.predicthealth.com
-- Password (plain text): t1YPsY1q@P0L
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('1d9a84f8-fd22-4249-9b25-36c1d2ecc71b', 'contacto@cisneros-concepcion.predicthealth.com', '$2b$12$WR2IJLoySWKyHgjf7tjDmOmv/Vo6IQBg5uNHp56dRG3xPyTXieiXu', 'institution', '1d9a84f8-fd22-4249-9b25-36c1d2ecc71b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@jurado-guardado.predicthealth.com
-- Password (plain text): h!*hyQx2Wo1I
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', 'contacto@jurado-guardado.predicthealth.com', '$2b$12$kEUmDGNeGSlr76.Itaaoq.BTQBALKGpSEqM8C8.2UXdf94q1IGWAm', 'institution', '5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-perez-y-godoy.predicthealth.com
-- Password (plain text): 6%oHUZNj668_
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('eea6be20-e19f-485f-ab54-537a7c28245f', 'contacto@club-perez-y-godoy.predicthealth.com', '$2b$12$4teNLQpnZMQkhsAHlMcfyuj8nmVYvYDOUkj6NrPNd6/93u5nUJ4NC', 'institution', 'eea6be20-e19f-485f-ab54-537a7c28245f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@de-la-fuente-arias.predicthealth.com
-- Password (plain text): )fS9tLNI5Cab
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('eb602cae-423a-455d-a22e-d47aea5eb650', 'contacto@de-la-fuente-arias.predicthealth.com', '$2b$12$VzfaaD6kVj6Fv97i5UBAsOG3Pyedqes8q9VrKzsLK3uuLaDFzQATC', 'institution', 'eb602cae-423a-455d-a22e-d47aea5eb650', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@hernandes-leiva-s-a.predicthealth.com
-- Password (plain text): 3vcF$sZ7#bx0
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('bb17faca-a7b2-4de8-bf29-2fcb569ef554', 'contacto@hernandes-leiva-s-a.predicthealth.com', '$2b$12$X7xv/u2MdEp25OeUX2il0uBYsRk.B165M1Cw5DrOfPBEaYLLnZYiu', 'institution', 'bb17faca-a7b2-4de8-bf29-2fcb569ef554', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@grupo-garza-y-arellano.predicthealth.com
-- Password (plain text): #$UDDVDyYk37
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('44a33aab-1a23-4995-bd07-41f95b34fd57', 'contacto@grupo-garza-y-arellano.predicthealth.com', '$2b$12$TMwUFpoyugqbcD4Obpzj..suXD3MiyWAFvYFf.3ZwYQT2YnyS/NwK', 'institution', '44a33aab-1a23-4995-bd07-41f95b34fd57', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@laboratorios-navarrete-anaya.predicthealth.com
-- Password (plain text): %*DM6XNeR1pi
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5462455f-fbe3-44c8-b0d1-0644c433aca6', 'contacto@laboratorios-navarrete-anaya.predicthealth.com', '$2b$12$eYSk8zPCW.GTh/tROUtzOuhq8vSAtLe47gm8/HTmbxMlflYavHZ8y', 'institution', '5462455f-fbe3-44c8-b0d1-0644c433aca6', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-armas-polanco.predicthealth.com
-- Password (plain text): (z4_2%Mb*uJb
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d050617d-dc89-4f28-b546-9680dd1c5fad', 'contacto@club-armas-polanco.predicthealth.com', '$2b$12$iej7U762qNCbPuXavkoV3O0TOaD1prj4Ygy/2BegiaU8PiJxKd1Lm', 'institution', 'd050617d-dc89-4f28-b546-9680dd1c5fad', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@olivera-lovato-y-saavedra.predicthealth.com
-- Password (plain text): k2+!OymkFIl8
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('7227444e-b122-48f4-8f01-2cda439507b1', 'contacto@olivera-lovato-y-saavedra.predicthealth.com', '$2b$12$gIRz9hdGrVDDa7pnxKfpmOHR/dUotcPgoPLOUcbFlpp8psVWPbBtK', 'institution', '7227444e-b122-48f4-8f01-2cda439507b1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@grupo-ochoa-corrales.predicthealth.com
-- Password (plain text): d+)%M9_qs3$O
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d86c173a-8a1d-43b4-a0c1-c836afdc378b', 'contacto@grupo-ochoa-corrales.predicthealth.com', '$2b$12$L0kjU/0A7OK5FjLT9aeiWOJ7vZcCU4KTb2YCZWGTPomixFTY4nj8G', 'institution', 'd86c173a-8a1d-43b4-a0c1-c836afdc378b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@banuelos-montano.predicthealth.com
-- Password (plain text): W_7yO43q*&z^
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('fb0a848d-4d51-4416-86bc-e568f694f9e7', 'contacto@banuelos-montano.predicthealth.com', '$2b$12$oZriZb67qJqDtjGhNmoha.Cj4N9.qxbJOut/Q7rfKGTPCS3/UZXYa', 'institution', 'fb0a848d-4d51-4416-86bc-e568f694f9e7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@melendez-arriaga.predicthealth.com
-- Password (plain text): t4VsnqCv#_)S
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ccccdffb-bc26-4d80-a590-0cd86dd5a1bc', 'contacto@melendez-arriaga.predicthealth.com', '$2b$12$HKAPM.Gt7zIyuH.erwX6U.YoOqT82Ztingoeoza9ioo45QssXvoMW', 'institution', 'ccccdffb-bc26-4d80-a590-0cd86dd5a1bc', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@corporacin-menchaca-y-salgado.predicthealth.com
-- Password (plain text): 8xqP+pnq!jKH
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('8cb48822-4d4c-42ed-af7f-737d3107b1db', 'contacto@corporacin-menchaca-y-salgado.predicthealth.com', '$2b$12$xu7.RalsvP3ZsyNrxklwrex4N4hWmkCLEWJAdSZeo44OzZ9aeKKKK', 'institution', '8cb48822-4d4c-42ed-af7f-737d3107b1db', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-salcedo-y-segura.predicthealth.com
-- Password (plain text): (FvQSn6g*6q8
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('700b8c76-7ad1-4453-9ce3-f598565c6452', 'contacto@club-salcedo-y-segura.predicthealth.com', '$2b$12$m1qbVl5g9g8U4RcfOCpk1eTqwbqj2aSP8KCI1xgf8.T.5oHuKRVoe', 'institution', '700b8c76-7ad1-4453-9ce3-f598565c6452', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@grupo-rosas-mena-y-sandoval.predicthealth.com
-- Password (plain text): +5tTRca$^zSu
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d3cb7dc8-9240-4800-a1d9-bf65c5dac801', 'contacto@grupo-rosas-mena-y-sandoval.predicthealth.com', '$2b$12$nrt3K.GHtA3Vy6FCbsh3kujWWzRSJOfTb6wdhbdHvG4mBtfTW.9dq', 'institution', 'd3cb7dc8-9240-4800-a1d9-bf65c5dac801', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@club-otero-valadez-y-crespo.predicthealth.com
-- Password (plain text): P+^9YqMr_ut8
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('06c71356-e038-4c3d-bfea-7865acacb684', 'contacto@club-otero-valadez-y-crespo.predicthealth.com', '$2b$12$BTAdbF131HeYmoR8mvBkp.bsd98tXUziG4Zi.fw0I9ETJQQ/vAiWq', 'institution', '06c71356-e038-4c3d-bfea-7865acacb684', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@industrias-esquibel-mesa-y-valle.predicthealth.com
-- Password (plain text): 0mAhGIYv&Hl6
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('30e2b2ec-9553-454e-92a4-c1dc89609cbb', 'contacto@industrias-esquibel-mesa-y-valle.predicthealth.com', '$2b$12$DGp0MabXq8yB4R5Ss3CGBu7xmLY/Sj2hJOhFnFZ92hahMbTW97ewq', 'institution', '30e2b2ec-9553-454e-92a4-c1dc89609cbb', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@calvillo-y-benavides-a-c.predicthealth.com
-- Password (plain text): rZ57II*p)h2M
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('2eead5aa-095b-418a-bd02-e3a917971887', 'contacto@calvillo-y-benavides-a-c.predicthealth.com', '$2b$12$YuBksLwh7X.9mEsErqAlauhw464wnBtXPfmiMTr9Wk6bP6YcQ.hfm', 'institution', '2eead5aa-095b-418a-bd02-e3a917971887', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@industrias-ledesma-jurado-y-pantoja.predicthealth.com
-- Password (plain text): 9NP)9x#4)WEU
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('05afd7e1-bb93-4c83-90a7-48a65b6e7598', 'contacto@industrias-ledesma-jurado-y-pantoja.predicthealth.com', '$2b$12$8E7AfYi7NRp04FFkfBOIl.QjTndffXnZOjpVepbSZwCKQNgql70AC', 'institution', '05afd7e1-bb93-4c83-90a7-48a65b6e7598', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@cervantes-peralta.predicthealth.com
-- Password (plain text): y(&JR1btOyU8
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', 'contacto@cervantes-peralta.predicthealth.com', '$2b$12$QlPJEtR9OeIxDKKWY6khYuqZ9lSBxI/XrDrEwufn1r4al9ClA4xj2', 'institution', '5f30701a-a1bf-4337-9a60-8c4ed7f8ea15', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@rico-y-escobar-s-a.predicthealth.com
-- Password (plain text): U(Ci%b^@@e9O
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('454f4ba6-cb6d-4f27-9d76-08f5b358b484', 'contacto@rico-y-escobar-s-a.predicthealth.com', '$2b$12$PtFbfHB9RnaykQSZE1.mQeydDjGUWOvfHAE07.5eqRWUc3oKce3v6', 'institution', '454f4ba6-cb6d-4f27-9d76-08f5b358b484', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: contacto@baez-viera-s-a.predicthealth.com
-- Password (plain text): H5qVh)MX(^*r
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282', 'contacto@baez-viera-s-a.predicthealth.com', '$2b$12$zf7a/0EnLSmrsvaU0uXvCOqfcKvl/rgsGQtVnZZdJDkHRpwXhY8w6', 'institution', '389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.mariajose.rosales@guevara.info
-- Password (plain text): &v#!mPeIH69f
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7', 'dr.mariajose.rosales@guevara.info', '$2b$12$mQJzImtUB13az2IwX8zjnOwlvyyH.lbQBE3Fz4luK/xpKALttXz0C', 'doctor', '06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.sessa.irizarry@salgado-villa.com
-- Password (plain text): !Gdr#6KwBp2V
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3e5b08ed-529d-45f0-8145-8371609882c1', 'dr.sessa.irizarry@salgado-villa.com', '$2b$12$N6Ka9v2G46/W3de/n17KPO2SU2PRuYGLZMmfN9LlVDIOEyjZV6GA.', 'doctor', '3e5b08ed-529d-45f0-8145-8371609882c1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.indira.olmos@rincon.com
-- Password (plain text): uM_2Yby4C$^+
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('57031194-3c31-4320-86c4-fd370789efac', 'dr.indira.olmos@rincon.com', '$2b$12$J/LDo9q75wkKsLFaD1CCIeLclqJyN48XC1qEL1RdWmKMAavoQYAu6', 'doctor', '57031194-3c31-4320-86c4-fd370789efac', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.perla.zavala@olivas.com
-- Password (plain text): n%4*Jfnf!Q)V
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('dc42b779-4b49-418b-ab0a-92caa2a8d6de', 'dr.perla.zavala@olivas.com', '$2b$12$7LUo4D2rNoP73jtIhXBheOpx14MxL4Cf/GGCUq85jTRCP5Ig.CJem', 'doctor', 'dc42b779-4b49-418b-ab0a-92caa2a8d6de', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.fidel.urbina@madera-quintana.com
-- Password (plain text): IFZzDSC1u7)W
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('14abdfde-e4c9-460c-9ce2-17886600b20d', 'dr.fidel.urbina@madera-quintana.com', '$2b$12$M2HcxfwOSOxN44kyWM9/9et/B0PWzjH0kqpQ8S1aRrtxZqrVx6N0a', 'doctor', '14abdfde-e4c9-460c-9ce2-17886600b20d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.rebeca.paredes@longoria-florez.com
-- Password (plain text): o(2PDe2m4O&G
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('df863eba-f0b8-4b1a-bdd1-71ed2f816ed7', 'dr.rebeca.paredes@longoria-florez.com', '$2b$12$D.t3UBffh2FnUIi4tDbKE.s1hd/52DrzWYZl400B8klp0PQykSAuG', 'doctor', 'df863eba-f0b8-4b1a-bdd1-71ed2f816ed7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.mario.gaona@laboratorios.net
-- Password (plain text): Z*b4OXiGdRux
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ba712fc8-c4d2-4e22-ae18-1991c46bc85d', 'dr.mario.gaona@laboratorios.net', '$2b$12$mukB7NZcrhAQcLl09MeO1uyAsS.4nXpS/orjNzIzzmKfHylTTKaJC', 'doctor', 'ba712fc8-c4d2-4e22-ae18-1991c46bc85d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.luis.ceja@baez-burgos.com
-- Password (plain text): M!@z_8SuwpYS
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('bbf715a1-3947-4642-a67a-b5c4c0c085d2', 'dr.luis.ceja@baez-burgos.com', '$2b$12$RyJNRYXuivhb1y/8HNLhtuJTBo9po/lC7kmzyolytY0RsOP8Wbx4u', 'doctor', 'bbf715a1-3947-4642-a67a-b5c4c0c085d2', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.sergio.guevara@mateo.com
-- Password (plain text): 9_PTOEht_e4q
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec', 'dr.sergio.guevara@mateo.com', '$2b$12$ouBn2Ak5QLxtW.RqPBAg7OBzood5dCKYtjzhxNgB7Gx1YT/tLcbJC', 'doctor', '851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.natalia.barrientos@balderas-marquez.com
-- Password (plain text): )gQc@T$p3fFp
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0fbbaab0-2284-4ac6-b1c9-498b5b3c4567', 'dr.natalia.barrientos@balderas-marquez.com', '$2b$12$hUoBk.8NXS7dfs8egqyjZe.WP7InlMr77w3qO3AVJt9wwOmz/xzz.', 'doctor', '0fbbaab0-2284-4ac6-b1c9-498b5b3c4567', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.berta.rincon@arias.com
-- Password (plain text): &5A&tuU)EHMH
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b6994d45-b80e-4260-834c-facdf3ea8eee', 'dr.berta.rincon@arias.com', '$2b$12$g8rlBROH/zByvgdP0u1U8epco03MKSTJFkxPiTzfS92eetb/NpHj.', 'doctor', 'b6994d45-b80e-4260-834c-facdf3ea8eee', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.lorenzo.rivera@corporacin.com
-- Password (plain text): I)lTdz6Z4*88
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f7cdc060-94e6-47ad-90e9-939ed86fb6da', 'dr.lorenzo.rivera@corporacin.com', '$2b$12$7fquDAAlwBBkvusybduaDOxEWEwMLcM/zywgzvaada97Mgftbfere', 'doctor', 'f7cdc060-94e6-47ad-90e9-939ed86fb6da', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.omar.trujillo@barela.biz
-- Password (plain text): fc9)itL1^1iN
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('23785934-fbf0-442c-add3-05df84fa5d17', 'dr.omar.trujillo@barela.biz', '$2b$12$l3heGGZyCRK2.075JXBfb.0Bl7gvn2Ps6rI4RZlkzxUM6Q2bt/Klm', 'doctor', '23785934-fbf0-442c-add3-05df84fa5d17', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.elvira.ochoa@castaneda-galvan.com
-- Password (plain text): $4Bxesn22&rN
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('bf7a015c-1589-42b3-b1e8-103fcbc0b041', 'dr.elvira.ochoa@castaneda-galvan.com', '$2b$12$QJ7OXXopMdo1kD/XIQArh.US16o9PJzvx8HKM/X2Mo1rXUmfFwTlq', 'doctor', 'bf7a015c-1589-42b3-b1e8-103fcbc0b041', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.natalia.murillo@proyectos.biz
-- Password (plain text): TEhF#Nln(BM2
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('4fa9d0ff-2c51-4918-b48a-b5cb37d444a3', 'dr.natalia.murillo@proyectos.biz', '$2b$12$EGTVYCC0EFciFfolN8Pu1.cI087xg3QzxU3bRhD67SyTsv8h8o.Za', 'doctor', '4fa9d0ff-2c51-4918-b48a-b5cb37d444a3', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.pedro.valdes@granados.com
-- Password (plain text): 9eSvO&pK^ksb
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('93dbdfc0-e05c-4eb6-975c-360eb8d293c1', 'dr.pedro.valdes@granados.com', '$2b$12$MkzGTU7p2yHvAJRNak9aJunCSHxD/34bugNeDWWXVvRkzsLMd6ucu', 'doctor', '93dbdfc0-e05c-4eb6-975c-360eb8d293c1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.eugenio.uribe@olmos-alejandro.com
-- Password (plain text): J_87Kq*j*Ub6
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a6db1b41-d601-4840-99e9-3d7d18901399', 'dr.eugenio.uribe@olmos-alejandro.com', '$2b$12$WRR3PQIaqi43QDCR4D8.BeUG8FHXadshqM51YW4OHlxlaacoswr.a', 'doctor', 'a6db1b41-d601-4840-99e9-3d7d18901399', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.linda.trejo@bravo-alvarado.com
-- Password (plain text): ^7oJNFsW(!6z
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d5e98ce0-e6f8-4577-a0dd-3281aa303b32', 'dr.linda.trejo@bravo-alvarado.com', '$2b$12$uYgF6gxc/RkDxSKQFN1PQOJk9G0en.WccH75Y7CS606WYrNNPjAVG', 'doctor', 'd5e98ce0-e6f8-4577-a0dd-3281aa303b32', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.susana.acosta@iglesias.info
-- Password (plain text): +3TP@vTb5kq*
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('44da48b1-6ff6-4db9-9de5-34e22de0429a', 'dr.susana.acosta@iglesias.info', '$2b$12$5vTMuYrsjbOuxwGmJazQWO7gcWlIpLRrbRiZGEUnKcMdJjXZcOGSe', 'doctor', '44da48b1-6ff6-4db9-9de5-34e22de0429a', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.rodrigo.mota@valdivia.com
-- Password (plain text): L(n!2HBux2gw
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3fafc20d-72d5-4633-95a0-df6b9ed175b6', 'dr.rodrigo.mota@valdivia.com', '$2b$12$gM3u4VjQ2e4B49ZPDn7EV.mRQs6ikI8xu0jzeFHSBuzwIXuBy5.zm', 'doctor', '3fafc20d-72d5-4633-95a0-df6b9ed175b6', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.linda.magana@alva.com
-- Password (plain text): m_NnuF^m+5@4
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c4fac110-0b61-4fb0-943d-0d00af7ed0cd', 'dr.linda.magana@alva.com', '$2b$12$TFiS8igwDykaFKgdSEI4GuRig6s/MApqvlJpS0aHuOJRpj.8UVylG', 'doctor', 'c4fac110-0b61-4fb0-943d-0d00af7ed0cd', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.joseluis.rubio@fernandez-carrillo.com
-- Password (plain text): d+9ZRE6b+l@F
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('88870e4f-1333-4bcc-8daf-c8743d61f3cb', 'dr.joseluis.rubio@fernandez-carrillo.com', '$2b$12$erqfP9VObUqiAot79mqkZepGl3SQKpHNij7UpjTY3QA.jvmuYxr5W', 'doctor', '88870e4f-1333-4bcc-8daf-c8743d61f3cb', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.concepcion.barajas@saldana.info
-- Password (plain text): i_07%Ynw8PW0
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6f035f60-87f7-4a9c-9501-4b8704facba3', 'dr.concepcion.barajas@saldana.info', '$2b$12$T/Rluv42FKyOzQBs/wCHcuQTWZ3ZrfMwaMkiNoCNLFSCN9Cy3TCG6', 'doctor', '6f035f60-87f7-4a9c-9501-4b8704facba3', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.debora.delgadillo@blanco.com
-- Password (plain text): i5dgCGiN!Cso
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('58a814d3-a275-436b-8e5c-4e743fed242f', 'dr.debora.delgadillo@blanco.com', '$2b$12$sN5GyPh7YX3J.qkCtnTbjea6AKLU5xlzahzP64HE/sqdOJRxH0iy6', 'doctor', '58a814d3-a275-436b-8e5c-4e743fed242f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.augusto.roque@rincon.biz
-- Password (plain text): !6MR_W1gTO#V
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f67c2f76-9bf1-43e4-8d0e-c0a94298f35b', 'dr.augusto.roque@rincon.biz', '$2b$12$5ULLH9kMFmZ89VNSiyWd1OE2gRlC0IiVO6zlsa7RSN7Ba3IraO.yi', 'doctor', 'f67c2f76-9bf1-43e4-8d0e-c0a94298f35b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.francisca.garay@cruz.info
-- Password (plain text): f$Mh@h+3(6T9
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('fb4d84a0-7bc1-4815-b7a3-b1719c616c79', 'dr.francisca.garay@cruz.info', '$2b$12$J./PPFVcCWvDetu19enSNuDLWMV5ZjDTQkIK7K3xxqAZ8aSy2jHwi', 'doctor', 'fb4d84a0-7bc1-4815-b7a3-b1719c616c79', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.judith.sevilla@despacho.com
-- Password (plain text): INwq$yiD&8NK
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c0bdb808-eb5f-479f-9261-dbbf9ff031a6', 'dr.judith.sevilla@despacho.com', '$2b$12$R97OBhWNXK6htLUCAuwTh.5rsjjxYOhNlGaSs2H21gFQ8JpiT8VnC', 'doctor', 'c0bdb808-eb5f-479f-9261-dbbf9ff031a6', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.nelly.robles@tamayo.biz
-- Password (plain text): 1yH06Bt4+S(x
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f501d643-d308-41e0-8ffc-8bfb52d64e13', 'dr.nelly.robles@tamayo.biz', '$2b$12$YRdB03faIn0j2hhqA4NMSuDi8bwC1zqovf2WUy30Ov8j9Z8G.lPfq', 'doctor', 'f501d643-d308-41e0-8ffc-8bfb52d64e13', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.soledad.noriega@industrias.biz
-- Password (plain text): d(UDRv$Tz00L
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('adeb74f6-f3dc-43a7-a841-6d24aba046ba', 'dr.soledad.noriega@industrias.biz', '$2b$12$F3gUAkV7qoZJ6kob8e5qDehDmno/E7sukXHWgUvD5g6PqzWscoGL.', 'doctor', 'adeb74f6-f3dc-43a7-a841-6d24aba046ba', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.silvano.espinosa@saldivar.org
-- Password (plain text): !GnpYy#CtD&6
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('dd24da99-43c7-4d6b-acc0-32fc0c237d02', 'dr.silvano.espinosa@saldivar.org', '$2b$12$pVTMjNaZMV2oQGjSEkwcj.op2MpH1fLVJSatEW9RYEk86J6h35DAq', 'doctor', 'dd24da99-43c7-4d6b-acc0-32fc0c237d02', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.fabiola.saavedra@burgos.net
-- Password (plain text): _UQghaBy#7r7
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0408b031-caa3-4b7c-ae65-d05342cf5c05', 'dr.fabiola.saavedra@burgos.net', '$2b$12$76VIfrvzinNALFyDFveTcOPPuKTzpF.arXWb4nwUDYL58z5/1xFzC', 'doctor', '0408b031-caa3-4b7c-ae65-d05342cf5c05', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.silvia.enriquez@padilla-alejandro.biz
-- Password (plain text): 4vSq(8aE)!Vo
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a865edbe-d50c-4bd1-b556-ae32d9d1858c', 'dr.silvia.enriquez@padilla-alejandro.biz', '$2b$12$nDCNrCb7Xw5QPX2FHFIbSu0efIfXn2B43iAD3i8fFQPjoHr9L0HEK', 'doctor', 'a865edbe-d50c-4bd1-b556-ae32d9d1858c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.maximiliano.segura@club.net
-- Password (plain text): hU4JYwcA)0C^
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('2a0aaddd-ea43-40bb-b5df-877b1b0d20f1', 'dr.maximiliano.segura@club.net', '$2b$12$Eghgd1yorzvC46TlbxCZhuk9xG08LgzmAsyJ8WK1nhyd2WyNvZPE2', 'doctor', '2a0aaddd-ea43-40bb-b5df-877b1b0d20f1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.josemaria.serna@pelayo-baeza.info
-- Password (plain text): #xbKqa@e1I9C
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('4754ba59-3dc1-4be2-a770-44d7c34184bc', 'dr.josemaria.serna@pelayo-baeza.info', '$2b$12$Jgw9DvVBLsKK2Cj5pcShLOQEGxeQWFJ/cuHeVi5upQB06KVJ/sZNy', 'doctor', '4754ba59-3dc1-4be2-a770-44d7c34184bc', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.eugenio.gastelum@grupo.com
-- Password (plain text): %EvNtlu*5&(H
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('16e23379-6774-417d-8104-a8e6f4712909', 'dr.eugenio.gastelum@grupo.com', '$2b$12$qX/qrd/HK1yXkSqI1E4MMOmxlIZA3VWJ1MPpaByAfbl8qD1BJuwPC', 'doctor', '16e23379-6774-417d-8104-a8e6f4712909', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.eva.cotto@industrias.com
-- Password (plain text): K#M01$EaZ67O
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('07527c1a-efd5-45e4-a0d9-01ba5207bb2f', 'dr.eva.cotto@industrias.com', '$2b$12$./b5ivwrK0uXPThlE118MulhFUrimby1RIRphz.CBwAU0SC3qhUZy', 'doctor', '07527c1a-efd5-45e4-a0d9-01ba5207bb2f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.indira.ramon@proyectos.com
-- Password (plain text): gn@9OzbU4NKA
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c186d1ad-fcba-4f6e-acd7-86cb4c09938e', 'dr.indira.ramon@proyectos.com', '$2b$12$3DcrNvjHiw2LYfcRXseZNOovKU0GDRSCEvv1ocaDWseddoTm.3R7.', 'doctor', 'c186d1ad-fcba-4f6e-acd7-86cb4c09938e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.patricia.angulo@industrias.com
-- Password (plain text): &H!AAWRwi47_
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('4cecebec-e16f-4949-a18b-8bfebae86618', 'dr.patricia.angulo@industrias.com', '$2b$12$KfRwspMR2A9twzWJ8jYOQO5iI2D4nM6xyHvr/eN58esQ0dv5YZ0q2', 'doctor', '4cecebec-e16f-4949-a18b-8bfebae86618', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.helena.valladares@corporacin.com
-- Password (plain text): 6tIJ5vEo5$BA
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6d21a37a-43d8-440b-bc64-87bb0ae1d45d', 'dr.helena.valladares@corporacin.com', '$2b$12$MbVLy2EiAFwxHsW0MamRLOFn8IZYG30d/rMOJ/P5xeQPExmmV5d9C', 'doctor', '6d21a37a-43d8-440b-bc64-87bb0ae1d45d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.ruben.pacheco@quezada.com
-- Password (plain text): *23HViCxxqPV
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('4d75aae7-5d33-44ad-a297-a32ff407415d', 'dr.ruben.pacheco@quezada.com', '$2b$12$d.6nwzOgatBdPQ1l/4bsU.aZ/FD5qbA9Y0gsiA.F/Ri1D2t3MDK1u', 'doctor', '4d75aae7-5d33-44ad-a297-a32ff407415d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.samuel.garibay@laboratorios.org
-- Password (plain text): )%0xMNy1H^X&
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('e901dbc1-3eed-4e5e-b23c-58d808477e33', 'dr.samuel.garibay@laboratorios.org', '$2b$12$kYe9jegNaqRo8nXIR3u7fu3OKxZjAvQx3T./Rj8HZOKwuHdLrk362', 'doctor', 'e901dbc1-3eed-4e5e-b23c-58d808477e33', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.joaquin.vigil@industrias.com
-- Password (plain text): _pRDk8%kv5%Z
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('61bb20b9-7520-42be-accf-743c84a0b934', 'dr.joaquin.vigil@industrias.com', '$2b$12$qUtXtJ1H7lPo6qY22LrMjuw0Wtw0ttxREjvD3Tl19fj65NOPkvgTK', 'doctor', '61bb20b9-7520-42be-accf-743c84a0b934', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.amador.arenas@collazo.org
-- Password (plain text): 5&)D7m_P@*7B
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b5a04df6-baea-460f-a946-f7b7606c9982', 'dr.amador.arenas@collazo.org', '$2b$12$7QuF/uy/nh28bQOk.Rr4EuVgYNotmThCTtXQe5lLIkAGpsqLwQfVW', 'doctor', 'b5a04df6-baea-460f-a946-f7b7606c9982', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.felipe.hidalgo@laboratorios.com
-- Password (plain text): 5!$5KEavPhKn
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c1182c2e-0624-42f9-aef6-7e7a1a2b7dba', 'dr.felipe.hidalgo@laboratorios.com', '$2b$12$fvEw4/cYcwDaM6gNlT0L/.CTzuxVzxUVkhmGberO11sXOml6Jo8im', 'doctor', 'c1182c2e-0624-42f9-aef6-7e7a1a2b7dba', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.mariateresa.baca@corporacin.biz
-- Password (plain text): #rI+9(fH6H)s
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0b238725-a392-4fbb-956b-0f71e15bc6da', 'dr.mariateresa.baca@corporacin.biz', '$2b$12$0ChZ868tlW840NqCG8Yz.eQOWIEN6ZLfPrgAsGAddzuVnItnataom', 'doctor', '0b238725-a392-4fbb-956b-0f71e15bc6da', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.miguelangel.perez@proyectos.com
-- Password (plain text): 64B_jg*eZf*P
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('63ec3e7d-b8e4-4988-9bc3-5b655f830e31', 'dr.miguelangel.perez@proyectos.com', '$2b$12$JqhEAEjPEJojUMLWcsJ4fOZ7tSQGVp81LCAOMRa3qSj.OyNkQeBKO', 'doctor', '63ec3e7d-b8e4-4988-9bc3-5b655f830e31', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.jonas.madera@villareal-cardenas.com
-- Password (plain text): 6%cU2KnuQ2t@
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d4df85ce-6d2b-46c9-b9cd-48b2490b3c88', 'dr.jonas.madera@villareal-cardenas.com', '$2b$12$tfkU68AM.4saWHvEI.9vqOpD7XizrHvl9Ecg/EXjsNMH7IV3a7Nsi', 'doctor', 'd4df85ce-6d2b-46c9-b9cd-48b2490b3c88', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.arcelia.delarosa@ramon.info
-- Password (plain text): @nOE8CJES1Bk
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('71618fe0-25a1-4281-98af-51797de3ae0a', 'dr.arcelia.delarosa@ramon.info', '$2b$12$4ldVB8AEpkSycLsOViLS7ebeVZjk1RpiHkE9SpW49IQzxPwDCJqRm', 'doctor', '71618fe0-25a1-4281-98af-51797de3ae0a', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.esther.echeverria@armendariz.com
-- Password (plain text): l8x%*$vu$RMA
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('389524b6-608c-4b31-affa-305b79635816', 'dr.esther.echeverria@armendariz.com', '$2b$12$czdXhzoReNZIvgfp0ie4xOCuc4xnjvxu1BSov3Hbsafdw7H5U92Y2', 'doctor', '389524b6-608c-4b31-affa-305b79635816', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.sofia.montez@farias.org
-- Password (plain text): JSG&gkV2)#3Y
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c0356e82-1510-4557-b654-cf84ac13f425', 'dr.sofia.montez@farias.org', '$2b$12$81YnKW5tYrDfltuJHLwZSeHspzsI/z3893kcxymK9F3PRgg79vNAC', 'doctor', 'c0356e82-1510-4557-b654-cf84ac13f425', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.debora.segura@grupo.org
-- Password (plain text): gUR)0!eT%7k%
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ce44b08f-7dae-4844-ae53-e01ac2f28f45', 'dr.debora.segura@grupo.org', '$2b$12$M8K2Su3.ubRQmsxDO1kq8uDPBdfAw3/EQ/NqeKkfR1pQXNLipq7Ui', 'doctor', 'ce44b08f-7dae-4844-ae53-e01ac2f28f45', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.luismiguel.villarreal@de.info
-- Password (plain text): yGhN*Y@w5yH&
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('9c9838c2-4464-4fbb-bc22-8f4ac64b4efe', 'dr.luismiguel.villarreal@de.info', '$2b$12$KmrjbO2yKZ5icJmpDP1fMu5Tb7B8gB.RxAfs7vYJqktRL1agd8uTy', 'doctor', '9c9838c2-4464-4fbb-bc22-8f4ac64b4efe', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.esmeralda.parra@limon-dominguez.info
-- Password (plain text): !jtM#ejq1i7E
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('e8db5b49-5605-41e5-91f2-d456b68c5ade', 'dr.esmeralda.parra@limon-dominguez.info', '$2b$12$8QzKKym5yU7sgMEVCcXvcOth0ATGoiaT6zDEGP/mQvLVdJYTzsUB6', 'doctor', 'e8db5b49-5605-41e5-91f2-d456b68c5ade', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.patricia.tellez@corporacin.com
-- Password (plain text): (W(GFERp@6*1
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('96d6da02-ca2f-4ace-b239-4584544e8230', 'dr.patricia.tellez@corporacin.com', '$2b$12$D6uvueeJtNlZAen5.4hbfuK5aLlBM/JYVou5JYpO/SQEL5RNJVjs6', 'doctor', '96d6da02-ca2f-4ace-b239-4584544e8230', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.timoteo.tafoya@chapa-zamudio.biz
-- Password (plain text): z+qu*RHtO2jf
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('38bf2ce6-5014-4bc1-8e32-9b9257eea501', 'dr.timoteo.tafoya@chapa-zamudio.biz', '$2b$12$TiiLJQ9gAFNrLdWsEKz84.UY9tuz5bkU.RwkIKyaDEerl43SEPUmy', 'doctor', '38bf2ce6-5014-4bc1-8e32-9b9257eea501', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.amanda.ferrer@laboratorios.org
-- Password (plain text): 7opGvJ7i+!p9
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c', 'dr.amanda.ferrer@laboratorios.org', '$2b$12$PmgOchNQV2H/7Ds4mj2gsu0FDT8l50t64u6Z.woaqyWUOB/lwaC6e', 'doctor', 'e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.caridad.villa@club.com
-- Password (plain text): wIGeYXB8dI1!
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('8ce8b684-8f8d-4828-987d-389dfe64afd1', 'dr.caridad.villa@club.com', '$2b$12$SidH9U8lkm1wEgq0KeJBPuKSVfvmzsX103uRVxlYHRSvxhaJjb5ui', 'doctor', '8ce8b684-8f8d-4828-987d-389dfe64afd1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.hector.castro@segovia.info
-- Password (plain text): &R0RvGeUj99M
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ca8bf565-35d3-40f3-b741-603201f6f072', 'dr.hector.castro@segovia.info', '$2b$12$9ojLbm23IosjR0adRVhuouEnm3YhF5W3.E.uceLfdpvPa3GowxTTu', 'doctor', 'ca8bf565-35d3-40f3-b741-603201f6f072', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.abraham.rodarte@despacho.net
-- Password (plain text): Xh#7mQNk6g*A
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('2937cc2f-22b7-4488-b9f8-a0795800a840', 'dr.abraham.rodarte@despacho.net', '$2b$12$wojt2veDBSWyGSLK/fofdON/Fh31l4rveywRH4h4Go3Btbb.XaUOe', 'doctor', '2937cc2f-22b7-4488-b9f8-a0795800a840', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.gloria.briones@grupo.info
-- Password (plain text): !eFX9aIuYEOU
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f8a511e3-b97b-4d17-8240-46520497ef7c', 'dr.gloria.briones@grupo.info', '$2b$12$qXTZnGU.uf5L8Dbc6Qsc4.YEhbzHmaEq1kjKwzNxOTqpXhCLURWLq', 'doctor', 'f8a511e3-b97b-4d17-8240-46520497ef7c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.joseluis.bahena@solano.com
-- Password (plain text): I&9$21Yu*L%2
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('879bcb9a-8520-4d02-b12b-ba5afa629d41', 'dr.joseluis.bahena@solano.com', '$2b$12$XVMQUIJZSEtz5LYU.a3l9uD18Tqtu4fdr3LUkedTqtRQHQafvaJga', 'doctor', '879bcb9a-8520-4d02-b12b-ba5afa629d41', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.daniela.laboy@urrutia-resendez.org
-- Password (plain text): $N6VMGjsGrD7
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('7817761a-e7c5-47cb-a260-7e243c11ef2f', 'dr.daniela.laboy@urrutia-resendez.org', '$2b$12$/NhnYpwd2ph3druQrCe7AOWAOgFll1I1/rgsiIiXTYoHcDNx8EB1S', 'doctor', '7817761a-e7c5-47cb-a260-7e243c11ef2f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.bruno.ledesma@florez-mojica.com
-- Password (plain text): 8qiAyQut@DFW
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('48384f36-0b57-4943-899f-cbffd4ec37b6', 'dr.bruno.ledesma@florez-mojica.com', '$2b$12$kNIKYVPjsWCoerlozFxf6uU7ydN7KpyR4ssHAtEKrpV/OdOt3dgT2', 'doctor', '48384f36-0b57-4943-899f-cbffd4ec37b6', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.noelia.garica@proyectos.com
-- Password (plain text): 5lTBsYYy+HD5
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0fc70684-777f-43eb-895d-9cb90ce0f584', 'dr.noelia.garica@proyectos.com', '$2b$12$EC2kvLUq5CTIpDpr/pVLGunmHwYqZxBxPU.sz.azUbdzS4/fz5wXi', 'doctor', '0fc70684-777f-43eb-895d-9cb90ce0f584', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.mitzy.godoy@bernal.com
-- Password (plain text): xV(o2Fsk5ay@
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a849f14b-3741-4e38-9dfb-6cc7d46265e8', 'dr.mitzy.godoy@bernal.com', '$2b$12$kkrDT66CxruJyvq2IR0HhurcOK8NeUUBreaypzCKS8.FgAduPh6tS', 'doctor', 'a849f14b-3741-4e38-9dfb-6cc7d46265e8', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.sessa.medina@holguin.com
-- Password (plain text): V7P_FR196yiM
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('22128ae9-ba6e-4e99-821a-dc445e76d641', 'dr.sessa.medina@holguin.com', '$2b$12$ToXfetD2DW0Gj33D457mmeDHqzYmuKBTEDEE/7gK162mWe6Iw6L7C', 'doctor', '22128ae9-ba6e-4e99-821a-dc445e76d641', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.mitzy.aguayo@despacho.biz
-- Password (plain text): L29qNiFc7a@5
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6c711a31-c752-44f2-b6cb-480f9bf6af1f', 'dr.mitzy.aguayo@despacho.biz', '$2b$12$0KdgU/lTViO8H/A2gaHOweDdAWlNjA03/wEf/h6uE5yLMsXvjH5uq', 'doctor', '6c711a31-c752-44f2-b6cb-480f9bf6af1f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.patricio.monroy@aguirre-bernal.com
-- Password (plain text): _wejQh99LJ&0
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ab923e2e-5d13-41e4-9c73-2f62cca0699d', 'dr.patricio.monroy@aguirre-bernal.com', '$2b$12$wBsZHlOMRwr8F79uC/dpSOizAe85IKg9zv3Bem3jdgp/VdblPcehC', 'doctor', 'ab923e2e-5d13-41e4-9c73-2f62cca0699d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.homero.valentin@olivares.com
-- Password (plain text): Hr$B6YkC+2Qj
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a7f19796-4c62-4a2b-82de-7c2677804e6a', 'dr.homero.valentin@olivares.com', '$2b$12$5fxkyIB2L2M9IrcM8XM0U.OX1qlo74oqBYSegW9fGepO4O3o2pyYC', 'doctor', 'a7f19796-4c62-4a2b-82de-7c2677804e6a', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.porfirio.farias@despacho.com
-- Password (plain text): %@PYOhyZ_$0_
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('28958f29-28c6-405a-acf5-949ffcaec286', 'dr.porfirio.farias@despacho.com', '$2b$12$LcMz8484Vid6L71OZFcn3u4YefbYyEBcPJMuETNQbKq60sDeLGZEW', 'doctor', '28958f29-28c6-405a-acf5-949ffcaec286', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.gonzalo.cortes@yanez.com
-- Password (plain text): gUyZdBe2%4pU
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('472116b5-933e-4f63-b3ca-e8c8f5d30bb4', 'dr.gonzalo.cortes@yanez.com', '$2b$12$UaWbi42xAp.Ic6sIA6OIhu0agecs1.iSRdRAwVxFztNNB9JiUev.e', 'doctor', '472116b5-933e-4f63-b3ca-e8c8f5d30bb4', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.marisol.tello@navarrete-leon.com
-- Password (plain text): ajl%S2ZdB#4&
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a2beaa02-c033-4e45-b702-305d5ce41e34', 'dr.marisol.tello@navarrete-leon.com', '$2b$12$EqojBayPxXzsjgOLUGiiMeXqsSNnzM/0aVu.hFdpn/.7sCf9Qkeae', 'doctor', 'a2beaa02-c033-4e45-b702-305d5ce41e34', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.mateo.serrato@laboratorios.biz
-- Password (plain text): XnsAK22bj*6v
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5879ec30-c291-476d-a48c-284fadf5f98a', 'dr.mateo.serrato@laboratorios.biz', '$2b$12$8CqExPdUaB9jl3rUovrjz.L6IDBnaHZV5/RFVGCSezYoRMfrEfpPm', 'doctor', '5879ec30-c291-476d-a48c-284fadf5f98a', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.reina.camacho@colunga.info
-- Password (plain text): !i%PaVCuuJx9
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d512bd88-12a3-45f9-85e8-14fb3cb5a6e1', 'dr.reina.camacho@colunga.info', '$2b$12$QSK5/MZXG1/YJsYGZ5h8huZosUr4jiqH5moyEa.ynSGIouefEpHhm', 'doctor', 'd512bd88-12a3-45f9-85e8-14fb3cb5a6e1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.homero.rodarte@alva-quintanilla.com
-- Password (plain text): $4I+Sz9)DFCp
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('757d6edf-5aa8-461b-ac4f-9e8365017424', 'dr.homero.rodarte@alva-quintanilla.com', '$2b$12$.0/8Q5/HAD2Wx2SQu5Ptk.IVKUt87gxVRY.URHb2k5aYUYf43DAIm', 'doctor', '757d6edf-5aa8-461b-ac4f-9e8365017424', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.martin.trevino@espinoza-pineda.info
-- Password (plain text): &9qpkRC)ohSr
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c0d54a00-2ee9-4827-a7fb-6196ef15bdee', 'dr.martin.trevino@espinoza-pineda.info', '$2b$12$93F7TFFHo25gcTFcfVHksuy9RkxN1zV2uas7ONgAE3G1MX2DVIkJa', 'doctor', 'c0d54a00-2ee9-4827-a7fb-6196ef15bdee', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.wilfrido.salazar@arenas-campos.net
-- Password (plain text): &$5Kdret2v1@
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a7ada88a-7935-4dd5-8a4f-935c4b7c0bab', 'dr.wilfrido.salazar@arenas-campos.net', '$2b$12$LSpdN3H4mgKs1No4xb4YxOmUoik62/nIS2mMDLMoH5ZkwsUrjXfUW', 'doctor', 'a7ada88a-7935-4dd5-8a4f-935c4b7c0bab', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.uriel.velazquez@zedillo-camarillo.net
-- Password (plain text): n#1OQqNr%mK9
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('4664d394-c950-4dbf-9b40-7b34c6d6dabb', 'dr.uriel.velazquez@zedillo-camarillo.net', '$2b$12$nYQWx2tmrEdiG1lSx7DL8eKHAlWwpgTkTPDwxZyS4gPTYUzehm0Gi', 'doctor', '4664d394-c950-4dbf-9b40-7b34c6d6dabb', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.jos.briones@robledo.com
-- Password (plain text): pA0MGzt6hF$Q
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c16b254c-dcf7-4a31-a101-1ed86b62477e', 'dr.jos.briones@robledo.com', '$2b$12$k6eDfUVNbdUxCf6U.nn7MOC3WDOu9K.K61dLdq07aSpKR4ud/NPIa', 'doctor', 'c16b254c-dcf7-4a31-a101-1ed86b62477e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.david.dominguez@maya.com
-- Password (plain text): Wh2WVMzB#zw5
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('e0926c16-7f63-41ae-a091-1d0688c88322', 'dr.david.dominguez@maya.com', '$2b$12$lC9L.SCibUCPnGEHFFK5BePrYfh/GpYRHUA2gb1XwE4qVT1yelYhe', 'doctor', 'e0926c16-7f63-41ae-a091-1d0688c88322', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.adan.ferrer@corporacin.info
-- Password (plain text): GbJ_7TQm+sb#
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('250b33c9-1ba3-44e6-9c35-cde7000d6d53', 'dr.adan.ferrer@corporacin.info', '$2b$12$kBFhPMqd2uT39OZAWWJlsOtBFvyv/2iPt4s22plqGLfZ9YIwEK1ma', 'doctor', '250b33c9-1ba3-44e6-9c35-cde7000d6d53', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.irene.cisneros@saucedo.com
-- Password (plain text): &xjD4Oq2^_#*
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b6c86aef-75e2-4c64-bceb-e7de898b5a1b', 'dr.irene.cisneros@saucedo.com', '$2b$12$nZYwBKlNbv82ZsGd9K1sR.kRCaGPHIjbO0k3gsopcRk3W1aTsqDvq', 'doctor', 'b6c86aef-75e2-4c64-bceb-e7de898b5a1b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.altagracia.orellana@barela.com
-- Password (plain text): #@99bkZXj6%N
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a3fb2dae-2a69-434f-86a9-65ae48c8f690', 'dr.altagracia.orellana@barela.com', '$2b$12$vAugJVBLlrv1tt7hroC/eeUTPIp3PSPW/gTQ2lffMW6S.QwsKTZUW', 'doctor', 'a3fb2dae-2a69-434f-86a9-65ae48c8f690', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.cristal.balderas@ozuna.com
-- Password (plain text): 2DJ*p+nf!2lM
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('820c1228-3d2d-4766-900f-32940f14e74b', 'dr.cristal.balderas@ozuna.com', '$2b$12$TO7PQDr1JIXp8ZlLUMmkp.x2WvuWhfzNpaSgJuPzZEcFCCsJaxi42', 'doctor', '820c1228-3d2d-4766-900f-32940f14e74b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.marisol.ulloa@vazquez-santillan.info
-- Password (plain text): N$%MWgRqYd0s
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('da3dbacf-8df0-46cf-bbef-b51615063a9b', 'dr.marisol.ulloa@vazquez-santillan.info', '$2b$12$j4VqEl4LOvLQ265tTuIMI.HY2fRA64NkClM0WX6h9aGdSeeykAgZa', 'doctor', 'da3dbacf-8df0-46cf-bbef-b51615063a9b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.alfonso.cazares@nava-soto.com
-- Password (plain text): 6C%Fwjh+(GxE
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('e6ce6823-6c4d-4ead-98d7-78b94483fe2c', 'dr.alfonso.cazares@nava-soto.com', '$2b$12$ynAZUvMrN40R6VzVXhPLc.BKfqyZkPUBxdC7pQI06WbANZQ1tCxXW', 'doctor', 'e6ce6823-6c4d-4ead-98d7-78b94483fe2c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.elisa.oquendo@despacho.com
-- Password (plain text): ((@OWvwXkck7
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('84cb6703-edfc-4180-9f80-619064c9684e', 'dr.elisa.oquendo@despacho.com', '$2b$12$urpK462tn0oaCJhfQR2h8eHANA/pqUyLrQu/W0w.Git54YBlUvoE.', 'doctor', '84cb6703-edfc-4180-9f80-619064c9684e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.silvano.brito@despacho.com
-- Password (plain text): ym*H6cHJI!(I
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('21e4d7a9-73dc-4156-b413-b389c2e92a0d', 'dr.silvano.brito@despacho.com', '$2b$12$1Knk4A10Q.Dix8CsxMitOulzYwaQIMJNHKcNxgW5./2OT0XIOlvBq', 'doctor', '21e4d7a9-73dc-4156-b413-b389c2e92a0d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.ursula.casares@vega-montalvo.com
-- Password (plain text): YY3*bWE*SA7J
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('85eb8041-b502-4b90-b586-c7c4593b5347', 'dr.ursula.casares@vega-montalvo.com', '$2b$12$aj/01O7De69NPWpcTEydQO2OEyKjhnmOjqeS0zqdWsVOKXJ22hw0O', 'doctor', '85eb8041-b502-4b90-b586-c7c4593b5347', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.marcela.corona@marroquin-cardenas.org
-- Password (plain text): _RGGh)nvI84v
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9', 'dr.marcela.corona@marroquin-cardenas.org', '$2b$12$6m/D7h4BG1QYs8.kmuo58uP2T/TmARGqTOiDOnT3j2f9y7cyBQrd2', 'doctor', 'c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.catalina.orta@padilla.com
-- Password (plain text): 6MlYaAu1y@a0
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('22d570dd-a72e-4599-8f13-df952d35d616', 'dr.catalina.orta@padilla.com', '$2b$12$3jjzBjzGDadfobjRvu/HYOP8aLuMkgGCbrgDsfTjT1haIP.3UJ7Vi', 'doctor', '22d570dd-a72e-4599-8f13-df952d35d616', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.rene.morales@matos.org
-- Password (plain text): 6sUIHHeQ^6RH
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('04a9b2e7-638b-4fe0-a106-16b582d946ab', 'dr.rene.morales@matos.org', '$2b$12$.C9kSIW1Gy1StVUGtMBONueMbFvHnW43RPX/j8BrhWHHsc6S6Rfzu', 'doctor', '04a9b2e7-638b-4fe0-a106-16b582d946ab', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.benjamin.leal@industrias.com
-- Password (plain text): YK3LOfDc_s2Y
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('03e547d1-325a-46ea-bc94-c188abf53f0f', 'dr.benjamin.leal@industrias.com', '$2b$12$HJ3DYy12yj7RzG0X61u1bOFrHl3Lprd/EUnz1SNYOZYnJYdfdasKq', 'doctor', '03e547d1-325a-46ea-bc94-c188abf53f0f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.catalina.alarcon@jimenez.org
-- Password (plain text): rNsQErH97MW+
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5a6de593-99b5-4942-a379-fd21b2a4999f', 'dr.catalina.alarcon@jimenez.org', '$2b$12$ft3VdymT68IY4rElyV94NOX2GBTBG/rnhYt44DyIGC0qOdYHC40L6', 'doctor', '5a6de593-99b5-4942-a379-fd21b2a4999f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.pedro.riojas@tellez-rincon.com
-- Password (plain text): f5Hi1Q9T(qCi
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b7dd043b-953f-4e04-8a80-1c613d3c6675', 'dr.pedro.riojas@tellez-rincon.com', '$2b$12$I07P/0e4a.AWH3xllnpq3.Vpuz44KWMCFvf7lz1nNQ5hBDqqqWJWO', 'doctor', 'b7dd043b-953f-4e04-8a80-1c613d3c6675', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.olivia.nieto@laboratorios.com
-- Password (plain text): _NXeQ&pLHU_0
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('852beb97-3c99-4391-879f-98f0c2154c20', 'dr.olivia.nieto@laboratorios.com', '$2b$12$6mFyAS/XbjZxnAqIIOo4YeY2Fpou3ldqJSoEMUCEBCs6dc46kp6jO', 'doctor', '852beb97-3c99-4391-879f-98f0c2154c20', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.victoria.corona@cadena.net
-- Password (plain text): czZ@5xRvMe8(
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('86bb4262-7a96-444b-a096-d3a1bd7782e7', 'dr.victoria.corona@cadena.net', '$2b$12$XkuDLSuNLhE7XaNBDgjTJOYutbnlMqdW1ymqkMlbMmZT6LqSTLoYa', 'doctor', '86bb4262-7a96-444b-a096-d3a1bd7782e7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.daniela.gallegos@villalpando-chapa.com
-- Password (plain text): Kj(w4yt_1*0U
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b441c98a-1075-4013-9fc2-9242d910713f', 'dr.daniela.gallegos@villalpando-chapa.com', '$2b$12$tj7u2nRfzHoQw6CgbnaRK.QWjOTMoPvoYkuvLr2D1l4ru53W4l6oW', 'doctor', 'b441c98a-1075-4013-9fc2-9242d910713f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.victoria.urbina@corporacin.com
-- Password (plain text): P&WZkfDjlh6E
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('77486cf8-54d8-4120-856f-642ebae74d48', 'dr.victoria.urbina@corporacin.com', '$2b$12$YQtGaEnyHtJhZMN13e37CuyjUvpFBOx3DlCGoZJwZtS/RITeTGQlK', 'doctor', '77486cf8-54d8-4120-856f-642ebae74d48', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: dr.leonardo.aguirre@arroyo.biz
-- Password (plain text): +_j0Oh!(7h%R
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0e2fa589-05b2-402c-9722-1022a0121b04', 'dr.leonardo.aguirre@arroyo.biz', '$2b$12$XMB/DkPdOfbhMYA3XdLheO0pg1rpIbRSlPRx8a8e68yumdHoH2L6m', 'doctor', '0e2fa589-05b2-402c-9722-1022a0121b04', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: linda.najera.1967@escobar.biz
-- Password (plain text): $0(iyQIu%2$e
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('2f5622af-8528-4c85-8e16-3d175a4f2d15', 'linda.najera.1967@escobar.biz', '$2b$12$Nt.znNV.HgD4TdFYVCbSIu1f5yyKKUqNBF5d8ptbmHG6Z4f9J19fy', 'patient', '2f5622af-8528-4c85-8e16-3d175a4f2d15', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: marisela.rocha.1971@industrias.biz
-- Password (plain text): +&BLcTnb08C%
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c', 'marisela.rocha.1971@industrias.biz', '$2b$12$X7vTY1yXEW.h6/E9vlRkU.A3/VR1gcykgSn7IQf/s1TZHd80lwJHq', 'patient', 'fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: homero.miranda.1976@ontiveros.net
-- Password (plain text): HndhdjnQ*3Qs
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('959aa1dd-346b-4542-8f99-0d5e75301249', 'homero.miranda.1976@ontiveros.net', '$2b$12$gK6jnqDXB6Pd3Kvm.9ZUX.BpBwOLvCwXY6gbn8Z5aoxfaub4aKleu', 'patient', '959aa1dd-346b-4542-8f99-0d5e75301249', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: manuel.vela.1989@armendariz.com
-- Password (plain text): 20F0vPgX*CUB
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('59402562-ce5f-450e-8e6c-9630514fe164', 'manuel.vela.1989@armendariz.com', '$2b$12$H2ecF1V/7XD7AFPoQ2hvnO9frxeXZQW.X6S.ozIN6zxX5SXZs/FGa', 'patient', '59402562-ce5f-450e-8e6c-9630514fe164', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: paulina.cervantez.1975@pedraza.biz
-- Password (plain text): )AqdfhkFx8Em
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f81c87d6-32f1-4c79-993a-18db4734ef65', 'paulina.cervantez.1975@pedraza.biz', '$2b$12$0H4Ob91SXqJ5b1hZF6mmxe4YXSElV1P2b2CJzUjaQFbJLAaZ1u4Iq', 'patient', 'f81c87d6-32f1-4c79-993a-18db4734ef65', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: benjamin.serna.1972@grupo.com
-- Password (plain text): 9N_V+_Cu^@wM
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0b6b8229-4027-4ec7-8bce-c805de96ced3', 'benjamin.serna.1972@grupo.com', '$2b$12$7kdF4a3u/fR50FSZhBUjEO2FVKqlMNvfxH8j.H3sQWcH6sxKZpHoa', 'patient', '0b6b8229-4027-4ec7-8bce-c805de96ced3', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: rosa.galvez.1962@rosas-urrutia.info
-- Password (plain text): )D5&Yc*0655x
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', 'rosa.galvez.1962@rosas-urrutia.info', '$2b$12$lHxIfC67wWOq/gvR722iye95CvIikBWjie5W7ckSn0nZXixvcpdYi', 'patient', 'f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: nelly.montemayor.1991@tafoya-cervantes.biz
-- Password (plain text): !W%ijHbi7I9N
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f2a1f62a-8030-4f65-b82d-ce7376b955bd', 'nelly.montemayor.1991@tafoya-cervantes.biz', '$2b$12$GHQ5RcJQlXWZ5HO9HPxU7OppUWgLKpkhjxRheCFvoKykTwryvIyme', 'patient', 'f2a1f62a-8030-4f65-b82d-ce7376b955bd', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: rolando.jaimes.1994@matias.org
-- Password (plain text): E%iXCvM5#_36
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0104fea2-d27c-4611-8414-da6c898b6944', 'rolando.jaimes.1994@matias.org', '$2b$12$NKQVWj.CoTvK.8JL1SUAx.RpBrsB4fABdx3s/a3sn7GNpZlIAXmG6', 'patient', '0104fea2-d27c-4611-8414-da6c898b6944', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: bruno.urena.1966@solorio-murillo.com
-- Password (plain text): ifPGge0*h*6T
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('cd0c2f0c-de08-439c-93c9-0feab1d433cc', 'bruno.urena.1966@solorio-murillo.com', '$2b$12$yMT5GpTRNDMX1U.vzKv7c.VQbG6AhYXGUMKOM/DrT/ecN09jh.ndm', 'patient', 'cd0c2f0c-de08-439c-93c9-0feab1d433cc', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: luismanuel.morales.1956@cordero-meza.com
-- Password (plain text): +U&^P7h5!16e
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', 'luismanuel.morales.1956@cordero-meza.com', '$2b$12$pzXpSQI0KQhbi0dXCsZWYON8A0MCOBmJH2ORgEHvjcOi0cmNoT8yC', 'patient', '7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: david.benavidez.1953@proyectos.org
-- Password (plain text): y!K09YyPt322
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('7893292b-965a-41da-896a-d0780c91fdd5', 'david.benavidez.1953@proyectos.org', '$2b$12$6TP3EsgQ18Y1Alwfs9PzVeyK4vjw.TORf5arMY7iUCDEJQyC5FXW6', 'patient', '7893292b-965a-41da-896a-d0780c91fdd5', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: clara.pelayo.1954@aparicio-ceballos.com
-- Password (plain text): wJ5OXwMaM$$b
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('87fb3c88-6653-45db-aa6c-20ea7512da64', 'clara.pelayo.1954@aparicio-ceballos.com', '$2b$12$8xLzsHWm237MYnPgT0cHOugOkUEU.YCDEpQTobE5/pJrAt6XLyaKe', 'patient', '87fb3c88-6653-45db-aa6c-20ea7512da64', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: santiago.armendariz.2001@industrias.com
-- Password (plain text): NAZPR5HgOi^(
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('05e42aed-c457-4579-904f-d397be3075f7', 'santiago.armendariz.2001@industrias.com', '$2b$12$5p7X0Lwguffa.wL.qLZtzOjtdoyADGX2b2LUBWF6X3Dovi5unGLYC', 'patient', '05e42aed-c457-4579-904f-d397be3075f7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: carlos.menchaca.1949@camacho-saenz.info
-- Password (plain text): 1L26SiModP#x
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('43756f6c-c157-4a44-9c84-ab2d62fddcf7', 'carlos.menchaca.1949@camacho-saenz.info', '$2b$12$tLWqkoczWaGSODgiqCo9HuR1P..acGPoIWNi8I6ROYFhI1WkMb.iO', 'patient', '43756f6c-c157-4a44-9c84-ab2d62fddcf7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: manuel.gracia.1978@grupo.net
-- Password (plain text): )k7rQnvT4%EF
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d8e1fa52-0a65-4917-b410-2954e05a34e5', 'manuel.gracia.1978@grupo.net', '$2b$12$Vhuh94P0bYjISvXH/5uPRukNvoP4YLqLOxFzPJv1c6hOGfic/196e', 'patient', 'd8e1fa52-0a65-4917-b410-2954e05a34e5', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: jos.perea.2000@corporacin.com
-- Password (plain text): 5sHFsai1)MAD
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('bbc67f38-a9eb-4379-aeaf-1560af0d1a34', 'jos.perea.2000@corporacin.com', '$2b$12$nKazE0EjG6dGyG7/YarvhuvU/JO6VzjsGumlTVqyiOYexqp7y8QKm', 'patient', 'bbc67f38-a9eb-4379-aeaf-1560af0d1a34', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: esparta.franco.1987@proyectos.com
-- Password (plain text): b&9mLx(HvB5J
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e', 'esparta.franco.1987@proyectos.com', '$2b$12$Dva4Hy9RwX/Naq8zMUcMlOaKBar1qxtkmLfwdPyUgsJnj/dYTSY6W', 'patient', 'b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: joseluis.miramontes.1951@gaytan.biz
-- Password (plain text): 7tL&ihzn)_5E
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('309df411-1d1a-4d00-a34e-36e8c32da210', 'joseluis.miramontes.1951@gaytan.biz', '$2b$12$hB3uNAPqLNn/rxooBvy97eH3tUIwXY3//3oWxyiTJZOswxzO81oim', 'patient', '309df411-1d1a-4d00-a34e-36e8c32da210', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: amalia.arenas.1975@alfaro.com
-- Password (plain text): ^ry9NddlA15G
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('663d036b-a19b-4557-af37-d68a9ce4976d', 'amalia.arenas.1975@alfaro.com', '$2b$12$gdO6Dmc74xfcoIbfvonZqu9RAiNUMkPU4UQTAAiY4VlM2MlBnCex6', 'patient', '663d036b-a19b-4557-af37-d68a9ce4976d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: angelica.serrato.1960@lozano.org
-- Password (plain text): *1exV^_X4jNg
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a754cbf1-a4ca-42dc-92c4-d980b6a25a6d', 'angelica.serrato.1960@lozano.org', '$2b$12$WXcrsynCF56dVATGMDCVl.5LhAb59qHrXFc6zHxMcuOwq1EjPI7Di', 'patient', 'a754cbf1-a4ca-42dc-92c4-d980b6a25a6d', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: pascual.barragan.1977@valdivia-briseno.net
-- Password (plain text): %Hvl42PmKXk5
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d5b1779e-21f2-4252-a421-f2aaf9998916', 'pascual.barragan.1977@valdivia-briseno.net', '$2b$12$TC3xoFIdpDL8rJ./LEOdk.qy4955Yo9SlgyeiP2tCJIfoPy14KKO.', 'patient', 'd5b1779e-21f2-4252-a421-f2aaf9998916', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: jesus.abreu.1955@moya-mares.com
-- Password (plain text): $28FfvAMl5dE
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6661483b-705b-412a-8bbd-39c0af0dadb1', 'jesus.abreu.1955@moya-mares.com', '$2b$12$Nuph7a7c75pO4RLOZeor2uZHdmgd.CBoVVbkV9Wnv6xE4ro12DaxW', 'patient', '6661483b-705b-412a-8bbd-39c0af0dadb1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: victor.espinosa.1988@grupo.biz
-- Password (plain text): IVSd9Ypv(P6J
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('676491c4-f31a-42b6-a991-a8dd09bbb1f0', 'victor.espinosa.1988@grupo.biz', '$2b$12$OcEcssALSOYBDcC27KOBq.mEeiltQ8beedzla1Tg6KNkc2mKOg.2W', 'patient', '676491c4-f31a-42b6-a991-a8dd09bbb1f0', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: mariajose.villasenor.1949@montenegro.com
-- Password (plain text): SVlVPi!Q@Ol5
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3a9e8e0e-6367-409d-a81c-9852069c710e', 'mariajose.villasenor.1949@montenegro.com', '$2b$12$6pSdrDX4Vd1YxEVG.WJEaeSMfEmAajIz49KyAn.663NYJvHj2a1Rm', 'patient', '3a9e8e0e-6367-409d-a81c-9852069c710e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: camilo.villa.1998@proyectos.org
-- Password (plain text): $Od7Qx1w!WbE
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('167dedde-166c-45e4-befc-4f1c9b7184ad', 'camilo.villa.1998@proyectos.org', '$2b$12$hONL.eW.I2tIw9MtwgzjCOwAhNkaUXXwVi/vk7NzrcuHhR7CXOQpa', 'patient', '167dedde-166c-45e4-befc-4f1c9b7184ad', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: mario.santillan.1966@coronado.info
-- Password (plain text): 0fWbXfQwLM)4
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('72eca572-4ecf-4be8-906b-40e89e0d9a08', 'mario.santillan.1966@coronado.info', '$2b$12$cRt3WDnRZwkNJIJwKJLBY.PYBtSGGnloChEqUyCoeXfyNDDR71Cbq', 'patient', '72eca572-4ecf-4be8-906b-40e89e0d9a08', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: cristobal.paez.1961@godoy-grijalva.com
-- Password (plain text): xyK1XOIl_HcT
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d5bec069-a317-4a40-b3e8-ea80220d75de', 'cristobal.paez.1961@godoy-grijalva.com', '$2b$12$nQpbrBMCxo3qoY6cVoeY4epXXpJK4enZdOIbOFBXlpeepRhjWewCC', 'patient', 'd5bec069-a317-4a40-b3e8-ea80220d75de', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: celia.olivo.1961@vazquez.com
-- Password (plain text): *Xyakf^En!Y6
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0e97294d-78cc-4428-a172-e4e1fd4efa72', 'celia.olivo.1961@vazquez.com', '$2b$12$up6mnpmjQXyNnMViV9519.Ztix4fQOrLqgjKywp3PbpPj0FqHgtIO', 'patient', '0e97294d-78cc-4428-a172-e4e1fd4efa72', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: teresa.arguello.1949@jaime-aranda.com
-- Password (plain text): 6*52tI(r%4YG
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('9f86a53f-f0e1-446d-89f0-86b086dd12a9', 'teresa.arguello.1949@jaime-aranda.com', '$2b$12$jx3RLPegv7sjns0eq6BmGuCSuxIdMqEOOR2XGFvq6cZ7Rolgy0kfq', 'patient', '9f86a53f-f0e1-446d-89f0-86b086dd12a9', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: pilar.valle.1981@grupo.com
-- Password (plain text): 4e)RkAR0!1Fi
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ae1f5c92-f3cf-43d8-918f-aaad6fb46c05', 'pilar.valle.1981@grupo.com', '$2b$12$8o.477qCFdzu8/0TuGRmwu6AeiGdyDIyLd/mu2KM5gWHiHEOQFDwi', 'patient', 'ae1f5c92-f3cf-43d8-918f-aaad6fb46c05', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: eva.orellana.1988@proyectos.com
-- Password (plain text): q)9aBgWr0%4m
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d28440a6-3bd9-4a48-8a72-d700ae0971e4', 'eva.orellana.1988@proyectos.com', '$2b$12$q1dH7DmqOzf4MCEa5TzHAOSqfg9vnh/ybqcnXrpaJ.xfZqkL98ky.', 'patient', 'd28440a6-3bd9-4a48-8a72-d700ae0971e4', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: rafael.olvera.1946@proyectos.net
-- Password (plain text): F*3HlcKGJx2Y
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('7f839ee8-bdd6-4a63-83e8-30db007565e2', 'rafael.olvera.1946@proyectos.net', '$2b$12$k/Rq1mkfXac0w1ZmCeFUmuhdRpo2oRSw80bMg/k6Ua9lQDikG92Py', 'patient', '7f839ee8-bdd6-4a63-83e8-30db007565e2', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: anel.baeza.1997@aponte.com
-- Password (plain text): )fNt1(%9*17C
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('67aa999f-9d31-4b61-a097-35097ea0d082', 'anel.baeza.1997@aponte.com', '$2b$12$PfyOXs4etI0QybPEvGQ7QO7EO4AiAdtlQVZ3rOE4xuWdhNwcwt0la', 'patient', '67aa999f-9d31-4b61-a097-35097ea0d082', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: jesus.negron.1966@proyectos.com
-- Password (plain text): %_Qt*Y7i&kL1
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('41aa2fbc-8ef4-4448-8686-399a1cd54be9', 'jesus.negron.1966@proyectos.com', '$2b$12$kL5pbJ4t4nkTTjj0.xtoheDXgOQRJ9QeFf6l8goY6Y4asmxdM2N/q', 'patient', '41aa2fbc-8ef4-4448-8686-399a1cd54be9', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: asuncion.ybarra.2000@proyectos.com
-- Password (plain text): DQ7OY1xi(gtz
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('111769f3-1a1b-44a9-9670-f4f2e424d1d2', 'asuncion.ybarra.2000@proyectos.com', '$2b$12$dZDIN/RM1KwoPnWjPjEo1OwytPr5z7Bc3j.avyrwu2pa5mOMSb3QS', 'patient', '111769f3-1a1b-44a9-9670-f4f2e424d1d2', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: roberto.varela.1961@laboratorios.com
-- Password (plain text): uS@I%Eb9b92A
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', 'roberto.varela.1961@laboratorios.com', '$2b$12$qM31u8eTff2K9dhJnEXID.QMvac/Vqv.A8v1.Zll.mIJH/bqPAvF2', 'patient', '2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: alejandra.acosta.1950@laboratorios.com
-- Password (plain text): b)v2QJMu)EIH
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6a8b6d41-8d20-4bc5-8d48-538d348f6086', 'alejandra.acosta.1950@laboratorios.com', '$2b$12$ljD0OkxxO0qQnH6xk4XuCepG027YJZs/ccU6Wiu/PPXESfH0BvJj2', 'patient', '6a8b6d41-8d20-4bc5-8d48-538d348f6086', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: minerva.ortiz.1985@club.biz
-- Password (plain text): 9&Uxb0GG@CQu
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('89657c95-84c0-4bd0-80c6-70a2c4721276', 'minerva.ortiz.1985@club.biz', '$2b$12$nidwJfTFlRDT7pH7LEpfeO5gZoTba.79oa.rTEQBh0m5vT/Ez9kXW', 'patient', '89657c95-84c0-4bd0-80c6-70a2c4721276', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: amanda.menendez.1966@despacho.biz
-- Password (plain text): (2FCweONeSg)
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b6658dac-0ee1-415c-95ad-28c6acea85bd', 'amanda.menendez.1966@despacho.biz', '$2b$12$4LAYIKorYqdLglkvTg4y1u8RGYD9Zf6WUMfJrMadilC.mmLva7E1u', 'patient', 'b6658dac-0ee1-415c-95ad-28c6acea85bd', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: hermelinda.medrano.1970@grupo.net
-- Password (plain text): %yetG1C^O3aP
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('56564104-6009-466c-9134-c15d3175613b', 'hermelinda.medrano.1970@grupo.net', '$2b$12$nQ0cHxbLTc7L1KWSy2EOFukHSC/0OySjp4IfAMmAlPqAHbaztbW7K', 'patient', '56564104-6009-466c-9134-c15d3175613b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: alonso.roldan.1960@gamez.com
-- Password (plain text): ^u&Ek$tN!u7j
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('edb1d693-b308-4ff6-8fd4-9e20561317e8', 'alonso.roldan.1960@gamez.com', '$2b$12$Sf/XgqLOhx01z41RLSD1U.cMsPH.GUrEkslr03OxzE.ViIP8ArMFW', 'patient', 'edb1d693-b308-4ff6-8fd4-9e20561317e8', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: alma.sosa.2001@renteria.org
-- Password (plain text): @6YzPnz!aUr3
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('9511f9b9-a450-489c-92b9-ac306733cee4', 'alma.sosa.2001@renteria.org', '$2b$12$lK3OBSTndr8dOJ8k7U5/D.kad31vUKXvleCwlW6b/643F7xO9kX1e', 'patient', '9511f9b9-a450-489c-92b9-ac306733cee4', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: estela.lucero.1979@industrias.com
-- Password (plain text): o6n+0aO8KV#V
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('004ce58b-6a0d-4646-92c3-4508deb6b354', 'estela.lucero.1979@industrias.com', '$2b$12$Bchq/HjH52p1fpZpj75MG.zxxVGKL33cz9PdFahf0knbCx7oeW7nW', 'patient', '004ce58b-6a0d-4646-92c3-4508deb6b354', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: gonzalo.laureano.1979@llamas.info
-- Password (plain text): V7%VvKdHTQK!
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0d1bcc20-a5be-40f0-a28b-23c2c77c51be', 'gonzalo.laureano.1979@llamas.info', '$2b$12$/P8wOOTsUsygUgusXTozve9VNzy3uu1S42srIsgLL2lj/fM9OcCty', 'patient', '0d1bcc20-a5be-40f0-a28b-23c2c77c51be', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: helena.muro.1973@laboratorios.com
-- Password (plain text): LVvk0F_v6RE^
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('38000dbb-417f-43ca-a60e-5812796420f7', 'helena.muro.1973@laboratorios.com', '$2b$12$Hg6r9C3iehfIzQmdgAa4D.CKeZ2sOurRY.cQmqztnbxGMZia4LL6O', 'patient', '38000dbb-417f-43ca-a60e-5812796420f7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: adela.vergara.1991@lopez-gallardo.com
-- Password (plain text): n3$Bqof!)7Zc
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', 'adela.vergara.1991@lopez-gallardo.com', '$2b$12$muk8f.dQJpP4TENPMbhPtuTZd/MXw4MW5D3CSpBT5yAHT6fqG4jhS', 'patient', '5ae0a393-b399-4dc6-95d8-297d3b3ef0a8', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: salma.almaraz.1994@corporacin.com
-- Password (plain text): L7nsoUND22D*
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('561c313d-2c15-41b1-b965-a38c8e0f6c42', 'salma.almaraz.1994@corporacin.com', '$2b$12$AkLEd7GHn/GW3TyBV0Q88erW8a4CxSpfRKCAlSFXi4LW1yoHvLx3i', 'patient', '561c313d-2c15-41b1-b965-a38c8e0f6c42', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: humberto.caraballo.1946@grupo.com
-- Password (plain text): PvOf0Ct7Y#^r
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', 'humberto.caraballo.1946@grupo.com', '$2b$12$2kcZsd0hkJW8JMSOAVvE0uECm2h85TroCT7JGhDhkAlAzK6/ps.eO', 'patient', 'ba4b2a5b-887d-4f3d-8ec7-570cfe087b28', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: mauricio.zavala.1997@corporacin.com
-- Password (plain text): A#qAQb4k6)21
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', 'mauricio.zavala.1997@corporacin.com', '$2b$12$OclOCTuBaezeU2dBiwd3c.WXXqVRiyiMp/PO6Qk13h7qK0JJ6n/vu', 'patient', 'cbdb51c5-0334-4e15-b4b9-13b1de1c4c20', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: roberto.alejandro.1960@laboratorios.info
-- Password (plain text): )Ls8Adzc5$(x
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('05bc2942-e676-42e9-ad01-ade9f7cc5aee', 'roberto.alejandro.1960@laboratorios.info', '$2b$12$uCzXSpNBVcpDiFqgauG8t.hEUGGsoyokYY61Qla67XEu069e3GiUq', 'patient', '05bc2942-e676-42e9-ad01-ade9f7cc5aee', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: victor.gutierrez.1983@laboratorios.net
-- Password (plain text): )5XoNP4y%Uq0
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c78e7658-d517-4ca1-990b-e6971f8d108f', 'victor.gutierrez.1983@laboratorios.net', '$2b$12$zztcWWsmlYV/CLoZA0KFK.JsREO5vrMp/.WtEOVFEsixl9/Mzfu5e', 'patient', 'c78e7658-d517-4ca1-990b-e6971f8d108f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: adan.nava.2000@cedillo.info
-- Password (plain text): r3FkFlY@(8^F
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('65474c27-8f72-4690-8f19-df9344e4be5e', 'adan.nava.2000@cedillo.info', '$2b$12$jgyy9OZddlFHzmfoARuta.mwjjAqT1Z9DOqvVUS1qKqPsgc2a86CC', 'patient', '65474c27-8f72-4690-8f19-df9344e4be5e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: amador.cano.1995@velasquez.com
-- Password (plain text): ^6TWY+Zylb#&
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c1b6fa98-203a-4321-96cd-e80e7a1c9461', 'amador.cano.1995@velasquez.com', '$2b$12$/Jomy7IcPqHmcrIj6w/SdO0Esfc8nUEs.SbYXW4o/oZF8E9XUvuKa', 'patient', 'c1b6fa98-203a-4321-96cd-e80e7a1c9461', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: alfonso.prado.1955@saucedo.net
-- Password (plain text): i(0FXRJy3x4d
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('9244b388-8c06-42c7-9c4e-cbaae5b1baa3', 'alfonso.prado.1955@saucedo.net', '$2b$12$rJJY2NU3w.5kdpwNoDeAl.90zk9nmyNmgRurtvY.FWtJU6Dbwv282', 'patient', '9244b388-8c06-42c7-9c4e-cbaae5b1baa3', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: uriel.suarez.1972@chapa.com
-- Password (plain text): #*S3kAMAq2i7
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('eb2e55f6-4738-4352-a59a-860909f1932c', 'uriel.suarez.1972@chapa.com', '$2b$12$AyFi.FJeWD5qNsKNNBUq5.wpUKcHdak3zhzb5D6NtImEMIYxahMXe', 'patient', 'eb2e55f6-4738-4352-a59a-860909f1932c', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: armando.porras.1954@maestas-mireles.biz
-- Password (plain text): )AGsBSnz64%v
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c572a4c7-e475-4d18-85da-417abcd00903', 'armando.porras.1954@maestas-mireles.biz', '$2b$12$jz4a5gbtVYrTLTyzL56T2ud4yMnXhrZCW9I477r7oPr2qf.SSmnWW', 'patient', 'c572a4c7-e475-4d18-85da-417abcd00903', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: teresa.granado.1953@beltran.net
-- Password (plain text): )u6CUQi#AM6T
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3', 'teresa.granado.1953@beltran.net', '$2b$12$AlYrxiz8Bw5RnFcyTBuemO2BnNXuyh5jx5jXK82oVU79OtfK0G5bq', 'patient', '5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: marcela.fernandez.1981@corporacin.net
-- Password (plain text): 2tD)sly*A7eo
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('9b02d89c-2c5b-4c51-8183-15ccd1184990', 'marcela.fernandez.1981@corporacin.net', '$2b$12$09p2ifC5JJ0KgNlG0fLw3eeQ1V8h04ikQCIhg9UFhJb2VA8dmItXK', 'patient', '9b02d89c-2c5b-4c51-8183-15ccd1184990', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: sergio.loya.1970@jaime-santiago.com
-- Password (plain text): 0xVQfmi**_4!
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('43ae2e81-ac13-40ac-949c-9e4f51d76098', 'sergio.loya.1970@jaime-santiago.com', '$2b$12$KyAEIcaF2hmBnla4P3v.fuBd/iqJHULOEEXxN8wvbBShhuF.A2gGS', 'patient', '43ae2e81-ac13-40ac-949c-9e4f51d76098', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: jorgeluis.molina.1953@rosas.com
-- Password (plain text): gCakH(Rl(!3v
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('49a18092-8f90-4f6b-873c-8715b64b8aff', 'jorgeluis.molina.1953@rosas.com', '$2b$12$vy/iSirzrwXCgGTB/g81wOP7QlezBAiLWpRCZdieIzUP29mEcuJgq', 'patient', '49a18092-8f90-4f6b-873c-8715b64b8aff', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: elvira.echeverria.1970@melgar.org
-- Password (plain text): 42PXu02d^P_3
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c9a949e5-e650-4d95-9e2e-49ed06e5d087', 'elvira.echeverria.1970@melgar.org', '$2b$12$h6ao1Wyi.1zjMgYn3tZCB.0cgkw0.J0CR7I7cyAXMOpuIXgXLNyF2', 'patient', 'c9a949e5-e650-4d95-9e2e-49ed06e5d087', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: federico.fajardo.1949@industrias.com
-- Password (plain text): *V%7Lvuon&9e
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a4e5cbb3-36f7-43d8-a65a-e30fc1361e56', 'federico.fajardo.1949@industrias.com', '$2b$12$dlOqwHZ1dKzpDMrkaD67duFN3S7p35/RK1aXJczUcPtNMEIJ6my3W', 'patient', 'a4e5cbb3-36f7-43d8-a65a-e30fc1361e56', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: elena.quintanilla.1979@arellano-delgadillo.com
-- Password (plain text): y2KHv310+zjK
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('447e48dc-861c-41e6-920e-a2dec785101f', 'elena.quintanilla.1979@arellano-delgadillo.com', '$2b$12$FdO1YrGw89Wb7.VuwW.D4uayjqszk3EYFjR44KksB0BmuIEqUkpxS', 'patient', '447e48dc-861c-41e6-920e-a2dec785101f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: cynthia.jurado.1991@zelaya-vazquez.com
-- Password (plain text): +^^0Zm&PenCB
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3a535951-40fd-4959-a34e-07b29f675ecc', 'cynthia.jurado.1991@zelaya-vazquez.com', '$2b$12$dPDRFbwj/iovW3Z81iHxhO99BzKRngrjfEVFOA8JMVJCvDbDL2ei2', 'patient', '3a535951-40fd-4959-a34e-07b29f675ecc', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: juana.gurule.1993@zaragoza.com
-- Password (plain text): PHO7y+Wj)3wB
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70', 'juana.gurule.1993@zaragoza.com', '$2b$12$UXrJmKtFFw.bwV9HpTTepeqULrGv3zQZ1WF6KsS5lL0XelFaQtVVe', 'patient', 'd4bfb3cb-c8d6-434a-a3d4-2712ecea4d70', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: lilia.mesa.1956@grijalva-trejo.com
-- Password (plain text): @^WGWJgw8&he
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6052a417-6725-4fab-b7dd-7f498454cd47', 'lilia.mesa.1956@grijalva-trejo.com', '$2b$12$nDT1kHf2fm65b20sF8Vl2.6sRF.eXN83wMH1DO.IaTeFAnT3qIXsK', 'patient', '6052a417-6725-4fab-b7dd-7f498454cd47', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: octavio.gurule.2004@grupo.com
-- Password (plain text): L*2(5C2lVN92
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', 'octavio.gurule.2004@grupo.com', '$2b$12$6auSOApvs/bwd/0981j5dePdIcvw5P84ocYhA./WzxUj6f129lxsK', 'patient', 'dad07e7d-fcb6-407a-9267-b7ab0a92d4a7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: reina.rangel.1975@proyectos.biz
-- Password (plain text): v0#(mbWTW@tP
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('cbd398cc-dfde-41c4-b7b1-ca32cc99945f', 'reina.rangel.1975@proyectos.biz', '$2b$12$uJjPO26Ng8iRSx.OryJFi.OJ3otTEaKUBlfZ4OJ.Ikjl9sHwWKJDG', 'patient', 'cbd398cc-dfde-41c4-b7b1-ca32cc99945f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: estefania.vanegas.1946@despacho.com
-- Password (plain text): +t2mcR#k&6Oz
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f740b251-4264-4220-8400-706331f650af', 'estefania.vanegas.1946@despacho.com', '$2b$12$vvIbYi12hwyOy9LBdwnHs.R318T2buZCYODkMxcdpVpD2gmQbhROm', 'patient', 'f740b251-4264-4220-8400-706331f650af', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: alfredo.holguin.1963@club.com
-- Password (plain text): *q*VNy)n2s1P
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', 'alfredo.holguin.1963@club.com', '$2b$12$BNsAOZjKRpPrNRxjpTAgZOmZCj8wi09r0N1GiYdLBGBj0AuHuMQCO', 'patient', 'fac7afba-7f9c-40f9-9a06-a9782ad7d3a7', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: reynaldo.meza.1997@gaitan.com
-- Password (plain text): 70Rvu+1v)Xm_
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('97d5d278-c876-4078-9dba-2940edfed9a0', 'reynaldo.meza.1997@gaitan.com', '$2b$12$SeqWoyr1OYiCDvT/wW0zlejZvjsGLX9L5WGOI4wvILHB4xd2ys74K', 'patient', '97d5d278-c876-4078-9dba-2940edfed9a0', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: daniel.caban.1964@laboratorios.biz
-- Password (plain text): a(mFt3vDINu@
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a329242d-9e38-4178-aa8e-5b7497209897', 'daniel.caban.1964@laboratorios.biz', '$2b$12$JdxWKWA7y0jd4zkERPl/HOpjSWCBV8wIefZTmomJRa9ATJhI.nlhu', 'patient', 'a329242d-9e38-4178-aa8e-5b7497209897', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: graciela.bonilla.1997@valentin-galvez.com
-- Password (plain text): P3TYGq8y+Zzh
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('fe2cc660-dd15-4d31-ac72-56114bdb6b92', 'graciela.bonilla.1997@valentin-galvez.com', '$2b$12$7LpIGVkFc/1EeiS4cWDB.Ozj8lZW4MFsrPAoKMZaqF.E4Fd78Rhl.', 'patient', 'fe2cc660-dd15-4d31-ac72-56114bdb6b92', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: jaqueline.olivas.1950@arredondo-barajas.com
-- Password (plain text): QL3*K7pgbCUj
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('fd01c50f-f3dd-4517-96c0-c0e65330a692', 'jaqueline.olivas.1950@arredondo-barajas.com', '$2b$12$zP6dTiVeSM2rP3ltdoS8K.1HYUyhLZEZsjm/ccF2mKwArC3TRwvpq', 'patient', 'fd01c50f-f3dd-4517-96c0-c0e65330a692', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: leonardo.mateo.1966@grupo.org
-- Password (plain text): 7#7Rpcl(397l
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('f56cc0bc-1765-4334-9594-73dcc9deac8e', 'leonardo.mateo.1966@grupo.org', '$2b$12$HNrSc2Ft3LTmiCfdP7kA3u72tlQV2KAn9WxcXQqGUT/yH5Ty3XHlq', 'patient', 'f56cc0bc-1765-4334-9594-73dcc9deac8e', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: antonio.sosa.1959@feliciano-ramirez.com
-- Password (plain text): h0MnECTz+er8
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('1c861cbf-991d-4820-b3f0-98538fb0d454', 'antonio.sosa.1959@feliciano-ramirez.com', '$2b$12$GbWK2QG..RrUMulPPc1dWuw2Z2RllUx4iEIGsOE2nNL8m0ulOWe8a', 'patient', '1c861cbf-991d-4820-b3f0-98538fb0d454', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: cristobal.chavez.2006@corporacin.com
-- Password (plain text): P#4TFqdby3W%
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('70f066e1-fc10-4b37-92ea-0de96307793b', 'cristobal.chavez.2006@corporacin.com', '$2b$12$FSX9bnqgJqQ0ZzHt2qoxLOM9SPztP.dK.94VgEreq2VUdxpu99DMS', 'patient', '70f066e1-fc10-4b37-92ea-0de96307793b', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: jaqueline.negrete.1973@grupo.com
-- Password (plain text): *85TaztxFv6F
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d1ec4069-41a0-4317-a6c6-84914d108257', 'jaqueline.negrete.1973@grupo.com', '$2b$12$nYU6ePNimNXlpFtsrAR7ROm6IVj80r2J8BqORk/ZDBMyBVbNdkni.', 'patient', 'd1ec4069-41a0-4317-a6c6-84914d108257', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: esteban.rios.1991@despacho.com
-- Password (plain text): N)m7GLl6+IVq
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('04239007-edaa-4c74-95dd-4ba4df226b0f', 'esteban.rios.1991@despacho.com', '$2b$12$YHiiQKOMLbtP0GLWn/UxX.XLr1WtudlE29memYKQ46jFcjUyo1V4u', 'patient', '04239007-edaa-4c74-95dd-4ba4df226b0f', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: zoe.gaona.1953@cornejo.com
-- Password (plain text): X%O7BRhw2$Gy
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('0deef39b-719e-4f3a-a84f-2072803b2548', 'zoe.gaona.1953@cornejo.com', '$2b$12$Nm8RIAK4Br0Y5wbFTOxgqOIh9jMJwv81lSvKhEfE6RIGlUQN9s/S2', 'patient', '0deef39b-719e-4f3a-a84f-2072803b2548', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: ana.saenz.1967@barragan-bravo.com
-- Password (plain text): 3CV+bmlm+3Fm
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5156864c-fa59-4e48-b357-477838800efc', 'ana.saenz.1967@barragan-bravo.com', '$2b$12$FgSPS1QZKGRl7uaY4CUnteFyQfcAlrr9tikxpFISI32wg7ktM8WiO', 'patient', '5156864c-fa59-4e48-b357-477838800efc', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: vanesa.nava.1996@jaramillo.net
-- Password (plain text): %S*IZRcog8OM
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d911f0a5-9268-4eb4-87e9-508d7c99b753', 'vanesa.nava.1996@jaramillo.net', '$2b$12$siofu24h27aKq6oI2vh.ye845qOjfKLUbYzH42F.ByNh66Fe5sJim', 'patient', 'd911f0a5-9268-4eb4-87e9-508d7c99b753', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: diana.ceja.1969@solano.com
-- Password (plain text): (Rz#^HKxq&g9
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('c3e065c2-c0a9-440f-98f3-1c5463949056', 'diana.ceja.1969@solano.com', '$2b$12$nn3D8H9DkyTussgQotKX5.jRQ8geSB.OzlVqYbPhtqN6Ylly4s/Mu', 'patient', 'c3e065c2-c0a9-440f-98f3-1c5463949056', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: emilio.delarosa.1946@laboratorios.com
-- Password (plain text): 42dI8gtI)E(#
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('b2eef54b-21a7-45ec-a693-bc60f1d6e293', 'emilio.delarosa.1946@laboratorios.com', '$2b$12$6QJqUoD/wKPbFty4DX8bKeVHqkMIPdjXjK5y6lc43AobTExJHU3u.', 'patient', 'b2eef54b-21a7-45ec-a693-bc60f1d6e293', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: monica.delarosa.1978@valdivia.biz
-- Password (plain text): *)4OR0q3XQ4(
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('3854a76e-ee29-4976-b630-1d7e18fb9887', 'monica.delarosa.1978@valdivia.biz', '$2b$12$Ffn/IRgtxXta91yikWJmYOP21dYCSW6QOlhWGmzXrehiFAb1lBeN2', 'patient', '3854a76e-ee29-4976-b630-1d7e18fb9887', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: reynaldo.garcia.1966@laboratorios.net
-- Password (plain text): HL@2D#6zNHQL
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6b2e25e9-ebcb-4150-a594-c5742cd42121', 'reynaldo.garcia.1966@laboratorios.net', '$2b$12$a6nNNTKRkvh0LU06UP6Q/exYOsviW9k4g2Gs35uKxv/MF6fScaUBq', 'patient', '6b2e25e9-ebcb-4150-a594-c5742cd42121', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: geronimo.pedraza.1972@proyectos.info
-- Password (plain text): svO*YGZVL5_U
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('cc38cb13-51a5-4539-99c2-894cd2b207f1', 'geronimo.pedraza.1972@proyectos.info', '$2b$12$oYSLNWsghyO4kX1PIzDdUu2H6ZV.hwquEjwD1WvClmw.krS/Zr4k.', 'patient', 'cc38cb13-51a5-4539-99c2-894cd2b207f1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: abelardo.barraza.1981@amador-nieves.com
-- Password (plain text): 9@dOCd*edOD3
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('6af409b5-c8b8-4664-97cd-d419eedcc932', 'abelardo.barraza.1981@amador-nieves.com', '$2b$12$JhAXTmaBPsQEIdNX1UUg0O4tZWPssdYivLBtr53SYoMNdPOy0w3MS', 'patient', '6af409b5-c8b8-4664-97cd-d419eedcc932', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: noelia.toro.1948@rodrigez-casas.info
-- Password (plain text): @GayHhYzI79y
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('227a2c03-dfd1-4e03-9c04-daaf74fc68bd', 'noelia.toro.1948@rodrigez-casas.info', '$2b$12$l3Nr5Ic52YtCJW4TeGGS1OetzCTecCpZwyXQUTBLQueJmEALCBd62', 'patient', '227a2c03-dfd1-4e03-9c04-daaf74fc68bd', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: ines.tellez.2001@club.com
-- Password (plain text): (9+TzTg)#^1T
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('bc6e7a77-d709-401c-bea7-82715eeb1a29', 'ines.tellez.2001@club.com', '$2b$12$BdeM83HZ92n1GfXcHzsaKOxaYccW.S.JKXpOy54bAuVXUjbgDJvAi', 'patient', 'bc6e7a77-d709-401c-bea7-82715eeb1a29', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: hector.maldonado.1974@despacho.com
-- Password (plain text): +xC45Hwp$#K+
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('d54d7239-e49a-4185-8875-4f71af08b789', 'hector.maldonado.1974@despacho.com', '$2b$12$.k3swDXTZe8jO/iUasjAduK7wIw0IgOnATG3HFdp8inqer8Sps6hi', 'patient', 'd54d7239-e49a-4185-8875-4f71af08b789', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: jonas.segura.1969@proyectos.com
-- Password (plain text): pF!2BXn#h_0T
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('8370857e-7e69-43a6-be63-78fc270c5fd5', 'jonas.segura.1969@proyectos.com', '$2b$12$.GAtP7oC44HmbwyHf72TUebo4UlJ/WpuRxhcX28mskT1sz6J64QP.', 'patient', '8370857e-7e69-43a6-be63-78fc270c5fd5', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: joseluis.gomez.2003@corporacin.info
-- Password (plain text): 2YLugHq2&8%C
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('e8813bf8-7bbb-4370-a181-880c0c959aa1', 'joseluis.gomez.2003@corporacin.info', '$2b$12$tfQgAZxxq0MBM2DA8yxyWePwbQzdKSTRMpjJIpEKm/8bnVRqFSb32', 'patient', 'e8813bf8-7bbb-4370-a181-880c0c959aa1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: fernando.gil.1947@pena-morales.com
-- Password (plain text): +8j!_Byi&OZZ
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('4337bfc4-5ea7-4621-bd24-dbf3f55e350a', 'fernando.gil.1947@pena-morales.com', '$2b$12$5IFOa8zfs9YfjelgCPv64uS0v5G7ghrV94ql4znt..oKGS37Shmf.', 'patient', '4337bfc4-5ea7-4621-bd24-dbf3f55e350a', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: angela.montanez.1974@proyectos.com
-- Password (plain text): &1JyYjacrrVM
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('517958b1-f860-4a42-965b-15a796055981', 'angela.montanez.1974@proyectos.com', '$2b$12$pHNxsjJQeXM/LXIbPNNRo.kAshDPu65wlhkZtHn74gVwYc1R6I3YC', 'patient', '517958b1-f860-4a42-965b-15a796055981', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: leonor.olivera.1953@grupo.com
-- Password (plain text): @@&IOJu5qZ3@
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('44e4c099-cf6e-4926-85f1-ab5cb34c59a1', 'leonor.olivera.1953@grupo.com', '$2b$12$WBT6Ul/vbW2o/fWen/VfjOCqK.a6/.DldT.ETKDGBgEDlaNlDMYfi', 'patient', '44e4c099-cf6e-4926-85f1-ab5cb34c59a1', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: gabino.aguirre.1951@cabrera.com
-- Password (plain text): %q#KC)v2X2ba
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('a0c3c815-c664-4931-927f-e4109a545603', 'gabino.aguirre.1951@cabrera.com', '$2b$12$f06yYKY5F5VT0i6iVxzwLug5uILs8EtLcfDTPKlsenY0OYxnNGBM.', 'patient', 'a0c3c815-c664-4931-927f-e4109a545603', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: judith.aleman.1976@longoria-tellez.com
-- Password (plain text): &D(1JOr@@VCV
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('5c1862f6-f802-41ae-a6fb-87dbc5555fb3', 'judith.aleman.1976@longoria-tellez.com', '$2b$12$LbFs1z5cLlj5EMgfG1TZrOMJl5FCFaQRMFP2MiLRf2NHzwA0jvmh2', 'patient', '5c1862f6-f802-41ae-a6fb-87dbc5555fb3', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- User: oswaldo.fuentes.1989@escobedo.info
-- Password (plain text): !PxvOjx0)8fM
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES ('11d31cb4-1dfb-479e-9329-8b8b35920b98', 'oswaldo.fuentes.1989@escobedo.info', '$2b$12$mUoccHdmU56Y9Uism/cZNuw2C61NIB703OLUhFnzQ6ZafaoWa2.6u', 'patient', '11d31cb4-1dfb-479e-9329-8b8b35920b98', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

