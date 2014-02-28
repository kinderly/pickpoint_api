module PickpointApi::Constants
  API_HOST = 'e-solution.pickpoint.ru'
  API_PORT = 80
  API_TEST_PATH = '/apitest'
  API_PROD_PATH = '/api'

  ACTIONS = {
    login:
    {
      path: '/login',
      method: :post
    },
    logout:
    {
      path: '/logout',
      method: :post
    },
    create_sending:
    {
      path: '/createsending',
      method: :post
    },
    create_shipment:
    {
      path: '/createshipment',
      method: :post
    },
    make_return:
    {
      path: '/makereturn',
      method: :post
    },
    get_return_invoice_list:
    {
      path: '/getreturninvoiceslist',
      method: :post
    },
    track_sending:
    {
      path: '/tracksending',
      method: :post
    },
    sending_info:
    {
      path: '/sendinginfo',
      method: :post
    },
    get_delivery_cost:
    {
      path: '/getdeliverycost',
      method: :post
    },
    courier:
    {
      path: '/courier',
      method: :post
    },
    courier_cancel:
    {
      path: '/couriercancel',
      method: :post
    },
    make_reestr:
    {
      path: '/makereestr',
      method: :post
    },
    make_reestr_number:
    {
      path: '/makereestrnumber',
      method: :post
    },
    get_reestr:
    {
      path: '/getreestr',
      method: :post
    },
    make_label:
    {
      path: '/makelabel',
      method: :post
    },
    make_zlabel:
    {
      path: '/makeZlabel',
      method: :post
    },
    city_list:
    {
      path: '/citylist',
      method: :get
    },
    postamat_list:
    {
      path: '/postamatlist',
      method: :get
    },
    get_zone:
    {
      path: '/getzone',
      method: :post
    },
    get_money_return_order:
    {
      path: '/getmoneyreturnorder',
      method: :post
    },
    get_product_return_order:
    {
      path: '/getproductreturnorder',
      method: :post
    },
    enclose_info:
    {
      path: '/encloseinfo',
      method: :post
    },
    track_sendings:
    {
      path: '/tracksendings',
      method: :post
    },
    get_states:
    {
      path: '/getstates',
      method: :get
    },
    get_invoices_change_state:
    {
      path: '/getInvoicesChangeState',
      method: :post
    }
  }.freeze

end
