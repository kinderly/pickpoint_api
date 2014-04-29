FactoryGirl.define do

  factory :label, class: PickpointApi::Label do
      postamat_number {"#{rand(1000..9999)}-#{rand(100..999)}"}
      client_name {Faker::Company.name}
      invoice_number {rand(15000000000..16000000000).to_s}
      inner_order_id {rand(1000..99999)}
      name {Faker::Name.name}
      phone {Faker::PhoneNumber.phone_number}
      total {rand(100.0..10000.0)}
      barcode {rand(100000000000..999999999999)}
  end

end

