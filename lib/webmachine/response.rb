module Webmachine
  # Represents an HTTP response from Webmachine.
  class Response
    # @return [HeaderHash] Response headers that will be sent to the client
    attr_reader :headers

    # @return [Fixnum] The HTTP status code of the response
    attr_accessor :code

    # @return [String, #each] The response body
    attr_accessor :body

    # @return [true,false] Whether the response is a redirect
    attr_accessor :redirect

    # @return [Array] the list of states that were traversed
    attr_reader :trace

    # @return [String] The error message when responding with an error
    #   code
    attr_accessor :error

    # Creates a new Response object with the appropriate defaults.
    def initialize
      @headers = HeaderHash.new
      @trace = []
      self.code = 200
      self.redirect = false
    end

    # Indicate that the response should be a redirect. This is only
    # used when processing a POST request in
    # {Resource::Callbacks#process_post} to indicate that the client
    # should request another resource using GET. Either pass the URI
    # of the target resource, or manually set the Location header
    # using {#headers}.
    # @param [String, URI] location the target of the redirection
    def do_redirect(location=nil)
      headers['Location'] = location.to_s if location
      self.redirect = true
    end

    # Set a cookie for the response.
    # @param [String, Symbol] name the name of the cookie
    # @param [String] value the value of the cookie
    # @param [Hash] attributes for the cookie. See RFC2109.
    def set_cookie(name, value, attributes = {})
      cookie = Webmachine::Cookie.new(name, value, attributes).to_s
      case headers['Set-Cookie']
      when nil
        headers['Set-Cookie'] = cookie
      when String
        headers['Set-Cookie'] = [headers['Set-Cookie'], cookie]
      when Array
        headers['Set-Cookie'] = headers['Set-Cookie'] + cookie
      end
    end

    #Set cache control header for the response
    #@param [Hash|String|CacheControl] directives HTTP Cache-Control directives
    def set_cache_control(directives)
      case directives
      when Hash
        cache_control = CacheControl.new(directives).to_s
      when String
        cache_control = directives
      when CacheControl
        cache_control = directives.to_s
      end

      if cache_control.empty?
        return #XXX or raise ArgumentError?
      else
        headers['Cache-Control'] = cache_control
      end
    end

    alias :is_redirect? :redirect
    alias :redirect_to :do_redirect

    # A {Hash} that can flatten array values into single values with a separator
    class HeaderHash < ::Hash
      # Return a new array with any {Array} values combined with the separator
      # @param [String] separator The separator used to join Array values
      # @return [HeaderHash] A new {HeaderHash} with Array values flattened
      def flattened(separator = ',')
        Hash[self.collect { |k,v|
          case v
          when Array
            [k,v.join(separator)]
          else
            [k,v]
          end
        }]

      end
    end

  end # class Response
end # module Webmachine
