--изменение типа для дат
--очистка денежных полей
--добавление поля с типом валюты
--обработка пустых значений
--очистка от лишних пробелов в конце и начале строки
--приведение к нижнему регистру
--нормализация категориальных полей

{{ config(materialized='table') }}

SELECT 
	contract_id, 
	client_id, 
	client_name, 
	product, 
	toDate(parseDateTimeBestEffortOrNull(start_date)) as start_date, 
	toDate(parseDateTimeBestEffortOrNull(end_date)) as end_date, 
	toDecimal64(nullif(trim(REGEXP_REPLACE(annual_premium, '[^0-9.-]','')),''),2) as annual_premium_num, 
	case
		WHEN annual_premium LIKE '%$%' OR annual_premium LIKE '%USD%' THEN 'USD'
	else 'EUR' end as currency,
    lower(trim(status)) as status, 
	lower(trim(risk_zone)) as risk_zone, 
	client_age, 
	channel, 
    CASE WHEN csp IN ('Worker','Employee') THEN 'EMPLOYEE'
         WHEN csp IN ('Manager') THEN 'MANAGER'
         WHEN csp IN ('Self_employed') THEN 'SELF_EMPLOYED'
         WHEN csp IN ('Student') THEN 'STUDENT'
         WHEN csp IN ('Retired') THEN 'RETIRED'
         WHEN csp IN ('Unemployed') THEN 'UNEMPLOYED'
         ELSE NULL END AS csp,
    CASE WHEN gender IN ('M','Male') THEN 'M'
         WHEN gender IN ('F','Female') THEN 'F'
         ELSE NULL END AS gender
FROM {{source('insurance_db', 'contracts')}}