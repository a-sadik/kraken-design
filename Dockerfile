FROM registry.udd.attijariwafa.net/base/ubi9/nodejs-20:latest as builder
WORKDIR /app
USER root
COPY package*.json ./

# Configuring npm for your internal registry
RUN ulimit -u 1024
RUN npm config set strict-ssl false
RUN npm config set registry http://172.29.7.156:8081/repository/npm-public/
RUN npm config set //172.29.7.156:8081/repository/npm-public/:_auth=cG9ydGFpbHdnOjIwMjQqcG9ydGFpbFdBZmE=
COPY . .
RUN npm install
RUN npm run build

FROM registry.udd.attijariwafa.net/base/ubi9/nginx-124:latest
USER root
WORKDIR /opt/app-root/src
COPY --chown=1001:0 --from=builder /app/dist /opt/app-root/src
COPY nginx.conf /etc/nginx/nginx.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN chmod 777 -R /opt/app-root/src
USER 1001
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
 
