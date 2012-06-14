module SpecUtils
  def example_init
    get_support_file('scribbler_example.rb')
  end

  def get_support_file(filename)
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'examples', filename))
  end
end
