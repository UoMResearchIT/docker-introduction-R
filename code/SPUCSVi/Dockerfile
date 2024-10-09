FROM python:3.12-slim

WORKDIR /spucsvi

COPY requirements.txt /spucsvi/requirements.txt
RUN pip install -r /spucsvi/requirements.txt


COPY ./*.py /spucsvi/
COPY ./templates /spucsvi/templates

# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000","--reload"]
CMD ["flask", "--app", "spucsvi", "run", "--debug", "--host", "0.0.0.0", "--port", "8322"]
