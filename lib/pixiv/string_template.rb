module Pixiv
  module StringTemplate    
    def self.convert template, context, opt = {}
      template.gsub(/\?.+?\?/) do |frag|
        meth = frag[1..-2]
        if context.respond_to? meth
          context.send meth
        elsif opt.key? meth
          opt[meth]
        elsif opt.key? meth.to_sym
          opt[meth.to_sym]
        else
          ""
        end
      end
    end
  end
end