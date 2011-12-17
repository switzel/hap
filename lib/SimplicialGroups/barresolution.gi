## Input : w =[[m1,h1,g11,g12,g13,..,g1n],...[mk,hk,gk1,...gk]]
## Output: image of w under d_n
#############################################
##############################################
######################################################################
InstallGlobalFunction(ReduceAlg,
function(w)
	local Compare,len,iw,L,i,nL,flag;
##############################	
Compare:=function(w,v)
	local n,i;
	n:=Length(w);
	for i in [2..n] do
		if w[i]<>v[i] then
			return 0;
		fi;
	od;
	return 1;
end;	
######################	
	len:=Length(w);
	L:=[];
	for iw in w do
		flag:=0;
		nL:=Length(L);
		for i in [1..nL] do
			if Compare(L[i],iw)=1 then
				flag:=1;
				L[i][1]:=L[i][1]+iw[1];
					if L[i][1]=0 then 
						Remove(L,i);
					fi;
				break;
			fi;
		od;
		if flag=0 then
			Add(L,iw);
		fi;
	od;
return L;	
end);
#######################################################################
#######################################################################
InstallGlobalFunction(BarResolutionBoundary,    ### w:=[[m1,h1,g1,g2,...]... ]
function(w)
	local n,i,j,len,sign,
	temp,iw,Dw;
	Dw:=[];
	for iw in w do 
		n:=Length(iw)-2;
	## Creat 0	 
		temp:=[iw[1],iw[2]*iw[3]];
		for j in [2..n] do
			Add(temp,iw[j+2]);
		od;
		Add(Dw,temp);
	## Creat 1 --> n 
		sign:=-1;
		for i in [1..n-1] do
		   temp:=[sign*iw[1],iw[2]];
		   for j in [1..i-1]	do
			   Add(temp,iw[j+2]);
		   od;
		   Add(temp,iw[i+2]*iw[i+3]);
		   for j in [i+2..n]do
				Add(temp,iw[j+2]);
		   od;
		   Add(Dw,temp);
		   sign:=-sign;  
		od;
	## Creat n+1
		temp:=[sign*iw[1],iw[2]];
		for j in [1..n-1] do
			Add(temp,iw[j+2]);
		od;
		Add(Dw,temp);
	od;
return Dw;
end);
#######################################################################
#######################################################################
InstallGlobalFunction(BarResolutionEquivalence,
	function(R)
	local lenE,Elts,e,n,
	hoto,dim,bound,
	g,i,j,Psibase,tmppsi,temp,Boundbase,Jtemp,tmp,sign,baseelt,
	SearchPos,HotoR,BarResolutionHomotopy,
	Phi,Psi,Equiv,TPsi,
	ReEquiv,RePhi,RePsi,ReTPsi;
	
	Elts:=R!.elts;
	lenE:=Length(Elts);
	e:=Identity(R!.group);
	hoto:=R!.homotopy;
	dim:=R!.dimension;
	bound:=R!.boundary;
	n:=EvaluateProperty(R,"length");
	
####################################################
SearchPos:=function(g)
   local j;
   for j in [1..lenE] do
		if Elts[j]=g then
		    return j;
		fi;	
   od;
   Add(Elts,g);           #These two lines added by Graham
   return Length(Elts);   #
end;
####################################################
HotoR:=function(n,w)  ### w:=[[m1,e1,pos1],...[mk,ek,posk]]
	local
		ReH, iw, Hw,jHw,m;
	ReH:=[];
	for iw in w do
	    m:=iw[1];
		Hw:=hoto(n,[iw[2],iw[3]]);
		for jHw in Hw do
			if jHw[1]>0 then 
				Add(ReH,[m,jHw[1],jHw[2]]);
			else
				Add(ReH,[-m,-jHw[1],jHw[2]]);
			fi;
		od;
	od;
	return ReH;
end;
############################################################
BarResolutionHomotopy:=function(w) #######Input w =[[m1,h1,g11,g12,g13,..,g1n],...[mk,hk,gk1,...gk]]
	local i,iw,len,Hw,iHw;
	Hw:=[];
	for iw in w do
		len:=Length(iw);
		iHw:=[iw[1],e,iw[2]];
		for i in [3..len] do
			Add(iHw,iw[i]);
		od;
		Add(Hw,iHw);
	od;	
	return Hw;
end;

#############################################################
	Psibase:=List([0..n],x->[]);
	Psibase[1][1]:=[[1,e]];  ##################[0][1]
	for i in [1..n] do
		for j in [1..dim(i)] do
			tmppsi:=[];
			Boundbase:=bound(i,j);
			for temp in Boundbase do
				if temp[1]<0 then 
					sign:=-1;
					baseelt:=-temp[1];
				else
					sign:=1;
					baseelt:=temp[1];	
				fi;
				g:=Elts[temp[2]];
				Jtemp:= StructuralCopy(Psibase[i][baseelt]);
				for tmp in Jtemp do
					tmp[1]:=sign*tmp[1];
					tmp[2]:=g*tmp[2];	
				od;
				tmppsi:=Concatenation(tmppsi,Jtemp);
			od;
			Psibase[i+1][j]:=BarResolutionHomotopy(tmppsi);
		od;	
	od;	
#############################################################
Psi:= function(n,w)        ## w:=[[m1,e1,pos1],...,[mk,ek,posk]]	ex: [[-2,1,5],...[5,4,27]]
	local Rew,iw,m,h,psiw,temp;
	Rew:=[];
	for iw in w do
		m:=iw[1];
		h:=Elts[iw[3]];
		psiw:=StructuralCopy(Psibase[n+1][iw[2]]);
		for temp in psiw do
			temp[1]:=m*temp[1];
			temp[2]:=h*temp[2];
			Add(Rew,temp);
		od;
	od;
	return ReduceAlg(Rew);
end;

################################################
Phi:=function(n,w)  ###### Input w =[[m1,h1,g11,g12,g13,..,g1n],...[mk,hk,gk1,...gk]]
	local     ### Output:  [[l,order,postion],...]
	Rew,iw,m,h,Biw,phiBiw,HphiBiw,temp;						
	if n=0 then  		#### w:=[[m1,h1],...[mk,hk]]
	   Rew:=[];
	   for iw in w do
			Add(Rew,[iw[1],1,SearchPos(iw[2])]);
	   od;
	   return Rew;
	fi;
	#############
	Rew:=[];
	for iw in w do
		m:=iw[1]; 
		iw[1]:=1;
		h:=iw[2]; 
		iw[2]:=e;
		Biw:=BarResolutionBoundary([iw]);  #first: We find image of a element of basis [1,e,g1,g2,...gn]
		phiBiw:=Phi(n-1,Biw);
		HphiBiw:=HotoR(n-1,phiBiw);
		for temp in HphiBiw do
			Add(Rew,[m*temp[1],temp[2],SearchPos(h*Elts[temp[3]])]);
		od;
	od;
	return ReduceAlg(Rew);
end;
############################################
Equiv:=function(n,w)         ### Input w =[[m1,h1,g11,g12,g13,..,g1n],...[mk,hk,gk1,...gk]]
    local PsiPhiw,HBw,HLw,temp;
    if n = 0 then 
		return [];
    fi;		
	PsiPhiw:=Psi(n,Phi(n,w));
	HBw:= Equiv(n-1,BarResolutionBoundary(w));
	HLw:= Concatenation(PsiPhiw,HBw);
	for temp in HLw do
		temp[1]:=-temp[1];
	od;
	HLw:=Concatenation(w,HLw);
    return ReduceAlg(BarResolutionHomotopy(HLw));
end;
##########################################

return rec(
            phi:=Phi,
			psi:=Psi,
			equiv:=Equiv
          );
end);	
					

#############################################
#############################################

