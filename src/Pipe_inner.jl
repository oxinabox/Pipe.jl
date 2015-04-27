#Reflow piped things replacing the _ in the next section

#Broken into seperate file to allow inport into testing without module so as to avoid macro namespace mangling

function rewrite(ff::Expr,target)
    function replace(arg::Any)
        arg #Normally do nothing
    end
    function replace(arg::Symbol)
        if arg==:_
            target
        else
            arg
        end
    end
    function replace(arg::Expr)
        rep = copy(arg)
        rep.args = map(replace,rep.args)
        rep
    end
       
    if (ff.head==:call)
        rep_args = map(replace,ff.args)
        if ff.args != rep_args
            #_ subsitution
            ff.args=rep_args
            return ff
        end
    end
    #No subsitution was done (either cos not a call, or cost no _ found)
    #Apply to a function that is being returned by ff, (ff could be a function call or something more complex)
    rewrite_apply(ff,target)
end
        

function rewrite_apply(ff::Union(Symbol,Expr),target)
    #function application
    :($ff($target))
end

function rewrite(ff::Symbol,target) 
    rewrite_apply(ff,target)
end

function funnel(ee::Any) #Could be a Symbol could be a literal
    #first (left most) input
    ee
end

function funnel(ee::Expr)
    if (ee.args[1]==:|>)
        ff = ee.args[3]
        target = funnel(ee.args[2]) #Recurse
        
        rewrite(ff,target)
    else
        #Not in a piping situtation
        ee #make no change
    end
end

macro pipe(ee)
    funnel(ee)    
end


