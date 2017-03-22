require 'gosu'
require 'active_support/all'

Gem.find_files("gosu_wrapper/**/*.rb").each &method(:require)

class GosuWrapper

  extend Util

  attr_reader :window_constructor, :window, :window_attributes,
              :hooks, :helpers

  def initialize(width:, height:, attributes:)
    @window_constructor = Class.new(Gosu::Window) do
      const_set("Attributes", attributes)
      attr_accessor *attributes
    end
    @window_attributes = @window_constructor::Attributes
    @window = @window_constructor.new(width, height)
    @window.window_height = height
    @window.window_width = width
    @hooks = []
    @helpers = []
    add_default_helpers
  end

  def add_default_helpers
    add_helper :div_window_into,  &GridHelpers.div_window_into
    add_helper :div_section_into, &GridHelpers.div_section_into
    add_helper :draw_grid,        &GridHelpers.draw_grid
  end

  # Delegate "set_<attr>" setters to window
  method_missing_for /^set_(.+)$/, type: :instance do |window_attr, val|
    Proc.new do
      if window_attr.to_sym.in? window_attributes
        window.instance_variable_set("@#{window_attr}", val)
      end
      val
    end
  end

  # Delegate "get_<attr>" getters to window
  method_missing_for /^get_(.+)$/, type: :instance do |window_attr|
    Proc.new do
      if window_attr.to_sym.in? window_attributes
        window.instance_variable_get("@#{window_attr}")
      end
    end
  end

  # Delegate "get_or_set_<attr>" getters to window
  method_missing_for /^get_or_set_(.+)$/, type: :instance do |window_attr, &blk|
    Proc.new do
      if window_attr.to_sym.in? window_attributes
        send(:"get_#{window_attr}") || send(
          :"set_#{window_attr}",
          instance_eval(&blk)
        )
      end
    end
  end

  # Delegate "change_<attr>" non-destructive setters to window
  # i.e. change_x(:+, 1) is equivalent to @x += 1
  method_missing_for /^change_(.+)$/, type: :instance do |window_attr, method_name, val|
    Proc.new do
      if window_attr.to_sym.in? window_attributes
        window.instance_variable_set(
          "@#{window_attr}",
          window.instance_variable_get("@#{window_attr}").send(method_name, val) 
        )
      end
    end
  end

  # Methods are defined on the window's anonyous class
  # The generated method's body is always invoked with the App instance's scope.
  def define_method_on_window(name, &blk)
    app = self
    window.define_singleton_method(name) do |*args, **keywords|
      app.scope(*args, **keywords, &blk)
    end
  end

  def add_hook(name, &blk)
    hooks << name
    define_method_on_window(name, &blk)
  end

  def add_helper(name, &blk)
    helpers << name
    define_method_on_window(name, &blk)
  end

  def show
    window.show
  end

  def image(path:)
    Gosu::Image.new(path)
  end

  def draw_rect(start_x:, start_y:, end_x:, end_y:, color:, **_)
    width = end_x - start_x
    height = end_y - start_y
    Gosu.draw_rect(start_x, start_y, width, height, color)
  end

  def colors
    Colors
  end

  def buttons
    Buttons
  end

  # A wrapper over instance_exec i.e. app.scope { set_x 200 }
  # Always returns self (app)
  # Be aware that this only sets the scope for one level
  # i.e. if you call a method in the passed block, it'll use a different scope
  def scope(*args, **keywords, &blk)
    if keywords.blank?
      instance_exec *args, &blk
    else
      instance_exec *args, **keywords, &blk
    end
  end

  # config is the same as scope, but returns self
  def config(&blk)
    scope &blk
    self
  end

  # Call a method which is defined on window.
  # Although this could have been overloaded onto get_<attr>,
  # to avoid namin conflicts that's limited to instance variables
  def invoke(name, *args, **keywords, &blk)
    window.send(name, *args, **keywords, &blk)
  end
  alias call_helper invoke
  alias dispatch invoke
  alias call_hook invoke

end
