#No change to nonpipes functionality 
@assert macroexpand( :(@pipe a) ) == :a #doesn't change single inputs
@assert macroexpand( :(@pipe b(a)) ) == :(b(a)) #doesn't change inputs that a function applications

#Compatable with Julia 1.3 piping functionality
@assert macroexpand( :(@pipe a|>b) ) == :(b(a)) #basic
@assert macroexpand( :(@pipe a|>b|>c) ) == :(c(b(a)))  #Keeps chaining 3
@assert macroexpand( :(@pipe a|>b|>c|>d) ) == :(d(c(b(a)))) #Keeps chaining 4

@assert macroexpand( :(@pipe a|>b(x)) ) == :((b(x))(a))  #applying to function calls returning functions
@assert macroexpand( :(@pipe a(x)|>b ) ) == :(b(a(x)))   #feeding functioncall results on wards

@assert macroexpand(:(@pipe 1|>a)) ==:(a(1)) #Works with literals (int)
@assert macroexpand(:(@pipe "foo"|>a)) == :(a("foo")) #Works with literal (string)
@assert macroexpand( :(@pipe a|>bb[2])) == :((bb[2])(a)) #Should work with RHS that is a array reference


#Marked locations
@assert macroexpand( :(@pipe a|>b(_) ) ) == :(b(a)) #Marked location only
@assert macroexpand( :(@pipe a|>b(x,_) ) ) == :(b(x,a)) # marked 2nd (and last)
@assert macroexpand( :(@pipe a|>b(_,x) ) ) == :(b(a,x)) # marked first
@assert macroexpand( :(@pipe a|>b(_,_) ) ) == :(b(a,a)) # marked double (Not certain if this is a good idea)
@assert macroexpand( :(@pipe a|>bb[2](x,_))) == :((bb[2])(x,a)) #Should work with RHS that is a array reference


#Mixing modes
@assert macroexpand( :(@pipe a|>b|>c(_) ) ) == :(c(b(a)))
@assert macroexpand( :(@pipe a|>b(x,_)|>c|>d(_,y) ) ) == :(d(c(b(x,a)),y))
@assert macroexpand( :(@pipe a|>b(xb,_)|>c|>d(_,xd)|>e(xe) |>f(xf,_,yf) ) ) == :(f(xf,(e(xe))(d(c(b(xb,a)),xd)),yf)) #Very Complex