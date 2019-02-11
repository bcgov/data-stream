# Lightning API

Subscribe to datasets and be notified of changes via webhook

#Requirements
Python 3, Pip

# Running

## Locally
1) `pip install -r requirements.txt`
2) `python setup.py develop` ## this is needed for / and /version you could alternately use install here
1) `python wsgi.py`

## Helm

### Helm install (Kubernetes)

### Helm update (Kubernetes)

# Test

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
