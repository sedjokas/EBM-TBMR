/**********************************************************************************************************************************
 *  TBS and TBMR Math - Model
 *  Author: Selain Kasereka
 *  Description: A mathematical model that allows to simulate the spread of TBS and TBMR in DR Congo, 
 * 	The dynamic of the disease is managed by ODE using rk4 method. The model is compartmental one, it has 7 compartments.
 **********************************************************************************************************************************/

model modelMathSerge

global {
	
//  Declaration of global variables 

// Model parameters	
	float Gamma; // Recruitment in S
	float mu; // Mortality rate of general population
	float muStarS; // Mortality rate for TBS
	float muStarR; // Mortality rate for TBMR
	float betaS; // Reactivation rate
	float betaR; // Amplification rate
	float alphaS; // Recovered rate for TBS
	float alphaR; // Recovered rate for TBMR
	float gamma; // Rate of a ES people (TBS) to became Exposed TBMR 
	float dS; // Rate of become exposed from IS to ES
	float dR; // Rate of become exposed from IR to ER
	float kS; // Rate of become infctious from ES to IS
	float kR; // Rate of become infctious from ER to IR
	float r1; // Rate of recovered from ES to  RS
	float r2; // Rate of recovered from ER to  RR
	float sigmaS; // Rate of relapse from RS to  IS
	float sigmaR; // Rate of relapse from RR to  IR
	//float p; //proportion
	
// Other parameters
	int test <- 0; // break the loop
	float stepI; // discrétisation step for the resolution of ODE using rk4 method.
	
//Population
	int S_people <- 100 min: 50 max:100000; //Number of scusceptible individuals
    int ES_people <- 0 min: 0 max:100000; //Number of exposed TBS individuals
    int ER_people <- 0 min: 0 max:100000; //Number of exposed TBMR  individuals
    int IS_people <- 2 min: 1 max:100000; //Number of infectious TBS individuals
    int IR_people <- 1 min: 1 max:100000; //Number of  infectious TBMR individuals
    int RS_people <- 0 min: 0 max:100000; //Number of recovered TBS individuals
    int RR_people <- 0 min: 0 max:100000; //Number of recovered TBMR individuals
    int IinitS <- 2 min: 2 max: 100000; //Number of infectious TBS individuals
    int IinitR <- 1 min: 1 max: 100000; //Number of infectious TBS individuals
    float N <- S_people + ES_people + ER_people + IS_people + IR_people + RS_people + RR_people; // Total population

// Calcuation of R0
	float R0S <- (kS*betaS*(Gamma/mu))/((mu + kS + r1)*(muStarS + alphaS + gamma) + (mu + r1)*dS);// R0 for TBS
	float R0MR <- (kR*betaR*(Gamma/mu))/((mu + kR + r2)*(muStarR + alphaR) + (mu + r2)*dR); // R0 for TBMR
	
	init{
//Create the math model
		create SEIR_maths number:1 {
			S <- float(S_people);
			ES <- float(ES_people);
			ER <- float(ER_people);
			IS <- float(IS_people);
			IR<- float(IR_people);
			RS <- float(RS_people);
			RR <- float(RR_people);
		}		
	}

// Create loop to manage the time of the simulation
reflex pause_simulation when: (cycle = 200) {
					do pause ;
			}	
			
			
			
			reflex save_data when: every(1#cycle){
		//save the following text into the csv  file. Note that each time the save statement is used, a new line is added at the end of the file.
		save [cycle,first(SEIR_maths).S,first(SEIR_maths).ES,first(SEIR_maths).IS,first(SEIR_maths).RS,first(SEIR_maths).ER,first(SEIR_maths).IR,first(SEIR_maths).RR] to: "../results/dataserge1.csv" type:"csv" rewrite: false;
		
	} 
			
}

// cerate the species of the created math model	
species SEIR_maths {

    float t;    
	float S <- N - ES -ER - IS - IS - RS - RR; 
	float ES;
	float ER;
	float IS <- IinitS;
	float IR <- IinitR;
	float RS;
	float RR;
	
 // definition de l'equation du modele SIR  
			
			equation SEIR_TB { 
		    diff(S,t) = Gamma - betaS*S*IS - betaR*S*IR - mu*S;
			diff(ES,t) = betaS*S*IS - (mu + kS + r1)*ES + dS*IS -  betaR*ES*IR + betaS*RR*IS +  betaS*RS*IS ;
			diff(IS,t) = kS*ES - (muStarS + alphaS + gamma + dS)*IS + sigmaS*RS;
			diff(RS,t) = r1*ES + alphaS*IS - betaS*RS*IS - mu*RS - betaR*RS*IR - sigmaS*RS;
			diff(ER,t) = gamma*IS - (mu + kR + r2)*ER + dR*IR + betaR*S*IR + betaR*ES*IR + betaR*RR*IR + betaR*RS*IR;
			diff(IR,t) = kR*ER - (muStarR + alphaS + dR)*IR + sigmaR*RR;
			diff(RR,t) = r2*ER + alphaR*IR - betaR*RR*IR - mu*RR - betaS*RR*IS - sigmaR*RR;
			
			}
	reflex solving {
		
		solve SEIR_TB method: rk4 step: stepI;
		
// Display the values of R0 in consol		
		test<-test + 1;
		if(test=1){
		write("R0 for TBS: "+R0S); 
		write("R0 for TBMR: "+R0MR);	
			}		 
		}
	}
	
//Create the experiement that will allows us to display all output
experiment EXECUTE_Model type: gui {
	
// Define parameters for user interface	
	//Population for users
	parameter 'Number of Susceptible: S' type: int var: S_people category: "Initial population";
	parameter 'Number of Exposed TBS: ES' type: int var: ES_people category: "Initial population";
	parameter 'Number of Exposed TBMR: ER' type: int var: ER_people category: "Initial population";
	parameter 'Number of Infectious TBS: IinitS' type: int var: IinitS category: "Initial population";
	parameter 'Number of Infectious TBMR: IinitR' type: int var: IinitR category: "Initial population";
	parameter 'Number of Recovered TBS: RS' type: int var: RS_people category: "Initial population";
	parameter 'Number of Recovered TBMR: RR' type: int var: RR_people category: "Initial population";
	 
	// Parametr for users
	//parameter 'Proportion' type: float var: p <- 0.5 category: "Parameters"; // Proportion
	parameter 'Discrétisation steps for RK4' type: float var: stepI <- 0.07 category: "Parameters"; // stepI
	parameter 'relapse: sigmaS' type: float var: sigmaS <- 0.0436 category: "Parameters"; //relapse RS to IS
	parameter 'relapse: sigmaR' type: float var: sigmaR <- 0.003375 category: "Parameters"; //relapse RR to IR
	parameter 'Recrutment: Gamma' type: float var: Gamma <- 3.03 category: "Parameters"; //Recruitment in S
	parameter 'Mortality rate of general population' type:  float var: mu  <- 0.0196 category: "Parameters"; // Mortality rate of general population
	parameter 'Mortality rate for TBS' type: float var: muStarS <- 0.03 category: "Parameters"; // Mortality rate for TBS
	parameter 'Mortality rate for TBMR' type: float var: muStarR <- 0.05 category: "Parameters"; // Mortality rate for TBMR
	parameter 'Reactivation rate' type: float var: betaS <- 0.0035 category: "Parameters"; // Reactivation rate
	parameter 'Amplification rate' type: float var: betaR <- 0.0035 category: "Parameters"; // Amplification rate
	parameter 'Recovered rate for TBS' type: float var: alphaS <- 0.9 category: "Parameters"; // Recovered rate for TBS
	parameter 'Recovered rate for TBMR' type: float var: alphaR <- 0.8 category: "Parameters"; // Recovered rate for TBMR
	parameter 'Rate of a ES people (TBS) to became Exposed TBMR gamma' type: float var: gamma <- 0.59 category: "Parameters"; // Rate of a ES people (TBS) to became Exposed TBMR 
	parameter 'Rate of become exposed from IS to ES' type: float var: dS <- 0.21 category: "Parameters"; // Rate of become exposed from IS to ES
	parameter 'Rate of become exposed from IR to ER' type: float var: dR <- 0.021 category: "Parameters"; // Rate of become exposed from IR to ER
	parameter 'Rate of become infctious from ES to IS' type: float var: kS <- 0.0202 category: "Parameters"; // Rate of become infctious from ES to IS
	parameter 'Rate of become infctious from ER to IR' type: float var: kR <- 0.25 category: "Parameters"; // Rate of become infctious from ER to IR
	parameter 'Rate of recovered from ES to  RS' type: float var: r1 <- 0.9 category: "Parameters"; // Rate of recovered from ES to  RS
	parameter 'Rate of recovered from ER to  RR' type: float var: r2<- 0.8 category: "Parameters"; // Rate of recovered from ER to  RR
	 
	output { 
		
// Graphic camambert
	 
 	display SEIR_MATHS_camambert refresh_every: 1 {
			chart "TB MODEL for TBS and TBMR" type: pie {
				data 'S' value: first(SEIR_maths).S color: rgb('green') ;				
				data 'ES' value: first(SEIR_maths).ES color: rgb('orange') ;
				data 'ER' value: first(SEIR_maths).ER color: rgb('magenta') ;
				data 'IS' value: first(SEIR_maths).IS color: rgb('red') ;				
				data 'IR' value: first(SEIR_maths).IR color: rgb('chocolate') ;
				data 'RS' value: first(SEIR_maths).RS color: rgb('blue') ;
				data 'RR' value: first(SEIR_maths).RR color: rgb(#77B5FE);
			}
		} 

//Graphic line
		
	display SEIR_MATHS_line refresh_every: 1 {
			chart "TB MODEL for TBS and TBMR" type: series background: rgb('white') {
				data 'S' value: first(SEIR_maths).S color: rgb('green') ;				
				data 'ES' value: first(SEIR_maths).ES color: rgb('orange') ;
				data 'ER' value: first(SEIR_maths).ER color: rgb('magenta') ;
				data 'IS' value: first(SEIR_maths).IS color: rgb('red') ;				
				data 'IR' value: first(SEIR_maths).IR color: rgb('chocolate') ;
			    data 'RS' value: first(SEIR_maths).RS color: rgb('blue') ;
				data 'RR' value: first(SEIR_maths).RR color: rgb(#77B5FE);
			}
		}	
	
	//Graphic line X 20
	 	
	display SEIR_MATHS_lineX20 refresh_every: 1 {
			chart "TB MODEL for TBS and TBMR X 50" type: series background: rgb('white') {
				data 'S' value: first(SEIR_maths).S*2 color: rgb('green') ;				
				data 'ES' value: first(SEIR_maths).ES*20 color: rgb('orange') ;
				data 'IS' value: first(SEIR_maths).IS*20 color: rgb('red') ;
				data 'RS' value: first(SEIR_maths).RS*20 color: rgb('blue') ;	
				data 'ER' value: first(SEIR_maths).ER*20 color: rgb('magenta') ;
				data 'IR' value: first(SEIR_maths).IR*20 color: rgb('chocolate') ;
				data 'RR' value: first(SEIR_maths).RR*20 color: rgb(#77B5FE);
			}
		}
	}


// The end of the program
}