module Gosu
  class Channel
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_destroy_channel, :Gosu_Channel_destroy,  [:pointer], :void

    attach_function :_channel_playing, :Gosu_Channel_playing, [:pointer], :bool
    attach_function :_channel_pause,   :Gosu_Channel_pause,   [:pointer], :void
    attach_function :_channel_paused,  :Gosu_Channel_paused,  [:pointer], :bool
    attach_function :_channel_resume,  :Gosu_Channel_resume,  [:pointer], :void
    attach_function :_channel_stop,   :Gosu_Channel_stop,     [:pointer], :void

    attach_function :_channel_set_volume, :Gosu_Channel_set_volume, [:pointer, :double], :void
    attach_function :_channel_set_speed,  :Gosu_Channel_set_speed,  [:pointer, :double], :void
    attach_function :_channel_set_pan,   :Gosu_Channel_set_pan,     [:pointer, :double], :void

    def initialize(pointer)
      @__channel = pointer
    end

    def __pointer
      @__channel
    end

    def playing?
      _channel_playing(@__channel)
    end

    def pause
      _channel_pause(@__channel)
    end

    def paused?
      _channel_paused(@__channel)
    end

    def resume
      _channel_resume(@__channel)
    end

    def stop
      _channel_stop(@__channel)
    end

    def volume=(double)
      _channel_set_volume(@__channel, double.clamp(0.0, 1.0))
    end

    def speed=(double)
      _channel_set_speed(@__channel, double.clamp(0.0, 1.0))
    end

    def pan=(double)
      _channel_set_pan(@__channel, double.clamp(0.0, 1.0))
    end
  end

  def free_object
    _destroy_channel(@__channel)
  end
end
