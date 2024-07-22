# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%
from __future__ import print_function
import pickle
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import os
import pandas as pd
import io
from googleapiclient.http import MediaIoBaseDownload

SCOPES = ['https://www.googleapis.com/auth/drive']
creds = None
redownload =  True
parent_folder = '15CSJvK4uRwZFu_GNZvsAktKIy0gl9-x9'
credentials_json = 'credentials/credentials.json'
export_folder = 'drive_files'


if redownload:
    # Code from Quickstart - python Google API
    if os.path.exists('credentials/token.pickle'):
        with open('credentials/token.pickle', 'rb') as token:
            creds = pickle.load(token)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                credentials_json, SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('credentials/token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    drive_service = build('drive', 'v3', credentials=creds)

    # 
    results = drive_service.files().list(q="'%s' in parents" % parent_folder, pageSize=100, fields="nextPageToken, files(id, name)", corpora = 'allDrives', includeItemsFromAllDrives=True, supportsAllDrives=True).execute()
    items = results.get('files', [])

    if not os.path.exists(export_folder):
        os.mkdir(export_folder)

    for item in items:
        file_id = item['id']

        request = drive_service.files().export_media(fileId=file_id, mimeType='text/csv')
        fh = io.BytesIO()
        downloader = MediaIoBaseDownload(fh, request)
        done = False
        while done is False:
            status, done = downloader.next_chunk()
            print("Download %d%%." % int(status.progress() * 100))

        with io.open(export_folder+'/'+ item['name']+'.csv', 'wb') as writer:
            writer.write(fh.getvalue())

    



# %%
