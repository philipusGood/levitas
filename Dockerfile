FROM ruby:3.1.2-slim

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems (production only)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets (SECRET_KEY_BASE placeholder is fine at build time)
ENV RAILS_ENV=production
RUN SECRET_KEY_BASE=placeholder_for_asset_precompile \
    bundle exec rails assets:precompile

# Set up entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
