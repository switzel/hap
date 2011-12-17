#(C) Graham Ellis, October 2005

#####################################################################
InstallGlobalFunction(NonabelianTensorSquare,
function(arg)
local
	AG, SizeOrList,
	gensAG, NiceGensAG,  
	G, gensG, relsG, 
	BG, GhomBG, BG1homF, BG2homF,
	F, relsT, gensF, gensF1, gensF2,
	AF, FhomAF,
	AGhomG, G1homF, G2homF, AG1homF, AG2homF,
	SF, gensSF, gensSFG, FhomSF, AFhomSF, AG1homSF, AG2homSF, SFhomAG,
	AFhomSSF,SSF,gensSF2,SSFhomSF,
	TensorSquare, delta,
	Trans,
	CrossedPairing, 
	UpperBound,
	i,v,w,x,y,z;


#####################################################################
UpperBound:=function(AG)
local Facts, p,P,hom,bnd;

Facts:=SSortedList(Factors(Order(AG)));
bnd:=1;

for p in Facts do
P:=SylowSubgroup(AG,p);
hom:=NonabelianTensorSquare(P).homomorphism;
bnd:=bnd*Order(Source(hom))/Order(DerivedSubgroup(P));
od;

return bnd*Order(DerivedSubgroup(AG))*Order(AG)^2;
end;
#####################################################################





AG:=arg[1];
if Length(arg)>1 then SizeOrList:=arg[2]*Order(AG)^2; 
else 
	if IsSolvable(AG) and not IsNilpotent(AG) then
	SizeOrList:=UpperBound(AG);
	else
	SizeOrList:=0;
	fi;
fi;

# AG and SF are groups whose elements are essentially enumerated. AG is 
# isomorphic to G and to BG. SF is equal to F/relsT and AF. Two isomorphic 
# copies of AG lie inside SF, and the homomorphisms AG1homSF, AG2homSF 
# identify the two copies. delta is the commutator map from TensorSquare to AG.
# The homomorphisms GhomBG, AGhomG, FhomSF, FhomAF, AFhomSF are all 
# isomorphisms. The relationship between the groups is summarized in the 
# following diagrams:   AG->G->BG->F->AF->SF and SF->AG.


gensAG:=GeneratorsOfGroup(AG);
AGhomG:=IsomorphismFpGroupByGenerators(AG,gensAG);
G:=Image(AGhomG);
gensG:=FreeGeneratorsOfFpGroup(G);
relsG:=RelatorsOfFpGroup(G);
BG:=Group(gensG);
GhomBG:=GroupHomomorphismByImagesNC(G,BG, GeneratorsOfGroup(G),gensG);
			#I hope GhomBG really is the identity map!

F:=FreeGroup(2*Length(gensG));
gensF:=GeneratorsOfGroup(F); gensF1:=[]; gensF2:=[];
for i in [1..Length(gensG)] do
Append(gensF1,[gensF[i]]);
Append(gensF2,[gensF[Length(gensG)+i]]);
od;

BG1homF:=GroupHomomorphismByImagesNC(BG,F,gensG,gensF1);
G1homF:=GroupHomomorphismByFunction(G,F,x->Image(BG1homF,Image(GhomBG,x)));
BG2homF:=GroupHomomorphismByImagesNC(BG,F,gensG,gensF2);
G2homF:=GroupHomomorphismByFunction(G,F,x->Image(BG2homF,Image(GhomBG,x)));
AG1homF:=GroupHomomorphismByFunction(AG,F,g->Image(G1homF,Image(AGhomG,g)));
AG2homF:=GroupHomomorphismByFunction(AG,F,g->Image(G2homF,Image(AGhomG,g)));

	if IsSolvable(AG) then 
	NiceGensAG:=Pcgs(AG);
	else
	NiceGensAG:=List(UpperCentralSeries(AG),x->GeneratorsOfGroup(x));
	NiceGensAG[1]:=[Identity(AG)];
	NiceGensAG:=Flat(NiceGensAG);
	Trans:=RightTransversal(AG,Group(NiceGensAG));
	Append(NiceGensAG,Elements(Trans));
	fi;

relsT:=[];
for x in relsG do
Append(relsT,[Image(BG1homF,x), Image(BG2homF,x)]);
od;

for z in GeneratorsOfGroup(AG) do
for x in NiceGensAG do
for y in NiceGensAG do
v:=Comm(Image(AG1homF,x),Image(AG2homF,y))^Image(AG1homF,z) ;
w:=Comm(Image(AG2homF,y^z),Image(AG1homF,x^z) );
Append(relsT,[v*w]);
v:=Comm(Image(AG1homF,x),Image(AG2homF,y))^Image(AG2homF,z);
Append(relsT,[v*w]);
od;
od;
od;

#####################################################################IF
if 

SizeOrList=0  
or
not ( (IsSolvable(AG) and IsInt(SizeOrList)) or IsNilpotent(AG))

then

AF:=F/relsT;
FhomAF:=
GroupHomomorphismByImagesNC(F,AF,GeneratorsOfGroup(F),GeneratorsOfGroup(AF));

AFhomSF:=IsomorphismSimplifiedFpGroup(AF);
SF:=Image(AFhomSF);
FhomSF:=
GroupHomomorphismByFunction(F,SF,x->Image(AFhomSF,Image(FhomAF,x)) );


else

AF:=F/relsT;
FhomAF:=
GroupHomomorphismByImagesNC(F,AF,GeneratorsOfGroup(F),GeneratorsOfGroup(AF));

AFhomSSF:=IsomorphismSimplifiedFpGroup(AF);
SSF:=Image(AFhomSSF);

	if IsNilpotent(AG) then
	SSFhomSF:=EpimorphismNilpotentQuotient(SSF);
	else
	SSFhomSF:=EpimorphismSolvableQuotient(SSF,SizeOrList); 
	fi;

SF:=Image(SSFhomSF);
gensSF2:=List(GeneratorsOfGroup(AF),x->Image(SSFhomSF,Image(AFhomSSF,x)));

AFhomSF:=GroupHomomorphismByImagesNC(AF,SF,GeneratorsOfGroup(AF),gensSF2);


FhomSF:=
GroupHomomorphismByFunction(F,SF,x->Image(AFhomSF,Image(FhomAF,x)) );

fi;
#####################################################################FI

AG1homSF:=GroupHomomorphismByFunction(AG,SF,x->Image(FhomSF,Image(AG1homF,x)));
AG2homSF:=GroupHomomorphismByFunction(AG,SF,x->Image(FhomSF,Image(AG2homF,x)));

TensorSquare:=Intersection(
NormalClosure(SF,Group(List(GeneratorsOfGroup(AG),x->Image(AG1homSF,x)))),
NormalClosure(SF,Group(List(GeneratorsOfGroup(AG),x->Image(AG2homSF,x))))
);


gensSF:=List(gensF,x->Image(FhomSF,x));
gensSFG:=[];
for i in [1..Length(gensAG)] do
Append(gensSFG,[gensAG[i]]);
od;
for i in [1..Length(gensAG)] do
Append(gensSFG,[gensAG[i]]);
od;

SFhomAG:=GroupHomomorphismByImagesNC(SF,AG,gensSF,gensSFG);

delta:=GroupHomomorphismByFunction(TensorSquare,AG,x->Image(SFhomAG,x));

#####################################################################
CrossedPairing:=function(x,y)

return Comm(Image(AG1homSF,x), Image(AG2homSF,y));

end;
#####################################################################

return rec(homomorphism:=delta, pairing:=CrossedPairing);
end);
#####################################################################

#####################################################################
InstallGlobalFunction(ThirdHomotopyGroupOfSuspensionB,
function(arg) ;

if Length(arg)>1 then
return AbelianInvariants(Kernel(
			NonabelianTensorSquare(arg[1],arg[2]).homomorphism));
else
return AbelianInvariants(Kernel(
                        NonabelianTensorSquare(arg[1]).homomorphism));
fi;

end);
#####################################################################

