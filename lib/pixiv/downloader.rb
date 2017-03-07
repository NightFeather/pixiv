module Pixiv
  class Downloader

    attr_reader :workdir, :suffix

    def initialize suffix = '.temp', workdir = Dir.pwd
      @workdir = workdir
      @suffix = suffix
    end

    def download_illust illust, template = "?title?", progress_cb = nil, finish_cb = nil
      filename = Pixiv::StringTemplate.convert template, illust
      uri = illust.original
      filename += File.extname(uri)
      download URI(uri), filename, progress_cb, finish_cb
    end

    def download_manga manga, template = "?user? - ?title?/?idx?", progress_cb = nil, finish_cb = nil
      manga.images.each_pair.map do |idx, image|
        filename = Pixiv::StringTemplate.convert template, manga, idx: idx.to_s.rjust(2,?0)
        uri = image
        filename += File.extname(uri)
        download URI(uri), filename, progress_cb, finish_cb
      end
    end

    def download_ugoira_cover ugoira, template = "?user? - ?title? - cover", progress_cb = nil, finish_cb = nil
      filename = Pixiv::StringTemplate.convert template, ugoira
      uri = ugoira.cover
      filename += File.extname(uri)
      download URI(uri), filename, progress_cb, finish_cb
    end

    def download_ugoira ugoira, template = "?user? - ?title?", progress_cb = nil, finish_cb = nil
      filename = Pixiv::StringTemplate.convert template, ugoira
      uri = ugoira.zip_url
      filename += File.extname(uri)
      download URI(uri), filename, progress_cb, finish_cb
    end

    def download uri, path, progress_cb = nil, finish_cb = nil
      length = 0
      uri = URI(uri)

      path = File.join(workdir, path) unless path =~ /^\//

      unless File.exist? (File.dirname path)
        system 'mkdir', '-p', File.dirname(path)
      end

      Net::HTTP.start(uri.hostname, use_ssl: uri.scheme == 'https') do |http|
        File.open path + @suffix, "wb" do |f|
          http.get uri, referer: 'https://app-api.pixiv.net/' do |chunk|
            f << chunk
            length += chunk.length
            progress_cb.call path, length if progress_cb and progress_cb.respond_to? :call
          end
        end
      end

      File.rename(path + @suffix, path)
      finish_cb.call path, length if finish_cb and finish_cb.respond_to? :call
      return path
    end
  end
end