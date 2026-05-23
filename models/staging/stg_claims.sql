--изменение типа для дат
--очистка денежных полей
--добавление поля с типом валюты
--обработка пустых значений
--очистка от лишних пробелов в конце и начале строки
--приведение к нижнему регистру
--расчет дополнительной метрики: количество дней от события до заявления
{{ config(materialized='table') }}

SELECT 
    claim_id, 
    contract_id, 
    toDate(parseDateTimeBestEffortOrNull(occurrence_date)) as occurrence_date, 
    toDate(parseDateTimeBestEffortOrNull(declaration_date)) as declaration_date, 
    claim_type, 
    toDecimal64(nullif(trim(REGEXP_REPLACE(damage_amount, '[^0-9.]','')),''),2) as damage_amount_num, 
    toDecimal64(nullif(trim(REGEXP_REPLACE(indemnified_amount, '[^0-9.]','')),''),2) as indemnified_amount_num, 
    case
	    WHEN damage_amount LIKE '%$%' OR damage_amount LIKE '%USD%' THEN 'USD'
    else 'EUR' end as currency,
    lower(trim(status)) as status, 
    nullif(expert_id,'') as expert_id, 
    nullif(liability,'') as liability,
    toDate(declaration_date)-toDate(occurrence_date) as days_to_report
FROM {{source ('insurance_db', 'claims')}}