# Modelo DAX · Vendas de Veículos v2

## Calendário (`dim_calendar`)
Tabela calculada, marcada como tabela de datas.

```DAX
dim_calendar = CALENDAR(DATE(2020, 1, 1), DATE(2021, 12, 31))

year        = YEAR(dim_calendar[Date])
month       = DATE(YEAR(dim_calendar[Date]), MONTH(dim_calendar[Date]), 1)   -- formato mmm-yy
weekday_num = WEEKDAY(dim_calendar[Date], 1)                                  -- 1 = domingo

weekday =
SWITCH(
    dim_calendar[weekday_num],
    1, "Domingo",
    2, "Segunda",
    3, "Terça",
    4, "Quarta",
    5, "Quinta",
    6, "Sexta",
    7, "Sábado"
)   -- Sort by column: weekday_num
```

Relacionamentos:
- `dim_calendar[Date]` → `fact_funnel[visit_page_date]` (ativo)
- `dim_calendar[Date]` → `fact_funnel[paid_date]` (inativo, usado com `USERELATIONSHIP`)

## Medidas (`# Medidas`)
```DAX
Visitas = COUNTROWS(fact_funnel)

Leads = [Visitas]

Vendas =
CALCULATE(
    COUNT(fact_funnel[paid_date]),
    USERELATIONSHIP(dim_calendar[Date], fact_funnel[paid_date])
)

Receita =
CALCULATE(
    SUMX(fact_funnel, RELATED(dim_products[price]) * (1 + fact_funnel[discount])),
    USERELATIONSHIP(dim_calendar[Date], fact_funnel[paid_date]),
    NOT ISBLANK(fact_funnel[paid_date])
)

Conversão    = DIVIDE([Vendas], [Leads])          -- formato %
Ticket médio = DIVIDE([Receita], [Vendas])        -- número inteiro, separador de milhar
```

## Localização para o mapa (`dim_customers[state_location]`)
As siglas sozinhas ("SC", "MT") eram interpretadas como estados dos EUA. O nome completo resolve a ambiguidade. Data category: **State or Province**.

```DAX
state_location =
SWITCH(
    dim_customers[state],
    "AC", "Acre",
    "AL", "Alagoas",
    "AP", "Amapá",
    "AM", "Amazonas",
    "BA", "Bahia",
    "CE", "Ceará",
    "DF", "Distrito Federal",
    "ES", "Espírito Santo",
    "GO", "Goiás",
    "MA", "Maranhão",
    "MT", "Mato Grosso",
    "MS", "Mato Grosso do Sul",
    "MG", "Minas Gerais",
    "PA", "Pará",
    "PB", "Paraíba",
    "PR", "Paraná",
    "PE", "Pernambuco",
    "PI", "Piauí",
    "RJ", "Rio de Janeiro",
    "RN", "Rio Grande do Norte",
    "RS", "Rio Grande do Sul",
    "RO", "Rondônia",
    "RR", "Roraima",
    "SC", "Santa Catarina",
    "SP", "São Paulo",
    "SE", "Sergipe",
    "TO", "Tocantins",
    dim_customers[state]
) & ", Brazil"
```

## Validação (ago/2021, igual à v1)
| Leads | Vendas | Receita | Conversão | Ticket médio |
|---|---|---|---|---|
| 6.353 | 1.254 | 68.274.090 | 20% | 54.445 |
