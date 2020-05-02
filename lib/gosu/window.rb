module Gosu
  class Window
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    callback :_callback_window_draw,                 [:pointer],                   :void
    callback :_callback_window_update,               [:pointer],                   :void
    callback :_callback_window_button_down,          [:pointer, :uint32],          :void
    callback :_callback_window_button_up,            [:pointer, :uint32],          :void
    callback :_callback_window_axis_motion,          [:pointer, :uint32, :double], :void
    callback :_callback_window_gamepad_connected,    [:pointer, :uint32, :string], :void
    callback :_callback_window_gamepad_disconnected, [:pointer, :uint32],          :void
    callback :_callback_window_drop,                 [:pointer, :string],          :void
    callback :_callback_window_needs_redraw,         [:pointer],                   :bool
    callback :_callback_window_needs_cursor,         [:pointer],                   :bool
    callback :_callback_window_close,                [:pointer],                   :bool

    attach_function :_create_window,  :Gosu_Window_create,  [:int, :int, :bool, :double, :bool], :pointer
    attach_function :_destroy_window, :Gosu_Window_destroy, [:pointer],                          :void

    attach_function :_window_set_draw,                 :Gosu_Window_set_draw,                 [:pointer, :_callback_window_draw, :pointer],                 :void
    attach_function :_window_set_update,               :Gosu_Window_set_update,               [:pointer, :_callback_window_update, :pointer],               :void
    attach_function :_window_set_button_down,          :Gosu_Window_set_button_down,          [:pointer, :_callback_window_button_down, :pointer],          :void
    attach_function :_window_set_button_up,            :Gosu_Window_set_button_up,            [:pointer, :_callback_window_button_up, :pointer],            :void
    attach_function :_window_set_axis_motion,          :Gosu_Window_set_axis_motion,          [:pointer, :_callback_window_axis_motion, :pointer],          :void
    attach_function :_window_set_gamepad_connected,    :Gosu_Window_set_gamepad_connected,    [:pointer, :_callback_window_gamepad_connected, :pointer],    :void
    attach_function :_window_set_gamepad_disconnected, :Gosu_Window_set_gamepad_disconnected, [:pointer, :_callback_window_gamepad_disconnected, :pointer], :void
    attach_function :_window_set_drop,                 :Gosu_Window_set_drop,                 [:pointer, :_callback_window_drop, :pointer],                 :void
    attach_function :_window_set_needs_redraw,         :Gosu_Window_set_needs_redraw,         [:pointer, :_callback_window_needs_redraw, :pointer],         :void
    attach_function :_window_set_needs_cursor,         :Gosu_Window_set_needs_cursor,         [:pointer, :_callback_window_needs_cursor, :pointer],         :void
    attach_function :_window_set_close,                :Gosu_Window_set_close,                [:pointer, :_callback_window_close, :pointer],                :void

    # Enable gosu's default button_down fullscreen toggle
    attach_function :_window_default_button_down, :Gosu_Window_default_button_down, [:pointer, :uint32], :void

    attach_function :_window_show,                :Gosu_Window_show,                [:pointer],                    :void
    attach_function :_window_tick,                :Gosu_Window_tick,                [:pointer],                    :bool
    attach_function :_window_close_immediately,   :Gosu_Window_close_immediately,   [:pointer],                    :void

    attach_function :_window_width,               :Gosu_Window_width,               [:pointer],                    :int
    attach_function :_window_set_width,           :Gosu_Window_set_width,           [:pointer, :int],              :void
    attach_function :_window_height,              :Gosu_Window_height,              [:pointer],                    :int
    attach_function :_window_set_height,          :Gosu_Window_set_height,          [:pointer, :int],              :void

    attach_function :_window_mouse_x,             :Gosu_Window_mouse_x,             [:pointer],                    :double
    attach_function :_window_set_mouse_x,         :Gosu_Window_set_mouse_x,         [:pointer, :double],           :void
    attach_function :_window_mouse_y,             :Gosu_Window_mouse_y,             [:pointer],                    :double
    attach_function :_window_set_mouse_y,         :Gosu_Window_set_mouse_y,         [:pointer, :double],           :void

    attach_function :_window_caption,             :Gosu_Window_caption,             [:pointer],                    :string
    attach_function :_window_set_caption,         :Gosu_Window_set_caption,         [:pointer, :string],           :void
    attach_function :_window_update_interval,     :Gosu_Window_update_interval,     [:pointer],                    :double
    attach_function :_window_set_update_interval, :Gosu_Window_set_update_interval, [:pointer, :double],           :void
    attach_function :_window_resize,              :Gosu_Window_resize,              [:pointer, :int, :int, :bool], :void
    attach_function :_window_is_fullscreen,       :Gosu_Window_is_fullscreen,       [:pointer],                    :bool
    attach_function :_window_is_resizable,        :Gosu_Window_is_resizable,        [:pointer],                    :bool

    attach_function :_window_text_input,          :Gosu_Window_text_input,          [:pointer],                    :pointer
    attach_function :_window_set_text_input,      :Gosu_Window_set_text_input,      [:pointer, :pointer],          :void


    def initialize(width, height, _fullscreen = nil, _update_interval = nil, _resizable = nil,
                   fullscreen: false, update_interval: 16.66666667, resizable: false)
      fullscreen = _fullscreen if _fullscreen
      update_interval = _update_interval if _update_interval
      resizable = _resizable if _resizable

      __window = _create_window(width, height, fullscreen, update_interval, resizable)
      @memory_pointer = FFI::AutoPointer.new(__window, Gosu::Window.method(:release))
      @text_input = nil

      @__update_proc                  = proc { |data| protected_update }
      @__draw_proc                    = proc { |data| protected_draw }
      @__button_down_proc             = proc { |data, id| protected_button_down(id) }
      @__button_up_proc               = proc { |data, id| protected_button_up(id) }
      @__axis_motion_proc             = proc { |data, id, value| protected_axis_motion(id, value) }
      @__gamepad_connected_proc    = proc { |data, id, name| protected_gamepad_connected(id, name) }
      @__gamepad_disconnected_proc = proc { |data, id| protected_gamepad_disconnected(id) }
      @__drop_proc                    = proc { |data, filename| protected_drop(filename) }
      @__needs_redraw_proc            = proc { |data| protected_needs_redraw? }
      @__needs_cursor_proc            = proc { |data| protected_needs_cursor? }
      @__close_proc                   = proc { |data| protected_close }

      _window_set_update(__pointer, @__update_proc, nil)
      _window_set_draw(__pointer, @__draw_proc, nil)
      _window_set_button_down(__pointer, @__button_down_proc, nil)
      _window_set_button_up(__pointer, @__button_up_proc, nil)
      _window_set_axis_motion(__pointer, @__axis_motion_proc, nil)
      _window_set_gamepad_connected(__pointer, @__gamepad_connected_proc, nil)
      _window_set_gamepad_disconnected(__pointer, @__gamepad_disconnected_proc, nil)
      _window_set_drop(__pointer, @__drop_proc, nil)
      _window_set_needs_redraw(__pointer, @__needs_redraw_proc, nil)
      _window_set_needs_cursor(__pointer, @__needs_cursor_proc, nil)
      _window_set_close(__pointer, @__close_proc, nil)

    end

    # Returns FFI pointer of C side Gosu::Window
    def __pointer
      @memory_pointer
    end

    def protected_draw
      super

      $gosu_gl_blocks.clear
    end

    def update; end
    def draw; end
    def button_down(id); _window_default_button_down(__pointer, id); end
    def button_up(id); end
    def axis_motion(id, value); end
    def gamepad_connected(id, name); end
    def gamepad_disconnected(id); end
    def drop(filename); end
    def needs_redraw?; true; end
    def needs_cursor?; false; end
    def close; close!; end

    def caption
      _window_caption(__pointer)
    end

    def caption=(text)
      _window_set_caption(__pointer, text)
    end

    def fullscreen?
      _window_is_fullscreen(__pointer)
    end

    def fullscreen=(boolean)
      raise ArgumentError "Expected boolean" unless boolean.is_a?(TrueClass) || boolean.is_a?(FalseClass)
      _window_resize(__pointer, self.width, self.height, boolean)
    end

    def resizable?
      _window_is_resizable(__pointer)
    end

    def text_input
      @text_input ? @text_input : nil
    end

    def text_input=(text_input)
      raise ArgumentError, "text_input must be a Gosu::TextInput" unless text_input.is_a?(Gosu::TextInput) || text_input == nil
      ptr = text_input ? text_input.__pointer : nil
      @text_input = text_input

      _window_set_text_input(__pointer, ptr)
    end

    def update_interval
      _window_update_interval(__pointer)
    end

    def update_interval=(double)
      _window_set_update_interval(__pointer, double)
    end

    def width
      _window_width(__pointer)
    end

    def width=(int)
      _window_resize(__pointer, int, height, fullscreen?)
    end

    def height
      _window_height(__pointer)
    end

    def height=(int)
      _window_resize(__pointer, width, int, fullscreen?)
    end

    def mouse_x
      _window_mouse_x(__pointer)
    end

    def mouse_x=(double)
      _window_set_mouse_x(__pointer, double)
    end

    def mouse_y
      _window_mouse_y(__pointer)
    end

    def mouse_y=(double)
      _window_set_mouse_y(__pointer, double)
    end

    def set_mouse_position(x, y)
      self.mouse_x = x
      self.mouse_y = y
    end

    def show
      _window_show(__pointer)

      if defined?(@__exception)
        raise @__exception
      end
    end

    def tick
      _window_tick(__pointer)
    end

    def close
      close!
    end

    def close!
      _window_close_immediately(__pointer)
    end

    def self.release(pointer)
      _destroy_window(pointer)
    end
  end
end
