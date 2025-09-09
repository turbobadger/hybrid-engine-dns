# Basic Auth credentials for middlewares.basicauth
# Generate with:
#   htpasswd -nbB <user> <password> | sed -e 's/\$/\$\$/g' > traefik/auth/.htpasswd
# Then enable the basicauth middleware on your routers.

