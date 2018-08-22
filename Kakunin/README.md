README.md

https://github.com/TheSoftwareHouse/Kakunin/issues/71

In the script I had tried:

## Alternative 1:
<pre>
   npm run kakunin init << EOF
3
http://todomvc.com
1
EOF
</pre>
But that does not result in files being generated.

## Alternative 2:
echo "3 http://todomvc.com 1" | ./kakunin-install.sh
doesn't work either:
? What kind of application would you like to test? 
  1) Angular 1
  2) Angular 2
  3) Other web app (e.g. React, jQuery based etc.)
  Answer: 
>> Please enter a valid index

