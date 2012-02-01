module TokyoManager
  module Shell
    # This is a wrapper for Kernel.` to allow us to stub shell commands in our specs.
    def self.execute(command)
      `#{command}`
    end
  end
end
