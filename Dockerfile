FROM apache/airflow:3.1.2-python3.12
USER root

RUN apt-get update \
  && apt-get install wget \
  && apt-get install gnupg2 \
  && apt-get update \
  && apt-get -y install vim
   
USER airflow
ENV PYTHONPATH="/opt/airflow/dags/include:${PYTHONPATH}"


COPY config/requirements.txt /opt/airflow
RUN pip install --no-cache-dir -r /opt/airflow/requirements.txt && rm /opt/airflow/requirements.txt

