FROM apache/airflow:3.1.2-python3.12
USER root

RUN apt-get update \
  && apt-get install wget \
  && apt-get install gnupg2 \
  && apt-get update \
  && apt-get -y install vim

#Installing odbc drivers
RUN sudo su \
  && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
  && curl https://packages.microsoft.com/config/debian/12/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list \
  && sudo apt-get update \
  && sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17 libfbclient2

#Installing bcp
RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc \
   && curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list \
   && sudo apt-get update && sudo ACCEPT_EULA=Y apt-get install -y mssql-tools18 unixodbc-dev \
   && echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile && source ~/.bash_profile

USER airflow
ENV PYTHONPATH="/opt/airflow/dags/include:${PYTHONPATH}"


COPY config/requirements.txt /opt/airflow
RUN pip install --no-cache-dir -r /opt/airflow/requirements.txt && rm /opt/airflow/requirements.txt
