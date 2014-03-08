# coding: utf-8

require ('json')

module DummyData

  LOGIN_SUCCESSFUL = {'SessionId' => '111111111'}.to_json

  LOGIN_FAILED = {'ErrorMessage' => 'Неверный логин или пароль'}.to_json

  LOGOUT_SUCCESSFUL = {'Success' => true}.to_json
  LOGOUT_FAIL = {'Success' => false}.to_json

  CREATE_SENDING_SUCCESSFUL = {
    'CreatedSendings' => [
      {
        'EDTN' => '14',
        'IKN' => '9990000000',
        'Barcode' => '200819647155'
      }
    ],
    'RejectedSendings' => []
  }.to_json

  PDF_SUCCESS = '%PDF'

  PDF_ERROR = 'Error: Произошла ошибка'

  CITY_LIST_SUCCESS = [
    {'Id'=>3926841, 'Name'=>'Борзые', 'Owner_Id'=>923, 'RegionName'=>'Московская обл.'},
    {'Id'=>3940057, 'Name'=>'Северный', 'Owner_Id'=>5, 'RegionName'=>'Московская обл.'}
  ].to_json

  STATES_SUCCESS = [
    {'State'=>101, 'StateText'=>'Зарегистрирован'},
    {'State'=>102, 'StateText'=>'Сформирован для передачи Логисту'},
    {'State'=>103, 'StateText'=>'Развоз до ПТ самостоятельно'}
  ].to_json

  ZONES_SUCCESS = {
    'Error' => nil,
    'Zones' => [
      {
        'DeliveryMax' => 2,
        'DeliveryMin' => 1,
        'FromCity' => 'Химки',
        'Koeff' => 1,
        'ToCity' => 'Санкт-Петербург',
        'ToPT' => '7801-035',
        'Zone' => '0'
      }
    ]
  }.to_json

  GET_STATE_SUCCESS = [
    {
      "ChangeDT" => "16.01.14 00:28",
      "State" => 112,
      "StateMessage" => "Невостребованное",
      "InvoiceNumber"=>"0000000000000",
      "SenderInvoiceNumber"=>"00000"
    }
  ].to_json


  SAMPLE_SENDING_REQUEST =  [{
    'EDTN' => 14,
    'IKN' => '9990000000',
     'Invoice' => {
        'SenderCode' => 2121,
        'Description' => 'A description',
        'RecipientName' => 'John Doe',
        'PostamatNumber' => '6101-004',
        'MobilePhone' => '+79030000000',
        'Email' => nil,
        'PostageType' => '10003',
        'GettingType' => '101',
        'PayType' => '1',
        'Sum' => 4490.0,
        'SubEncloses' => [
          {
            'Line' => 1,
            'ProductCode' => 4559802,
            'GoodsCode' => '79380-555',
            'Name' => 'Fire extinguisher large',
            'Price' => 4290.0
          }]
      }
  }]

end
