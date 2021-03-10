# frozen_string_literal: true

RSpec.describe 'tapy generate', type: :feature do
  before { reload_tmp }

  context 'with a valid repo' do
    it 'render a root file' do
      run_command('tapy g http://gitserver/tapy-docker.git', path: 'tmp/')

      expected_rendered_file = <<~DESC
        FROM ruby:2.7.2-alpine AS dev

        RUN apk update \\
          && apk upgrade \\
          && apk add --update \\
            tzdata \\
            linux-headers \\
            build-base \\
            && rm -rf /var/cache/apk/*

        WORKDIR /usr/src/app

        # TODO: Add production stage

        FROM dev AS release

        COPY Gemfile Gemfile.lock ./

        RUN bundle install --jobs 2 --retry 1

        COPY . .
      DESC

      expect(File.read('tmp/Dockerfile')).to eq(expected_rendered_file)
    end

    it 'render subfolder file' do
      run_command('tapy g http://gitserver/tapy-docker.git', path: 'tmp/')

      expected_rendered_file = <<~DESC
        FROM ruby:2.7.2-alpine AS dev

        RUN ruby -e 'puts "Hello World"'
      DESC

      expect(File.read('tmp/docker/other/Dockerfile')).to eq(expected_rendered_file)
    end

    context 'with valid options' do
      it 'executes the command' do
        run_command('tapy g http://gitserver/tapy-docker.git ruby:2.6.6 bundler:2.1.4 postgres', path: 'tmp/')

        expected_rendered_file = <<~DESC
          FROM ruby:2.6.6-alpine AS dev

          RUN apk update \\
            && apk upgrade \\
            && apk add --update \\
              tzdata \\
              linux-headers \\
              build-base \\
              postgresql-dev  \\
              postgresql-client \\
              && rm -rf /var/cache/apk/*

          WORKDIR /usr/src/app

          RUN gem install bundler -v 2.1.4

          # TODO: Add production stage

          FROM dev AS release

          COPY Gemfile Gemfile.lock ./

          RUN bundle install --jobs 2 --retry 1

          COPY . .
        DESC

        expect(File.read('tmp/Dockerfile')).to eq(expected_rendered_file)
      end
    end

    it 'render subfolder file' do
      run_command('tapy g http://gitserver/tapy-docker.git ruby:2.6.6 bundler:2.1.4 postgres', path: 'tmp/')

      expected_rendered_file = <<~DESC
        FROM ruby:2.6.6-alpine AS dev

        RUN ruby -e 'puts "Hello World"'
      DESC

      expect(File.read('tmp/docker/other/Dockerfile')).to eq(expected_rendered_file)
    end
  end
end
