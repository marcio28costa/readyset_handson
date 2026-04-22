FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir mysql-connector-python

COPY benchmark.py .

ENV STARTUP_RETRIES=8

CMD ["python", "-u", "benchmark.py"]
