FROM python:3.7

WORKDIR /app

COPY requirements.txt requirements.txt
COPY README.md README.md
COPY setup.py setup.py

RUN pip install -r requirements.txt
RUN python setup.py install

COPY . .

EXPOSE 3003

ENTRYPOINT ["python", "wsgi.py"]