--очистка денежных полей
--добавление поля с типом валюты
--обработка пустых значений
--очистка от лишних пробелов в конце и начале строки
{{ config(materialized='table') }}
SELECT 
	contract_id,
	brand,
	model,
	`year`, 
	power,
	fuel_type,
	toDecimal64(nullif(trim(REGEXP_REPLACE(current_value, '[^0-9.]','')),''),2) as current_value_num,
	case
		WHEN current_value LIKE '%$%' OR current_value LIKE '%USD%' THEN 'USD'
	else 'EUR' end as currency,
	color,
	`usage`,
	previous_claims
FROM {{source('insurance_db', 'vehicles')}}