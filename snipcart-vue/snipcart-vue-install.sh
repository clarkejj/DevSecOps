#!/bin/bash

# This is snipcart-vue-install.sh from https://github.com/wilsonmar/DevSecOps/master/snipcart-vue
# from 

# https://github.com/sanity-io/example-ecommerce-snipcart-vue
# It uses snipcart with vue.js, nuxt.js, etc.

# Need to add in - https://www.gatsbyjs.org/
# based on https://github.com/gatsbyjs/gatsby/
# https://github.com/serverless/components/tree/master/examples/retail-app/
# Twitter: #buildwithgatsby

function fancy_echo() {
   local fmt="$1"; shift
   # shellcheck disable=SC2059
   printf "\\n>>> $fmt\\n" "$@"
}

module="snipcart-vue"

# Check response above for:
# nvm
# Found by manual nvm ls-remote
nvm update --lts node
nvm update node
nvm update npm

# node -lts
# npm update yarn
# Other prerequisites: babel, etc.

### Cleanup:

   # Kill gatsby process if it's still running from previous run:
   PID="$(ps -A | grep -m1 '$module' | grep -v "grep" | awk '{print $1}')"
      if [ ! -z "$PID" ]; then 
         fancy_echo "$module running on PID=$PID. killing it ..."
         kill $PID
      else
         fancy_echo "$module not found running on PID=$PID ..."
      fi

# https://github.com/sanity-io/example-ecommerce-snipcart-vue
# npm install
# npm run dev
# open localhost:3000

   ### Delete container folder from previous run (or it will cause error), thus the container:
   ### Download again, but things have probably changed anyway:
   cd ~/
         if [ -d "$package_path" ]; then  # found:
            # Delete container folder from previous run (or it will cause error), thus the container:
            fancy_echo "Deleting container folder: $package_path ..."
            rm -rf "$package_path"
         fi
         # Create container folder again:
         mkdir "$package_path" && cd "$package_path"
         fancy_echo "PWD=$PWD"

# See list at https://www.gatsbyjs.org/docs/gatsby-starters/
if [ "$GATSBY_PROJECT" = "snipcart-jekyll-integration" ]; then
   fancy_echo "$GATSBY_PROJECT"
   # Alternative  - https://snipcart.com/blog/static-site-e-commerce-part-2-integrating-snipcart-with-jekyll
     # by Maxime Laboissonniere
   # gatsby new "$GATSBY_PROJECT" https://github.com/snipcart/snipcart-jekyll-integration
  # jekyll serve
     # live demo at http://snipcart.github.io/snipcart-jekyll-integration/

   # exit/ skip to testing
elif [ "$GATSBY_PROJECT" = "gatsby-starter-blog" ]; then

   # Alternative 2 - https://snipcart.com/blog/snipcart-reactjs-static-ecommerce-gatsby JANUARY 28, 2016
   gatsby new "$GATSBY_PROJECT" https://github.com/gatsbyjs/gatsby-starter-blog
    # Demo: http://snipcart-gatsby.netlify.com/  by Gabriel Robert - https://twitter.com/kvlt_grobert
   # mkdir /posts/ then
   # mkdir bow-tie and curl from index.md
   # mkdir fireworks and curl from index.md
   # mkdir fireworks and curl from index.md

   # TODO: Make changes to config.toml & /pages/bow-ties/index.md per https://next.gatsbyjs.org/docs/gatsby-starters/
    # see https://github.com/gatsbyjs/gatsby/#-get-up-and-running-in-5-minutes
			# by Kyle Mathews   
         # https://github.com/snipcart/snipcart-gatsby-integration # last changed Jan 28, 2016

#elif [ "$GATSBY_PROJECT" = "gatsby-netlify" ]; then
#   gatsby new "$GATSBY_PROJECT" https://github.com/wilsonmar/gatsby-netlify

   # The repo was forked from https://github.com/snipcart/gatsby-netlify
   # as described by https://snipcart.com/blog/static-forms-serverless-gatsby-netlify
   # A demo of it by the original author is at https://gatsby-netlify-snipcart.netlify.com/

elif [ "$GATSBY_PROJECT" = "gatsby-material-starter" ]; then
   # Alternative 3 - Per https://snipcart.com/blog/pwa-example-ecommerce-gatsby
   # A PWA Example: Build an E-Commerce Progressive Web App with Gatsby JULY 03, 2018
                       # Demo: https://vagr9k.github.io/gatsby-material-starter/
   gatsby new "$GATSBY_PROJECT" https://github.com/Vagr9K/gatsby-material-starter
   # BLAH: I'm getting errors about dependencies. 

elif [ "$GATSBY_PROJECT" = "gatsby-starter-gatsbythemes" ]; then
   gatsby new "$GATSBY_PROJECT" https://github.com/saschajullmann/gatsby-starter-gatsbythemes

elif [ "$GATSBY_PROJECT" = "gatsby-starter-bulma-storybook" ]; then
   gatsby new "$GATSBY_PROJECT" https://github.com/gvaldambrini/gatsby-starter-bulma-storybook
   # BLAH: I'm getting "Failed to compile with 7 errors"

#elif [ "$GATSBY_PROJECT" = "gatsby-???" ]; then

#elif [ "$GATSBY_PROJECT" = "snipcart-gatsby-grav.netlify.com" ]; then
#   gatsby new "$GATSBY_PROJECT" https://snipcart-gatsby-grav.netlify.com
   # Makes use of Grav CMS

#elif [ "$GATSBY_PROJECT" = "gatsby-???" ]; then
   # Alternative 5 - https://www.datocms.com/blog/static-ecommerce-website-snipcart-gatsbyjs-datocms/
   # Makes use of DatoCMS

else 
    fancy_echo "GATSBY_PROJECT=$GATSBY_PROJECT not recognized. Exiting."
    exit  #ERROR
fi


### TODO: Update package.json per # https://hackernoon.com/testing-react-components-with-jest-and-enzyme-41d592c174f
### TODO: Copy html.jsx and 
# replace "{SNIPCART API KEY}" with API KEY from Snipcart.

### Catch return code from previous step:
if [ $? -ne 0 ]; then
    fancy_echo "previous command $? did not finish well. Exiting."
    exit
fi

   cd "$GATSBY_PROJECT"
   fancy_echo "Running gatsby develop in background at PWD=$PWD ..."
   gatsby develop --verbose &
   ### Catch return code from previous step:
   if [ $? -ne 0 ]; then
     fancy_echo "previous command $? did not finish well. Exiting."
     exit
   fi

   ### Get process ID:
   PID="$(ps -A | grep -m1 'gatsby' | grep -v "grep" | awk '{print $1}')"
      if [ ! -z "$PID" ]; then 
         fancy_echo "gatsby running on PID=$PID. killing it ..."
      fi
   # ps -al

# gatsby serve   # starts a local HTML server for testing your built site.
# open "http://localhost:$GATSBY_IP"


### TODO: Setup testing (version-specific):
# npm install --save-dev jest react-test-renderer enzyme enzyme-adapter-react-16 enzyme-to-json
# TODO: need babel-jest for Babel https://github.com/facebook/jest/tree/master/packages/babel-jest
# npm install --save-dev ts-jest  # for TypeScript. https://github.com/kulshekhar/ts-jest

### Install Jest :
   module="jest-cli"
   if [ -z "$(npm list -g "$module" | grep "$module")" ] ; then # empty, so install:
      fancy_echo "Installing $module at $PWD ..."
      npm install -g $module  # globally
   else  # not empty, installed:
      fancy_echo "$module already installed ..." 
   fi      
#   npm list -g "$module"
   # ls -al node_modules
exit

### TODO: Build and Run tests
# https://www.robinwieruch.de/react-testing-tutorial/
   # Use Jest along with Enzyme for unit/integration/snapshot tests. 
      # https://medium.com/@guidsen/testing-your-react-components-with-enzyme-5f1c7f185b58#.pwa0lobix
      # Jest is used by Facebook to test all JavaScript code including React applications. 
      # One of Jest’s philosophies is to provide an integrated “zero-configuration” experience. 
      # Jest parallelizes test runs across workers to maximize performance.
      # Since Jest comes with its own Test Runner and Assertion functionalities, it makes Mocha and Chai obsolete. 

      # Enzyme is a JavaScript utility for React to assert, manipulate, and traverse React Component outputs.
      # Originally developed by Airbnb, http://airbnb.io/enzyme/index.html
      # It can be used with any test runner (mocha, jasmine,…)

   # use shallow rendering with Jest snapshots.
   # est stores snapshots besides your tests in files like __snapshots__/Label.spec.js.snap 
   # that you commit with your code.
   # interactive watch mode that reruns only tests that are relevant to your changes.

   # Shallow rendering renders only component itself without its children. It doesn’t require DOM.
   # So if you change something in a child component it won’t change shallow output of your component. 
   # Or a bug, introduced to a child component, won’t break your component’s test. 

      # Use enzyme-to-json to convert Enzyme wrappers for Jest snapshot matcher. https://github.com/adriantoine/enzyme-to-json
      # Enzyme work with shallow rendering, static rendered markup or DOM rendering.
   # Use Cypress for E2E tests.

### Make change to code
# See https://next.gatsbyjs.org/tutorial/
# Make changes by editing src/pages/index.js
# Save the changes and the browser should update in real time.

### Create a production build:
# gatsby build
yarn build

### Run a local HTML server to test the web application in production mode (on port 9000):
yarn serve
http://localhost:9000 

### TODO: Get a GCP account
### TODO: Create a GCP project (one time) at https://console.cloud.google.com/cloud-resource-manager?_ga=2.128790540.-185449045.1526826697
# Make sure that billing is enabled for your project. https://cloud.google.com/billing/docs/how-to/modify-project
### TODO: At the domain registrar (GoDaddy or domains.Google.com), get a real domain name.
### TODO: Set CNAME to points to c.storage.googleapis.com.
# Verify to Google that you own the domain https://cloud.google.com/storage/docs/domain-name-verification#verification
### TODO: Set monitoring https://cloud.google.com/storage/docs/static-website#tip-charges

### TODO: Manually Create a bucket to store assets (one time)
### Push to CDN for hosting (Cloudflare, AWS, Azure, Google, Heroku)
# See https://cloud.google.com/storage/docs/hosting-static-website

### Deploy using Netlify CDN:
exit

### Deploy to CDN for public production view:
   module="netlify-cli"
   if [ -z "$(npm list -g "$module" | grep "$module")" ] ; then # empty, so install:
      fancy_echo "Installing $module at $PWD ..."
      npm install -g $module  # globally
   else  # not empty, installed:
      fancy_echo "$module already installed ..." 
   fi      

   netlify init
   netlify update -n snipcart-gatsby
   netlify deploy


### Run Google Lighthouse report:
   module="lighthouse"
   if [ -z "$(npm list -g "$module" | grep "$module")" ] ; then # empty, so install:
      fancy_echo "Installing $module at $PWD ..."
      npm install -g $module  # globally
   else  # not empty, installed:
      fancy_echo "$module already installed ..." 
      npm upgrade -g $module  # globally
   fi      

lighthouse  --output json https://ll....
