FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY pva_discovery.py .
USER 65534:65534
ENTRYPOINT ["python", "-u", "pva_discovery.py"]
