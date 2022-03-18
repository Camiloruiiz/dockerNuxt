### STAGE 1: Build ###
FROM node:16.14.0 as build
RUN mkdir /usr/src/app
WORKDIR /usr/src/app
# ENV PATH /usr/src/app/node_modules/.bin:$PATH
COPY package.json /usr/src/app/package.json
RUN npm install
COPY . /usr/src/app
RUN npm run generate

### STAGE 2: NGINX ###
FROM nginx:stable-alpine
COPY --from=build /usr/src/app/public_html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
