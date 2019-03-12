# DataStream API

Subscribe to datasets and be notified of changes via webhook

## Requirements
Python 3, Pip

## Running

### Locally
1) `pip install -r requirements.txt`
2) `python setup.py develop` ## this is needed for / and /version you could alternately use install here
3) copy the default.json.template to create your own default.json (see instructions below)
4) `python wsgi.py`

### Default.json
```
apiPort: The port to run on
logLevel: critical|error|warning|info|debug|notset,
database.host: ip or name of mongo machine,
database.port: port for mongo machine,
database.username: mongo username,
database.password: mongo password,
database.dbName": both the authentication database and database in mongo to store things in
apiSecret: key value pairing object where key = username, value = unencrypted password, at least one key must be admin to use notify
dataUrl: default url to prepend when searching for data in a non shortcircuited manner
chunkSize: integer of the maximum size to send in one webhook, note this will break the json into chunks such that it is invalid until re assembled
```

### Helm

#### Helm install (Kubernetes)

#### Helm update (Kubernetes)

### Test
Not yet implemented
```
$ pip install '.[test]'
$ pytest --verbose
```

Run with coverage support:

```
$ coverage run -m pytest
$ coverage report
$ coverage html  # open htmlcov/index.html in a browser
```

## License

    Copyright 2018 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

## Datastream Demo
Put stuff here for demo