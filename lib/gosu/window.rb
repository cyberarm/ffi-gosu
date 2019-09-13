module Gosu
  class Window
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    callback :_callback_window_draw,         [],        :void
    callback :_callback_window_update,       [],        :void
    callback :_callback_window_button_down,  [:uint32], :void
    callback :_callback_window_button_up,    [:uint32], :void
    callback :_callback_window_drop,         [:string], :void
    callback :_callback_window_needs_redraw, [],        :bool
    callback :_callback_window_needs_cursor, [],        :bool
    callback :_callback_window_close,        [],        :bool

    attach_function :_create_window,  :Gosu_Window_create,  [:int, :int, :bool, :double, :bool], :pointer
    attach_function :_destroy_window, :Gosu_Window_destroy, [:pointer],                          :void

    attach_function :_window_set_draw,         :Gosu_Window_set_draw,         [:pointer, :_callback_window_draw],         :void
    attach_function :_window_set_update,       :Gosu_Window_set_update,       [:pointer, :_callback_window_update],       :void
    attach_function :_window_set_button_down,  :Gosu_Window_set_button_down,  [:pointer, :_callback_window_button_down],  :void
    attach_function :_window_set_button_up,    :Gosu_Window_set_button_up,    [:pointer, :_callback_window_button_up],    :void
    attach_function :_window_set_drop,         :Gosu_Window_set_drop,         [:pointer, :_callback_window_drop],         :void
    attach_function :_window_set_needs_redraw, :Gosu_Window_set_needs_redraw, [:pointer, :_callback_window_needs_redraw], :void
    attach_function :_window_set_needs_cursor, :Gosu_Window_set_needs_cursor, [:pointer, :_callback_window_needs_cursor], :void
    attach_function :_window_set_close,        :Gosu_Window_set_close,        [:pointer, :_callback_window_close],        :void

    # Enable gosu's default button_down fullscreen toggle
    attach_function :_window_gosu_button_down, :Gosu_Window_gosu_button_down, [:pointer, :uint32], :void

    attach_function :_window_show,                :Gosu_Window_show,                [:pointer],                    :void
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
    attach_function :_window_fullscreen,          :Gosu_Window_fullscreen,          [:pointer],                    :bool

    attach_function :_window_text_input,          :Gosu_Window_text_input,          [:pointer],                    :pointer
    attach_function :_window_set_text_input,      :Gosu_Window_set_text_input,      [:pointer, :pointer],          :void


    def initialize(width, height, _fullscreen = nil, _update_interval = nil, _resizable = nil,
                   fullscreen: false, update_interval: 16.66666667, resizable: false)
      fullscreen = _fullscreen if _fullscreen
      update_update_interval = _update_interval if _update_interval
      resizable = _resizable if _resizable

      @__window = _create_window(width, height, fullscreen, update_interval, resizable)
      @__text_input = nil

      @__update_proc       = proc { protected_update }
      @__draw_proc         = proc { protected_draw }
      @__button_down_proc  = proc { |id| protected_button_down(id) }
      @__button_up_proc    = proc { |id| protected_button_up(id) }
      @__drop_proc         = proc { |filename| drop(filename) }
      @__needs_redraw_proc = proc { protected_needs_redraw? }
      @__needs_cursor_proc = proc { protected_needs_cursor? }
      @__close_proc        = proc { close }

      _window_set_update(@__window, @__update_proc)
      _window_set_draw(@__window, @__draw_proc)
      _window_set_button_down(@__window, @__button_down_proc)
      _window_set_button_up(@__window, @__button_up_proc)
      _window_set_drop(@__window, @__drop_proc)
      _window_set_needs_redraw(@__window, @__needs_redraw_proc)
      _window_set_needs_cursor(@__window, @__needs_cursor_proc)
      _window_set_close(@__window, @__close_proc)
    end

    # Returns FFI pointer of C side Gosu::Window
    def __pointer
      @__window
    end

    def protected_draw
      super

      $gosu_gl_blocks.clear
    end

    def update; end
    def draw; end
    def button_down(id); _window_gosu_button_down(@__window, id); end
    def button_up(id); end
    def drop(filename); end
    def needs_redraw?; true; end
    def needs_cursor?; false; end
    def close; close!; end

    def caption
      _window_caption(@__window)
    end

    def caption=(text)
      _window_set_caption(@__window, text)
    end

    def fullscreen?
      _window_fullscreen(@__window)
    end

    def fullscreen=(boolean)
      raise ArgumentError "Expected boolean" unless boolean.is_a?(TrueClass) || boolean.is_a?(FalseClass)
      _window_resize(@__window, self.width, self.height, boolean)
    end

    def text_input
      Gosu::TextInput.__from_pointer(_window_text_input(@__window))
    end

    def text_input=(text_input)
      raise ArgumentError, "text_input must be a Gosu::TextInput" unless text_input.is_a?(Gosu::TextInput) || text_input == nil
      ptr = text_input ? text_input.__pointer : nil
      @__text_input = ptr

      _window_set_text_input(@__window, ptr)
    end

    def update_interval
      _window_update_interval(@__window)
    end

    def update_interval=(double)
      _window_set_update_interval(@__window, double)
    end

    def width
      _window_width(@__window)
    end

    def width=(int)
      _window_resize(@__window, int, height, fullscreen?)
    end

    def height
      _window_height(@__window)
    end

    def height=(int)
      _window_resize(@__window, width, int, fullscreen?)
    end

    def mouse_x
      _window_mouse_x(@__window)
    end

    def mouse_x=(double)
      _window_set_mouse_x(@__window, double)
    end

    def mouse_y
      _window_mouse_y(@__window)
    end

    def mouse_y=(double)
      _window_set_mouse_y(@__window, double)
    end

    def show
      _window_show(@__window)

      if defined?(@__exception)
        raise @__exception
      end
    end

    def close
      close!
    end

    def close!
      _window_close_immediately(@__window)
    end

    def free_object
      _destroy_window(@__window)
    end
  end
end