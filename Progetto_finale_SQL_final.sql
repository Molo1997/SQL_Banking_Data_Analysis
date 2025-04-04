-- 1. Creazione della tabella con l'età del cliente

-- Creazione della tabella temporanea per i clienti con l'età calcolata al 24 ottobre 2024 (data odierna)
DROP TABLE IF EXISTS temp_cliente;
CREATE TABLE temp_cliente AS
SELECT 
    id_cliente,
    nome,
    cognome,
    data_nascita,
    TIMESTAMPDIFF(YEAR, data_nascita, '2024-10-24') AS eta
FROM 
    cliente;

-- Controllo sulla tabella
SELECT COUNT(DISTINCT id_cliente) AS numero_clienti FROM temp_cliente; -- 200


-- 2. Indicatori sulle transazioni su tutti i conti

-- Conteggio distinti di id_cliente nella tabella conto
SELECT COUNT(DISTINCT id_cliente) AS numero_clienti_con_conto
FROM conto; -- 142 clienti che hanno un conto (ipotizzo siano i clienti attuali)
-- Creazione della tabella conti, unendo i conti con la descrizione del tipo di conto
DROP TABLE IF EXISTS temp_conto;
CREATE TEMPORARY TABLE temp_conto AS
SELECT 
    c.id_conto,
    c.id_cliente,
    tc.desc_tipo_conto
FROM 
    tipo_conto tc
LEFT JOIN 
    conto c ON c.id_tipo_conto = tc.id_tipo_conto;

-- Creazione tabella delle transazioni, unendo le transazioni con la tipologia
DROP TABLE IF EXISTS temp_transazioni;
CREATE TEMPORARY TABLE temp_transazioni AS
SELECT 
    t.data,
    t.importo,
    t.id_conto,
    tt.desc_tipo_trans,
    tt.segno
FROM 
    transazioni t
RIGHT JOIN 
    tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione;

-- Creazione della tabella che unisce le transazioni con i conti
DROP TABLE IF EXISTS transazioni_conto;
CREATE TEMPORARY TABLE transazioni_conto AS
SELECT 
    tt.*,  
    tc.id_cliente,
    tc.desc_tipo_conto
FROM 
    temp_transazioni tt
JOIN 
    temp_conto tc ON tt.id_conto = tc.id_conto; 

-- Controllo sulla tabella unita
SELECT COUNT(DISTINCT id_cliente) AS numero_clienti FROM transazioni_conto; -- 142

-- Creazione della tabella per gli indicatori sulle transazioni per cliente
DROP TABLE IF EXISTS temp_indicatori_transazioni;
CREATE TABLE temp_indicatori_transazioni AS
SELECT 
    tc.id_cliente, 
    COUNT(CASE WHEN tt.segno = '-' THEN 1 END) AS numero_transazioni_uscita,
    COUNT(CASE WHEN tt.segno = '+' THEN 1 END) AS numero_transazioni_entrata,
    SUM(CASE WHEN tt.segno = '-' THEN t.importo END) AS totale_importo_uscita,
    SUM(CASE WHEN tt.segno = '+' THEN t.importo END) AS totale_importo_entrata
FROM 
    transazioni t
JOIN 
    tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
JOIN 
    conto c ON t.id_conto = c.id_conto
JOIN 
    temp_conto tc ON c.id_conto = tc.id_conto 
GROUP BY 
    tc.id_cliente;  -- Raggruppo per id_cliente per garantire unicità

-- Controllo degli indicatori
SELECT * FROM temp_indicatori_transazioni;


-- 3. Indicatori sui conti
-- Creazione della tabella per il numero totale di conti per cliente
DROP TABLE IF EXISTS temp_numero_conti;
CREATE TABLE temp_numero_conti AS
SELECT 
    c.id_cliente,  
    COUNT(c.id_conto) AS numero_totale_conti  
FROM 
    conto c
GROUP BY 
    c.id_cliente; 
-- Creazione della tabella per il numero di conti per tipologia
DROP TABLE IF EXISTS temp_numero_conti_tipo;
CREATE TABLE temp_numero_conti_tipo AS
SELECT 
    c.id_cliente,  
    -- Conto i conti per ogni tipo di conto specifico
    SUM(CASE WHEN c.desc_tipo_conto = 'Conto Base' THEN 1 ELSE 0 END) AS numero_conti_base,
    SUM(CASE WHEN c.desc_tipo_conto = 'Conto Business' THEN 1 ELSE 0 END) AS numero_conti_business,
    SUM(CASE WHEN c.desc_tipo_conto = 'Conto Privati' THEN 1 ELSE 0 END) AS numero_conti_privati,
    SUM(CASE WHEN c.desc_tipo_conto = 'Conto Famiglie' THEN 1 ELSE 0 END) AS numero_conti_famiglie
FROM 
    temp_conto c  
GROUP BY 
    c.id_cliente; 


-- 4. Indicatori sulle transazioni per tipologia di conto
-- Creazione della tabella per gli indicatori sulle transazioni per cliente e tipo di conto
DROP TABLE IF EXISTS temp_indicatori_transazioni_tipo_conto;
CREATE TABLE temp_indicatori_transazioni_tipo_conto AS
SELECT 
    id_cliente,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Base' AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_base,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Base' AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_base,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Base' AND tt.segno = '-' THEN t.importo ELSE 0 END) AS totale_importo_uscita_base,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Base' AND tt.segno = '+' THEN t.importo ELSE 0 END) AS totale_importo_entrata_base,
    
    SUM(CASE WHEN desc_tipo_conto = 'Conto Business' AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_business,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Business' AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_business,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Business' AND tt.segno = '-' THEN t.importo ELSE 0 END) AS totale_importo_uscita_business,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Business' AND tt.segno = '+' THEN t.importo ELSE 0 END) AS totale_importo_entrata_business,
    
    SUM(CASE WHEN desc_tipo_conto = 'Conto Privati' AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_privati,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Privati' AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_privati,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Privati' AND tt.segno = '-' THEN t.importo ELSE 0 END) AS totale_importo_uscita_privati,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Privati' AND tt.segno = '+' THEN t.importo ELSE 0 END) AS totale_importo_entrata_privati,
    
    SUM(CASE WHEN desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_famiglie,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_famiglie,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '-' THEN t.importo ELSE 0 END) AS totale_importo_uscita_famiglie,
    SUM(CASE WHEN desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '+' THEN t.importo ELSE 0 END) AS totale_importo_entrata_famiglie
FROM 
    transazioni t
JOIN 
    tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
JOIN 
    temp_conto c ON t.id_conto = c.id_conto
GROUP BY 
    id_cliente;

-- Creazione della tabella finale con tutti gli indicatori per ogni id_cliente
DROP TABLE IF EXISTS final_indicatori_cliente;

CREATE TABLE final_indicatori_cliente AS
SELECT 
    tc.id_cliente,
    tc.eta,  
    it.numero_transazioni_uscita,
    it.numero_transazioni_entrata,
    it.totale_importo_uscita,
    it.totale_importo_entrata,
    nc.numero_totale_conti,
    nct.numero_conti_base,
    nct.numero_conti_business,
    nct.numero_conti_privati,
    nct.numero_conti_famiglie,
    itc.numero_transazioni_uscita_base,
    itc.numero_transazioni_entrata_base,
    itc.totale_importo_uscita_base,
    itc.totale_importo_entrata_base,
    itc.numero_transazioni_uscita_business,
    itc.numero_transazioni_entrata_business,
    itc.totale_importo_uscita_business,
    itc.totale_importo_entrata_business,
    itc.numero_transazioni_uscita_privati,
    itc.numero_transazioni_entrata_privati,
    itc.totale_importo_uscita_privati,
    itc.totale_importo_entrata_privati,
    itc.numero_transazioni_uscita_famiglie,
    itc.numero_transazioni_entrata_famiglie,
    itc.totale_importo_uscita_famiglie,
    itc.totale_importo_entrata_famiglie
FROM 
    temp_cliente tc
LEFT JOIN 
    temp_indicatori_transazioni it ON tc.id_cliente = it.id_cliente
LEFT JOIN 
    temp_numero_conti nc ON tc.id_cliente = nc.id_cliente
LEFT JOIN 
    temp_numero_conti_tipo nct ON tc.id_cliente = nct.id_cliente
LEFT JOIN 
    temp_indicatori_transazioni_tipo_conto itc ON tc.id_cliente = itc.id_cliente;

-- Controllo della tabella finale
SELECT * FROM final_indicatori_cliente;


