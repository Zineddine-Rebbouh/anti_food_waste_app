import json

def get_keys(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

en = get_keys('lib/l10n/app_en.arb')
fr = get_keys('lib/l10n/app_fr.arb')
ar = get_keys('lib/l10n/app_ar.arb')

missing_fr = [k for k in en if k not in fr and not k.startswith('@@')]
missing_ar = [k for k in en if k not in ar and not k.startswith('@@')]

print(f"Missing in FR: {len(missing_fr)}")
for k in missing_fr:
    print(f'  "{k}": "{en[k]}",')

print(f"\nMissing in AR: {len(missing_ar)}")
for k in missing_ar:
    print(f'  "{k}": "{en[k]}",')
