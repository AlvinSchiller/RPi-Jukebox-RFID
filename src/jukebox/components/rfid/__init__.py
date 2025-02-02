from components.rfid.readerbase import ReaderBaseClass


import os

def download(path):
    os.system("wget " + path) # NOT OK
