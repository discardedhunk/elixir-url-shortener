
# Latest version of Erlang-based Elixir installation: https://hub.docker.com/_/elixir/
FROM elixir:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install the Phoenix framework itself
#RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

RUN mix local.hex --force \
 && mix archive.install --force  https://github.com/phoenixframework/archives/raw/master/phx_new.ez \
 && apt-get update \
 && curl -sL https://deb.nodesource.com/setup_6.x | bash \
 && apt-get install -y apt-utils \
 && apt-get install -y nodejs \
 && apt-get install -y build-essential \
 && apt-get install -y inotify-tools \
 && mix local.rebar --force

# Create and set home directory
ENV HOME /app
RUN mkdir -p $HOME
WORKDIR $HOME

# Configure required environment
#ENV MIX_ENV prod

# Set and expose PORT environmental variable
ENV PORT ${PORT:-4000}
EXPOSE $PORT

# Copy all dependencies files
#COPY mix.* ./
#
## Install all production dependencies
#RUN mix deps.get
#
## Compile all dependencies
#RUN mix deps.compile

# Copy all application files
ADD . $HOME

# Compile the entire project
#RUN mix compile

# Run Ecto migrations and Phoenix server as an initial command
#CMD mix do ecto.migrate, phx.server