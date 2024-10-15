FROM spuacv/spuc:latest

RUN pip install pandas

COPY stats.py /spuc/plugins/stats.py
COPY print.config /spuc/config/print.config

ENV EXPORT=true

ENTRYPOINT ["python", "/spuc/spuc.py"]
CMD ["--units", "iulu"]
