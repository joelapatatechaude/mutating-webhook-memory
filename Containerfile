FROM registry.redhat.io/ubi9/ubi-minimal
RUN microdnf install python pip -y
RUN pip install fastapi uvicorn
EXPOSE 8000
COPY webhook.py /opt/webhook.py
CMD python /opt/webhook.py
