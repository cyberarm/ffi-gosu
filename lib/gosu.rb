require "ffi"
require_relative "gosu/version"
require_relative "gosu/window"
require_relative "gosu/image"

module Gosu
  extend FFI::Library
  ffi_lib Gosu::LIBRARY_PATH

  callback :_callback,            [],         :void
  callback :_callback_with_block, [:pointer], :void

  attach_function :fps, :Gosu_fps, [], :long

  attach_function :_translate, :Gosu_translate, [:double, :double, :_callback_with_block], :void
  attach_function :_rotate,    :Gosu_rotate,    [:double, :double, :double, :_callback_with_block], :void
  attach_function :_scale,     :Gosu_scale,     [:double, :double, :double, :double, :_callback_with_block], :void
  attach_function :_clip_to,   :Gosu_clip_to,   [:double, :double, :double, :double, :_callback_with_block], :void

  attach_function :_gl, :Gosu_gl, [:_callback], :void
  attach_function :_render, :Gosu_render, [:_callback_with_block], :pointer
  attach_function :_record, :Gosu_record, [:_callback_with_block], :pointer

  attach_function :_button_down, :Gosu_button_down, [:uint32], :bool

  attach_function :_draw_line, :Gosu_draw_line, [:double, :double, :uint32, :double, :double, :uint32, :double, :uint32], :void
  attach_function :_draw_quad, :Gosu_draw_quad, [:double, :double, :uint32, :double, :double, :uint32, :double, :uint32,
                                                 :double, :double, :uint32, :double, :double, :uint32, :double, :uint32], :void
  attach_function :_draw_rect, :Gosu_draw_rect, [:double, :double, :double, :double, :uint32, :double, :uint32],          :void

  def self.gl(z = nil, &block)
    _gl(block)
  end

  def self.render(width, height, retro: false, &block)
    _render(block)
  end

  def self.record(width, height, &block)
    _record(block)
  end

  def self.translate(x, y, &block)
    _translate(x, y, block)
  end

  def self.rotate(angle, around_x = 0, around_y = 0, &block)
    _rotate(angle, around_x, around_y, block)
  end

  def self.scale(x, y, around_x, around_y, &block)
    _scale(x, y, around_x, around_y, block)
  end

  # Note: JRuby stops rendering after a second or two... block out of scope? (GC'd resulting in a nullptr in C land?)
  def self.clip_to(x, y, width, height, &block)
    _clip_to(x, y, width, height, block)
  end

  def self.button_down?(id)
    _button_down(id)
  end

  def self.draw_line(x1, y1, c1, x2, y2, c2, z = 0, mode = 0x0)
    _draw_line(x1, y1, c1, x2, y2, c2, z, mode)
  end

  def self.draw_quad(x1, y1, c1, x2, y2, c2,
                     x3, y3, c3, x4, y4, c4,
                     z = 0, mode = 0x0)
    _draw_quad(x1, y1, c1, x2, y2, c2,
               x3, y3, c3, x4, y4, c4,
               z, mode)
  end

  def self.draw_rect(x, y, width, height, c, z = 0, mode = 0xffffffff)
    _draw_rect(x, y, width, height, c, z, mode)
  end
end