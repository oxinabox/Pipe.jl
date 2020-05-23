module Pipe
#Reflow piped things replacing the _ in the next section

export @pipe

const PLACEHOLDER = :_

function replace(arg::Any, target)
    arg #Normally do nothing
end

function replace(arg::Symbol, target)
    if arg==PLACEHOLDER
        target
    else
        arg
    end
end

function replace(arg::Expr, target)
    rep = copy(arg)
    rep.args = map(x->replace(x, target), rep.args)
    rep
end

function rewrite(ff::Expr, target, broadcast=false)
    if broadcast
        temp_var = gensym()
        rep_args = map(x->replace(x, temp_var), ff.args)
        if ff.args != rep_args
            #_ subsitution
            ff.args = rep_args
            return :($temp_var->$ff)
        end
    else
        rep_args = map(x->replace(x, target), ff.args)
        if ff.args != rep_args
            #_ subsitution
            ff.args = rep_args
            return ff
        end
    end

    #No subsitution was done (no _ found)
    #Apply to a function that is being returned by ff,
    #(ff could be a function call or something more complex)
    rewrite_apply(ff,target,broadcast)
end

function rewrite_apply(ff, target, broadcast=false)
    if broadcast
        temp_var = gensym()
        :($temp_var->$ff($temp_var))
    else
        :($ff($target)) #function application
    end
end

function rewrite(ff::Symbol, target, broadcast=false)
    if ff==PLACEHOLDER
        target
    else
        rewrite_apply(ff,target,broadcast)
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
        rewritten = rewrite(ee.args[3],target,true)
        ee.args[3] = rewritten
        ee
    else
        #Not in a piping situtation
        ee #make no change
    end
end

macro pipe(ee)
    esc(funnel(ee))
end

end
