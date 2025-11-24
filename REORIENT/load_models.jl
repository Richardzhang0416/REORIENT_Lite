flush(stdout); print("Loading model description... "); a=time();

function VarP1!(m::JuMP.Model,ps,pp)::JuMP.Model

    @variable(m, pG[ps.G, ps.H] >= .0)   
    @variable(m, pR[ps.R, ps.H] >= .0)   
    @variable(m, pResG[ps.G, ps.H] >= .0) 
    @variable(m, pResSE[ps.SE, ps.H] >= .0)   
    @variable(m, pSEI[ps.SE, ps.H] >= .0)     
    @variable(m, pSEO[ps.SE, ps.H] >= .0)    
    @variable(m, qSEb[ps.SE_b, ps.H] >= .0)     
    @variable(m, qSEhy[ps.SEE, ps.H] >= .0)     
    @variable(m, pLShed[ps.Z, ps.H] >= .0)      
    @variable(m, pRespenalty[ps.Z, ps.H] >= .0)  
    @variable(m, pGShed[ps.Z, ps.H] >= .0)      
    @variable(m, pL[ps.L, ps.H])                
    @variable(m, pHyseoReg[ps.HydroReg, ps.H] >= .0)  
    @variable(m, pHLShed[ps.ZP, ps.H] >= .0)
    @variable(m, pHGShed[ps.ZP, ps.H] >= .0)   
    @variable(m, pEB[ps.EB, ps.H] >= .0)        
    @variable(m, pE[ps.E, ps.H] >= .0)          
    @variable(m, vSHy[ps.Shy, ps.H] >= .0)     
    @variable(m, vSHyI[ps.Shy, ps.H] >= .0)    
    @variable(m, vSHyO[ps.Shy, ps.H] >= .0)     
    @variable(m, vHyLShed[ps.Z, ps.H] >= .0)    
    @variable(m, vHyGShed[ps.Z, ps.H] >= .0)    
    @variable(m, vDHyUK[ps.Z] >= .0)           
    @variable(m, vLHy[ps.LHy, ps.H])           
    @variable(m, vSMRCCS[ps.SMRCCS, ps.H] >= .0)    
    @variable(m, g_ub[ps.G] >= .0)     
    @variable(m, se_ub[ps.SE] >= .0)    
    @variable(m, see_ub[ps.SEE] >= .0)  
    @variable(m, r_ub[ps.R] >= .0)     
    @variable(m, e_ub[ps.E] >= .0)      
    @variable(m, hydroreg_ub[ps.HydroReg] >= .0)   
    @variable(m, shy_ub[ps.Shy] >= .0) 
    @variable(m, eb_ub[ps.EB] >= .0)   
    @variable(m, l_ub[ps.L] >= .0)           
    @variable(m, lHy_ub[ps.LHy] >= .0)        
    @variable(m, smrccs_ub[ps.SMRCCS] >= .0)  
    @variable(m, plm_ub[ps.PLM] >= .0)        
    @variable(m, hD >= .0)      
    @variable(m, hDHy >= .0)   
    @variable(m, hco2 >= .0)   
    @variable(m, c0 >= .0)
    @variable(m, cco2 >= .0)
    @variable(m, cco2NO >= .0)
    @variable(m, cvar >= .0)
    @variable(m, cfuel >= .0)

    return m
end

function VarP2!(m,ms,mp)

    @variable(m, x0p[ms.P, ms.I0] >= .0)       
    @variable(m, xp[ms.P, ms.I])                 
    @variable(m, x0pN[ms.PN, ms.I0] >= .0)      
    @variable(m, x0pNi[ms.PNi, ms.I0], Bin)    
    @variable(m, xpN[ms.PN, ms.I] >= .0)       
    @variable(m, x0l[ms.L, ms.I0] >= .0)        
    @variable(m, x0lNi[ms.Li, ms.I0], Bin)     
    @variable(m, xl[ms.L, ms.I] >= .0)          
    @variable(m, x0lHyN[ms.LHyN, ms.I0] >= .0)  
    @variable(m, x0lHyR[ms.LHyR, ms.I0], Bin)   
    @variable(m, xlHy[ms.LHy, ms.I] >= .0)     
    @variable(m, x0ReF[ms.P_PLM, ms.I0], Bin)   
    @variable(m, xReF[ms.P_PLM, ms.I] <= .0)    
    @variable(m, x0Aba[ms.P_PLM, ms.I0], Bin)   
    @variable(m, x0ReT[ms.P_OEHPLM, ms.I0] >= .0)  
    @variable(m, xReT[ms.P_OEHPLM, ms.I] >= .0)     
    @variable(m, beta[ms.I] >= .0) 
    @variable(m, f >= .0) 
    @variable(m, o >= .0) 
    @variable(m, cfuel[ms.I])   
    @variable(m, cvar[ms.I])   
    @variable(m, cco2[ms.I])   
    @variable(m, cco2NO[ms.I])  
    @variable(m, hco2[ms.I])    
    @variable(m, hD[ms.I])     
    @variable(m, hDHy[ms.I])             
            
    for i in ms.I
        fix(cco2[i], mp.c_co2[i]; force=true)          
        fix(cco2NO[i], mp.c_co2NO[i]; force=true)      
        fix(hD[i], mp.h_D[i]; force=true)               
        fix(hDHy[i], mp.h_DHy[i]; force=true)          
        fix(hco2[i], mp.h_co2[i]; force=true)           
        fix(cfuel[i], mp.fuel_scaling[i]; force=true)  
        fix(cvar[i], mp.var_scaling[i]; force=true)    
    end

    return m

end

function REORIENT!(m,ms,mp,lT)

    #INVESTMENT PART
    # */ -- variables ---------------------------------------------- /* #
    @variable(m, x0p[ms.P, ms.I0] >= .0)        # vector collects newly investment of all devices
    @variable(m, xp[ms.P, ms.I])                # vector collects accumulated capacity of all devices
    
    @variable(m, x0pN[ms.PN, ms.I0] >= .0)      # newly installed capacity of technologies
    @variable(m, x0pNi[ms.PNi, ms.I0], Bin)     # whether to build the new technology
    @variable(m, xpN[ms.PN, ms.I] >= .0)        # accumulated capacity of technologies
    
    @variable(m, x0l[ms.L, ms.I0] >= .0)        # newly installed capacity of lines
    @variable(m, x0lNi[ms.Li, ms.I0], Bin)      # whether to build a new line 
    @variable(m, xl[ms.L, ms.I] >= .0)          # accumulated capacity of lines
    
    @variable(m, x0lHyN[ms.LHyN, ms.I0] >= .0)  # newly installed capacity of hydrogen pipelines
    @variable(m, x0lHyR[ms.LHyR, ms.I0], Bin)   # whether to retrofit an existing natural gas pipeline for hydrogen transport
    @variable(m, xlHy[ms.LHy, ms.I] >= .0)      # accumulated capacity of hydrogen pipelines
    
    @variable(m, x0ReF[ms.P_PLM, ms.I0], Bin)   # whether to retrofit an existing natural gas platform
    @variable(m, xReF[ms.P_PLM, ms.I] <= .0)    # accumulated capacity of an existing natural gas platform
    @variable(m, x0Aba[ms.P_PLM, ms.I0], Bin)   # whether to abandon
    @variable(m, x0ReT[ms.P_OEHPLM, ms.I0] >= .0)   # investment for retrofitted techs
    @variable(m, xReT[ms.P_OEHPLM, ms.I] >= .0)     # accumulated capacity for retrofitted techs
    
    @variable(m, beta[ms.I] >= .0) # operational cost of node i
    @variable(m, f >= .0) # operational cost of node i
    @variable(m, o >= .0) # operational cost of node i
    
    ###Objective function
    @constraint(m, f == sum(mp.df[i0]*mp.prob[i0]*(sum(mp.ci[p][i0]*x0pN[p,i0] for p in ms.PN) + sum(mp.cil[l][i0]*x0l[l,i0] for l in ms.L) + 
                            sum(mp.cilHy[l][i0]*x0lHyN[l,i0] for l in ms.LHyN)+ sum(mp.ci[p][i0]*x0ReT[p,i0] for p in ms.P_OEHPLM)) for i0 in ms.I0) +
                        sum(mp.kappa[i]*mp.df[i]*mp.prob[i]*(sum(mp.cf[p][i]*xpN[p,i] for p in ms.PN) + sum(mp.cfl[l][i]*xl[l,i] for l in ms.L) + 
                            sum(mp.cflHy[l][i]*xlHy[l,i] for l in ms.LHyN) + sum(mp.cf[p][i]*xReT[p,i] for p in ms.P_OEHPLM) +
                            sum(mp.cval[p]*mp.c_OG[i]*xReF[p,i] for p in ms.P_PLM)) for i in ms.I) +
                        sum(mp.prob[i0]*(sum(mp.cfcap[p][i0]*x0pNi[p,i0] for p in ms.PNi) + sum(mp.cfcapl[l][i0]*x0li[l,i0] for l in ms.Li) + 
                            sum(mp.cfcaplHy[l][i0]*x0lHyR[l,i0] for l in ms.LHyR) + sum(mp.cfcap[p][i0]*x0ReF[p,i0] for p in ms.P_PLM) +
                            sum(mp.caba[p][i0]*x0Aba[p,i0] for p in ms.P_PLM)) for i0 in ms.I0));

    @constraint(m, o == sum(oCost(mp,beta,i) for i in ms.I)); ## operational part of the expected cost
    @objective(m, Min, f + o); # investment plus operational cost (10^10 €)
    
    # newly invested techs
    @constraint(m, acc_cap_p[p=ms.PN, i=ms.I], 10*xp[p,i] == mp.xh[p][i] + 10*sum(x0p[p,i0] for i0 in ms.map[i] if 5*(mp.lv[i] - mp.lv[i0]) < mp.lf[p][i0]));
    @constraint(m, max_built_p[p=ms.PN, i0=ms.I0], 10*x0pN[p,i0] <= mp.xmb[p]);
    @constraint(m, max_installed_p[p=ms.PN, i=ms.I], 10*xpN[p,i] <= mp.xmi[p]);
    @constraint(m, new_bin_p[z=ms.ZO, i=ms.I0], sum(x0pN[p,i] for p in ms.P_OEHz[z]) <= sum(x0pNi[p,i] for p in ms.PNiz[z])*100);
    @constraint(m, collect_x0pN[p=ms.PN, i0=ms.I0], x0p[p,i0] == x0pN[p,i0]);
    @constraint(m, collect_xpN[p=ms.PN, i=ms.I], xp[p,i] == xpN[p,i]);
    @constraint(m, collect_x0pNi[p=ms.PNi, i0=ms.I0], x0p[p,i0] == x0pNi[p,i0]);
    # # newly invested transmission lines
    @constraint(m, acc_cap_l[l=ms.L, i=ms.I], 10*xl[l,i] == mp.xhl[l][i] + 10*sum(x0l[l,i0] for i0 in ms.map[i] if 5*(mp.lv[i] - mp.lv[i0]) < mp.lfl[l][i0]));
    @constraint(m, max_built_l[l=ms.L, i0=ms.I0], x0l[l,i0] <= mp.xmbl[l]);
    @constraint(m, max_installed_l[l=ms.L, i=ms.I], xl[l,i] <= mp.xmil[l]);
    @constraint(m, new_bin_l[l=ms.Li, i=ms.I0], x0l[l,i] <= x0li[l,i]*mp.xmbl[l]);
    @constraint(m, collect_x0l[l=ms.L, i0=ms.I0], x0p[l,i0] == x0l[l,i0]);
    @constraint(m, collect_xl[l=ms.L, i=ms.I], xp[l,i] == xl[l,i]);
    # hydrogen pipelines (new and retrofit)
    @constraint(m, acc_cap_lHyN[l=ms.LHyN, i=ms.I], xlHy[l,i] == sum(x0lHyN[l,i0] for i0 in ms.map[i] if 5*(mp.lv[i] - mp.lv[i0]) < mp.lflHy[l][i0]));
    @constraint(m, max_built_lHyN[l=ms.LHyN, i0=ms.I0], 10*x0lHyN[l,i0] <= mp.xmblHy[l]);
    @constraint(m, max_installed_lHyN[l=ms.LHyN, i=ms.I], 10*xlHy[l,i] <= mp.xmilHy[l]);
    @constraint(m, one_time_retrofit_lHyR[l=ms.LHyR], sum(x0lHyR[l,i0] for i0 in ms.I0) <= 1);
    @constraint(m, acc_cap_retrofit_lHyR[l=ms.LHyR, i=ms.I], 10*xlHy[l,i] == mp.xmilHy[l]*sum(x0lHyR[l,i0] for i0 in ms.map[i]));
    @constraint(m, collect_x0lHyN[l=ms.LHyN, i0=ms.I0], x0p[l,i0] == x0lHyN[l,i0]);
    @constraint(m, collect_x0lHyR[l=ms.LHyR, i0=ms.I0], x0p[l,i0] == x0lHyR[l,i0]);
    @constraint(m, collect_xlHy[l=ms.LHy, i=ms.I], xp[l,i] == xlHy[l,i]);
    # platform retrofit
    @constraint(m, one_time_retrofit_abandon_plm[p=ms.P_PLM], sum(x0ReF[p,i0] for i0 in ms.I0) + sum(x0Aba[p,i0] for i0 in ms.I0) == 1);
    @constraint(m, either_retrofit_abandon_plm[p=ms.P_PLM,i0=ms.I0], x0ReF[p,i0] + x0Aba[p,i0] <= 1);
    @constraint(m, max_built_oehplm[p=ms.P_OEHPLM, i0=ms.I0], 10*x0ReT[p,i0] <= mp.xmb[p]);
    @constraint(m, max_installed_oehplm[p=ms.P_OEHPLM, i=ms.I], 10*xReT[p,i] <= mp.xmi[p]);
    @constraint(m, acc_cap_plm[p=ms.P_PLM, i=ms.I], xReF[p,i] == mp.h_P[i]*(1 - sum(x0ReF[p,i0] for i0 in ms.map[i]) - sum(x0Aba[p,i0] for i0 in ms.map[i])));
    @constraint(m, acc_cap_ReT[p=ms.P_OEHPLM, i=ms.I], xReT[p,i] == sum(x0ReT[p,i0] for i0 in ms.map[i] if 5*(mp.lv[i] - mp.lv[i0]) < mp.lf[p][i0]));
    @constraint(m, no_retrofitted_first_stage[p=ms.P_OEHPLM], x0ReT[p,"N1"] == 0);
    @constraint(m, retrofitted_investment[z=ms.ZO, s=2:length(ms.S)-1, i=ms.IL[s]], sum(x0ReT[p,i] for p in ms.P_OEHPLMz[z]) <= sum(x0ReF[p,i0]*100 for p in ms.P_PLMz[z] for i0 in ms.map[i]));
    @constraint(m, collect_x0ReF_x0Aba[p=ms.P_PLM, i0=ms.I0], x0p[p,i0] == x0ReF[p,i0] + x0Aba[p,i0]);
    @constraint(m, collect_x0ReT[p=ms.P_OEHPLM, i0=ms.I0], x0p[p,i0] == x0ReT[p,i0]);
    @constraint(m, collect_xReF_xAba[p=ms.P_PLM, i=ms.I], xp[p,i] == xReF[p,i]);
    @constraint(m, collect_xReT[p=ms.P_OEHPLM, i=ms.I], xp[p,i] == xReT[p,i]);
    
    # OPERATIONAL PART
    # */ -- Auxiliary info ----------------------------------------- /* #
    HS = H2S(ps.H,pp.st,pp.ln); # map of period (h) to slice
    sc = Dict(h => pp.yr*pp.WS[HS[h]]/(pp.ln[HS[h]]*pp.ts[HS[h]]) for h in ps.H); # Auxiliary dictionary (optional) that contains the scaling factors given a period h
    H_noend=H_excl_end(pp.st,pp.ln);
    
    @variable(m, pG[ms.I, ps.G, ps.H] >= .0)    # power output of all technologies
    @variable(m, pR[ms.I, ps.R, ps.H] >= .0)    # renewable power output
    @variable(m, pResG[ms.I, ps.G, ps.H] >= .0) # power reserve of generator
    @variable(m, pResSE[ms.I, ps.SE, ps.H] >= .0)   # power reserve of electricity storage
    @variable(m, pSEI[ms.I, ps.SE, ps.H] >= .0)     # charging power of electricity store
    @variable(m, pSEO[ms.I, ps.SE, ps.H] >= .0)     # discharging power of electricity store
    @variable(m, qSEb[ms.I, ps.SE_b, ps.H] >= .0)       # energy level of electricity store
    @variable(m, qSEhy[ms.I, ps.SEE, ps.H] >= .0)       # energy level of electricity store (with a separate energy capacity)
    @variable(m, pLShed[ms.I, ps.Z, ps.H] >= .0)        # load shed
    @variable(m, pRespenalty[ms.I, ps.Z, ps.H] >= .0)   # reserve violation
    @variable(m, pGShed[ms.I, ps.Z, ps.H] >= .0)        # generation shed
    @variable(m, pL[ms.I, ps.L, ps.H])                  # power flow along line l
    @variable(m, pHyseoReg[ms.I, ps.HydroReg, ps.H] >= .0)  # power output of regulated hydro
    
    # heat variables
    @variable(m, pHLShed[ms.I, ps.ZP, ps.H] >= .0)   # heat load shed
    @variable(m, pHGShed[ms.I, ps.ZP, ps.H] >= .0)   # heat generation shed
    @variable(m, pEB[ms.I, ps.EB, ps.H] >= .0)       # heat energy output of electric boiler
    
    # hydrogen variables
    @variable(m, pE[ms.I, ps.E, ps.H] >= .0)            # input power of electrolyser
    @variable(m, vSHy[ms.I, ps.Shy, ps.H] >= .0)        # storage level of hydrogen storage
    @variable(m, vSHyI[ms.I, ps.Shy, ps.H] >= .0)       # hydrogen injection into the storage facility
    @variable(m, vSHyO[ms.I, ps.Shy, ps.H] >= .0)       # hydrogen withdrawn from the storage facility
    @variable(m, vHyLShed[ms.I, ps.Z, ps.H] >= .0)      # hydrogen load shed
    @variable(m, vHyGShed[ms.I, ps.Z, ps.H] >= .0)      # hydrogen generation shed
    @variable(m, vDHyUK[ms.I, ps.Z] >= .0)              # hydrogen demand in the UK
    @variable(m, vLHy[ms.I, ps.LHy, ps.H])              # hydrogen flow along pipeline l
    @variable(m, vSMRCCS[ms.I, ps.SMRCCS, ps.H] >= .0)  # hydrogen production from SMRCCS
    
    # linking variables
    @variable(m, g_ub[ms.I, ps.G] >= .0)        # capacity of generators
    @variable(m, se_ub[ms.I, ps.SE] >= .0)      # charging capacity of electricity storage
    @variable(m, see_ub[ms.I, ps.SEE] >= .0)    # energy capacity of electricity storage
    @variable(m, r_ub[ms.I, ps.R] >= .0)        # renewable capacity
    @variable(m, e_ub[ms.I, ps.E] >= .0)        # electrolyser capacity
    @variable(m, hydroreg_ub[ms.I, ps.HydroReg] >= .0)    # regulated hydrog capacity
    @variable(m, shy_ub[ms.I, ps.Shy] >= .0)    # hydrogen storage capacity
    @variable(m, eb_ub[ms.I, ps.EB] >= .0)      # electric boiler capacity
    @variable(m, l_ub[ms.I, ps.L] >= .0)        # tranmission line capacity
    @variable(m, lHy_ub[ms.I, ps.LHy] >= .0)    # tranmission line capacity
    @variable(m, smrccs_ub[ms.I, ps.SMRCCS] >= .0)  # electrolyser capacity
    @variable(m, plm_ub[ms.I, ps.PLM] >= .0)
    @variable(m, hD[ms.I] >= .0)    # power load scaling
    @variable(m, hDHy[ms.I] >= .0)  # hydrogen load scaling
    @variable(m, hco2[ms.I] >= .0)  # co2 budget scaling
    @variable(m, c0[ms.I]>= .0)
    @variable(m, cco2[ms.I] >= .0)
    @variable(m, cco2NO[ms.I] >= .0)
    @variable(m, cvar[ms.I] >= .0)
    @variable(m, cfuel[ms.I] >= .0)
    
    # Cost gathering expressions
    @constraint(m, [i=ms.I], c0[i]*exp10(1)/sc[1] == exp10(-2)*sum(pp.ts[HS[h]]*((pLShed[i,z,h] + pRespenalty[i,z,h])*pp.CLShed[z]+vHyLShed[i,z,h]*pp.CLShed[z]) for z in ps.Z for h in ps.H) +
                                                        exp10(-2)*sum(pp.ts[HS[h]]*pHLShed[i,z,h]*pp.CHLShed[z] for z in ps.ZP for h in ps.H));
    @constraint(m, [i=ms.I], cco2[i]*exp10(3)/sc[1] == sum(pp.ts[HS[h]]*pp.Eg[g]*pG[i,g,h]/pp.Eta[g] for z in ps.ZEU for g in ps.Gz[z] for h in ps.H) +
                                                        sum(pp.ts[HS[h]]*pp.Eg[smrccs]*vSMRCCS[i,smrccs,h] for z in ps.ZEU for smrccs in ps.SMRCCSz[z] for h in ps.H));
    @constraint(m, [i=ms.I], cco2NO[i]*exp10(3)/sc[1] == sum(pp.ts[HS[h]]*pp.Eg[g]*pG[i,g,h]/pp.Eta[g] for z in ps.ZNO for g in ps.Gz[z] for h in ps.H) +
                                                        sum(pp.ts[HS[h]]*pp.Eg[smrccs]*vSMRCCS[i,smrccs,h] for z in ps.ZNO for smrccs in ps.SMRCCSz[z] for h in ps.H));
    @constraint(m, [i=ms.I], cvar[i]*exp10(3)/sc[1] == sum(pp.ts[HS[h]]*pp.cvar[g]*pG[i,g,h] for g in ps.G for h in ps.H));
    @constraint(m, [i=ms.I], cfuel[i]*exp10(3)/sc[1] == sum(pp.ts[HS[h]]*pp.cfuel[g]*pG[i,g,h]/pp.Eta[g] for g in ps.G for h in ps.H) +
                                                        sum(pp.ts[HS[h]]*pp.cfuel[smrccs]*vSMRCCS[i,smrccs,h]/pp.Eta[smrccs] for smrccs in ps.SMRCCS for h in ps.H));

    # */ ---------------- generator constraints ---------------- /* #
    @constraint(m, gen_cap[i=ms.I, g=ps.G, h=ps.H], pG[i,g,h] + pResG[i,g,h] <= g_ub[i,g]);
    @constraint(m, gen_ramp_up[i=ms.I, g=ps.G, h=H_noend], pG[i,g,h+1] + pResG[i,g,h+1] - pG[i,g,h] - pResG[i,g,h] <= pp.ts[HS[h]]*pp.Rg[g]*g_ub[i,g]);
    @constraint(m, gen_ramp_down[i=ms.I, g=ps.G, h=H_noend], pG[i,g,h+1] + pResG[i,g,h+1] - pG[i,g,h] - pResG[i,g,h] >= -pp.ts[HS[h]]*pp.Rg[g]*g_ub[i,g]);
    @constraint(m, turbine_output_limit[i=ms.I, z=ps.ZP, h=ps.H], sum(pG[i,g,h] for g in ps.Gz[z])*exp10(2) <= exp10(-1)*sum(plm_ub[i,plm] for plm in ps.PLMz[z])*sum(pp.Kp[process]*pp.Pprofiles[process][h] for process in ps.Processz[z]));
    
    # */ ---------------- renewable output ---------------- /* #
    @constraint(m, renewable_output[i=ms.I, r=ps.R, h=ps.H], exp10(2)*pR[i,r,h] == exp10(2)*r_ub[i,r]*pp.Pprofiles[r][h]);
    @constraint(m, hydroReg_ouptut[i=ms.I, hydro=ps.HydroReg, h=ps.H], pHyseoReg[i,hydro,h] <= hydroreg_ub[i,hydro]);
    @constraint(m, hydroReg_season_limit[i=ms.I, hydro=ps.HydroReg, s=ps.S], sum(pHyseoReg[i,hydro,h] for h in ps.H_sl[s])*exp10(3)/length(ps.H_sl[s])/10 <= sum(pp.Pprofiles[hydro][h] for h in ps.H_sl[s])/length(ps.H_sl[s])/10);
    
    # # */ ---------------- electricity storage constraints ---------------- /* #
    @constraint(m, electricity_storage_charge_cap[i=ms.I, se=ps.SE, h=ps.H], pSEI[i,se,h] <= se_ub[i,se]);
    @constraint(m, electricity_storage_discharge_cap[i=ms.I, se=ps.SE, h=ps.H], pSEO[i,se,h] + pResSE[i,se,h] <= se_ub[i,se]);
    @constraint(m, electricity_storage_energy_limit1[i=ms.I, se=ps.SE_b, h=ps.H], pp.ts[HS[h]]*(pSEO[i,se,h] + pResSE[i,se,h]) <= qSEb[i,se,h]);
    @constraint(m, electricity_storage_energy_limit2[i=ms.I, z=ps.Z, see=ps.SEEz[z], se=ps.SE_hydroz[z], h=ps.H], pp.ts[HS[h]]*(pSEO[i,se,h] + pResSE[i,se,h]) <= qSEhy[i,see,h]);
    @constraint(m, battery_energy_cap[i=ms.I, se=ps.SE_b, h=ps.H], qSEb[i,se,h] <= pp.SE_ratio[se]*se_ub[i,se]);
    @constraint(m, hydro_pump_energy_cap[i=ms.I, se=ps.SEE, h=ps.H], qSEhy[i,se,h] <= see_ub[i,se]);
    @constraint(m, battery_storage_initial_level[i=ms.I, se=ps.SE_b, s=ps.S, h=ps.H_sl[s][1]], qSEb[i,se,h] == 0.5*pp.SE_ratio[se]*se_ub[i,se]);
    @constraint(m, hydro_pump_storage_initial_level[i=ms.I, see=ps.SEE, s=ps.S, h=ps.H_sl[s][1]], qSEhy[i,see,h] == 0.5*see_ub[i,see]);
    @constraint(m, battery_storage_end_level[i=ms.I, se=ps.SE_b, s=ps.S, h=ps.H_sl[s][end]], qSEb[i,se,h] == 0.5*pp.SE_ratio[se]*se_ub[i,se]);
    @constraint(m, hydro_pump_storage_end_level[i=ms.I, see=ps.SEE, s=ps.S, h=ps.H_sl[s][end]], qSEhy[i,see,h] == 0.5*see_ub[i,see]);
    @constraint(m, battery_storage_balance[i=ms.I, se=ps.SE_b, h=H_noend], qSEb[i,se,h+1] ==
                    qSEb[i,se,h] + pp.ts[HS[h]]*(pp.Eta[se]*pSEI[i,se,h] - pSEO[i,se,h]));
    @constraint(m, hydro_pump_storage_balance[i=ms.I, z=ps.Z, see=ps.SEEz[z], se=ps.SE_hydroz[z], h=H_noend], qSEhy[i,see,h+1] ==
                    qSEhy[i,see,h] + pp.ts[HS[h]]*(pp.Eta[se]*pSEI[i,se,h] - pSEO[i,se,h]));
    
    # */ ---------------- electricity nodal balance ---------------- /* #
    @constraint(m, KCL[i=ms.I, z=ps.Z, h=ps.H], sum(pG[i,g,h] for g in ps.Gz[z]) + sum(pR[i,r,h] for r in ps.Rz[z]) + sum(pHyseoReg[i,hydro,h] for hydro in ps.HydroRegz[z]) +
                    sum(pSEO[i,se,h] for se in ps.SEz[z]) + pLShed[i,z,h] + sum(pp.Etal[l]*pL[i,l,h] for l in ps.Lto[z]) ==
                    (hD[i]*sum(pp.Pd[z][h] for z in ps.Dz[z]) + sum(plm_ub[i,plm] for plm in ps.PLMz[z])*sum(pp.Kp[process]*pp.Pprofiles[process][h] for process in ps.Processz[z]))*exp10(-3) +
                    sum(pSEI[i,se,h] for se in ps.SEz[z]) + sum(pEB[i,eb,h] for eb in ps.EBz[z]) + pGShed[i,z,h] + sum(pp.Etal[l]*pL[i,l,h] for l in ps.Lfm[z]) + sum(pE[i,e,h] for e in ps.Ez[z]))
    
    # */ ---------------- transmission constraints ---------------- /* #
    @constraint(m, line_cap1[i=ms.I, l=ps.L, h=ps.H], pL[i,l,h] <= l_ub[i,l]);
    @constraint(m, line_cap2[i=ms.I, l=ps.L, h=ps.H], pL[i,l,h] >= -l_ub[i,l]);
    
    # */ ---------------- spinning reserve ---------------- /* #
    @constraint(m, reserve[i=ms.I, z=ps.Z, h=ps.H], hD[i]*sum(pp.spin_res[z]*pp.Pd[d][h] for d in ps.Dz[z])*exp10(-3) +
                    sum(plm_ub[i,plm] for plm in ps.PLMz[z])*sum(pp.spin_res[z]*pp.Kp[process]*pp.Pprofiles[process][h] for process in ps.Processz[z])*exp10(-3) <=
                    sum(pResG[i,g,h] for g in ps.Gz[z]) + sum(pResSE[i,se,h] for se in ps.SEz[z]) + pRespenalty[i,z,h]);
    
    # */ ---------------- heat constraints ---------------- /* #
    @constraint(m, Eboiler_cap[i=ms.I, eb=ps.EB, h=ps.H], pEB[i,eb,h] <= eb_ub[i,eb]);
    @constraint(m, heat_balance2[i=ms.I, z=ps.ZP, h=ps.H], exp10(2)*sum(pp.Eta_th[g]*pG[i,g,h] for g in ps.Gz[z]) + exp10(2)*sum(pp.Eta[eb]*pEB[i,eb,h] for eb in ps.EBz[z]) + exp10(2)*pHLShed[i,z,h] == 
                                                                sum(plm_ub[i,plm] for plm in ps.PLMz[z])*sum(pp.Kp[sep]*pp.Pprofiles[sep][h] for sep in ps.Sepz[z])*exp10(-1) + exp10(2)*pHGShed[i,z,h]);
    
    # */ ---------------- hydrogen constraints ---------------- /* #
    @constraint(m, hydrogen_pipeline_cap1[i=ms.I, l=ps.LHy, h=ps.H], vLHy[i,l,h] <= lHy_ub[i,l]);
    @constraint(m, hydrogen_pipeline_cap2[i=ms.I, l=ps.LHy, h=ps.H], vLHy[i,l,h] >= -lHy_ub[i,l]);
    @constraint(m, electrolyser_cap[i=ms.I, e=ps.E, h=ps.H], pE[i,e,h] <= e_ub[i,e]);
    @constraint(m, smrccs_cap[i=ms.I, smrccs=ps.SMRCCS, h=ps.H], vSMRCCS[i,smrccs,h] <= smrccs_ub[i,smrccs]);
    @constraint(m, hydrogen_store_cap[i=ms.I, shy=ps.Shy, h=ps.H], vSHy[i,shy,h] <= shy_ub[i,shy]);
    @constraint(m, hydrogen_store_charge_cap[i=ms.I, shy=ps.Shy, h=ps.H], vSHyI[i,shy,h] <= shy_ub[i,shy]);
    @constraint(m, hydrogen_store_discharge_cap[i=ms.I, shy=ps.Shy, h=ps.H], vSHyO[i,shy,h] <= shy_ub[i,shy]);
    @constraint(m, hydrogen_store_discharge_cap2[i=ms.I, shy=ps.Shy, h=ps.H], vSHyO[i,shy,h] <= vSHy[i,shy,h]);
    @constraint(m, hydrogen_store_initial_level[i=ms.I, shy=ps.Shy, s=ps.S, h=ps.H_sl[s][1]], vSHy[i,shy,h] == 0*shy_ub[i,shy]);
    @constraint(m, hydrogen_store_end_level[i=ms.I, shy=ps.Shy, s=ps.S, h=ps.H_sl[s][end]], vSHy[i,shy,h] == 0*shy_ub[i,shy]);
    @constraint(m, hydrogen_store_balance[i=ms.I, shy=ps.Shy, h=H_noend], vSHy[i,shy,h+1] - vSHy[i,shy,h] == vSHyI[i,shy,h] - vSHyO[i,shy,h]);
    @constraint(m, hydrogen_balance[i=ms.I, z=ps.Z, h=ps.H], 5*sum(pE[i,e,h] for e in ps.Ez[z])/(pp.Eta_EF*exp10(1)) + 5*sum(vSHyO[i,shy,h] for shy in ps.Shyz[z])*exp10(2) + 5*vHyLShed[i,z,h]*exp10(2) +
                                5*sum(vSMRCCS[i,smrccs,h] for smrccs in ps.SMRCCSz[z])*exp10(2) + 5*sum(vLHy[i,l,h] for l in ps.LHyto[z])*exp10(2) ==
                                5*hDHy[i]*sum(pp.DHy[z] for z in ps.DHyz[z])/pp.yr*exp10(2) + 5*vDHyUK[i,z]  + 5*sum(vSHyI[i,shy,h] for shy in ps.Shyz[z])*exp10(2) +
                                5*sum(pG[i,f,h]/(pp.theta_Hy*pp.Eta[f]) for f in ps.Fz[z])/exp10(1) + 5*vHyGShed[i,z,h]*exp10(2) + 5*sum(vLHy[i,l,h] for l in ps.LHyfm[z])*exp10(2));
    @constraint(m, hydrogen_demand_UK[i=ms.I], sum(vDHyUK[i,z] for z in ps.ZUK) == hDHy[i]*pp.DHy["hydrogen_load_UK"]/pp.yr*exp10(2));

    @constraint(m, co2_budget[i=ms.I],  7.5*exp10(1)*(sum(pG[i,g,h]*pp.ts[HS[h]]*pp.Eg[g]/pp.Eta[g] for g in ps.G for h in ps.H) +
                                sum(vSMRCCS[i,smrccs,h]*pp.ts[HS[h]]*pp.Eg[smrccs] for smrccs in ps.SMRCCS for h in ps.H))/length(ps.H) <= 
                                7.5*exp10(4)*hco2[i]*pp.ME/(sc[1]*length(ps.H)));
    
    # LINKING PART
    # Objective linking
    @constraint(m, csr_ObjLink[i in ms.I], 100*beta[i] == 0.01*(c0[i] + mp.c_co2[i]*cco2[i] + mp.c_co2NO[i]*cco2NO[i] + mp.var_scaling[i]*cvar[i] + mp.fuel_scaling[i]*cfuel[i]));
    ### Investment set variables
    op2inv=Dict(lT[i][5]=>lT[i][8] for i in eachindex(lT));
    
    @constraint(m, csr_g_ub[i=ms.I, g=ps.G], 10*xp[op2inv[g],i] == 0.1*g_ub[i,g]);
    @constraint(m, csr_se_ub[i=ms.I, g=ps.SE], 10*xp[op2inv[g],i] == 0.1*se_ub[i,g]);
    @constraint(m, csr_see_ub[i=ms.I, g=ps.SEE], 10*xp[op2inv[g],i] == 0.1*see_ub[i,g]);
    @constraint(m, csr_r_ub[i=ms.I, g=ps.R], 10*xp[op2inv[g],i] == 0.1*r_ub[i,g]);
    @constraint(m, csr_hydroreg_ub[i=ms.I, g=ps.HydroReg], 10*xp[op2inv[g],i] == 0.1*hydroreg_ub[i,g]);
    @constraint(m, csr_e_ub[i=ms.I, g=ps.E], 10*xp[op2inv[g],i] == 0.1*e_ub[i,g]);
    @constraint(m, csr_shy_ub[i=ms.I, g=ps.Shy], 10*xp[op2inv[g],i] == 0.1*shy_ub[i,g]);
    @constraint(m, csr_eb_ub[i=ms.I, g=ps.EB], 10*xp[op2inv[g],i] == 0.1*eb_ub[i,g]);
    @constraint(m, csr_l_ub[i=ms.I, l=ps.L], 10*xp[op2inv[l],i] == 0.1*l_ub[i,l]);
    @constraint(m, csr_lHy_ub[i=ms.I, l=ps.LHy], 10*xp[op2inv[l],i] == 0.1lHy_ub[i,l]);
    @constraint(m, csr_smrccs_ub[i=ms.I, g=ps.SMRCCS], 10*xp[op2inv[g],i] == 0.1*smrccs_ub[i,g]);
    @constraint(m, csr_plm_ub[i=ms.I, g=ps.PLM], xp[op2inv[g],i] == -plm_ub[i,g]);
    @constraint(m, csr_hD[i=ms.I], hD[i] == -1.0*mp.h_D[i]);
    @constraint(m, csr_hDHy[i=ms.I], hDHy[i] == -1.0*mp.h_DHy[i]);
    @constraint(m, csr_hco2[i=ms.I], hco2[i] == mp.h_co2[i]);    

    return m
end

function oCost(mp,beta,i) #operational cost function
    return mp.df[i]*mp.kappa[i]*mp.prob[i]*beta[i]
end

println("done in $(round(time()-a,digits=1))s ");