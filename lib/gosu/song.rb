module Gosu
  class Song
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_song_current_song, :Gosu_Song_current_song, [], :pointer

    attach_function :_create_song, :Gosu_Song_create, [:string], :pointer
    attach_function :_destroy_song, :Gosu_Song_destroy, [:pointer], :void

    attach_function :_song_play,    :Gosu_Song_play,    [:pointer, :bool], :void
    attach_function :_song_playing, :Gosu_Song_playing, [:pointer],        :bool
    attach_function :_song_pause,   :Gosu_Song_pause,   [:pointer],        :void
    attach_function :_song_paused,  :Gosu_Song_paused,  [:pointer],        :bool
    attach_function :_song_stop,    :Gosu_Song_stop,    [:pointer],        :void

    attach_function :_song_volume,     :Gosu_Song_volume,     [:pointer],          :double
    attach_function :_song_set_volume, :Gosu_Song_set_volume, [:pointer, :double], :void

    def self.current_song
      ptr = _song_current_song
      unless ptr.null?
        Gosu::Song.new(_song_current_song)
      else
        nil
      end
    end

    def initialize(filename_or_pointer)
      if filename_or_pointer.is_a?(String)
        @__song = _create_song(filename_or_pointer)
      elsif filename_or_pointer.is_a?(FFI::Pointer)
        @__song = filename_or_pointer
      else
        pp filename_or_pointer
        raise ArgumentError
      end
    end

    def __pointer
      @__song
    end

    def play(looping = false)
      _song_play(@__song, looping)
    end

    def playing?
      _song_playing(@__song)
    end

    def pause
      _song_pause(@__song)
    end

    def paused?
      _song_paused(@__song)
    end

    def stop
      _song_stop(@__song)
    end

    def volume
      _song_volume(@__song)
    end

    def volume=(double)
      _song_set_volume(@__song, double.clamp(0.0, 1.0))
    end
  end

  def eql?(other)
    __pointer.address == other&.__pointer&.address
  end

  def free_object
    _destroy_song(@__song)
  end
end