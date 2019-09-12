module Gosu
  class GLTexInfo < FFI::Struct
    layout  :tex_name, :int
    layout  :left,     :double
    layout  :right,    :double
    layout  :top,      :double
    layout  :bottom,   :double
  end
end