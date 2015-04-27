module Pipe
#Reflow piped things replacing the _ in the next section
#Broken into seperate file to allow for testing without namespace mangling
export @pipe
include("Pipe_inner.jl")

end
