# PurlFetcher::Client

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/purl_fetcher/client`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'purl_fetcher-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install purl_fetcher-client

## Usage

### Uploading a file

```ruby
PurlFetcher::Client.configure(url:'http://127.0.0.1:3000')

PurlFetcher::Client::UploadFiles.upload(
  file_metadata: {
    'file1.txt' => PurlFetcher::Client::DirectUploadRequest.new(
      checksum: '123',
      byte_size: 10_000,
      content_type: 'image/tiff',
      filename: 'image.tiff'
    )
  },
  filepath_map: {
    'file1.txt' => File.expand_path('Gemfile.lock')
  }
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/purl_fetcher-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the PurlFetcher::Client project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/purl_fetcher-client/blob/main/CODE_OF_CONDUCT.md).
