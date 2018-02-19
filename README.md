# Pipe

- Julia 0.3: [![Build Status 0.3](https://travis-matrix-badges.herokuapp.com/repos/oxinabox/Pipe.jl/branches/master/1)](https://travis-ci.org/oxinabox/Pipe.jl)
 - Julia 0.4: [![Build Status 0.4](https://travis-matrix-badges.herokuapp.com/repos/oxinabox/Pipe.jl/branches/master/2)](https://travis-ci.org/oxinabox/Pipe.jl)
 - Julia 0.5: [![Build Status 0.5](https://travis-matrix-badges.herokuapp.com/repos/oxinabox/Pipe.jl/branches/master/3)](https://travis-ci.org/oxinabox/Pipe.jl)
 - Julia 0.6: [![Build Status 0.6](https://travis-matrix-badges.herokuapp.com/repos/oxinabox/Pipe.jl/branches/master/4)](https://travis-ci.org/oxinabox/Pipe.jl)
 - Julia Nightly: [![Build Status Nightly](https://travis-matrix-badges.herokuapp.com/repos/oxinabox/Pipe.jl/branches/master/5)](https://travis-ci.org/oxinabox/Pipe.jl)
 
## Installation
As per normal install by calling (On the julia REPL or IJulia):

```
Pkg.add("Pipe")
```


## Usage


To use this place `@pipe` at the start of the line for which you want "advanced piping functionality" to work.

This works the same as Julia Piping,
except if you place a underscore in the right hand of the expressing, it will be replaced with the lefthand side.

So:

```
@pipe a|>b(x,_) # == b(x,a) #Not: (b(x,_))(a) 
```

Futher  the _ can be unpacked, called, deindexed offetc.

```
@pipe a|>b(_...) # == b(a...)
@pipe a|>b(_(1,2)) # == b(a(1,2))
@pipe a|>b(_[3]) # == b(a[3])
```

This last can be used for interacting with multiple returned values. In general however, this is frowned upon.
Generally a pipeline is good for expressing a logical flow data through Single Input Single Output functions. When you deindex multiple times, that is case of working with Multiple Input Multiple Output functions.
In that case it is likely more clear to create named variables, and call the functions normally in sequence.
There is also a performace cost for doing multiple deindexes (see below).


For example:

```
function get_angle(rise,run)
    atan(rise/run)
end

@pipe (2,4) |> get_angle(_[1],_[2]) # == 0.4636476090008061
get_angle(2,4) # == 0.4636476090008061 #Note the ordinary way is much clearer

```

However, for each `_` right hand side of the `|>`, the left hand side will be called.
This can incurr a performance cost.
Eg

```
function ratio(value, lr, rr)
    println("slitting on ratio $lr:$rr")
    value*lr/(lr+rr), value*rr/(lr+rr)
end

function percent(left, right)
    left/right*100
end

@pipe 10 |> ratio(_,4,1) |> percent(_[1],_[2]) # = 400.0, outputs splitting on ratio 4:1 Twice
@pipe 10 |> ratio(_,4,1) |> percent(_...) # = 400.0, outputs splitting on ratio 4:1 Once
```




---------------------

## Issues

If you are using `_` as a variable name etc, you will not be able to use that variable inside this  (except as most LHS, but that will get confusing). If you have a convincing reason why you should be using _ as a variable name then do tell me.
I'm not 100% sold that _ is the best marker for this.

## See Also:

 - [List of similar/related works](https://github.com/JuliaLang/julia/issues/5571#issuecomment-205754539)
