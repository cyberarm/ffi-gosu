module Gosu
  class TextInput
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    callback :_callback_filter, [:pointer, :string], :void

    attach_function :_create_textinput,   :Gosu_TextInput_create,   [],         :pointer
    attach_function :_destroy_textinput,  :Gosu_TextInput_destroy,  [:pointer], :void

    attach_function :_textinput_caret_pos,            :Gosu_TextInput_caret_pos,           [:pointer],          :uint32
    attach_function :_textinput_set_caret_pos,        :Gosu_TextInput_set_caret_pos,       [:pointer, :uint32], :void
    attach_function :_textinput_selection_start,      :Gosu_TextInput_selection_start,     [:pointer],          :uint32
    attach_function :_textinput_set_selection_start,  :Gosu_TextInput_set_selection_start, [:pointer, :uint32], :void

    attach_function :_textinput_text,              :Gosu_TextInput_text,              [:pointer],                              :string
    attach_function :_textinput_set_text,          :Gosu_TextInput_set_text,          [:pointer, :string],                     :void
    attach_function :_textinput_set_filter,        :Gosu_TextInput_set_filter,        [:pointer, :_callback_filter, :pointer], :void
    attach_function :_textinput_set_filter_result, :Gosu_TextInput_set_filter_result, [:pointer, :string],                     :void

    attach_function :_textinput_delete_backward, :Gosu_TextInput_delete_backward, [:pointer], :void
    attach_function :_textinput_delete_forward,  :Gosu_TextInput_delete_forward,  [:pointer], :void

    def initialize
      __text_input = _create_textinput
      @memory_pointer = FFI::AutoPointer.new(__text_input, Gosu::TextInput.method(:release))

      @__filter_proc = proc { |data, text| protected_filter(text) }
      _textinput_set_filter(__pointer, @__filter_proc, nil)
    end

    def __pointer
      @memory_pointer
    end

    def text
      _textinput_text(__pointer)
    end

    def text=(string)
      _textinput_set_text(__pointer, string.to_s)
    end

    def caret_pos
      _textinput_caret_pos(__pointer)
    end

    def caret_pos=(int)
      _textinput_set_caret_pos(__pointer, int)
    end

    def selection_start
      _textinput_selection_start(__pointer)
    end

    def selection_start=(int)
      _textinput_set_selection_start(__pointer, int)
    end

    def filter(text)
      return text
    end

    def delete_backward
      _textinput_delete_backward(__pointer)
    end

    def delete_forward
      _textinput_delete_forward(__pointer)
    end

    # Ensures that filter_result is set on C side before filter callback returns
    private def protected_filter(text)
      string = filter(text)
      _textinput_set_filter_result(__pointer, string)
    end

    def self.release(pointer)
      _destroy_textinput(pointer)
    end
  end
end