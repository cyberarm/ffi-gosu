module Gosu
  class Font
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_create_font, :Gosu_Font_create,   [:int, :string, :uint32], :pointer
    attach_function :_destroy_font, :Gosu_Font_destroy, [:pointer],               :void

    attach_function :_font_height, :Gosu_Font_height, [:pointer], :int
    attach_function :_font_flags,  :Gosu_Font_flags,  [:pointer], :uint32

    attach_function :_font_text_width,   :Gosu_Font_text_width,   [:pointer, :string], :double
    attach_function :_font_markup_width, :Gosu_Font_markup_width, [:pointer, :string], :double

    attach_function :_font_draw_text,   :Gosu_Font_draw_text,   [:pointer, :string, :double, :double, :double,
                                                                 :double, :double, :uint32, :uint32],          :void
    attach_function :_font_draw_markup, :Gosu_Font_draw_markup, [:pointer, :string, :double, :double, :double,
                                                                 :double, :double, :uint32, :uint32],          :void

    attach_function :_font_draw_text_rel, :Gosu_Font_draw_text_rel,     [:pointer, :string, :double, :double, :double,
                                                                         :double, :double, :double, :double, :uint32, :uint32], :void
    attach_function :_font_draw_markup_rel, :Gosu_Font_draw_markup_rel, [:pointer, :string, :double, :double, :double,
                                                                         :double, :double, :double, :double, :uint32, :uint32], :void

    attach_function :_font_set_image, :Gosu_Font_set_image, [:pointer, :string, :uint32, :pointer], :void

    def initialize(height, name: Gosu.default_font_name, flags: 0x0)
      @__font = _create_font(height, name, flags)
    end

    def __pointer
      @__font
    end

    def height
      _font_height(@__font)
    end

    def flags
      _font_flags(@__font)
    end

    def text_width(text)
      _font_text_width(@__font, text.to_s)
    end

    def markup_width(text)
      _font_markup_width(@__font, text.to_s)
    end

    def draw(text, x, y, z, scale_x = 1, scale_y = 1, c = Gosu::Color::WHITE, mode = :default)
      raise "Using Gosu::Font.draw is deprecated, use Gosu::Font.draw_text or Gosu::Font.draw_markup"
    end

    def draw_rot(text, x, y, z, angle, scale_x = 1, scale_y = 1, c = Gosu::Color::WHITE, mode = :default)
      Gosu.rotate(angle, x, y) { draw_markup(text.to_s, x, y, z, scale_x, scale_y, Gosu.color_to_drawop(c), Gosu.mode_to_mask(mode)) }
    end

    def draw_text(text, x, y, z, scale_x = 1, scale_y = 1, c = Gosu::Color::WHITE, mode = :default)
      _font_draw_text(@__font, text.to_s, x, y, z, scale_x, scale_y, Gosu.color_to_drawop(c), Gosu.mode_to_mask(mode))
    end

    def draw_markup(text, x, y, z, scale_x = 1, scale_y = 1, c = Gosu::Color::WHITE, mode = :default)
      _font_draw_markup(@__font, text.to_s, x, y, z, scale_x, scale_y, Gosu.color_to_drawop(c), Gosu.mode_to_mask(mode))
    end

    def draw_text_rel(text, x, y, z, rel_x, rel_y, scale_x = 1, scale_y = 1, c = Gosu::Color::WHITE, mode = :default)
      _font_draw_text_rel(@__font, text.to_s, x, y, z, rel_x, rel_y, scale_x, scale_y, Gosu.color_to_drawop(c), Gosu.mode_to_mask(mode))
    end

    def draw_markup_rel(text, x, y, z, rel_x, rel_y, scale_x = 1, scale_y = 1, c = Gosu::Color::WHITE, mode = :default)
      _font_draw_markup_rel(@__font, text.to_s, x, y, z, rel_x, rel_y, scale_x, scale_y, Gosu.color_to_drawop(c), Gosu.mode_to_mask(mode))
    end

    def set_image(codepoint, flags, image)
      _font_set_image(@__font, codepoint, flags, image.__pointer)
    end

    def free_object
      _destroy_font(@__font)
    end
  end
end