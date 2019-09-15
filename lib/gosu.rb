require "ffi"

require_relative "gosu/numeric"

require_relative "gosu/version"
require_relative "gosu/constants"
require_relative "gosu/window"
require_relative "gosu/image"
require_relative "gosu/font"
require_relative "gosu/color"
require_relative "gosu/text_input"
require_relative "gosu/gl_tex_info"
require_relative "gosu/channel"
require_relative "gosu/sample"
require_relative "gosu/song"

require_relative "gosu/compat"


module Gosu
  extend FFI::Library
  ffi_lib Gosu::LIBRARY_PATH

  callback :_callback,            [],         :void
  callback :_callback_with_block, [:pointer], :void

  # Argumentless functions that don't need nice pretty argument handling
  attach_function :fps,          :Gosu_fps,                    [], :int
  attach_function :flush,        :Gosu_flush,                  [], :void
  attach_function :language,     :Gosu_language,               [], :string
  attach_function :milliseconds, :Gosu_milliseconds,           [], :long
  attach_function :default_font_name, :Gosu_default_font_name, [], :string

  # attach_function :_transform, :Gosu_transform, [:double, :double, :_callback_with_block], :void
  attach_function :_translate, :Gosu_translate, [:double, :double, :_callback_with_block], :void
  attach_function :_rotate,    :Gosu_rotate,    [:double, :double, :double, :_callback_with_block], :void
  attach_function :_scale,     :Gosu_scale,     [:double, :double, :double, :double, :_callback_with_block], :void
  attach_function :_clip_to,   :Gosu_clip_to,   [:double, :double, :double, :double, :_callback_with_block], :void

  attach_function :_gl_z,    :Gosu_gl_z,  [:double, :_callback],                        :void
  attach_function :_gl,      :Gosu_gl,    [:_callback],                                 :void
  attach_function :_render, :Gosu_render, [:int, :int, :_callback_with_block, :uint32], :pointer
  attach_function :_record, :Gosu_record, [:int, :int, :_callback_with_block],          :pointer

  attach_function :_button_down, :Gosu_button_down,            [:uint32], :bool
  attach_function :button_id_to_char, :Gosu_button_id_to_char, [:uint32], :string
  attach_function :char_to_button_id, :Gosu_button_char_to_id, [:string], :uint32

  attach_function :_draw_line, :Gosu_draw_line,         [:double, :double, :uint32, :double, :double, :uint32, :double, :uint32], :void
  attach_function :_draw_quad, :Gosu_draw_quad,         [:double, :double, :uint32, :double, :double, :uint32,
                                                         :double, :double, :uint32, :double, :double, :uint32, :double, :uint32], :void
  attach_function :_draw_triangle, :Gosu_draw_triangle, [:double, :double, :uint32, :double, :double, :uint32,
                                                         :double, :double, :uint32, :double, :uint32],                            :void
  attach_function :_draw_rect, :Gosu_draw_rect,         [:double, :double, :double, :double, :uint32, :double, :uint32],          :void

  attach_function :offset_x,   :Gosu_offset_x,   [:double, :double],                   :double
  attach_function :offset_y,   :Gosu_offset_y,   [:double, :double],                   :double
  attach_function :distance,   :Gosu_distance,   [:double, :double, :double, :double], :double
  attach_function :angle,      :Gosu_angle,      [:double, :double, :double, :double], :double
  attach_function :angle_diff, :Gosu_angle_diff, [:double, :double],                   :double
  attach_function :random,     :Gosu_random,     [:double, :double],                   :double

  attach_function :_screen_width,     :Gosu_screen_width,     [:pointer], :uint32
  attach_function :_screen_height,    :Gosu_screen_height,    [:pointer], :uint32
  attach_function :_available_width,  :Gosu_available_width,  [:pointer], :uint32
  attach_function :_available_height, :Gosu_available_height, [:pointer], :uint32

  def self.gl(z = nil, &block)
    # Gosu.gl might not be called immediately
    # so to prevent block getting GC'd until used
    # store them in a global variable which is
    # cleared after rendering is complete
    # i.e. after Window.draw is done.
    $gosu_gl_blocks ||= []
    $gosu_gl_blocks << block

    raise "Block not given!" unless block

    if z
      _gl_z(z, block)
    else
      _gl(block)
    end
  end

  def self.render(width, height, retro: false, &block)
    Gosu::Image.new(_render(width, height, block, 0x00000000))
  end

  def self.record(width, height, &block)
    Gosu::Image.new(_record(width, height, block))
  end

  def self.translate(x, y, &block)
    _translate(x, y, block)
  end

  def self.rotate(angle, around_x = 0, around_y = 0, &block)
    _rotate(angle, around_x, around_y, block)
  end

  def self.scale(x, y, around_x = 0, around_y = 0, &block)
    _scale(x, y, around_x, around_y, block)
  end

  # Note: On JRuby this seems to get "optimized out" for some reason
  # For now, call jruby with the `--dev` option
  def self.clip_to(x, y, width, height, &block)
    _clip_to(x, y, width, height, block)
  end

  def self.button_down?(id)
    _button_down(id)
  end

  def self.draw_line(x1, y1, c1, x2, y2, c2, z = 0, mode = :default)
    _draw_line(x1, y1, color_to_drawop(c1), x2, y2, color_to_drawop(c2), z, Gosu.mode_to_mask(mode))
  end

  def self.draw_quad(x1, y1, c1, x2, y2, c2,
                     x3, y3, c3, x4, y4, c4,
                     z = 0, mode = :default)
    _draw_quad(x1, y1, color_to_drawop(c1), x2, y2, color_to_drawop(c2),
               x3, y3, color_to_drawop(c3), x4, y4, color_to_drawop(c4),
               z, Gosu.mode_to_mask(mode))
  end

  def self.draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3, z = 0, mode = :default)
    _draw_triangle(x1, y1, color_to_drawop(c1), x2, y2, color_to_drawop(c2),
               x3, y3, color_to_drawop(c3), z, Gosu.mode_to_mask(mode))
  end

  def self.draw_rect(x, y, width, height, c, z = 0, mode = :default)
    _draw_rect(x, y, width, height, color_to_drawop(c), z, Gosu.mode_to_mask(mode))
  end

  def self.available_width(window = nil)
    _available_width(window)
  end

  def self.available_height(window = nil)
    _available_height(window)
  end

  def self.screen_width(window = nil)
    _screen_width(window)
  end

  def self.screen_height(window = nil)
    _screen_height(window)
  end

  def self.enable_undocumented_retrofication
  end

  def self.color_to_drawop(color)
    color.is_a?(Gosu::Color) ? color.gl : color
  end

  # SEE: https://github.com/gosu/gosu/blob/master/Gosu/GraphicsBase.hpp
  def self.image_flags(mode)
    mode = mode ? :retro : :default if mode.is_a?(TrueClass) || mode.is_a?(FalseClass)

    case mode
    when :default, :smooth
      0
    when :retro
      1 << 5
    else
      return mode if mode.is_a?(Numeric)
      raise ArgumentError, "No such mode: #{mode}"
    end
  end

  def self.font_flags(bold, italic, underline)
    flags = 0x0
    flags |= 1 if bold
    flags |= 2 if italic
    flags |= 4 if underline

    return flags
  end

  def self.font_alignment_flags(mode)
    case mode
    when :left
      0
    when :right
      1
    when :center
      2
    when :justify
      3
    else
      return mode if mode.is_a?(Numeric)
      raise ArgumentError, "No such mode: #{mode}"
    end
  end

  def self.mode_to_mask(mode)
    case mode
    when :default
      0
    when :additive, :add
      1
    when :multiply
      2
    else
      return mode if mode.is_a?(Numeric)
      raise ArgumentError, "No such mode: #{mode}"
    end
  end
end