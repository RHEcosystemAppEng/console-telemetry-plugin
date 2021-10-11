FROM registry.access.redhat.com/ubi8/nodejs-14:1 AS BUILD_IMAGE

USER 0
RUN npm i -g yarn@1.22.10
WORKDIR /opt/app-root/src/app
COPY . /opt/app-root/src/app
RUN yarn install
RUN yarn build

FROM registry.access.redhat.com/ubi8/nodejs-14-minimal:1

USER 65532:0
COPY LICENSE /licenses/LICENSE
WORKDIR /app
COPY --from=BUILD_IMAGE /opt/app-root/src/app/dist ./dist
COPY --from=BUILD_IMAGE /opt/app-root/src/app/node_modules ./node_modules
COPY --from=BUILD_IMAGE /opt/app-root/src/app/http-server.sh ./http-server.sh

USER 0
RUN chmod g+wr -R /app/dist
USER 65532:0

EXPOSE 9001
ENTRYPOINT [ "./http-server.sh", "./dist" ]
