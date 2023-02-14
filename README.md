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
  request_type: 'erase_all',
  data_older_than: 1.month.ago, # Optional: by default, it will be todays date
)
```

Creating a request will automatically enqueue the request to be processed in 4 hours - this gives time to cancel an accidental request. You can configure this grace period as desired.

## Anonymization Helpers
A set of helper methods are available to make the anonymization even simpler. These are not mandatory, but can help you
keep your code cleaner and, better, write less code.

### erase_fields

```ruby
erase_fields(record, fields, base_changes = {})
```

The method `erase_fields` is available in the Data Policy class. It expects an array of field anonymization options.
It will automatically process those fields and update the record in the database using `update_columns` (so validations
are skipped). The last optional argument (`base_changes`) is a hash of attributes that should be updated when the record
is updated. See the example below:

```ruby
class ContactDataPolicy < GdprAdmin::ApplicationDataPolicy
  FIELDS = [
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

  def erase(contact)
    erase_fields(contact, FIELDS, { anonymized_at: Time.zone.now })
  end
end
```

The anonymizers used above (e.g. `anonymize_first_name`), by default, will use the value of the field being updated as
the seed. That means that, when anonymization with the same anonymizer function, equal values will **always** yield the
same anonymized value. _(note: different values may also yield the same value)_

To use the built-in anonymizer functions, you need to install the gem `faker`.

## Multi-Tenancy
GDPR Admin is built maily for B2B SaaS services and it assumes that the service may have multiple tenants. The
`GDPR::Request` object always expects a `tenant` to be provided. When processing the request, data will be automatically
segregated using the tenant adapter.

### Tenant Class
By default, GDPR Admin will assume that the tenant class is `Organization`. You can change that by setting the
`tenant_class` in the config.

```ruby
GdprAdmin.configure do |config|
  config.tenant_class = 'Tenant'
end
```

### ActsAsTenant Adapter
You can segregated the process to a tenant using `ActsAsTenant` gem:

```ruby
GdprAdmin.configure do |config|
  config.tenant_adapter = :acts_as_tenant
end
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
