FROM nginx:mainline-alpine
MAINTAINER recursethis

### template files
COPY ./templates/default.conf /etc/nginx/conf.d/

ENTRYPOINT ["nginx", "-g", "daemon off;"]
