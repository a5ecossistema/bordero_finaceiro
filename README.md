# Painel Financeiro · Grupo A5 Ecossistema

Página única (`index.html`) que lê e grava numa Planilha Google via SheetDB.
Toda a lógica está no próprio arquivo — não há build.

O `chart.umd.min.js` (Chart.js 4.4.4) é servido pelo próprio projeto, não por CDN:
a URL antiga apontava para uma versão que o cdnjs nunca publicou, dava 404 e
deixava todos os gráficos em branco sem nenhum erro no console. Se um dia
precisar atualizar:

```
curl -sfL -o chart.umd.min.js https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js
```

**Ao subir, o `chart.umd.min.js` tem que ir junto com o `index.html`** — o
Dockerfile já copia os dois. Se ele faltar, o painel agora mostra um aviso
vermelho no lugar de cada gráfico, em vez de ficar em branco.

## Deploy no Coolify

1. Suba esta pasta para um repositório Git.
2. No Coolify: **New Resource → Application → Public/Private Repository**.
3. Build Pack: **Dockerfile** (já está na raiz).
4. Porta exposta: **80**.
5. Health check path: `/health`.

O nginx serve o `index.html` com `Cache-Control: no-store`, então um deploy novo
aparece na hora para quem já tinha o painel aberto (basta recarregar).

## Estrutura da planilha (aba única)

Uma única aba com uma coluna `tipo` que separa os três grupos:

| coluna    | usada por                | observação                                   |
|-----------|--------------------------|----------------------------------------------|
| `id`      | todos                    | gerado pelo painel; sem ele não dá pra editar/excluir pela tela |
| `tipo`    | todos                    | `pagar`, `receber` ou `vendas`               |
| `mes`     | todos                    | aceita "Setembro", "set", "09"               |
| `status`  | todos                    | pagar/receber: Pago, Pendente, Atrasado · vendas: Fechada, Em negociação, Perdida |
| `valor`   | todos                    | aceita `1500`, `1.500,00`, `R$ 1.500,00`     |
| `cliente` | receber, vendas          | é a chave que junta os dois na aba Clientes  |

## Aba Clientes

É **derivada** de vendas + contas a receber (não tem cadastro próprio):
toda venda lançada faz o cliente aparecer na aba na hora. O agrupamento é
por nome normalizado (sem acento, sem caixa alta, sem espaço duplo), então
"Cliente X" e "cliente  x" caem no mesmo card.

Cada card mostra: vendas fechadas (quantidade e valor), valor em negociação,
em aberto (contas a receber **não** pagas), já recebido e a situação.
Clientes que vieram de uma venda mas ainda não têm cobrança lançada recebem
a etiqueta "Veio de venda — sem conta a receber lançada".

## Pendências conhecidas

- A URL do SheetDB está no HTML, ou seja, qualquer visitante do painel pode
  ler/alterar/apagar a planilha inteira. A correção é um proxy no backend
  com a chave em variável de ambiente.
- Os meses não guardam o ano: Setembro/2026 e Setembro/2027 caem no mesmo bucket.
- "Saldo do mês" usa vendas fechadas menos contas pagas (regime de competência),
  não o que de fato entrou no caixa.
- Valor `0` não é aceito no lançamento em lote.
