using Base.Test

include("../src/Pipe_inner.jl") #Hack to avoid namespace mangling in macros

#No change to nonpipes functionality 
@test macroexpand( :(@pipe a) ) == :a #doesn't change single inputs
@test macroexpand( :(@pipe b(a)) ) == :(b(a)) #doesn't change inputs that a function applications

#Compatable with Julia 1.3 piping functionality
@test macroexpand( :(@pipe a|>b) ) == :(b(a)) #basic
@test macroexpand( :(@pipe a|>b|>c) ) == :(c(b(a)))  #Keeps chaining 3
@test macroexpand( :(@pipe a|>b|>c|>d) ) == :(d(c(b(a)))) #Keeps chaining 4

@test macroexpand( :(@pipe a|>b(x)) ) == :((b(x))(a))  #applying to function calls returning functions
@test macroexpand( :(@pipe a(x)|>b ) ) == :(b(a(x)))   #feeding functioncall results on wards

@test macroexpand(:(@pipe 1|>a)) ==:(a(1)) #Works with literals (int)
@test macroexpand(:(@pipe "foo"|>a)) == :(a("foo")) #Works with literal (string)
@test macroexpand( :(@pipe a|>bb[2])) == :((bb[2])(a)) #Should work with RHS that is a array reference


#Marked locations
@test macroexpand( :(@pipe a|>b(_) ) ) == :(b(a)) #Marked location only
@test macroexpand( :(@pipe a|>b(x,_) ) ) == :(b(x,a)) # marked 2nd (and last)
@test macroexpand( :(@pipe a|>b(_,x) ) ) == :(b(a,x)) # marked first
@test macroexpand( :(@pipe a|>b(_,_) ) ) == :(b(a,a)) # marked double (Not certain if this is a good idea)
@test macroexpand( :(@pipe a|>bb[2](x,_))) == :((bb[2])(x,a)) #Should work with RHS that is a array reference

#marked Unpacking
@test macroexpand( :(@pipe a|>b(_...) ) ) == :(b(a...)) # Unpacking
@test macroexpand( :(@pipe a|>bb[2](_...))) == :((bb[2])(a...)) #Should work with RHS of arry ref and do unpacking

#Mixing modes
@test macroexpand( :(@pipe a|>b|>c(_) ) ) == :(c(b(a)))
@test macroexpand( :(@pipe a|>b(x,_)|>c|>d(_,y) ) ) == :(d(c(b(x,a)),y))
@test macroexpand( :(@pipe a|>b(xb,_)|>c|>d(_,xd)|>e(xe) |>f(xf,_,yf) ) ) == :(f(xf,(e(xe))(d(c(b(xb,a)),xd)),yf)) #Very Complex



