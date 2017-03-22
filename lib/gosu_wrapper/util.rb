class GosuWrapper
  module Util
    
    def method_missing_for(regex, type:, &definition_blk)
      anon_module = Module.new do |mod|
        define_method(:method_missing) do |name, *args, **keywords, &caller_blk|
          match = name.to_s.scan(regex).flatten[0]
          if match
            if respond_to?(name)
              send(name, *args, &caller_blk)
            else
              if type == :instance
                instance_eval &(
                  definition_blk.call(match, *args, **keywords, &caller_blk)
                )
              elsif type == :class
                singleton_class.class_exec &(
                  definition_blk.call(match, *args, **keywords, &caller_blk)
                )
              end
            end
          else
            super(name, *args, **keywords, &caller_blk)
          end
        end
      end

      base = case type
      when :instance
        self
      when :class
        self.singleton_class
      end
      base.prepend anon_module

    end

  end
end
