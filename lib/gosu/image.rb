module Gosu
  class Image
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_create_image,      :Gosu_Image_create,     [:string, :uint32], :pointer
    attach_function :_destroy_image,     :Gosu_Image_destroy,    [:pointer],         :void

    attach_function :_create_image_from_markup, :Gosu_Image_create_from_markup,   [:string, :string, :double, :int, :double, :uint32, :uint32, :uint32], :pointer
    attach_function :_create_image_from_text,   :Gosu_Image_create_from_text,     [:string, :string, :double, :int, :double, :uint32, :uint32, :uint32], :pointer
    attach_function :_create_image_from_blob,   :Gosu_Image_create_from_blob,     [:string, :int, :int, :uint32],                                        :pointer
    attach_function :_image_subimage,           :Gosu_Image_create_from_subimage, [:pointer, :int, :int, :int, :int],                                    :pointer

    attach_function :_image_width,       :Gosu_Image_width,      [:pointer], :int
    attach_function :_image_height,      :Gosu_Image_height,     [:pointer], :int

    attach_function :_image_draw,        :Gosu_Image_draw,       [:pointer, :double, :double, :double, :double, :double, :uint32, :uint32], :void
    attach_function :_image_draw_rot,    :Gosu_Image_draw_rot,   [:pointer, :double, :double, :double, :double, :double, :double,
                                                                  :double, :double, :uint32, :uint32],                                      :void

    attach_function :_image_save,        :Gosu_Image_save,        [:pointer, :string],              :void
    attach_function :_image_to_blob,     :Gosu_Image_to_blob,     [:pointer],                       :string
    attach_function :_image_insert,      :Gosu_Image_insert,      [:pointer, :pointer, :int, :int], :pointer
    attach_function :_image_gl_tex_info, :Gosu_Image_gl_tex_info, [:pointer],                       :pointer

    def self.from_text(markup, line_height, font: Gosu.default_font_name, width: -1, spacing: 0, align: :left,
                       bold: false, italic: false, underline: false, retro: false)
      Gosu::Image.new( _create_image_from_text(markup, font, line_height, width, spacing,
                      Gosu.font_alignment_flags(align), Gosu.font_flags(bold, italic, underline), Gosu.image_flags(retro)) )
    end

    def self.from_markup(markup, line_height, font: Gosu.default_font_name, width: -1, spacing: 0, align: :left,
                       bold: false, italic: false, underline: false, retro: false)
      Gosu::Image.new( _create_image_from_markup(markup, font, line_height, width, spacing,
                      Gosu.font_alignment_flags(align), Gosu.font_flags(bold, italic, underline), Gosu.image_flags(retro)) )
    end

    def self.load_tiles(filename, tile_width ,tile_height, options = {})
    end

    def initialize(object, retro: false)
      image_flags = 0x00000000

      if object.is_a?(String)
        @__image = _create_image(object, image_flags)

      elsif object.is_a?(FFI::Pointer)
        @__image = object
      elsif object.respond_to?(:to_blob) &&
            object.respond_to?(:columns)
            object.respond_to?(:rows)
        @__image = _create_image_from_blob(object.to_blob, object.columns, object.rows, image_flags)
      else
        pp object
        raise ArgumentError
      end

      raise RuntimeError unless @__image
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

    def draw(x, y, z, scale_x = 1, scale_y = 1, color = Gosu::Color::WHITE, flags = :default)
      _image_draw(@__image, x, y, z, scale_x, scale_y, Gosu.color_to_drawop(color), Gosu.image_flags(flags))
    end

    def draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = Gosu::Color::WHITE, flags = :default)
      _image_draw_rot(@__image, x, y, z, angle, center_x, center_y, scale_x, scale_y, Gosu.color_to_drawop(color), Gosu.image_flags(flags))
    end

    def save(filename)
      _image_save(@__image, filename)
    end

    def to_blob
      _image_to_blob(@__image)
    end

    def subimage(left, top, width, height)
      Gosu::Image.new( _image_subimage(@__image, left, top, width, height) )
    end

    def insert(image, x, y)
      _image_insert(@__image, image.__pointer, x, y)
    end

    def gl_tex_info
      tex_info = _image_gl_tex_info(@__image)
      tex_info ? GLTexInfo.new(tex_info) : nil
    end

    # TODO: investigate if/how to have ruby's GC handle this
    def free_object
      _destroy_image(@__image)
    end
  end
end