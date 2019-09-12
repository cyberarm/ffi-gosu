module Gosu
  class Image
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_create_image,  :Gosu_Image_create,  [:string, :uint32],                                                        :pointer
    attach_function :_image_width,   :Gosu_Image_width,   [:pointer],                                                                :int
    attach_function :_image_height,  :Gosu_Image_height,  [:pointer],                                                                :int
    attach_function :_image_draw,    :Gosu_Image_draw,    [:pointer, :double, :double, :double, :double, :double, :uint32, :uint32], :void
    attach_function :_image_save,    :Gosu_Image_save,    [:pointer, :string],                                                       :void
    attach_function :_image_to_blob, :Gosu_Image_to_blob, [:pointer],                                                                :string
    attach_function :_destroy_image, :Gosu_Image_destroy, [:pointer],                                                                :void

    def self.from_text(text, line_height, options = {})
    end

    def self.from_markup(text, line_height, options = {})
    end

    def self.load_tiles(filename, tile_width ,tile_height, options = {})
    end

    def initialize(filename_or_pointer, retro: false)
      flags = 0x00000000

      if filename_or_pointer.is_a?(String)
        @__image = _create_image(filename_or_pointer, flags)

      elsif filename_or_pointer.is_a?(FFI::Pointer)
        @__image = filename_or_pointer
      else
        raise ArgumentError
      end
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

    def draw(x, y, z, scale_x = 1, scale_y = 1, color = Gosu::Color::WHITE, flags = 0x00000000)
      _image_draw(@__image, x, y, z, scale_x, scale_y, Gosu.color_to_drawop(color), flags)
    end

    def save(filename)
      _image_save(@__image, filename)
    end

    def to_blob
      v = _image_to_blob(@__image)
      # pp v
      return v
    end

    # TODO: investigate if/how to have ruby's GC handle this
    def free_object
      _destroy_image(@__image)
    end
  end
end