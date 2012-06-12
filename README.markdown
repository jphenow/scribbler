# Scribbler

Scribbler is a little utility for simplifying logging across one application or more.
Currently it assists in:

* Dynamically defining methods for accessing the log files
* Centralized log method for file, message, and error checks
  - Currently also able to notify NewRelic, abstraction and extension to come

## Todo

* Finish making `rake scribbler:install` copy some initial template files
* More options in configure
* More testing
* Currently attempts to notify NewRelic if its there, abstract and allow custom services
