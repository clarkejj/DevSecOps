#!/usr/bin/expect -f 
spawn npm run kakunin init
   expect "? What kind of application would you like to test?"
   send -- "3\r"
   expect "? What is base url? [http://localhost:3000]"
   send -- "http://todomvc.com\r"
   expect "? What kind of email service would you like to use?"
   send -- "1\r"
