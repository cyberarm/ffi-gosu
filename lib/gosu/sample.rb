module Gosu
  class Sample
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_create_sample,  :Gosu_Sample_create,   [:string],  :pointer
    attach_function :_destroy_sample, :Gosu_Sample_destroy,  [:pointer], :void

    attach_function :_sample_play,     :Gosu_Sample_play,     [:pointer, :double, :double, :bool],          :pointer
    attach_function :_sample_play_pan, :Gosu_Sample_play_pan, [:pointer, :double, :double, :double, :bool], :pointer

    def initialize(filename)
      __sample = _create_sample(filename)
      @memory_pointer = FFI::AutoPointer.new(__sample, Gosu::Sample.method(:release))
    end

    def __pointer
      @memory_pointer
    end

    def play(volume = 1, speed = 1, looping = false)
      Gosu::Channel.new( _sample_play(__pointer, volume, speed, looping) )
    end

    def play_pan(pan = 0, volume = 1, speed = 1, looping = false)
      Gosu::Channel.new( _sample_play_pan(__pointer, pan, volume, speed, looping) )
    end

    def self.release(pointer)
      _destroy_sample(pointer)
    end
  end
end