{% macro load_raw() %}
  {% do run_query("create schema if not exists jaffle_shop") %}
  {% do run_query("create schema if not exists stripe") %}
  {% do run_query("create or replace table jaffle_shop.customers as select * from read_csv_auto('raw_data/jaffle_shop_customers.csv')") %}
  {% do run_query("create or replace table jaffle_shop.orders as select *, current_timestamp as _etl_loaded_at from read_csv_auto('raw_data/jaffle_shop_orders.csv')") %}
  {% do run_query("create or replace table stripe.payment as select *, current_timestamp as _batched_at from read_csv_auto('raw_data/stripe_payments.csv')") %}
{% endmacro %}