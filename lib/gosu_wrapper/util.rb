class GosuWrapper
  module Util

  # ================================================
    def method_missing_for(regex, type:, &definition_blk)
    # Regex should include a match group
    # type should be either :instance or :class
    # Definition blk is run unless there's an existing method with the same name.
    # if caller_blk is provided, it will be passed to definition_blk's invocation
    #
    # Example:
    #
    # class Animal
    #   extend Util
    #   attr_reader :noises
    #   def initialize
    #     @noises = { cat: "meow" }
    #   end
    #   method_missing_for /^(.+)_goes$/ do |match, arg|
    #     puts @noises[match]
    #   end
    # end
    # 
    # Animal.new.cat_goes # => "meow"
    #
    # Through the use of an anonymous modules (adding method_missing to the
    # inheritance chain vs overwriting it with define_method), this can be
    # used multiple times.
    #
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
  # ================================================

  end
end
