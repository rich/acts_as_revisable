Gem::Specification.new do |s|
  FatJam::ActsAsRevisable::GemSpecOptions::HASH.each do |key, value|
    s.send(key,value)
  end
  s.name = "acts_as_revisable"
end