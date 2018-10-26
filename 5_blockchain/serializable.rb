module Serializable
  def self.included(base)
    base.extend ClassMethods
  end

  def dump
    Marshal.dump(self)
  end

  module ClassMethods
    def load(serialized)
      Marshal.load(serialized)
    end
  end
end
