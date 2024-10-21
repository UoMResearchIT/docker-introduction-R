FROM python:3.12-slim

RUN apt update
RUN apt install -y curl

WORKDIR /spuc

COPY ./requirements.txt /spuc/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /spuc/requirements.txt

COPY ./*.py /spuc/
COPY ./config/*.config /spuc/config/
RUN mkdir /spuc/output

EXPOSE 8321

ENTRYPOINT ["python", "/spuc/spuc.py"]
CMD ["--units", "iuhc"]
