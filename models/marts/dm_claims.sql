
{{config(materialized='table')}}

with mart as (
    select * from {{ ref('int_claims_enriched') }}
)

SELECT 
    claim_id,
    contract_id,
    occurrence_date,
    declaration_date,
    days_to_report,
    claim_type,
    damage_amount_num,
    indemnified_amount_num,
    
    -- Бизнес-статус урегулирования
    case
        when (status = 'closed' or status='rejected') and indemnified_amount_num > 0 then 'settled'
        when (status = 'closed' or status='rejected')  and (indemnified_amount_num = 0 or indemnified_amount_num is null) then 'rejected'
        else 'pending'
    end as settlement_status,
    
    -- Коэффициент выплаты (0..1)
    indemnified_amount_num  / nullif(damage_amount_num , 0) as settlement_ratio,
    
    -- Атрибуты
    brand,
    model,
    fuel_type,
    usage,
    -- Возраст автомобиля на момент события (приблизительно)
    (extract(year from occurrence_date) - year) as vehicle_age_at_claim,
    
    -- Ответственность
    liability,
    expert_id,
    
    now() as etl_updated_at
FROM mart
