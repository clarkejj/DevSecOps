execution-tests.sh

# https://github.com/intuit/karate/issues/396

docker run --volume ${bamboo.working.directory}/reports:/usr/src/app/target --workdir /usr/src/app --rm mypersonal-Registry/bdd-api:latest mvn test -Dcucumber.options="--tags @MyTags"

Reports available in path ${bamboo.working.directory}/reports after execution.