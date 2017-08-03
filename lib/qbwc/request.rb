class QBWC::Request

  attr_reader   :request, :response_proc

  def initialize(request)
    #Handle Cases for a request passed in as a Hash or String
    #If it's a hash verify that it is properly wrapped with qbxml_msg_rq and xml_attributes for on_error events
    #Allow strings of QBXML to be passed in directly. 
    case
      when request.is_a?(Hash)

        unless request.keys.include?(:qbxml_msgs_rq)
          wrapped_request = { :qbxml_msgs_rq => {:xml_attributes => {"onError"=> QBWC::on_error } } }
          wrapped_request[:qbxml_msgs_rq] = wrapped_request[:qbxml_msgs_rq].merge(request)
          request = wrapped_request
        end

        @request = <<-XML
#{QBWC.parser.to_qbxml(request)}
        XML

      when request.is_a?(String)
        @request = request
    end

    if @request.present?
      @request.gsub!(/version="(\d+)\.(\d+)"\?/,'version="\1.\2" ?')
      @request.gsub!(/ISO-8859-1/, "UTF-8")
    end

    @request = I18n.transliterate @request
  end

  def to_qbxml
    QBWC.parser.to_qbxml(request, :validate => true)
  end

  def to_hash
    hash = QBWC.parser.from_qbxml(@request.to_s)["qbxml"]["qbxml_msgs_rq"]
    hash.except('xml_attributes')
  end

end
