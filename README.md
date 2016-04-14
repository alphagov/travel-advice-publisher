# Travel Advice Publisher

Travel Advice Publisher manages foreign travel advice content on GOV.UK.

## Screenshots

![Travel Advice Publisher](docs/images/screenshot.png)

## Technical documentation

Travel Advice Publisher is a Ruby on Rails content management web application
which provides a versioned workflow for drafting and publishing [foreign travel
advice](http://www.gov.uk/foreign-travel-advice).  The application persists
content in MongoDB and in the downstream
[publishing-api](https://github.com/alphagov/publishing-api).  Travel advice
content is rendered by
[multipage-frontend](https://github.com/alphagov/multipage-frontend).

## Dependencies

- [asset-manager](https://github.com/alphagov/asset-manager)
- [content-store](https://github.com/alphagov/content-store)
- [panopticon](https://github.com/alphagov/panopticon)
- [publishing-api](https://github.com/alphagov/publishing-api)

## Running the application

`bundle exec rails s -p 3035`

## Running the test suite

`bundle exec rake`

## Further technical information

Detailed technical information can be found in the [travel advice publisher
documentation](docs/further-technical-information.md).
