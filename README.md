To use this place @pipe at the start of the line for which you want "advanced piping functionality to worl".

This works the same as Julia 1.3 Piping,
except if you place a underscore in the right hand of the expressing, it will be replaced with the lefthand side.

So:

```
@pipe a|>b(x,_) #== b(x,a) #Not: (b(x,_))(a) 
```

If you are using _ as a variable name etc, you will not be able to use that variable inside this  (except as most LHS, but that will get confusing). If you have a convincing reason why you should be using _ as a variable name then do tell me.
I'm not 100% sold that _ is the best marker for this.

###See Also:
[Lazy.jl](https://github.com/one-more-minute/Lazy.jl#macros)'s threading macros.
They are similar, the stylistic difference this has, is the preserving of the |> symbol, which I find more readable