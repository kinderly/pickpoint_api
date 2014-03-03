# Pickpoint API

[![Build Status](https://travis-ci.org/kinderly/pickpoint_api.png?branch=master)](https://travis-ci.org/kinderly/pickpoint_api)

## Description

This gem provides a basic Ruby wrapper over [Pickpoint](http://pickpoint.ru/) API.

## Usage

```ruby
require('pickpoint_api')

PickpointApi.session('login', 'password', test: true) do |s|
  postamats = s.postamat_list

  s.create_sending(@my_sending_hash)

  tracking_response = s.track_sending(@invoice_id_1)

  labels_response_pdf = s.make_label([@invoice_id_1, @invoice_id_2])

  reestr_response_pdf = s.make_reestr([@invoice_id_1, @invoice_id_2])

end
```

Alternatively, you can create a Session object explicitly:

```ruby
require ('pickpoint_api')

session = PickpointApi::Session.new(test: true)
session.login('login', 'password')
tracking_response = session.track_sending(@invoice_id_1)
session.logout
```
