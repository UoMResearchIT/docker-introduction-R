FROM python:3.12-slim

WORKDIR /spucsvi

COPY requirements.txt /spucsvi/requirements.txt
RUN pip install -r /spucsvi/requirements.txt

COPY ./*.py /spucsvi/
COPY ./templates /spucsvi/templates

CMD ["gunicorn", "-w", "1", "spucsvi:app", "-b", "0.0.0.0:8322", "--log-level", "warning"]
