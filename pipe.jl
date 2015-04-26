#Reflow piped things replacing the _ in the next section
function rewrite(ff::Expr,target)
    @assert(ff.head==:call)
    rep_indexs = find(ff.args.==:_)
    if length(rep_indexs)>0
        #_ subsitution
        ff.args[rep_indexs]=target
        ff
    else
        #Apply to a function that is being returned by ff
        rewrite_apply(ff,target)
    end

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