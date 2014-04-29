require 'barby'
require 'barby/barcode/code_25_interleaved'
require 'barby/outputter/png_outputter'
require 'base64'
require 'erb'

class PickpointApi::Label

  attr_accessor :postamat_number
  attr_accessor :client_name
  attr_accessor :invoice_number
  attr_accessor :inner_order_id
  attr_accessor :name
  attr_accessor :phone
  attr_accessor :total
  attr_accessor :barcode

  def postamat_minor
    postamat_number[0..2]
  end

  def postamat_major
    postamat_number[3..postamat_number.size-1]
  end

  def barcode_raw(height = 75)
    bc = Barby::Code25Interleaved.new(barcode)
    bc.wide_width = 5
    bc.narrow_width = 2
    Base64.encode64(bc.to_png(height: height, margin: 0))

  end

  def barcode_base64(height = 75)
    s = barcode_raw(height)
    "data:image/png;base64,#{s}"
  end

  def self.render(labels, template = nil)
    renderer = ERB.new(template || default_template)
    labels = labels.is_a?(Array) ? labels : [labels]
    @labels = labels.select{|l| l.is_a?(PickpointApi::Label)}
    renderer.result(binding)
  end

  def pickpoint_logo_base_64
    @logo ||= "data:image/png;base64,#{Base64.encode64(File.binread(self.class.pickpoint_logo))}"
  end

  private

  def self.default_template
    File.read(default_erb)
  end

  def self.path(filename)
    File.join(File.dirname(File.expand_path(__FILE__)), filename)
  end

  def self.default_erb
    path('templates/labels.html.erb')
  end

  def self.pickpoint_logo
    path('templates/pickpoint_logo.png')
  end

end
