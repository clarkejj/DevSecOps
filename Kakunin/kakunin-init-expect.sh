#!/usr/bin/expect -f 
# File kakunin-init-expect.sh
spawn npm run kakunin init
#   expect "? What kind of application would you like to test?"
   expect "Answer: "
   send -- "3\r"
#   expect "? What is base url? [http://localhost:3000]"
   expect "Answer: "
   send -- "http://todomvc.com\r"
#   expect "? What kind of email service would you like to use?"
   expect "Answer: "
   send -- "1\r"
