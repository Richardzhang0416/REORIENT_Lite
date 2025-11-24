print("Preparation of models...     "); a=time();
m = Model(optimizer_with_attributes(()->Gurobi.Optimizer(gurobi_env),"OutputFlag"=>0))
VarP1!(m,ps,pp);                  
m2 = Model(optimizer_with_attributes(()->Gurobi.Optimizer(gurobi_env),"OutputFlag"=>0))
VarP2!(m2,ms,mp);                
lT,i2n=linkingTable(data["Linkage"]);
n2i=Dict(i2n[i]=>i for i in keys(i2n));
addLinking!(lT);
unc=writeUNC(lT,"u",n2i,i2n);
println("done in $(round(time()-a,digits=1))s ")

print("Loading and optimising REORIENT..."); a=time();
mU = Model(optimizer_with_attributes(()->Gurobi.Optimizer(gurobi_env),"OutputFlag"=>1,"Method"=>2,"Crossover"=>0,"Presolve"=>1,"DegenMoves"=>0,
                                "MIPGap"=>0.01,"MIPFocus"=>1, "NodeMethod"=>2))
REORIENT!(mU,ms,mp,lT);
nv = length(all_variables(mU))
nvb= num_constraints(mU,VariableRef, MOI.ZeroOne)
nc = 0
nc += num_constraints(mU,GenericAffExpr{Float64,VariableRef},MOI.EqualTo{Float64})
nc += num_constraints(mU,GenericAffExpr{Float64,VariableRef},MOI.GreaterThan{Float64})
nc += num_constraints(mU,GenericAffExpr{Float64,VariableRef},MOI.LessThan{Float64})
nc += num_constraints(mU,VariableRef,MOI.EqualTo{Float64})
nc += num_constraints(mU,VariableRef,MOI.GreaterThan{Float64})
nc += num_constraints(mU,VariableRef,MOI.LessThan{Float64})
nvl = length("$nv")
ncl = length("$nc")
println("variables   : $(round(nv*exp10(1-nvl);digits=2)) x 10^$(nvl-1)")
println("binaries    : $(nvb)")
println("constraints : $(round(nc*exp10(1-ncl);digits=2)) x 10^$(ncl-1)")
println(" ")
open(pwd()*"/$modelpath/REORIENT_size.txt","a") do io
    println(io,"variables   : $(nv)")
    println(io,"binaries    : $(nvb)")
    println(io,"constraints : $(nc)")
end
optimize!(mU);
println("done in $(round(time()-a,digits=1))s ")
