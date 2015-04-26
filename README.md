To use this place @pipe at the start of the line for which you want "advanced piping functionality to worl".

This works the same as Julia 1.3 Piping,
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

This last can be used for interacting with multiple returned values.

For example:

```
function get_angle(rise,run)
    atan(rise/run)
end

@pipe (2,4) |> get_angle(_[1],_[2]) # == 0.4636476090008061

```

However, for each `_` right hand side of the `|>`, the left hand side will be called.
This can incurr a performance cost.
Eg

```
function ratio(value, lr, rr)
    println("slitting on ration $lr:$rr")
    value*lr/(lr+rr), value*rr/(lr+rr)
end

function percent(left, right)
    left/right*100
end

@pipe 10 |> ratio(_,4,1) |> percent(_[1],_[2]) # = 400.0, outputs slitting on ration 4:1 Twice
@pipe 10 |> ratio(_,4,1) |> percent(_...) # = 400.0, outputs slitting on ration 4:1 Once
```




---------------------

If you are using `_` as a variable name etc, you will not be able to use that variable inside this  (except as most LHS, but that will get confusing). If you have a convincing reason why you should be using _ as a variable name then do tell me.
I'm not 100% sold that _ is the best marker for this.

###See Also:
[Lazy.jl](https://github.com/one-more-minute/Lazy.jl#macros)'s threading macros.
They are similar, the stylistic difference this has, is the preserving of the |> symbol, which I find more readable
