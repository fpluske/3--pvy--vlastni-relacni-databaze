**Vlastní Relační Databáze**

Krátký popis a zdroje pro projekt schématu databáze.

- **dbdiagram:** https://dbdiagram.io/d/Vlastni-relacni-databaze-690dc4eb6735e11170b71c00
- **Obrázek schématu:**

<img width="1113" height="682" alt="Vlastní relační databáze" src="https://github.com/user-attachments/assets/a42cd656-c1bc-4db3-b04b-8f008ddc333a" />

Instrukce pro generování demo dat (skript se nachází v `scripts/faker_data.py`):

- Nainstalujte závislosti:

```powershell
pip install -r requirements.txt
```

- Spusťte generátor:

```powershell
python .\scripts\faker_data.py
```

Po spuštění bude v kořeni projektu vytvořen SQL dump (`random-zaznamy.sql`), který obsahuje INSERT příkazy podle schématu.

Poznámky:
- Skript generuje data v češtině pomocí `Faker`.
- Pokud chcete upravit téma (např. jiné kategorie nebo počty záznamů), otevřete `scripts/faker_data.py` a změňte proměnné `NUM_*` nebo sekce pro generování kategorií/produktů.
