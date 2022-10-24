{% test column_does_not_contain_value(model, column_name, value) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} = '{{ value }}'
{% endtest %}