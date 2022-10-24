{% macro grant(role) %}
  {% set sql %}
      GRANT USAGE ON SCHEMA {{ schema }} TO ROLE {{ role }};
      {% if role == "sysadmin" %}
       GRANT SELECT, UPDATE, TRIGGER ON {{ this }} TO ROLE {{ role }};
      {% else %} 
        GRANT SELECT ON {{ this }} TO ROLE {{ role }};
      {% endif %}
    {% endset %}
  {% set table = run_query(sql) %}
{% endmacro %}