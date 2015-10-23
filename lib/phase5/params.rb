require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}
      route_params.keys.each do |key|
        handle_nested_hash_array([{key => route_params[key]}])
      end

      parse_www_encoded_form(req.query_string) if req.query_string
      parse_www_encoded_form(req.body) if req.body
    end

    def [](key)
      @params[key.to_sym] || @params[key.to_s]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      params_array = URI::decode_www_form(www_encoded_form).map do |k, v|
        [parse_key(k), v]
      end

      params_array.map! do |sub_array|
        array_to_hash(sub_array.flatten)
      end

      handle_nested_hash_array(params_array)
    end

    def handle_nested_hash_array(params_array)
      params_array.each do |working_hash|
        params = @params

        while true
          if params.keys.include?(working_hash.keys[0])
            params = params[working_hash.keys[0]]
            working_hash = working_hash[working_hash.keys[0]]
          else
            break
          end

          break if !working_hash.values[0].is_a?(Hash)
          break if !params.values[0].is_a?(Hash)
        end
        params.merge!(working_hash)
      end
    end

    def array_to_hash(params_array)
      return params_array.join if params_array.length == 1
      hash = {}
      hash[params_array[0]] = array_to_hash(params_array.drop(1))
      hash
    end


    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
