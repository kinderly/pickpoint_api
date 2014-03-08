# Pickpoint API

[![Build Status](https://travis-ci.org/kinderly/pickpoint_api.png?branch=master)](https://travis-ci.org/kinderly/pickpoint_api)
[![Gem Version](https://badge.fury.io/rb/pickpoint_api.png)](http://badge.fury.io/rb/pickpoint_api)
[![Coverage Status](https://coveralls.io/repos/kinderly/pickpoint_api/badge.png)](https://coveralls.io/r/kinderly/pickpoint_api)
[![Code Climate](https://codeclimate.com/github/kinderly/pickpoint_api.png)](https://codeclimate.com/github/kinderly/pickpoint_api)

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
