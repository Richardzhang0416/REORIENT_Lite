print("Loading packages...          "); a=time();
import Pkg
using JuMP
using Gurobi
using CSV
using DataFrames
using Dates
using Suppressor
using XLSX
using JLD2
using FileIO
gurobi_env = @suppress Gurobi.Env()
println("done in $(round(time()-a,digits=1))s ")
