FROM python:3.13-slim

WORKDIR /app

COPY app/ ./app/
COPY app/requirements.txt .
COPY run.py .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]