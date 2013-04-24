require 'ruby_parser'

module Led
  module Translator
    def self.parser
      @parser ||= RubyParser.new
    end
    
    def self.translate(ruby_source, ctx = {})
      sexp = parser.process(ruby_source)
      convert_sexp(ctx, sexp.to_a)
    end
    
    def self.convert_sexp(ctx, sexp)
      ctx[:parent] = ctx[:sexp]
      
      puts "convert_sexp #{sexp.inspect}"
      copy = sexp.dup
      typ = copy.shift
      method = :"convert_#{typ}"
      if respond_to?(method)
        send(method, ctx.merge(:sexp => sexp), *copy)
      else
        raise "Can't translate #{typ}!"
      end
    end
    
    def self.convert_return(ctx, value)
      "return #{convert_sexp(ctx, value)}\n"
    end
    
    def self.convert_lit(ctx, value)
      lit = case value
      when Fixnum, Float
        value
      when String
        value.inspect
      when nil
        'nil'
      when true
        1
      when false
        0
      else
        raise "Can't translate literal #{value.inspect}"
      end
      
      # if top level regard this as implicit return
      if ctx[:parent].nil?
        "return #{lit}\n"
      else
        lit.to_s
      end
    end
    
    def self.convert_nil(ctx)
      convert_lit(ctx, nil)
    end
    
    def self.convert_str(ctx, value)
      convert_lit(ctx, value)
    end
    
    def self.convert_true(ctx)
      convert_lit(ctx, true)
    end
    
    def self.convert_false(ctx)
      convert_lit(ctx, false)
    end
  end
end