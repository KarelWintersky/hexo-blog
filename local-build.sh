#!/bin/bash
hexo generate

echo 'removing old content'
rm -rf /srv/webhosts/localhost/localhost/blog/*

echo 'copying new content'
cp -r /srv/hexoblog/public/* /srv/webhosts/localhost/localhost/blog/ 
