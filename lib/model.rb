require 'json'

class Hash
  alias_method :orig_fetch, :[]
  
  # allow access by symbol key
  def [](key)
    if Symbol === key
      has_key?(key) ? orig_fetch(key) : orig_fetch(key.to_s)
    else
      orig_fetch(key)
    end
  end
  
  def symbolize_keys
    inject({}) {|m, kv| v = kv[1]; m[kv[0].to_sym] = v.is_a?(Hash) ? v.symbolize_keys : v; m}
  end
end

module Led
  class Model
    class << self
      def set_primary_key(key)
        @primary_key = key
      end
      
      def primary_key
        @primary_key ||= :id
      end
      
      def add_index(key)
        indexes[key] = "models:#{name.downcase}:indexes:#{key}"
      end
      
      def indexes
        @indexes ||= {}
      end
      
      def [](key)
        from_json(Led.conn.hget(object_map_key, key))
      end
      
      def from_json(json_str)
        load(JSON.parse(json_str).symbolize_keys)
      end
      
      def object_map_key
        @object_map_key ||= "models:#{name.downcase}:objects"
      end
      
      def index_set_key(key, value)
        "models:#{name.downcase}:indexes:#{key}:#{value.inspect}"
      end
      
      def load(hash)
        new(hash, hash.dup)
      end
      
      def create(hash)
        new(hash).save(true)
      end
      
      def filter(term)
        conditions = {}
        sets = []
        
        term.each do |k, v|
          if indexes[k]
            sets << index_set_key(k, v)
          else
            conditions[k] = v
          end
        end
        
        # load objects
        if sets.empty?
          objects = Led.conn.hgetall(object_map_key).map do |s|
            from_json(s)
          end
        else
          intersected = Led.conn.sinter(*sets)
          return [] if intersected.empty?

          objects = Led.conn.hmget(object_map_key, intersected).map do |s|
            from_json(s)
          end
        end
        
        if conditions.empty?
          # return all found objects
          objects
        else
          objects.select do |o|
            conditions.inject(true) {|m, kv| m && (o[kv[0]] == kv[1])}
          end
        end
      end
    end
    
    attr_reader :values
    
    def initialize(hash = {}, saved_hash = {})
      @values = hash
      @saved_values = @values
    end
    
    def pkey
      self.class.primary_key
    end
    
    def save(create = false)
      if @saved_values[pkey] && @saved_values[pkey] != @values[pkey]
        # pkey value has changed, so first remove the old record
        Led.conn.hdel(self.class.object_map_key, @saved_values[pkey])
      end
      
      pk = @values[pkey]
      
      # save object
      Led.conn.hset(self.class.object_map_key, pk, @values.to_json)
      
      # update indexes
      self.class.indexes.each do |key, _|
        if create || (@saved_values[key] != @values[key])
          k = self.class.index_set_key(key, @saved_values[:key])
          Led.conn.srem(k, pk)
          k = self.class.index_set_key(key, @values[key])
          Led.conn.sadd(k, pk)
        end
      end

      # update saved values
      @saved_values = @values.dup

      self
    end
    
    SETTER_REGEXP = /^([0-9a-zA-Z_]+)=$/.freeze
    
    def method_missing(m, *args)
      if m =~ SETTER_REGEXP
        @values[$1.to_sym] = args[0]
      else
        @values[m]
      end
    end

    def inspect
      v = values.map {|k, v| "#{k}: #{v.inspect}"}.join(', ')
      "#<#{self.class.name}:#{@values[:pkey]} #{v}>"
    end
  
    def ==(obj)
      (obj.class == self.class) && (obj.values == @values)
    end
  end
end