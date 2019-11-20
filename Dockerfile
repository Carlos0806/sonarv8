FROM openjdk:11

LABEL maintainer="Carlos Escobar <cescobar@uva3.com>"


RUN apt-get update \
    && apt-get install -y curl unzip libfreetype6 libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

# Http port
EXPOSE 9000

#RUN groupadd -r sonarqube && useradd -r -g sonarqube sonarqube

ARG SONAR_VERSION=8.0
ARG SONARQUBE_ZIP_DIR=/tmp/zip
ARG SONARQUBE_ZIP_LOCATION=$SONARQUBE_ZIP_DIR/sonarqube-${SONARQUBE_VERSION}.zip
ENV SONAR_VERSION=8.0 \
    SONAR_SCANNER_VERSION=4.2.0.1873 \
    NODE_VERSION=8.12.0 \
    NPM_VERSION=5.6.0 \
    SONAR_URL=https://binaries.sonarsource.com/Distribution \
    SONARQUBE_HOME=/opt/sq \
    SONARQUBE_PUBLIC_HOME=/opt/sonarqube \
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONAR_SCANNER_HOME=/opt/sonar-scanner \
    PATH=$PATH:/opt/sonar-scanner/bin \
    SONARQUBE_JDBC_URL= 
    
# Install gosu
# RUN set -x \
#     && echo "---> Installing gosu" \
#     && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
#     && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
#     && export GNUPGHOME="$(mktemp -d)" \
#     && for server in $(shuf -e ha.pool.sks-keyservers.net \
#                             hkp://p80.pool.sks-keyservers.net:80 \
#                             keyserver.ubuntu.com \
#                             hkp://keyserver.ubuntu.com:80 \
#                             pgp.mit.edu) ; do \
#         gpg --batch --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
#     done \
#     && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
#     && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
#     && chmod +x /usr/local/bin/gosu \
#     && gosu nobody true 

# Install  node and npm    
RUN set -x \
    apt-get -qq update \
    && echo "---> Installing node" \
    && curl -SLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz" \
    # tar -xJf "node-v${NODE_VERSION}-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
    && gunzip "node-v${NODE_VERSION}-linux-x64.tar.gz"  \
    && tar -xvf "node-v${NODE_VERSION}-linux-x64.tar" -C /usr/local --strip-components=1 \
    && rm "node-v${NODE_VERSION}-linux-x64.tar" \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && chmod 777 /usr/local/lib/node_modules -R \
    && echo "---> Installing npm" \
    && npm install -g npm@${NPM_VERSION}

  
# RUN set -x \
#     # create user with appropriate rights, groups and permissions
#     && useradd --user-group --create-home sonarqube \
#     && echo "---> Installing SonarQube" \
#     && cd /opt \
#     && wget -O sonarqube.zip --no-verbose $SONAR_URL/sonarqube/sonarqube-$SONAR_VERSION.zip \
#     && unzip sonarqube.zip \
#     && mv sonarqube-$SONAR_VERSION sonarqube \
#     && chown -R sonarqube:sonarqube sonarqube \
#     && rm sonarqube.zip* \
#     && rm -rf $SONARQUBE_HOME/bin/* \

SHELL ["/bin/bash", "-c"]
RUN sed -i -e "s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" \
  "$JAVA_HOME/conf/security/java.security" 

#Install SonarQube and SonarScanner
RUN set -x \
    && useradd --user-group --create-home sonarqube \
    && echo "---> Installing SonarQube" \
    && cd /opt \
# download and unzip Sonarqube
    && if [ -f "$SONARQUBE_ZIP_LOCATION" ] ; \
        then cp "$SONARQUBE_ZIP_LOCATION" sonarqube.zip; \
        else curl -o sonarqube.zip -fsSL "$SONAR_URL/sonarqube/sonarqube-$SONAR_VERSION.zip" ; \
        fi \
    && rm -Rf $SONARQUBE_ZIP_DIR \
    && unzip -q sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sq \
    && rm sonarqube.zip* \
# empty bin directory from useless scripts
# create copies or delete directories allowed to be mounted as volumes, original directories will be recreated below as symlinks
    && rm --recursive --force "$SONARQUBE_HOME/bin"/* \
    && mv "$SONARQUBE_HOME/conf" "$SONARQUBE_HOME/conf_save" \
    && mv "$SONARQUBE_HOME/extensions" "$SONARQUBE_HOME/extensions_save" \
    && rm --recursive --force "$SONARQUBE_HOME/logs" \
    && rm --recursive --force "$SONARQUBE_HOME/data" \
# create directories to be declared as volumes
# copy into them to ensure they are initialized by 'docker run' when new volume is created
# 'docker run' initialization will not work if volume is bound to the host's filesystem or when volume already exists
# initialization is implemented in 'run.sh' for these cases
    && mkdir --parents "$SONARQUBE_PUBLIC_HOME/conf" \
    && mkdir --parents "$SONARQUBE_PUBLIC_HOME/extensions" \
    && mkdir --parents "$SONARQUBE_PUBLIC_HOME/logs" \
    && mkdir --parents "$SONARQUBE_PUBLIC_HOME/data" \
    && cp --recursive "$SONARQUBE_HOME/conf_save"/* "$SONARQUBE_PUBLIC_HOME/conf/" \
    && cp --recursive "$SONARQUBE_HOME/extensions_save"/* "$SONARQUBE_PUBLIC_HOME/extensions/" \
# create symlinks to volume directories
    && ln -s "$SONARQUBE_PUBLIC_HOME/conf" "$SONARQUBE_HOME/conf" \
    && ln -s "$SONARQUBE_PUBLIC_HOME/extensions" "$SONARQUBE_HOME/extensions" \
    && ln -s "$SONARQUBE_PUBLIC_HOME/logs" "$SONARQUBE_HOME/logs" \
    && ln -s "$SONARQUBE_PUBLIC_HOME/data" "$SONARQUBE_HOME/data" \
    && chown --recursive sonarqube:sonarqube "$SONARQUBE_HOME" "$SONARQUBE_PUBLIC_HOME" \
# Install Sonar Scanner    
    && echo "---> Installing Sonar Scanner" \
    && wget -O sonarscanner.zip --no-verbose $SONAR_URL/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION.zip \
    && unzip sonarscanner.zip \
    && mv sonar-scanner-$SONAR_SCANNER_VERSION sonar-scanner \
    && rm sonarscanner.zip

#ADD sonar-l10n-zh-plugin-1.21.jar /opt/sonarqube/extensions/plugins/

#COPY zip/* $SONARQUBE_ZIP_DIR

VOLUME "$SONARQUBE_HOME/data"

COPY --chown=sonarqube:sonarqube run.sh "$SONARQUBE_HOME/bin/"

USER sonarqube

WORKDIR $SONARQUBE_HOME

ENTRYPOINT ["./bin/run.sh"]