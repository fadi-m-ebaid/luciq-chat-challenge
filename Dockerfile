# Dockerfile

# 1. Base Image: Start with an official Ruby image
FROM ruby:3.4.7-slim-bookworm

# 2. Set Environment Variables
ENV RAILS_LOG_TO_STDOUT=true \
    BUNDLE_WITHOUT="development:test" \
    WORKDIR=/app

WORKDIR $WORKDIR

# 3. Install Essential Dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev default-mysql-client default-libmysqlclient-dev nodejs yarn git

# 4. Copy Gemfiles to trace dependancies change and optemize build
COPY Gemfile Gemfile.lock ./

# 5. Install Ruby Gems
RUN bundle install

# 6. Copy Application Code
COPY . .

# 7. Listen Port# This tells Docker that our application will listen for connections on port 3000.
EXPOSE 3000

# 8. Entrypoint# This is the main command that will run when the container starts.# It runs a script that can fix a common Rails/Docker issue and then starts the server.
COPY entrypoint.sh /bin/
RUN chmod +x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

# 9. Start the Rails Server
CMD ["rails", "server", "-b", "0.0.0.0"]