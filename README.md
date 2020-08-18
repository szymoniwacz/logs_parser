# Logs parser

Usage
---
To execute script run it passing a path to log file as an argument.
```sh
ruby ./parser.rb webserver.log
```

The provided log file should be a text file with lines containing request path and IP address. E.g:
```
/pages/1 126.318.035.038
/pages/3 126.318.035.035
/pages/3 126.318.035.036
/pages/1 126.318.035.037
/about 126.318.035.037
/pages/2 126.318.035.035
```

Tests
---
To run tests 'rspec' gem is needed (```gem install rspec```) and run
```sh
rspec spec/spec.rb
```
