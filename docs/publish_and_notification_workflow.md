# Publish and Notification Workflow

The act of ‘publishing’ an edition initiates a job with an ordered sequence of tasks that send the content to the [publishing api](https://github.com/alphagov/publishing-api) and trigger an email alert via the [email alerts api](https://github.com/alphagov/email-alert-api).

The [tasks order is validated](https://github.com/alphagov/travel-advice-publisher/blob/master/app/notifiers/publishing_api_notifier.rb#L43-43) to ensure that the email notification is always the final one.

The last task (delivery of email via the email-alert-api) queues up a new Sidekiq job only if the previous tasks completed successfully (publishing has succeeded).

## The Workflow
The publish action [builds an array of four tasks](https://github.com/alphagov/travel-advice-publisher/blob/master/app/controllers/admin/editions_controller.rb#L97-L101).

- [put_content](https://github.com/alphagov/travel-advice-publisher/blob/master/app/notifiers/publishing_api_notifier.rb#L7-7)
- [put_links](https://github.com/alphagov/travel-advice-publisher/blob/master/app/notifiers/publishing_api_notifier.rb#L13)
- [publish](https://github.com/alphagov/travel-advice-publisher/blob/master/app/notifiers/publishing_api_notifier.rb#L19)

If one of the first three actions fails for whatever reason, the [Sidekiq](http://sidekiq.org/) job fails and the retry mechanism kicks in (retries at exponentially increasing intervals up to 25 times in 21 days before being moved to the ‘dead’ queue).

Once the first three actions have succeeded, the [fourth action enqueues a new job to send the email notification command to email alerts api](https://github.com/alphagov/travel-advice-publisher/blob/master/app/workers/publishing_api_worker.rb#L9-L11). This job can then fail/retry/succeed as above.

## Publishing/Alert Status
The publisher currently has no view on the status of the publishing or email alert. Once they click `Publish` and the job is queued, a flash message is displayed - `Barbados travel advice published.` which at that point is not necessarily the case.
