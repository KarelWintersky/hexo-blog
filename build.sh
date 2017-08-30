#!/bin/bash
### .config file is:
##!/bin/bash
# FTP_HOST=''
# FTP_LOGIN=''
# FTP_PASSWORD=''
# FTP_PATH=''

source .config
PATH_PUBLIC='./public'

# Generate static files

echo
echo '---------------------------------------------------------------------------------------'
echo 'Clearing public directory'
echo 
echo 'Generating static files'
echo '---------------------------------------------------------------------------------------'
echo 

rm -rf ${PATH_PUBLIC}

hexo generate

# Upload

echo
echo '---------------------------------------------------------------------------------------'
echo 'Clearing remote directory...'
echo '---------------------------------------------------------------------------------------'
echo 

lftp -e "rm -rf /${FTP_PATH}; mkdir -p /${FTP_PATH}; bye" -u ${FTP_LOGIN},${FTP_PASSWORD} ${FTP_HOST}

echo 
echo '---------------------------------------------------------------------------------------'
echo 'Uploading...'
echo '---------------------------------------------------------------------------------------'
echo 

cd $PATH_PUBLIC
# find ** > /tmp/upload.list
find ** -type f > /tmp/upload.list
wput --less-verbose --timestamping --input-file=/tmp/upload.list --reupload --binary ftp://$FTP_LOGIN:$FTP_PASSWORD@$FTP_HOST/$FTP_PATH

echo ''
echo '---------------------------------------------------------------------------------------'
echo 'Finish.'
echo '---------------------------------------------------------------------------------------'
echo

