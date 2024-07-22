# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%

import pandas as pd
import os
import numpy as np
import matplotlib.pyplot as plt

# %%
export_folder = 'drive_files'

# %% Read files into a list
all_files = []
all_coding_characteristics = []
target_names = []
for file in sorted(os.listdir(export_folder)[4:]):
    print(file)
    if file.find('additional_coding') == -1:
        all_files.append(pd.read_csv(os.path.join(export_folder, file), skiprows=1))
        target_names.append(file)

# %% Add a column for weekIndex
df = all_files[0]
df['weekIndex'] = 0
for week_index in range(1, len(all_files)):
    this_week = all_files[week_index]
    this_week['weekIndex'] = week_index
    df = pd.concat([df, this_week])

# %% Drop blank or extraneous columns from worksheets
df = df.drop(columns=list(filter(lambda x: x.find('Unnamed') != -1, df)))
# %% df.columns

# %% Decode the themes
code_book_maintheme = pd.read_csv('codes_theme.tsv', sep='\t')
code_book_1st = {-1: 'Not coded'}
for i, row in code_book_maintheme.iterrows():
    code_book_1st[row['code']] = row['theme']
print(code_book_1st)
df['1st Theme String'] = [code_book_1st[x] for x in np.floor(df['1st Theme'].fillna(-1)).tolist()]
#df['1st Main Theme Numeric'] = np.floor(df['1st Theme'].fillna(-1)).tolist()

# %% Decode the sources
code_source = pd.read_csv('code_source.tsv', sep='\t')
code_book_source = {-1: 'Not coded'}
for i, row in code_source.iterrows():
    code_book_source[row['code']] = row['source']
# %%
df['Source Type String'] = [code_book_source[x] for x in np.floor(df['Source Type'].fillna(-1)).tolist()]
#df['Source Type Numeric'] = np.floor(df['Source Type'].fillna(-1)).tolist()

# %% Decode prevention sub-themes
code_prevention = pd.read_csv('codes_prevention.tsv', sep='\t')
code_book_prevention = {-1: 'Not coded', -2: 'Not prevention'}
for i, row in code_prevention.iterrows():
    code_book_prevention[row['code']] = row['theme']

# %%
prevention_string = []
for x in df['1st Theme'].fillna(-1).tolist():
    if x in code_book_prevention.keys():
        prevention_string.append(code_book_prevention[x])
    else:
        prevention_string.append(code_book_prevention[-2])
df['Prevention String'] = prevention_string

# %%
df.to_csv('aggregated_data.csv', index=False)

# %%
df_with_coding = df[~pd.isna(df['1st Theme'])]

#%%
print(df_with_coding)

# %%
df_with_coding.to_csv('aggregated_coded_data.csv')

# %%
