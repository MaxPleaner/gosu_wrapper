### Installing

_gosu and activesupport will be loaded as dependencies_

`gem install gosu_wrapper` or in a gemfile: `gem 'gosu_wrapper'`

### Usage

One public class is exposed, `GosuWrapper`. It's essentially a wrapper over an
anonymous `Gosu::Window` class that gets functionality added through metaprogramming.

In lieue of a "getting started" snippet, I'm going to delegate that to the
[gosu_wrapper_snake_example](http://github.com/maxpleaner/gosu_wrapper_snake_example)
codebase and run through the API step-by-step here.

---

**`#initialize(width:, height:, attributes:)`**

  - This defines `#window` which is an instance of `Gosu::Window`.

  - width & height are num pixels (of the total window).

  - attributes is an array of symbols.
    - It must at least include `:window_height` and `:window_width`.  
    - All of the keys in your app's state hash should be given here.  
    - Each of them get attr_accessors defined on `#window` and shorthand accessors
      using `method_missing` (see next section).

---

**There are four instance methods added using `method_missing`**

  1. `#get_<attr>`  
      delegates the getter to `window`

  2. `#set_<attr>(val)`  
      delegates the setter to `window`

  3. `#change_<attr>(sym, arg)`  
      a shorthand for some update operations on non-mutable objects. 
      For example `change_score(:+, 1)` 

  4. `#get_or_set_<attr>(&blk)`  
      returns the val if it's truthy, and otherwise sets the val equal to the 
      block result (returning it as well).

---

**`#define_method_on_window(name, &blk)`**

  - this should be a private method, but is used by `#add_hook/#add_helper` so 
    it's worth explaining.

  - It defines the method named `name` on `window` with `blk` as its body.

  - Arguments are determined by the given block

  - The block is always invoked with the `GosuWrapper` instance as the value of `self`

---

**`#scope(*args, **keywords, &blk)`**

  - another method that should be private; this is what handles calling a proc 
    with the `GosuWrapper` instance as the value of `self`.

---

**`#config(&blk)`**

  - mostly the same thing as `#scope` but is meant to be used publically.  

  - the only functional difference is this always returns `self` 
    (the `GosuWrapper` instance) whereas `#scope` returns the result of the 
    block.

  - Like `#scope`, this is a classic DSL-style method which exists for the 
    sole purpose of saving keystrokes (using `instance_exec`)

---

**`#add_hook(name, &blk)`**

  - a "hook" conceptually is a method internally defined by `Gosu::Window` 
    that we're tapping into by overriding. Hooking into events `update`, 
    `button_down`, and `draw` are how the app works fundamentally.

  - the `button_down` proc is passed an `id` which can be checked against 
    the values in `#buttons` to determine which key was pressed.

  - `update` and `draw` are run every tick. Conceptually, `update` 
    is used to change the state and `draw` to represent it.

---

**`#add_helper(name, &blk)`**

  - functionally speaking this is the exact same thing as `add_hook` - 
    it defines a method on `Gosu::Window`.

  - It exists to distinguish between built-in hooks like `update` from 
    custom methods. 

  - These can be called with `#invoke` or its alias `#call_helper`.

---

**`#show`**

  - Starts the game. Needs to be called only once.

---

**`#draw_rect(start_x:, start_y:, end_x:, end_y:, color)`**

  - Should be called from `draw` only. Fills the rectangle with `color`
  - Needs to run every `draw` tick.

---

**`#colors`**

  - a hash of name => color object pairs
  - e.g. `colors[:red]`
  - it's also possible to make hexademical colors with Gosu

---

**`#buttons`**

  - a hash of name => button id pairs
  - e.g. `buttons[:right]` or `buttons[:escape]`
  - not all the gosu buttons are mapped here but I'd welcome a PR to add more.

---

**`#invoke/#call_helper/#dispatch/#call_hook`**

  - all aliases for the same simple thing: calling a function on 
    `window` (the `Gosu::Window instance`).

---

**default helpers**

There are a few predefined helpers.

They can be called with `#call_helper(name_sym, *args, **keywords, &blk)`

The required parameters differ between the helpers.

1. `div_window_into(num_cols:, num_rows:, margin:)` 
   - splits the window into a grid but doesn't draw it
   - returns a matrix-like hash which can be passed to `draw_grid` 
     as the `sections` argument
   - uses `div_section_into` internally

2. `div_setion_into(start_x: start_y:, end_x:, end_y:, num_cols:, num_rows:, margin:)`
  - splits a rectangle into a grid but doesn't draw it
  - returns a matrix-like hash which can be passed to `draw_grid`
  - `margin` is an optional reduction of the size of each column. 
    It's passed as `1` in `div_window_into` and the columns won't be 
    distinguishable (there will be no visible border) unless this is positive.
  - specifically, the return value looks like this:  

          # many rows and columns can be stored in this structure
          {
            <row_idx> => {
              start_x: <num>, start_y: <num>, end_x: <num>, end_y: <num>,
              cols: {
                <col_idx> => {
                  start_x: <num>, start_y: <num>, end_x: <num>, end_y: <num>
                }
              }
            }
          }

3. `draw_grid(sections:, row_color:, col_color:)`
  - The result of `div_window_into` can be passed to this.
  - Internally it uses `GridHelpers#draw_rect`

