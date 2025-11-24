################# DATA PREPARATION #########################
############################################################
print("Preparing data...            "); a=time();

#### 1. OPERATIONAL PART ##################################
inheritData!(data["Operation"],"tech_types"=>"technologies","Name"=>"Tech_type");
augmentSlices!(data["Operation"],"slices"); # Add information about length and offset for each slice

### Time series composer
genTimeSeries!(data["Operation"],"slices","time_series_info","time_series");

###### Add the timeseries to the demand, generation and areas
inheritData!(data["Operation"],"time_series"=>"technologies", "Name"=>"time_series",["Series"]);
inheritData!(data["Operation"],"time_series"=>"loads", "Name"=>"time_series",["Series"]);

##### Scale the "Series" by the "Scaling" factor
scaleData!(data["Operation"],"loads","Series","Scaling");

#####Define Sets / Paramters from tables - Specific functions
psDict=loadSets(data["Operation"],"sets");
ppDict=loadParameters(data["Operation"],"parameters");

#### 2. INVESTMENT PART ##################################
augmentStructure(data["Investment"],"structure"); # Creates long-term path based on nodes
inheritData!(data["Investment"],"stages"=>"structure","Stage"=>"Level"); # Inherits data about node length and type of node (operation or investment)
inheritData!(data["Investment"],"tech_types"=>"technologies", "Name"=>"Tech_type");
addMapTable(data["Investment"],"structure","Node"); #(Optional) Once the information about stages has been inherited then sets of parents (for investment and operation) are calculated.
addYrs(data["Investment"],"structure")

msDict=loadSets(data["Investment"],"sets");
mpDict=loadParameters(data["Investment"],"parameters");

#### Store data in JLD2 file
save("$path/$jldFile", "data", data);
jldopen("$path/$jldFile", "a+") do f f["ppDict"]=ppDict; f["psDict"]=psDict; f["mpDict"]=mpDict; f["msDict"]=msDict; end

println("done in $(round(time()-a,digits=1))s ")

##### Convert dictonaries into tight structures

ps=transformStructure(psDict,"ps");
pp=transformStructure(ppDict,"pp");

ms=transformStructure(msDict,"ms");
structureDefinition(mpDict,"mp");
fTypes=fieldtypes(mp_type); fFields=fieldnames(mp_type); types=[]; fields=[];
for i in eachindex(fTypes)
   push!(types,fTypes[i])
   push!(fields,fFields[i])
end
nameV="mp"
stpar="$(nameV)_type("
for n in eachindex(fields)
    global stpar
   stpar*="$(types[n])()"
   if n!=length(fields) stpar*="," else stpar*=");" end
end
mp=eval(Meta.parse(stpar));
for i in eachindex(fields)
   setfield!(mp,fields[i],convert(types[i],mpDict[string(fields[i])]))
end

print("Custom data population...    "); a=time();

for s in ms.S, n in ms.IL[s]
    mp.df[n]=data["Investment"]["discount_factor"]["discount_factor_S$(s)"][1]
    mp.fuel_scaling[n]=1.05^(s-1)
    mp.var_scaling[n]=1
    for p in ms.PN
        mp.xh[p][n]=data["Investment"]["technologies"]["Capacity_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cf[p][n]=data["Investment"]["technologies"]["FixOM_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cfuel[p][n]=data["Investment"]["technologies"]["FuelCost_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cvar[p][n]=data["Investment"]["technologies"]["VarOM_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.lf[p][n]=data["Investment"]["technologies"]["Life_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cfcap[p][n]=data["Investment"]["technologies"]["FixCap_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        if data["Investment"]["technologies"]["Life_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)] <= (7-s)*5
            mp.ci[p][n]=(data["Investment"]["technologies"]["Capex_S$(s)"])[findfirst(data["Investment"]["technologies"]["Name"].==p)]
        else
            mp.ci[p][n]=(data["Investment"]["technologies"]["Capex_S$(s)"]./data["Investment"]["technologies"]["Life_S$(s)"])[findfirst(data["Investment"]["technologies"]["Name"].==p)]*(35-5 .-data["Investment"]["structure"]["YearOff"][n])
        end
    end
    for p in ms.P_PLM
        mp.xh[p][n]=data["Investment"]["technologies"]["Capacity_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cf[p][n]=data["Investment"]["technologies"]["FixOM_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cfuel[p][n]=data["Investment"]["technologies"]["FuelCost_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cvar[p][n]=data["Investment"]["technologies"]["VarOM_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.lf[p][n]=data["Investment"]["technologies"]["Life_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cfcap[p][n]=data["Investment"]["technologies"]["FixCap_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.caba[p][n]=data["Investment"]["abandonment_cost"]["Capex_S$(s)"][findfirst(data["Investment"]["abandonment_cost"]["Name"].==p)]
        if data["Investment"]["technologies"]["Life_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)] <= (7-s)*5
            mp.ci[p][n]=(data["Investment"]["technologies"]["Capex_S$(s)"])[findfirst(data["Investment"]["technologies"]["Name"].==p)]
        else
            mp.ci[p][n]=(data["Investment"]["technologies"]["Capex_S$(s)"]./data["Investment"]["technologies"]["Life_S$(s)"])[findfirst(data["Investment"]["technologies"]["Name"].==p)]*(35-5 .-data["Investment"]["structure"]["YearOff"][n])
        end
    end
    for p in ms.P_OEHPLM
        mp.xh[p][n]=data["Investment"]["technologies"]["Capacity_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cf[p][n]=data["Investment"]["technologies"]["FixOM_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cfuel[p][n]=data["Investment"]["technologies"]["FuelCost_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cvar[p][n]=data["Investment"]["technologies"]["VarOM_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.lf[p][n]=data["Investment"]["technologies"]["Life_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        mp.cfcap[p][n]=data["Investment"]["technologies"]["FixCap_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
        if data["Investment"]["technologies"]["Life_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)] <= (7-s)*5
            mp.ci[p][n]=(data["Investment"]["technologies"]["Capex_S$(s)"])[findfirst(data["Investment"]["technologies"]["Name"].==p)]
        else
            mp.ci[p][n]=(data["Investment"]["technologies"]["Capex_S$(s)"]./data["Investment"]["technologies"]["Life_S$(s)"])[findfirst(data["Investment"]["technologies"]["Name"].==p)]*(35-5 .-data["Investment"]["structure"]["YearOff"][n])
        end
    end
    for p in ms.PNi
        mp.cfcap[p][n]=data["Investment"]["technologies"]["FixCap_S$(s)"][findfirst(data["Investment"]["technologies"]["Name"].==p)]
    end
    for l in ms.L
        mp.xhl[l][n]=data["Investment"]["line_hist"]["Capacity_S$(s)"][findfirst(data["Investment"]["line_hist"]["Name"].==l)]
        mp.cfl[l][n]=data["Investment"]["lines"]["FixOM_S$(s)"][findfirst(data["Investment"]["line_hist"]["Name"].==l)]
        mp.lfl[l][n]=data["Investment"]["lines"]["Life_S$(s)"][findfirst(data["Investment"]["lines"]["Name"].==l)]
        mp.cfcapl[l][n]=data["Investment"]["lines"]["FixCap_S$(s)"][findfirst(data["Investment"]["lines"]["Name"].==l)]
        if data["Investment"]["lines"]["Life_S$(s)"][findfirst(data["Investment"]["lines"]["Name"].==l)] <= (7-s)*5
            mp.cil[l][n]=(data["Investment"]["lines"]["Capex_S$(s)"])[findfirst(data["Investment"]["lines"]["Name"].==l)]
        else
            mp.cil[l][n]=(data["Investment"]["lines"]["Capex_S$(s)"]./data["Investment"]["lines"]["Life_S$(s)"])[findfirst(data["Investment"]["lines"]["Name"].==l)]*(35-5 .-data["Investment"]["structure"]["YearOff"][n])
        end
    end
    for l in ms.LHy
        mp.xhlHy[l][n]=data["Investment"]["pipeline_hist"]["Capacity_S$(s)"][findfirst(data["Investment"]["pipeline_hist"]["Name"].==l)]
        mp.cflHy[l][n]=data["Investment"]["pipelines"]["FixOM_S$(s)"][findfirst(data["Investment"]["pipeline_hist"]["Name"].==l)]
        mp.lflHy[l][n]=data["Investment"]["pipelines"]["Life_S$(s)"][findfirst(data["Investment"]["pipelines"]["Name"].==l)]
        mp.cfcaplHy[l][n]=data["Investment"]["pipelines"]["FixCap_S$(s)"][findfirst(data["Investment"]["pipelines"]["Name"].==l)]
        if data["Investment"]["pipelines"]["Life_S$(s)"][findfirst(data["Investment"]["pipelines"]["Name"].==l)] <= (7-s)*5
            mp.cilHy[l][n]=(data["Investment"]["pipelines"]["Capex_S$(s)"])[findfirst(data["Investment"]["pipelines"]["Name"].==l)]
        else
            mp.cilHy[l][n]=(data["Investment"]["pipelines"]["Capex_S$(s)"]./data["Investment"]["pipelines"]["Life_S$(s)"])[findfirst(data["Investment"]["pipelines"]["Name"].==l)]*(35-5 .-data["Investment"]["structure"]["YearOff"][n])
        end
    end
end

# remove noise
for r=ps.R for h=ps.H
    if pp.Pprofiles[r][h]<=exp10(-4)
        pp.Pprofiles[r][h]=0
    end
end end 

for z in ps.ZP for h in ps.H 
    for process in ps.Processz[z]
        if startswith(process,"WaterLiftPump")==true
            if pp.Pprofiles[process][h]<=exp10(3)
                pp.Pprofiles[process][h]=0
            end
        end
    end
end end 

println("done in $(round(time()-a,digits=1))s ");