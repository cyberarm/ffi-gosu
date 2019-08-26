module Gosu
    class Image
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_create_image,  :Gosu_Image_create,  [:string, :uint32],                                      :pointer
    attach_function :_image_width,   :Gosu_Image_width,   [:pointer],                                              :int
    attach_function :_image_height,  :Gosu_Image_height,  [:pointer],                                              :int
    attach_function :_image_draw,    :Gosu_Image_draw,    [:pointer, :double, :double, :double, :uint32, :uint32], :void
    attach_function :_image_save,    :Gosu_Image_save,    [:pointer, :string],                                     :void
    attach_function :_destroy_image, :Gosu_Image_destroy, [:pointer],                                              :void

    def initialize(filename, retro: false)
      flags = 0x00000000
      @__image = _create_image(filename, flags)
    end

    def __pointer
      @__image
    end

    def width
      _image_width(@__image)
    end

    def height
      _image_height(@__image)
    end

    def draw(x, y, z, color = 0xffffffff, flags = 0x00000000)
      _image_draw(@__image, x, y, z, color, flags)
    end

    def save(filename)
      _image_save(@__image, filename)
    end

    # TODO: investigate if/how to have ruby's GC handle this
    def free_object
      _destroy_image(@__image)
    end
  end
end