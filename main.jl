cd(dirname(@__FILE__)); flush(stdout); println("*/"*repeat("-",40)*"/*");

modelpath="REORIENT";                               # Path to the optimisation model
path="$modelpath/dataXLSX";                         # Specifies the relative path where data is held

include("functions/load_packages.jl");              # Loads the required packages
include("functions/load_support.jl");               # Loads the data support functions
include("$modelpath/load_models.jl");               # Contains the models

#### Data loading & saving to JLD2 file
mainFile="main_ns.xlsx";                            # Name of the index file
jldFile="data.jld2";                                # Name of jld2 file to be saved or read
flush(stdout); print("Generating data tables...    "); a=time();
data=generateTablesfromXLSXNew(path,mainFile);      # Data loaded from XLSX files into dictionaries
println("done in $(round(time()-a,digits=1))s ")
include("$path/data_preparation.jl")                # Custom combination of functions, according to requirements of model

#### Model building and solving
include("functions/build_models.jl")                # Create and solve REORIENT model
