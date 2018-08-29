#!/usr/bin/expect 
# File kakunin-init-expect.sh
# See https://www.pantz.org/software/expect/expect_examples_and_tips.html

#   set timeout -1  # wait to avoid timeout

spawn npm run kakunin init
#   expect "? What kind of application would you like to test?"
#  "/r" in for return key.
   expect "Answer: "
   send -- "3\r"

   expect "? What is base url? [http://localhost:3000]"
#   expect "{[#>$]}"         #expect several prompts, like #,$ and >
   send -- "http://todomvc.com\r"

#   expect "? What kind of email service would you like to use?"
   expect "Answer: "
   send -- "\r"

#   expect eof        ;# for the spawned task to end.
#   close