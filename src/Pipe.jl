module Pipe
#Reflow piped things replacing the _ in the next section

export @pipe

const PLACEHOLDER = :_

function rewrite(ff::Expr, target, elementwise=false)
    function replace(arg::Any)
        arg #Normally do nothing
    end
    function replace(arg::Symbol)
        if arg==PLACEHOLDER
            target
        else
            arg
        end
    end
    function replace(arg::Expr)
        rep = copy(arg)
        rep.args = replace.(rep.args)
        rep
    end

    if elementwise
        rep_arg1 = Symbol(:., ff.args[1])
        rep_args = [rep_arg1; replace.(ff.args[2:end])]
    else
        rep_args = replace.(ff.args)
    end
    if ff.args != rep_args
        #_ subsitution
        ff.args=rep_args
        return ff
    end
    #No subsitution was done (no _ found)
    #Apply to a function that is being returned by ff,
    #(ff could be a function call or something more complex)
    rewrite_apply(ff,target)
end

function rewrite_apply(ff, target, elementwise=false)
    if elementwise
        :($ff.($target)) #function application
    else
        :($ff($target)) #function application
    end
end

function rewrite(ff::Symbol, target, elementwise=false)
    if ff==PLACEHOLDER
        target
    else
        rewrite_apply(ff,target,elementwise)
    end
end

function funnel(ee::Any) #Could be a Symbol could be a literal
    ee #first (left most) input
end

function funnel(ee::Expr)
    if (ee.args[1]==:|>)
        target = funnel(ee.args[2]) #Recurse
        rewrite(ee.args[3],target)
    elseif (ee.args[1]==:.|>)
        target = funnel(ee.args[2]) #Recurse
        rewrite(ee.args[3],target,true)
    else
        #Not in a piping situtation
        ee #make no change
    end
end

macro pipe(ee)
    esc(funnel(ee))
end

end
