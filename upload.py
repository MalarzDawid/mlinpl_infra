from pydrive2.auth import GoogleAuth
from pydrive2.drive import GoogleDrive
from oauth2client.service_account import ServiceAccountCredentials
import pkg_resources
import os
import argparse


def upload_file_to_gdrive(filepath):
    gauth = GoogleAuth()
    # NOTE: if you are getting storage quota exceeded error, create a new service account, and give that service account permission to access the folder and replace the google_credentials.
    gauth.credentials = ServiceAccountCredentials.from_json_keyfile_name(
        pkg_resources.resource_filename(__name__, "credentials.json"), scopes=['https://www.googleapis.com/auth/drive'])

    drive = GoogleDrive(gauth)

    print(f"UPLOAD: {filepath}")
    filename = os.path.basename(filepath)
    file1 = drive.CreateFile({'parents': [{"id": ""}], 'title': filename})

    file1.SetContentFile(filepath)
    file1.Upload()
    print("\n--------- File is Uploaded ----------")
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--filename', type=str)
    args = parser.parse_args()
    upload_file_to_gdrive(args.filename)