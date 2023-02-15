<p align="center">
  <a href="http://github.com/Colex/gdpr_admin" target="blank"><img src="https://i.ibb.co/mJwpsFY/logo.png" width="120" alt="GDPR and Ruby logo" /></a>
</p>

# GDPR Admin

[![Build Status](https://github.com/Colex/gdpr_admin/actions/workflows/build.yml/badge.svg)](https://github.com/Colex/gdpr_admin/actions/workflows/build.yml)
[![Code Climate](https://codeclimate.com/github/Colex/gdpr_admin.svg)](https://codeclimate.com/github/Colex/gdpr_admin)
[![Gem Version](https://badge.fury.io/rb/gdpr_admin.svg)](http://badge.fury.io/rb/gdpr_admin)

Rails engine for processing GDPR processes. GDPR Admin offers a simple interface for defining strategies for automating the process of data access and data removal as required by data privacy regulations like GDPR.

GDPR Admin uses simple Ruby classes, so you're free to code your Data Policies as you see fit. A swiss knife of
helper methods are available to make the processes even simpler.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "gdpr_admin"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install gdpr_admin
```

## Usage

Create your data policies file within `app/gdpr` _(configurable)_ and inherit from `GdprAdmin::ApplicationDataPolicy`.
Implement the methods `#scope`, `#export` and `#erase` for the new data policy. Within the data policy, you will be
able to access the `GdprAdmin::Request` object in any method by calling the method `request` - you can, therefore, have
different scopes and different removal behaviors depending on the request.

```ruby
class UserDataPolicy < GdprAdmin::ApplicationDataPolicy
  def scope
    User.with_deleted.where(updated_at: ...request.data_older_than)
  end

  def erase(user)
    user.update_columns(
      first_name: 'Anonymous',
      last_name: "User #{user.id}",
      email: "anonymous.user#{user.id}@company.co",
      anonymized_at: Time.zone.now,
    )
  end
end
```

Once you have all your data policies defined, create a `GdprAdmin::Request` to process a new request:

```ruby
GdprAdmin::Request.create!(
  tenant: current_tenant,
  requester: current_admin_user,
  request_type: 'erase_tenant',
  data_older_than: 1.month.ago, # Optional: by default, it will be todays date
)
```

Creating a request will automatically enqueue the request to be processed in 4 hours - this gives time to cancel an accidental request. You can configure this grace period as desired.

### Anonymization Helpers
A set of helper methods are available to make the anonymization even simpler. These are not mandatory, but can help you
keep your code cleaner and, better, write less code.

#### `erase_fields`

```ruby
erase_fields(record, fields, base_changes = {})
```

The method `erase_fields` is available in the Data Policy class. It expects an array of field anonymization options.
It will automatically process those fields and update the record in the database using `update_columns` (so validations
are skipped). The last optional argument (`base_changes`) is a hash of attributes that should be updated when the record
is updated. See the example below:

```ruby
class ContactDataPolicy < GdprAdmin::ApplicationDataPolicy
  def fields
    [
      { field: :first_name, method: :anonymize_first_name },
      { field: :last_name, method: :anonymize_last_name },
      { field: :gender, method: :skip },
      {
        field: :email,
        method: lambda { |contact|
          domain = contact.email[/@.*/]
          "anonymous.contact#{contact.id}#{domain}"
        },
      },
      { field: :street_address, method: :nilify },
      { field: :city, method: :anonymize_city, seed: :id },
    ]
  end

  def erase(contact)
    erase_fields(contact, fields, { anonymized_at: Time.zone.now })
  end
end
```

The anonymizers used above (e.g. `anonymize_first_name`), by default, will use the value of the field being updated as
the seed. That means that, when anonymization with the same anonymizer function, equal values will **always** yield the
same anonymized value. _(note: different values may also yield the same value)_

To use the built-in anonymizer functions, you need to install the gem `faker`.

## PaperTrail
GDPR Admin provides a set of tools to keep your PaperTrail GDPR Compliant.

### PaperTrail Data Privacy
By default, PaperTrail versions will not be anonymized. You may extend the default `PaperTrail::VersionDataPrivacy`
with your own scope. If you track custom fields with your versions (e.g. `ip`), then you can also define an anonymizer
for those here:

```ruby
# app/gdpr/paper_trail/version_data_privacy.rb

module PaperTrail
  class VersionDataPolicy < GdprAdmin::PaperTrail::VersionDataPolicy
    def fields
      [
        { field: 'ip', method: :anonymize_ip },
      ]
    end

    def scope
      return PaperTrail::Version.where(updated_at: ...request.data_older_than) if request.erase_data?

      PaperTrail::Version.none
    end
  end
end
```

#### `PaperTrail::VersionDataPolicy#erase`
**NOTE:** this method only support JSON format for `object` and, optionally, `object_changes`. If you need a different
format, you will need to re-implement this method as desired.

`erase(version, item_fields = nil)`

The `erase` method will, by default, anonymize the data within `object` and `object_changes` (and whichever fields are
defined in the `#fields` method). It will choose which fields to anonymize the `object` and `object_changes` and which
anonymization methods by finding the `item`'s data policy and loading the fields from its `fields` method. Unless
`item_fields` is defined, in which case it will be used instead.

For example, if you have a `item_type` set to `User`, it will try to find the `UserDataPrivacy`. If you want to use a
different class for a `item_type`, you must define a `data_policy_class` in the model.

```ruby
class User < ApplicationRecord
  def data_policy_class
    PersonDataPolicy
  end
end
```

If you'd like to just namespace all policies, then you can define `data_policy_prefix` in the `ApplicationRecord`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  def data_policy_prefix
    'Gdpr::'
  end
end

# Now, user should be defined in `Gdpr::UserDataPolicy`
```

### PaperTrail Helpers
When using the method `erase_fields`, no PaperTrail versions will be created in the database. GDPR Admin offer other
helper methods to deal with PaperTrail. (If you are not using `paper_trail`, this section may not be relevant)

#### `without_paper_trail`

Given a block, this method will execute it in a context where PaperTrail is disabled, so no versions are created:
```ruby
def erase(contact)
  without_paper_trail do
    contact.update!(first_name: 'John', last_name: 'Doe')
  end
end
```

As mentioned above, this is **not** required when using `erase_fields` as it is the default behavior.

## Configuration
Configure GDPR Admin in a initializer file `config/initializers/gdpr_admin.rb`. The configuration should be done within
the block of `GdprAdmin.configure(&block)`:

```ruby
# config/initializers/gdpr_admin/rb
GdprAdmin.configure do |config|
  # GDPR Admin configuration here...
end
```

### Multi-Tenancy
GDPR Admin is built maily for B2B SaaS services and it assumes that the service may have multiple tenants. The
`GDPR::Request` object always expects a `tenant` to be provided. When processing the request, data will be automatically
segregated using the tenant adapter.

#### Tenant Class
By default, GDPR Admin will assume that the tenant class is `Organization`. You can change that by setting the
`tenant_class` in the config.

```ruby
GdprAdmin.configure do |config|
  config.tenant_class = 'Tenant'
end
```

#### ActsAsTenant Adapter
You can segregated the process to a tenant using `ActsAsTenant` gem:

```ruby
GdprAdmin.configure do |config|
  config.tenant_adapter = :acts_as_tenant
end
```

### Jobs
Requests are processed asynchronously using ActiveJob.

#### Custom Queue
You can set which queue should be used to schedule the job for processing the request using the config `default_job_queue`:

```ruby
GdprAdmin.configure do |config|
  config.default_job_queue = :gdpr_tasks
end
```

#### Grace Periods
To allow for cancelling any accidental erasure request, the jobs are scheduled with a configurable grace period.
By default, erasure requests will wait 4 hours before being executed, while export requests will be executed immediately.

```ruby
GdprAdmin.configure do |config|
  config.erasure_grace_period = 1.day
  config.export_grace_period = 2.minutes
end
```

### Other Configurations

#### Data Policies Directory
By default, GDPR Admin will assume that your data policies are defined in `app/gdpr`. If you wish to have them
in a different place, you can change the option `data_policies_path`:

```ruby
GdprAdmin.configure do |config|
  # Change data policies path to be within the models directory (app/models/gdpr)
  config.data_policies_path = Rails.root.join('app', 'models', 'gdpr')
end
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
