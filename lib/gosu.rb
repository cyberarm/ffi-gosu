require "ffi"
require "fiddle"

if RUBY_PLATFORM =~ /mswin$|mingw32|mingw64|win32\-|\-win32/
  binary_path = File.expand_path("../../../gosu/lib", __dir__)#File.dirname(__FILE__)
  # 64-bit builds of Windows use "x64-mingw32" as RUBY_PLATFORM
  binary_path += "64" if RUBY_PLATFORM =~ /^x64-/

  begin
    # Make DLLs available as shown here:
    # https://github.com/oneclick/rubyinstaller2/wiki/For-gem-developers
    require 'ruby_installer'
    RubyInstaller::Runtime.add_dll_directory(binary_path)
  rescue LoadError
    # Add this gem to the PATH on Windows so that bundled DLLs can be found.
    # When running through Ocra on Windows, we need to be careful to preserve the ENV["PATH"]
    # encoding (see #385).
    path_encoding = ENV["PATH"].encoding
    ENV["PATH"] = "#{binary_path.encode(path_encoding)};#{ENV["PATH"]}"
  end

  # Add the correct lib directory for the current version of Ruby (major.minor).
  $LOAD_PATH.unshift File.join(binary_path, RUBY_VERSION[/^\d+.\d+/])
end

module Gosu
  LIBRARY_PATH = [
    File.expand_path("../../../gosu/build/ffi/libgosu-ffi.so", __dir__),
    "/usr/local/lib/libgosu-ffi.dylib", # Homebrew on macOS (Intel) or manual installation
    "/opt/homebrew/lib/libgosu-ffi.dylib", # Homebrew on macOS (Apple Silicon)
    "gosu-ffi"
  ]

  extend FFI::Library
  ffi_lib Gosu::LIBRARY_PATH

  callback :_callback,             [:pointer],          :void
  callback :_callback_with_string, [:pointer, :string], :void

  # Argumentless functions that don't need nice pretty argument handling
  attach_function :fps,            :Gosu_fps,                    [], :int
  attach_function :flush,          :Gosu_flush,                  [], :void
  attach_function :milliseconds,   :Gosu_milliseconds,           [], :long
  attach_function :default_font_name, :Gosu_default_font_name, [], :string

  attach_function :_user_languages, :Gosu_user_languages, [:_callback_with_string, :pointer], :void

  attach_function :_transform, :Gosu_transform, [:double, :double, :double, :double, :double, :double, :double, :double,
                                                 :double, :double, :double, :double, :double, :double, :double, :double,
                                                 :_callback
                                                ], :void
  attach_function :_translate, :Gosu_translate, [:double, :double, :_callback], :void
  attach_function :_rotate,    :Gosu_rotate,    [:double, :double, :double, :_callback], :void
  attach_function :_scale,     :Gosu_scale,     [:double, :double, :double, :double, :_callback], :void
  attach_function :_clip_to,   :Gosu_clip_to,   [:double, :double, :double, :double, :_callback], :void

  attach_function :_gl_z,    :Gosu_gl_z,  [:double, :_callback],             :void
  attach_function :_gl,      :Gosu_gl,    [:_callback],                      :void
  attach_function :_render, :Gosu_render, [:int, :int, :_callback, :uint32], :pointer
  attach_function :_record, :Gosu_record, [:int, :int, :_callback],          :pointer

  attach_function :_button_down, :Gosu_button_down,            [:uint32], :bool
  attach_function :axis,        :Gosu_axis,                    [:uint32], :double
  attach_function :button_id_to_char, :Gosu_button_id_to_char, [:uint32], :string
  attach_function :char_to_button_id, :Gosu_button_char_to_id, [:string], :uint32
  attach_function :_button_name, :Gosu_button_name,            [:uint32], :string
  attach_function :_gamepad_name, :Gosu_gamepad_name,          [:uint32], :string

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

  attach_function :Gosu_last_error, [], :string

  def self.user_languages
    languages = []
    callback = proc { |data, string| languages << string if string }
    _user_languages(callback, nil)
    languages
  end

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

  def self.render(width, height, retro: false, tileable: false, &block)
    Gosu::Image.new(_render(width, height, block, Gosu.image_flags(retro: retro, tileable: tileable)))
  end

  def self.record(width, height, &block)
    Gosu::Image.new(_record(width, height, block))
  end

  def self.transform(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, &block)
    _transform(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, block)
  end

  def self.translate(x, y, &block)
    _translate(x, y, block)
  end

  def self.rotate(angle, around_x = 0, around_y = 0, &block)
    _rotate(angle, around_x, around_y, block)
  end

  def self.scale(x, y = x, around_x = 0, around_y = 0, &block)
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

  def self.button_name(id)
    name = _button_name(id)
    name&.empty? ? nil : name
  end

  def self.gamepad_name(id)
    name = _gamepad_name(id)
    name&.empty? ? nil : name
  end

  def self.draw_line(x1, y1, c1, x2, y2, c2, z = 0, mode = :default)
    _draw_line(x1, y1, color_to_drawop(c1), x2, y2, color_to_drawop(c2), z, Gosu.blend_mode(mode))
  end

  def self.draw_quad(x1, y1, c1, x2, y2, c2,
                     x3, y3, c3, x4, y4, c4,
                     z = 0, mode = :default)
    _draw_quad(x1, y1, color_to_drawop(c1), x2, y2, color_to_drawop(c2),
               x3, y3, color_to_drawop(c3), x4, y4, color_to_drawop(c4),
               z, Gosu.blend_mode(mode))
  end

  def self.draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3, z = 0, mode = :default)
    _draw_triangle(x1, y1, color_to_drawop(c1), x2, y2, color_to_drawop(c2),
                   x3, y3, color_to_drawop(c3), z, Gosu.blend_mode(mode))
  end

  def self.draw_rect(x, y, width, height, c, z = 0, mode = :default)
    _draw_rect(x, y, width, height, color_to_drawop(c), z, Gosu.blend_mode(mode))
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

  def self.window_flags(fullscreen: false, resizable: false, borderless: false)
    flags = 0
    flags |= 1 if fullscreen
    flags |= 2 if resizable
    flags |= 4 if borderless

    flags
  end

  # SEE: https://github.com/gosu/gosu/blob/master/Gosu/GraphicsBase.hpp
  def self.image_flags(retro: false, tileable: false)
    flags = 0

    flags = 30 if tileable
    flags |= 1 << 5 if retro

    flags
  end

  def self.font_flags(bold, italic, underline)
    flags = 0x0
    flags |= 1 if bold
    flags |= 2 if italic
    flags |= 4 if underline

    flags
  end

  def self.font_alignment_flags(flags)
    case flags
    when :left
      0
    when :right
      1
    when :center
      2
    when :justify
      3
    else
      return flags if flags.is_a?(Numeric)

      raise ArgumentError, "No such font alignment: #{flags}"
    end
  end

  def self.blend_mode(mode)
    case mode
    when :default
      0
    when :additive, :add
      1
    when :multiply
      2
    else
      return mode if mode.is_a?(Numeric)

      raise ArgumentError, "No such blend mode: #{mode}"
    end
  end

  def self.check_last_error
    if (err = Gosu_last_error())
      raise err
    end
  end
end

# Individual classes need to be loaded after defining Gosu.check_last_error.

require_relative "gosu/numeric"

require_relative "gosu/channel"
require_relative "gosu/color"
require_relative "gosu/constants"
require_relative "gosu/font"
require_relative "gosu/gl_tex_info"
require_relative "gosu/image"
require_relative "gosu/sample"
require_relative "gosu/song"
require_relative "gosu/text_input"
require_relative "gosu/version"
require_relative "gosu/window"

require_relative "gosu/compat"
