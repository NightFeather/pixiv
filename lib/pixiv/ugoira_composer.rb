require 'securerandom'

module Pixiv
  class UgoiraComposer
    def initialize ugoira, zipname, template, tempdir = nil
      @ugoira   = ugoira
      @zipname  = zipname
      @output   = StringTemplate.convert template, ugoira
      @tempdir  = tempdir || '/tmp/'
      @tempdir  = File.join(@tempdir, "ugoira2mp4-" + SecureRandom.hex(8))
      @metafile = File.join @tempdir, 'meta.txt'
      system 'mkdir', '-p', @tempdir
    end
  
    def decompress
      system 'unzip', @zipname, '-d', @tempdir
    end
  
    def build_concat_meta
      res = @ugoira.metadata["frames"].map do |o|
        "file '%s'\nduration %2.3f\n" % [ File.join(@tempdir, o["file"]), o["delay"] / 1000.0 ]
      end

      length = @ugoira.metadata["frames"].map { |o| o['delay'] }.reduce(&:+)

      res = res * ((5000 / length) + 1) if length < 5000

      File.open @metafile, 'wb' do |f|
        f << res.join
      end
    end
  
    def compose_mp4
      system 'ffmpeg',
             '-f', 'concat', 
             '-safe', '0' ,
             '-i', @metafile,
             '-pix_fmt', 'yuv420p',
             @output + '.mp4'
    end

    def compose_gif
      res = @ugoira.metadata["frames"].map do |o|
        [ '-delay', ((o["delay"]) / 500.0).to_s, File.join(@tempdir, o["file"]) ]
      end
      system 'convert', *res.flatten, '-loop', '0' , @output + '.gif'
    end

    def doit
      decompress
      build_concat_meta
      compose_mp4
    end

    def cleanup
      system 'rm', '-r', @tempdir
    end
  end
end
