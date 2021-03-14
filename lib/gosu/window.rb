module Gosu
  class Window
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    callback :_callback,                               [:pointer],             :void
    callback :_callback_with_unsigned,                 [:pointer, :uint32],    :void
    callback :_callback_with_string,                   [:pointer, :string],    :void
    callback :_callback_returns_bool,                  [:pointer],             :bool
    callback :_callback_hit_test_returns_unsigned,     [:pointer, :int, :int], :uint32

    attach_function :Gosu_Window_create,  [:int, :int, :uint32, :double], :pointer
    attach_function :Gosu_Window_destroy, [:pointer],                     :void

    attach_function :Gosu_Window_set_draw,                 [:pointer, :_callback, :pointer],                           :void
    attach_function :Gosu_Window_set_update,               [:pointer, :_callback, :pointer],                           :void
    attach_function :Gosu_Window_set_button_down,          [:pointer, :_callback_with_unsigned, :pointer],             :void
    attach_function :Gosu_Window_set_button_up,            [:pointer, :_callback_with_unsigned, :pointer],             :void
    attach_function :Gosu_Window_set_gamepad_connected,    [:pointer, :_callback_with_unsigned, :pointer],             :void
    attach_function :Gosu_Window_set_gamepad_disconnected, [:pointer, :_callback_with_unsigned, :pointer],             :void
    attach_function :Gosu_Window_set_drop,                 [:pointer, :_callback_with_string, :pointer],               :void
    attach_function :Gosu_Window_set_needs_redraw,         [:pointer, :_callback_returns_bool, :pointer],              :void
    attach_function :Gosu_Window_set_needs_cursor,         [:pointer, :_callback_returns_bool, :pointer],              :void
    #attach_function :Gosu_Window_set_capture_cursor,       [:pointer, :_callback_returns_bool, :pointer],              :void
    #attach_function :Gosu_Window_set_hit_test,             [:pointer, :_callback_hit_test_returns_unsigned, :pointer], :void
    attach_function :Gosu_Window_set_close,                [:pointer, :_callback, :pointer],                           :void

    # Enable gosu's default button_down fullscreen toggle
    attach_function :Gosu_Window_default_button_down, [:pointer, :uint32], :void

    attach_function :Gosu_Window_show,                [:pointer],                    :void
    attach_function :Gosu_Window_tick,                [:pointer],                    :bool
    attach_function :Gosu_Window_close_immediately,   [:pointer],                    :void

    attach_function :Gosu_Window_width,               [:pointer],                    :int
    attach_function :Gosu_Window_set_width,           [:pointer, :int],              :void
    attach_function :Gosu_Window_height,              [:pointer],                    :int
    attach_function :Gosu_Window_set_height,          [:pointer, :int],              :void

    attach_function :Gosu_Window_mouse_x,             [:pointer],                    :double
    attach_function :Gosu_Window_set_mouse_x,         [:pointer, :double],           :void
    attach_function :Gosu_Window_mouse_y,             [:pointer],                    :double
    attach_function :Gosu_Window_set_mouse_y,         [:pointer, :double],           :void

    attach_function :Gosu_Window_caption,             [:pointer],                    :string
    attach_function :Gosu_Window_set_caption,         [:pointer, :string],           :void
    attach_function :Gosu_Window_update_interval,     [:pointer],                    :double
    attach_function :Gosu_Window_set_update_interval, [:pointer, :double],           :void
    attach_function :Gosu_Window_resize,              [:pointer, :int, :int, :bool], :void
    attach_function :Gosu_Window_is_fullscreen,       [:pointer],                    :bool
    attach_function :Gosu_Window_is_resizable,        [:pointer],                    :bool
    attach_function :Gosu_Window_is_borderless,       [:pointer],                    :bool
    attach_function :Gosu_Window_set_fullscreen,      [:pointer, :bool],             :void
    attach_function :Gosu_Window_set_resizable,       [:pointer, :bool],             :void
    attach_function :Gosu_Window_set_borderless,      [:pointer, :bool],             :void

    #attach_function :Gosu_Window_minimize,            [:pointer],                    :void
    #attach_function :Gosu_Window_restore,             [:pointer],                    :void
    #attach_function :Gosu_Window_maximize,            [:pointer],                    :void

    attach_function :Gosu_Window_text_input,          [:pointer],                    :pointer
    attach_function :Gosu_Window_set_text_input,      [:pointer, :pointer],          :void


    def initialize(width, height, _fullscreen = nil, _update_interval = nil, _resizable = nil, _borderless = nil,
                   fullscreen: false, update_interval: 16.66666667, resizable: false, borderless: false)
      fullscreen = _fullscreen if _fullscreen
      update_interval = _update_interval if _update_interval
      resizable = _resizable if _resizable
      borderless = _borderless if _borderless

      window_flags = Gosu.window_flags(fullscreen: fullscreen, resizable: resizable, borderless: borderless)

      __window = Gosu_Window_create(width, height, window_flags, update_interval)
      Gosu.check_last_error
      @memory_pointer = FFI::AutoPointer.new(__window, Gosu::Window.method(:release))
      @text_input = nil

      @__update_proc                  = proc { |data| protected_update }
      @__draw_proc                    = proc { |data| protected_draw }
      @__button_down_proc             = proc { |data, id| protected_button_down(id) }
      @__button_up_proc               = proc { |data, id| protected_button_up(id) }
      @__gamepad_connected_proc       = proc { |data, id| protected_gamepad_connected(id) }
      @__gamepad_disconnected_proc    = proc { |data, id| protected_gamepad_disconnected(id) }
      @__drop_proc                    = proc { |data, filename| protected_drop(filename) }
      @__needs_redraw_proc            = proc { |data| protected_needs_redraw? }
      @__needs_cursor_proc            = proc { |data| protected_needs_cursor? }
      @__capture_cursor_proc          = proc { |data| protected_capture_cursor? }
      @__hit_test_proc                = proc { |data, x, y| protected_hit_test(x, y) }
      @__close_proc                   = proc { |data| protected_close }

      Gosu_Window_set_update(__pointer, @__update_proc, nil)
      Gosu.check_last_error
      Gosu_Window_set_draw(__pointer, @__draw_proc, nil)
      Gosu.check_last_error
      Gosu_Window_set_button_down(__pointer, @__button_down_proc, nil)
      Gosu.check_last_error
      Gosu_Window_set_button_up(__pointer, @__button_up_proc, nil)
      Gosu.check_last_error
      Gosu_Window_set_gamepad_connected(__pointer, @__gamepad_connected_proc, nil)
      Gosu.check_last_error
      Gosu_Window_set_gamepad_disconnected(__pointer, @__gamepad_disconnected_proc, nil)
      Gosu.check_last_error
      Gosu_Window_set_drop(__pointer, @__drop_proc, nil)
      Gosu.check_last_error
      Gosu_Window_set_needs_redraw(__pointer, @__needs_redraw_proc, nil)
      Gosu.check_last_error
      Gosu_Window_set_needs_cursor(__pointer, @__needs_cursor_proc, nil)
      Gosu.check_last_error
      #Gosu_Window_set_capture_cursor(__pointer, @__capture_cursor_proc, nil)
      #Gosu.check_last_error
      #Gosu_Window_set_hit_test(__pointer, @__hit_test_proc, nil)
      #Gosu.check_last_error
      Gosu_Window_set_close(__pointer, @__close_proc, nil)
      Gosu.check_last_error
    end

    # Returns FFI pointer of C side Gosu::Window
    def __pointer
      @memory_pointer
    end

    def protected_draw
      super

      $gosu_gl_blocks.clear
    end

    def update
    end

    def draw
    end

    def button_down(id)
      Gosu_Window_default_button_down(__pointer, id)
      Gosu.check_last_error
    end

    def button_up(id)
    end

    def gamepad_connected(id)
    end

    def gamepad_disconnected(id)
    end

    def drop(filename)
    end

    def needs_redraw?
      true
    end

    def needs_cursor?
      false
    end

    def capture_cursor?
      false
    end

    def hit_test(x, y)
      0
    end

    def close
      close!
    end

    def caption
      Gosu_Window_caption(__pointer).tap { Gosu.check_last_error }
    end

    def caption=(text)
      Gosu_Window_set_caption(__pointer, text)
      Gosu.check_last_error
    end

    def fullscreen?
      Gosu_Window_is_fullscreen(__pointer).tap { Gosu.check_last_error }
    end

    def fullscreen=(boolean)
      Gosu_Window_resize(__pointer, width, height, !!boolean)
      Gosu.check_last_error
    end

    def resizable?
      Gosu_Window_is_resizable(__pointer).tap { Gosu.check_last_error }
    end

    def resizable=(boolean)
      Gosu_Window_set_resizable(__pointer, !!boolean)
      Gosu.check_last_error
    end

    def borderless?
      Gosu_Window_is_borderless(__pointer).tap { Gosu.check_last_error }
    end

    def borderless=(boolean)
      Gosu_Window_set_borderless(__pointer, !!boolean)
      Gosu.check_last_error
    end

    def text_input
      @text_input || nil
    end

    def text_input=(text_input)
      raise ArgumentError, "text_input must be a Gosu::TextInput" unless text_input.is_a?(Gosu::TextInput) || text_input.nil?

      ptr = text_input ? text_input.__pointer : nil
      @text_input = text_input

      Gosu_Window_set_text_input(__pointer, ptr)
      Gosu.check_last_error
    end

    def update_interval
      Gosu_Window_update_interval(__pointer).tap { Gosu.check_last_error }
    end

    def update_interval=(double)
      Gosu_Window_set_update_interval(__pointer, double)
      Gosu.check_last_error
    end

    def width
      Gosu_Window_width(__pointer).tap { Gosu.check_last_error }
    end

    def width=(int)
      Gosu_Window_resize(__pointer, int, height, fullscreen?)
      Gosu.check_last_error
    end

    def height
      Gosu_Window_height(__pointer).tap { Gosu.check_last_error }
    end

    def height=(int)
      Gosu_Window_resize(__pointer, width, int, fullscreen?)
      Gosu.check_last_error
    end

    def mouse_x
      Gosu_Window_mouse_x(__pointer).tap { Gosu.check_last_error }
    end

    def mouse_x=(double)
      Gosu_Window_set_mouse_x(__pointer, double)
      Gosu.check_last_error
    end

    def mouse_y
      Gosu_Window_mouse_y(__pointer).tap { Gosu.check_last_error }
    end

    def mouse_y=(double)
      Gosu_Window_set_mouse_y(__pointer, double)
      Gosu.check_last_error
    end

    def set_mouse_position(x, y)
      self.mouse_x = x
      self.mouse_y = y
    end

    def show
      Gosu_Window_show(__pointer)

      raise @__exception if defined?(@__exception)

      Gosu.check_last_error
    end

    def tick
      Gosu_Window_tick(__pointer).tap { Gosu.check_last_error }
    end

    def minimize
      Gosu_Window_minimize(__pointer)
      Gosu.check_last_error
    end

    def restore
      Gosu_Window_restore(__pointer)
      Gosu.check_last_error
    end

    def maximize
      Gosu_Window_maximize(__pointer)
      Gosu.check_last_error
    end

    def close!
      Gosu_Window_close_immediately(__pointer)
      Gosu.check_last_error
    end

    def self.release(pointer)
      Gosu_Window_destroy(pointer)
      Gosu.check_last_error
    end
  end
end
