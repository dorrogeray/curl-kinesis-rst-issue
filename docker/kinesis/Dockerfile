FROM node:20

ENV APPDIR /usr/src/app
ENV DATADIR /var/lib/kinesalite

USER root
RUN mkdir $APPDIR $DATADIR && chown node:node $APPDIR $DATADIR
USER node
WORKDIR $APPDIR

RUN npm install kinesalite@3.3.1

EXPOSE 4567
VOLUME $DATADIR

ENTRYPOINT ["node", "/usr/src/app/node_modules/kinesalite/cli.js", "--ssl", "--path", "/var/lib/kinesalite"]
