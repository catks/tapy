module Tapy
  Error = Class.new(StandardError)
  InstallError = Class.new(Error)
  UninstallError = Class.new(Error)
  UpdateError = Class.new(Error)
end
