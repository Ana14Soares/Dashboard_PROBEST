# -*- coding: utf-8 -*-
"""
Exporta os dados do dashboard SteamAnalytics a partir do steam.csv.

O app recalcula KPIs e gráficos a cada filtro, então recebe o catálogo
jogo a jogo (estatística descritiva no app; testes de hipótese ficam no notebook).

Uso:  python exportar_dashboard.py caminho/steam.csv pasta/de/saida
Gera: jogos.json (catálogo completo) e metadados.json
"""
import json
import sys
from datetime import date

import pandas as pd

CSV = sys.argv[1] if len(sys.argv) > 1 else "steam.csv"
SAIDA = sys.argv[2] if len(sys.argv) > 2 else "."
MIN_AVALIACOES = 50
GENEROS_TOP = ["Action", "Adventure", "Casual", "RPG",
               "Simulation", "Strategy", "Sports", "Racing"]

# ---------------------------------------------------------------- limpeza (igual ao notebook)
df = pd.read_csv(CSV).drop_duplicates(subset="appid").copy()
df["ano"] = pd.to_datetime(df["release_date"], errors="coerce").dt.year
assert df["ano"].notna().all(), "há jogos sem data de lançamento válida"
faixas = df["owners"].str.split("-", expand=True).astype(int)
df["donos_min"], df["donos_max"] = faixas[0], faixas[1]

jogos = []
ordem = (df["positive_ratings"] + df["negative_ratings"]).sort_values(ascending=False).index
for _, r in df.loc[ordem].iterrows():
    jogos.append({
        "appid": int(r["appid"]),
        "nome": str(r["name"]),
        "ano": int(r["ano"]),
        "preco": round(float(r["price"]), 2),
        "positivas": int(r["positive_ratings"]),
        "negativas": int(r["negative_ratings"]),
        "donos_min": int(r["donos_min"]),
        "donos_max": int(r["donos_max"]),
        "plataformas": str(r["platforms"]).split(";"),
        "conquistas": int(r["achievements"]),
        "generos": [g for g in str(r["genres"]).split(";") if g in GENEROS_TOP],
        "indie": "Indie" in str(r["genres"]).split(";"),
    })

metadados = {
    "gerado_em": date.today().isoformat(),
    "fonte": "Steam Store Games (Nik Davis, Kaggle) — APIs da Steam e do SteamSpy",
    "total_jogos": len(jogos),
    "min_avaliacoes": MIN_AVALIACOES,
    "moeda": "GBP",
    "ano_min": int(df["ano"].min()),
    "ano_max": int(df["ano"].max()),
    "ano_parcial": int(df["ano"].max()),   # coleta feita no meio de 2019
}

with open(f"{SAIDA}/jogos.json", "w", encoding="utf-8") as f:
    json.dump(jogos, f, ensure_ascii=False, separators=(",", ":"))
with open(f"{SAIDA}/metadados.json", "w", encoding="utf-8") as f:
    json.dump(metadados, f, ensure_ascii=False, indent=2)
print(f"{len(jogos)} jogos exportados para {SAIDA}")
