require_relative '../phase2/controller_base'
require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    include ActiveSupport
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def render(template_name)
      controller_name = "#{self.class}".underscore
      erb_template = File.read("views/#{controller_name}/#{template_name}.html.erb")

      self.render_content(ERB.new(erb_template).result(binding), "text/html")      
    end
  end
end
