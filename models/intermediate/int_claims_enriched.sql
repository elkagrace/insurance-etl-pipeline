--соединение заявок, контрактов и машин по contract_id
{{ config(materialized='table') }}

with claims as (
    select * from {{ ref('stg_claims') }}
),
contracts as (
    select * from {{ ref('stg_contracts') }}
),
vehicles as (
    select * from {{ ref('stg_vehicles') }}
)

select
    -- Идентификаторы
    c.claim_id as claim_id,
    c.contract_id as contract_id,
    cnt.client_id as clien_id, 
    
    -- Даты и временные метрики
    c.occurrence_date as occurrence_date,
    c.declaration_date as declaration_date,
    c.days_to_report as days_to_report,
    
    -- Тип и суммы
    c.claim_type as claim_type,
    c.damage_amount_num as damage_amount_num,
    c.indemnified_amount_num as indemnified_amount_num,
    c.currency as currency, 
    c.status as status,
    
    -- Атрибуты договора
    cnt.product as product,
    cnt.annual_premium_num as annual_premium_num,
    
    -- Атрибуты автомобиля
    v.brand as brand,
    v.model as model,
    v.year as year,
    v.fuel_type as fuel_type ,
    v.usage as usage,
    v.previous_claims as previous_claims,
    v.current_value_num as current_value_num,
    
    -- Дополнительные поля из claims
    c.expert_id as expert_id,
    c.liability as liability

from claims c
left join contracts cnt on c.contract_id = cnt.contract_id
left join vehicles v on cnt.contract_id = v.contract_id