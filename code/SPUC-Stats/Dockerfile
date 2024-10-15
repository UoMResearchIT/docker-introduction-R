FROM ghcr.io/uomresearchit/spuc:latest

RUN pip install pandas

COPY stats.py /spuc/plugins/stats.py
COPY print.config /code/config/print.config

ENV EXPORT=True

ENTRYPOINT ["python", "/spuc/spuc.py", "--units", "iulu"]
CMD []

