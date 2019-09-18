module Gosu
  class GLTexInfo < FFI::Struct
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
  end
end