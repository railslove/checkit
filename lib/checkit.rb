# Disable all warnings
$VERBOSE = nil

# Create namespace
CheckIt = Module.new

# Utility classes
require "checkit/version"
require "checkit/styled_io"

# Checks
require "checkit/config_files"
require "checkit/services"

# Core application
require "checkit/core"
