module Gosu
  class Window
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    callback :_callback_window_redraw,       [],        :void
    callback :_callback_window_update,       [],        :void
    callback :_callback_window_button_down,  [:uint32], :void
    callback :_callback_window_button_up,    [:uint32], :void
    callback :_callback_window_drop,         [:string], :void
    callback :_callback_window_needs_redraw, [],        :bool
    callback :_callback_window_needs_cursor, [],        :bool

    attach_function :_create_window, :Gosu_Window_create, [:int, :int, :bool, :double, :bool], :pointer
    attach_function :_show_window, :Gosu_Window_show, [:pointer], :void

    attach_function :_window_set_draw,         :Gosu_Window_set_draw,         [:pointer, :_callback_window_redraw],       :void
    attach_function :_window_set_update,       :Gosu_Window_set_update,       [:pointer, :_callback_window_update],       :void
    attach_function :_window_set_button_down,  :Gosu_Window_set_button_down,  [:pointer, :_callback_window_button_down],  :void
    attach_function :_window_set_button_up,    :Gosu_Window_set_button_up,    [:pointer, :_callback_window_button_up],    :void
    attach_function :_window_set_drop,         :Gosu_Window_set_drop,         [:pointer, :_callback_window_drop],         :void
    attach_function :_window_set_needs_redraw, :Gosu_Window_set_needs_redraw, [:pointer, :_callback_window_needs_redraw], :void
    attach_function :_window_set_needs_cursor, :Gosu_Window_set_needs_cursor, [:pointer, :_callback_window_needs_cursor], :void

    attach_function :_window_width, :Gosu_Window_width, [:pointer], :int
    attach_function :_window_height, :Gosu_Window_height, [:pointer], :int
    attach_function :_window_mouse_x, :Gosu_Window_mouse_x, [:pointer], :double
    attach_function :_window_mouse_y, :Gosu_Window_mouse_y, [:pointer], :double
    attach_function :_window_caption, :Gosu_Window_caption, [:pointer], :string
    attach_function :_window_set_caption, :Gosu_Window_set_caption, [:pointer, :string], :void
    attach_function :_destroy_window, :Gosu_Window_destroy, [:pointer], :void

    def initialize(width, height, fullscreen: false, update_interval: 16.66666667, resizable: false)
      @__window = _create_window(width, height, fullscreen, update_interval, resizable)
      @__update_proc       = proc { update }
      @__draw_proc         = proc { draw }
      @__button_down_proc  = proc { |id| button_down(id) }
      @__button_up_proc    = proc { |id| button_up(id) }
      @__drop_proc         = proc { |filename| drop(filename) }
      @__needs_redraw_proc = proc { needs_redraw? }
      @__needs_cursor_proc = proc { needs_cursor? }

      _window_set_update(@__window, @__update_proc)
      _window_set_draw(@__window, @__draw_proc)
      _window_set_button_down(@__window, @__button_down_proc)
      _window_set_button_up(@__window, @__button_up_proc)
      _window_set_drop(@__window, @__drop_proc)
      _window_set_needs_redraw(@__window, @__needs_redraw_proc)
      _window_set_needs_cursor(@__window, @__needs_cursor_proc)
    end

    def update; end
    def draw; end
    def button_down(id); end
    def button_up(id); end
    def drop(filename); end
    def needs_redraw?; true; end
    def needs_cursor?; true; end

    def caption
      _window_caption(@__window)
    end

    def caption=(text)
      _window_set_caption(@__window, text)
    end

    def width
      _window_width(@__window)
    end

    def height
      _window_height(@__window)
    end

    def mouse_x
      _window_mouse_x(@__window)
    end

    def mouse_y
      _window_mouse_y(@__window)
    end

    def show
      _show_window(@__window)
    end

    def free_object
      _destroy_window(@__window)
    end
  end
end