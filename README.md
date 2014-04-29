# Pickpoint API

[![Build Status](https://travis-ci.org/kinderly/pickpoint_api.png?branch=master)](https://travis-ci.org/kinderly/pickpoint_api)
[![Gem Version](https://badge.fury.io/rb/pickpoint_api.png)](http://badge.fury.io/rb/pickpoint_api)
[![Coverage Status](https://coveralls.io/repos/kinderly/pickpoint_api/badge.png)](https://coveralls.io/r/kinderly/pickpoint_api)
[![Code Climate](https://codeclimate.com/github/kinderly/pickpoint_api.png)](https://codeclimate.com/github/kinderly/pickpoint_api)

## Description

This gem provides a Ruby wrapper over [Pickpoint](http://pickpoint.ru/) API. All API methods documented by Feb 1 2014 are implemented.

## Installation

You can install this gem with the following command:

```bash
gem install pickpoint_api
```

Or, if you are using Bundler, add it to your Gemfile:

```ruby
gem pickpoint_api
```

If you desire to have the most up-do-date development version, add Git URL to the Gemfile:
```ruby
gem pickpoint_api, git: 'git@github.com:kinderly/pickpoint_api.git'
```

## Usage

```ruby
require('pickpoint_api')

PickpointApi.session('login', 'password', test: true) do |s|
  result = s.create_sending(@my_sending_hash)
  result = s.create_shipment(@my_shipment_hash)
  result = s.make_return(invoice_id: @invoice_id)
  result = s.make_return(sender_invoice_number: @order_number)
  return_invoices_list = s.get_return_invoices_list(DateTime.parse('2014-01-01'), DateTime.now)
  tracking_response = s.track_sending(@invoice_id)
  tracking_response = s.track_sending(nil, @order_number)
  info = s.sending_info(@invoice_id)
  info = s.sending_info(nil, @order_number)
  cost_result = s.get_delivery_cost(@delivery_hash)
  courier_result = s.courier(@courier_hash)
  courier_cancel_result = s.courier_cancel(@courier_order_number)
  reestr_response_pdf = s.make_reestr(@invoice_id)
  reestr_response_pdf = s.make_reestr([@invoice_id1, @invoice_id2])
  reestr_numbers = s.make_reestr_number(@invoice_id)
  reestr_numbers = s.make_reestr_number([@invoice_id1, @invoice_id2])
  reestr_pdf = get_reestr(@invoice_id)
  reestr_pdf = get_reestr(nil, @reestr_number)
  labels_pdf = make_label(invoice_id)
  labels_pdf = make_label([@invoice_id1, @invoice_id2])
  zebra_labels_pdf = make_zlabel(invoice_id)
  zebra_labels_pdf = make_zlabel([@invoice_id1, @invoice_id2])
  cities = s.city_list
  postamats = s.postamat_list
  zone_info = s.get_zone(@city_name)
  zone_info = s.get_zone(@city_name, @postamat_num)
  result = s.get_money_return_order(@ikn, @document_number, @date_from, @date_to)
  result = s.get_product_return_order(@ikn, @document_number, @date_from, @date_to)
  result = s.enclose_info(@barcode)
  history = s.track_sendings(invoice_id)
  history = s.track_sendings([@invoice_id1, @invoice_id2])
  states = s.get_states
  registered_invoices = s.get_invoices_change_state(101, @date_from, @date_to)
end
```

Alternatively, you can create a Session object explicitly:

```ruby
require ('pickpoint_api')

session = PickpointApi::Session.new(test: true)
session.login('login', 'password')
cities = s.city_list
postamats = s.postamat_list
zone_info = s.get_zone(@city_name)
session.logout
```

Please refer to the official [Pickpoint](http://pickpoint.ru/) API documentation to learn about method meanings, expected request arguments, data format etc.

### Rendering labels locally
You can render Pickpoint labels in your own layout without sending a request to Pickpoint API. The labels are rendered in HTML format.
```ruby
label = PickpointApi::Label.new
label.postamat_number = '1234-567'
label.client_name = 'Horns & Hooves LTD'
label.invoice_number = '1231231232'
label.inner_order_id = '32167'
label.name = 'John Doe'
label.phone = '+790311111111'
label.total = 3216.70
label.barcode = 210000000000

html = PickpointApi::Label.render(label)
```

You can also render several labels on one page:
```ruby
html = PickpointApi::Label.render([label1, label2, label3])
```

There's a built-in ERB template for rendering labels, but you can also provide your own:
```ruby
html = PickpointApi::Label.render(label, my_erb_string)
```
