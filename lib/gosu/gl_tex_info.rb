module Gosu
  class GLTexInfo < FFI::ManagedStruct
    layout  :tex_name, :int,
            :left,     :double,
            :right,    :double,
            :top,      :double,
            :bottom,   :double

    def tex_name
      self[:tex_name]
    end

    def left
      self[:left]
    end

    def right
      self[:right]
    end

    def top
      self[:top]
    end

    def bottom
      self[:bottom]
    end

    def self.release(pointer)
      Gosu::Image._image_gl_tex_info_destroy(pointer)
    end
  end
end