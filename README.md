# REORIENT

[![DOI](https://zenodo.org/badge/1103192172.svg)](https://doi.org/10.5281/zenodo.17701723)

This is a guide to the REORIENT (REnewable resOuRce Investment for the ENergy Transition) model, an integrated energy system investment and operational planning optimisation model under multi-timescale unicertainty developed by [Zhang et al. 2025](https://doi.org/10.1016/j.ejor.2025.04.005). The guide aims to provide a user manual and an overview of the model. The guide is structured as follows: 

- [**Model development history**](#model-development-history)
- [**Model description**](#model-description)
- [**Get started - How to run REORIENT for the first time**](#get-started---how-to-run-reorient-for-the-first-time)
- [**Setting up a model instance**](#setting-up-a-model-instance)
- [**The functions directory**](#the-functions-directory)

**NB!**: *This GitHub repo is to release an open version of the REORIENT energy model. The solution algorithms are not available in this repo. Therefore,please consider the model size when generating scenario trees (short-term and long-term)*. 


## Model development history
The REORIENT  model is the latest version of the models that were under development during [Dr Hongyu Zhang](https://www.hongyuzhang.com)'s PhD. It went through roughly three phases of development before reaching the REORIENT model. 

### Phase I
The first model developed in Zhang's PhD is a deterministic mixed-integer linear programme for large-scale offshore energy system planning. Its key feature is the modelling of investment planning with high operational detail for offshore oil and gas fields. This model was published in [Zhang et al. 2022](https://doi.org/10.1016/j.energy.2022.125219). It served as the predecessor and foundation of the REORIENT model. At the time, Phase I had the internal name *OffMod*.

### Phase II
Major developments were made to the Phase I model by (1) interfacing the offshore energy system with the onshore system, and (2) modelling short-term uncertainties, including wind and solar capacity factors, energy load, platform production profiles, and hydropower production limits. This model was published in [Zhang et al. 2022](https://doi.org/10.1115/OMAE2022-78551). 

### Phase III
The modelling functions and capabilities developed in Phase III led to the eventual REORIENT model. The added functions include: (1) integrating capacity expansion, retrofit, and abandonment planning, and (2) using multi-horizon stochastic mixed-integer linear programming with multi-timescale uncertainty. The model was published in [Zhang et al. 2025](https://doi.org/10.1016/j.ejor.2025.04.005). 

### Current development
Since the introduction of REORIENT, it has been actively developed. In an extended version by [Zhang et al. 2025](https://doi.org/10.48550/arXiv.2409.00227), the model was expanded to include industrial sectors and the option of CCS related to both industry and power generation. In addition, scenario generation was enhanced in this work.


## Model description

A short description of the model is given here. For more details we recommend reading the original model description by [Zhang et al. 2025](https://doi.org/10.1016/j.ejor.2025.04.005).

REORIENT is an integrated energy planning model. The model is (1) integrating capacity expansion, retrofit and abandonment planning, and (2) using multi-horizon stochastic mixed-integer linear programming with short-term and long-term uncertainty. The model instances in the repository are based on the European energy system, but could generally extend to every system.

The original model combined modelling (a) capacity expansion of the European power system, (b) investment in new hydrogen infrastructures, (c) retrofitting oil and gas infrastructures in the North Sea region for hydrogen production and distribution, and abandoning existing infrastructures, and (d) long-term uncertainty in oil and gas prices and short-term uncertainty in time series parameters.

The model is built in [Julia](https://julialang.org/downloads/) using [JuMP](https://jump.dev/JuMP.jl/stable/) and the [Gurobi](https://www.gurobi.com/) solver. 


## Get started - How to run REORIENT for the first time 

### Packages and versions

To set up the model, install **Julia v1.12.1** and install the required packages:

| Package      | Version  |
|--------------|----------|
| JuMP         | 1.29.3   |
| Gurobi       | 1.8.0    |
| CSV          | 0.10.15  |
| DataFrames   | 1.6.1    |
| Clustering   | 0.15.8   |
| Suppressor   | 0.2.8    |
| XLSX         | 0.10.4   |
| JLD2         | 0.6.3    |
| FileIO       | 1.17.1   |

REORIENT is actively maintained to support new releases.


### Running the code

The model is loaded and solved by running the **main.jl** file of the project directory. Before a first time run, make sure that all required packages are installed: 

To run the code: 
```shell
$ julia main.jl
```

If you want to keep the names and data from the code execution in a shell (very useful for debugging and inspecting solutions), the recommended way is to open a julia shell (`julia` / `julia -t 32`) and run: 

```shell
julia> include("main.jl")
```

## Setting up a model instance
There are two necessary parts to a model instance directory. The first is a `/dataXLSX` directory where data is loaded from and the second is a `load_models.jl` file. There is one model instance in the repo, namely the `REOREINT`, which corresponds to the original model developed by [Zhang et al. 2025](https://doi.org/10.1016/j.ejor.2025.04.005).
### Data, sets and parameters

The data and parameters are mainly set using the following files in the `/dataXLSX` directory of the model instance, which are described in detail below: 

 - `data_preparation.jl`
 - `investment_ns.xlsx`
 - `operation_ns.xlsx`
 - `link_ns.xlsx`

#### data_preparation.jl
This loads the data and structures it in accordance with the input from the excel files. Data that is not automatically loaded from the excel files are also manually populated in this file. The result are three important objects: 
- `ms`: The Sets for the investment problem
- `mp`: The Parameters for the investment problem
- `ps`: The Sets for the operational problem
- `pp`: The Parameters for the operational problem

The fields of these objects correspond to the names defined in the "sets" and "parameters" sheets of investment and operations excel workbooks.

Importantly, the setting of some parameters, for the most part related to costs, are done manually in the "Custom data preparation" portion of the `data_preparation.jl` file. When adding variables, sets or changing the setup in other ways, be careful to assert that all cost coefficients are still correctly added. 

#### investment_ns.xlsx

This is where the strategic sets, parameters and data are defined.

Sheet overview: 

- **index**: Maps the sheet_name to a table_name that is used when referring to the data in other parts of the file.
- **parameters**: Overview of which data belongs to which parameter.
- **sets**: Overview of which data belongs to which set.
- **tech_types**: Includes all types of technology that are present in the model. The cost structure and characteristics regarding lifetime and efficiency for each stage are set explicitly here.
- **technologies**: Includes all technologies that exist or can be invested in the model. Technology types of the same type in different geographical nodes are included explicitly here. 
- **abandonment_cost**: Data for the cost of abandonment. Only applied for oil platforms in current model versions.
- **all_devices**: List of all devices included in the model.
- **areas**: Overview of geographical nodes. Used for plotting.
- **line and line_hist**: Data for line cost, capacity, and lengths.
- **pipeline and pipeline_hist**: Data for pipeline cost, capacity, and lengths.
- **stages**: Defining the investment stages in the problem.
- **structure**: Defines the long term scenario tree by defining parameter values for all nodes in the tree. Scales different parameters per stage.
- **discount factor**: Discount factor for each investment stage.

#### operation_ns.xlsx

This is where the operational sets, parameters, and data are defined.

Sheet overview:

- **index**: Maps the sheet_name to a table_name that is used when referring to the data in other parts of the file.
- **parameters**: Overview of which data belongs to which parameter.
- **sets**: Overview of which data belongs to which set.
- **tech_types**: Includes all types of technology that are present in the model. The operational parameters, regarding ramping, efficiencies, CO$_2$ emissions, and variable costs are set here.
- **technologies**: Includes all technologies that exist or can be invested in the model. Technology types of the same type in different geographical nodes are included explicitly here.
- **lines**: Length, loss, type, and destinations for power lines.
- **pipeline**: Destinations for pipelines.
- **loads**: Mapping of power demand for each area to load time series.
- **hydrogen_demand**: Hydrogen demand for each area.
- **areas**: Overview of geographical nodes
- **slices**: Used for setting short-term scenarios in original version
- **time_series_info**: Used for setting short-term scenarios in original version
- **wind**: Time series for wind power production profiles.
- **solar**: Time series for solar production profiles.
- **load**: Tims series for load.
- **HydroRunoftheRiver/HydroRegulated**: Time series for hydro production.
- **gas_production/gas_export/gas_injection**: Time series for gas production/export/injection. 
- **oil_production**: Time series for oil production. 
- **water_injection/water_lift/water_bore**: Time series for water injection/lift/bore. 

#### link_ns.xlsx

This is where the variables from the investment problem are linked with the operational variables.

Sheet overview:
- **index**: Maps the sheet_name to a table_name that is used when referring to the data in other parts of the file.
- **indicies**
- **variables**
- **definitions**
  

### Building the model

The actual model(s) are built in the `build_models.jl` file of each instance directory.

The 
- VarP1!: Definition of the operational variables
- VarP2!: Definition of the investment planning variables
- REORIENT!: Definition of the REORIENT model
- oCost: Function that calculates the operational objective function.

The models are build with JuMP, heavily utilising the `@variable` and `@constraint` macros. For a thurough introduction into modelling with JuMP, we refer to the [official documentation](#https://jump.dev/JuMP.jl/stable/).

### Adding new technologies
To add a new technology to a model instance, sheets in all three excel workbooks need to be edited, as well as the `load_models.jl` file. Use the existing setup as a model for adding new variables. A warning is that the current data handling is a bit rigid, so adding new variables is not trivial. Some tips to verify that everything is set up correctly: 
- Ensure that the `ms`, `mp`, `ps` and `pp` are correctly set up after the data sheets are loaded.
- Check for errors in the "sets" and "parameters" tabs in both operational and investment workbooks.
- Be sure that all cost-coefficients are correctly added in the "custom data preparation" part of the `data_preparation.jl` file, especially if new sets are added.
- After the models are built, variables and constraints can be printed on normal form:
```Julia
show(model) # print model summary including all names
println(model[:`constraint_name/variable_name`])
```

### Important considerations when building the model
#### Numerical issues
Some constraints in the already implemented instances are scaled by a static factor. This can be important to avoid numerical issues leading to inaccuracies in the solvers.

#### Units
A common source of error when working with the model is the different units in play, especially when multiple commodities and sectors are modelled (hydrogen, CCS, industry, power). Efforts have been made to document both the code and data files to clarify all units. Still, make sure that all data, variables and constraints are coherent in terms of the units they use.

## The functions directory

A brief overview of the use and content of the functions directory files will be given here. 

- **load_support.jl**
Contains support functions for the data loading and short-term scenario generation. Functions are used in "data_preparation".

-------

*This guide is currently under development, and additional information will be added in due course.*