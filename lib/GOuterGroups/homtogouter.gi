#(C) Graham ellis 2008

#####################################################################
#####################################################################
##
##  Method for applying Hom_G(_,A) to one boundary homomorphism in
##  a free ZG-resolution R. We won't document this method in the manual
##  as it is really only for internal use.
InstallMethod(HomToGModule,
[IsHapResolution,IsInt,IsGOuterGroup,IsGOuterGroup,IsGOuterGroup],
function(R,n,A,M,N)
local phi,UM,UN, act, MAT,i,x,b,fn,s;

#M:=DirectProductGog(List([1..R!.dimension(n)],i->A));
#N:=DirectProductGog(List([1..R!.dimension(n+1)],i->A));
UM:=ActedGroup(M);
UN:=ActedGroup(N);
act:=OuterAction(A);

MAT:=List([1..R!.dimension(n)],i->List([1..R!.dimension(n+1)],j->[]));

for i in [1..R!.dimension(n+1)] do
for x in R!.boundary(n+1,i) do
Add(MAT[AbsInt(x[1])][i],SignInt(x[1])*x[2]);
od;
od;

	##########################################################
	fn:=function(j,a) #Here a is in A and i is the component of the product
	local x,i,ans;
	
	ans:=One(UN);
	for i in [1..R!.dimension(n+1)] do
	for x in MAT[j][i] do
	ans:=ans*   Image(Embedding(UN,i),
	         act(R!.elts[AbsInt(x)],a)^SignInt(x) );
	od;
	od;
	return ans;
	end;
	##########################################################

phi:=GroupHomomorphismByFunction(UM,UN,x->
Product(List([1..R!.dimension(n)],j->fn(j,Image(Projection(UM,j),x))))
);

return GOuterGroupHomomorphism(M,N,phi);
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
##
##  Method for applying Hom_G(_,A) to a free ZG-resolution R.
InstallMethod(HomToGModule,
[IsHapResolution,IsGOuterGroup],
function(R,A)
local gogs,homos,Boundary, properties, L;

L:=EvaluateProperty(R,"length");
homos:=[1..L];  #homs[1] has source in degree 0.
gogs:=[1..L+1]; #gogs[1] is the chain module C_0


########################################
Boundary:=function(n)
if IsInt(homos[n+1]) then
if IsInt(gogs[n+1]) then gogs[n+1]:=
DirectProductGog(List([1..R!.dimension(n)],i->A)); fi;
if IsInt(gogs[n+2]) then gogs[n+2]:=
DirectProductGog(List([1..R!.dimension(n+1)],i->A)); fi;
homos[n+1]:=HomToGModule(R,n,A,gogs[n+1],gogs[n+2]);
fi;
return homos[n+1];
end;
########################################

return Objectify(HapGCocomplex,
                rec(
		resolution:=R,
		module:=A,
                boundary:=Boundary,
                properties:=
                [["length",L],
                ["type", "Gcomplex"],
                 ]));
end);



#####################################################################
#####################################################################
##
InstallMethod( ViewObj,
"for HapGComplex",
[IsHapGCocomplex],
 function(R)
Print("G-cocomplex of length ",
EvaluateProperty(R,"length"), " . \n");
 end);

InstallMethod( PrintObj,
"for HapGComplex",
[IsHapGCocomplex],
function(R)
Print("G-cocomplex of length ",
EvaluateProperty(R,"length"), " . \n");
end);
#######################################################################
#######################################################################

#######################################################################
#######################################################################
InstallMethod(Cohomology,
    "Cohomology of a G-cocomplex returned as abelian invariants",
     [IsHapGCocomplex,IsInt],
function(C,n);

if n=0 then
return 
AbelianInvariants(
Kernel(Mapping(C!.boundary(n))));
fi;

return
AbelianInvariants(
Kernel(Mapping(C!.boundary(n)))
/
Image(Mapping(C!.boundary(n-1)))
);
end);

#######################################################################
#######################################################################
InstallMethod(CohomologyModule,
    "Cohomology of a G-cocomplex returned as abelian invariants",
     [IsHapGCocomplex,IsInt],
function(C,n)
local 	H,N,A,R,alpha,nat,coh,
	ClassRepresentative,RepresentativeCocycle, 
	DP,dim,
	StandardCocycle;

if n=0 then
return Kernel(C!.boundary(0));
fi;

DP:=ActedGroup(Source(C!.boundary(n)));
H:=Kernel(C!.boundary(n));
N:=Range(C!.boundary(n-1));
nat:=NaturalHomomorphism(H,N);
coh:=Target(nat);

if not "resolution" in NamesOfComponents(C) then
return coh; fi;

##
##  The rest of this method is devoted to producing a cocycle 
##  for each element of coh.

A:=C!.module;
alpha:=OuterAction(A);
R:=C!.resolution;


	###############################################
	ClassRepresentative:=function(c) #Find a rep in the direct product
	local cc;			 #for the class c, and return 
					 #it as a list	

	cc:=PreImagesRepresentative(Mapping(nat),c);
	return
	List([1..R!.dimension(n)],i->Image(Projection(DP,i),cc));
	end;
	###############################################

	###############################################
	RepresentativeCocycle:=function(c)
	local lst,cocycle,stancocycle,CocycleRec;

	lst:=ClassRepresentative(c);

	  #############################################
	  cocycle:=function(w) #where w is a word in R_n
	  local x,ans;
	  
	  ans:=One(ActedGroup(A));
	  for x in w do
	  ans:=ans * alpha(R!.elts[x[2]],lst[AbsInt(x[1])])^SignInt(x[1]);
	  od;
		
	  return ans;
	  end;
	  #############################################

	  #############################################
	  stancocycle:=function(arg);
          return cocycle(Syzygy(R,List([1..Length(arg)],i->arg[i])));
	  end;
	  #############################################

##  Let's speed things up
##  for small groups and
##  2-cocycles.

	  if Order(R!.group)<2001 and n=2 then
	   CocycleRec:=
             List([1..Order(R!.group)], i->
                List([1..Order(R!.group)],j->0) );
	  #############################################
	  stancocycle:=function(arg)
	  local  u,v;
          u:=Position(Elements(R!.group),arg[1]); 
          v:=Position(Elements(R!.group),arg[2]);

	  if CocycleRec[u][v]=0 then
          CocycleRec[u][v]:= cocycle(Syzygy(R,List([1..Length(arg)],i->arg[i])));
          fi;
          
	  return CocycleRec[u][v];
          end;
	  #############################################
	  fi;

##  Finishished speeding things up.
##  
##

	return StandardNCocycle(A,stancocycle,n);
	end;
	###############################################

coh!.representativeCocycle:=RepresentativeCocycle;
return coh;
end);
##################################################################

#######################################################################
#######################################################################
##
##  Method for kernel of G-outer group homomorphisms.
##
InstallMethod(Kernel,
	"Kernel of G-outer group homomorphisms",
              [IsGOuterGroupHomomorphism],
function(PHI)
local K;

K:=GOuterGroup();
SetActingGroup(K,ActingGroup(Source(PHI)));
SetActedGroup(K,Kernel(Mapping(PHI)));
SetOuterAction(K,OuterAction(Source(PHI)));
return K;
end);

#######################################################################
#######################################################################
##
##  Method for image of G-outer group homomorphisms. We'll use "Range"
##  as "Image" is a function.
InstallOtherMethod(Range,
        "Range=Image of G-outer group homomorphisms",
              [IsGOuterGroupHomomorphism],
function(PHI)
local K;

K:=GOuterGroup();
SetActingGroup(K,ActingGroup(Source(PHI)));
SetActedGroup(K,Image(Mapping(PHI)));
SetOuterAction(K,OuterAction(Target(PHI)));
return K;
end);


#######################################################################
#######################################################################
##
##  Method for quotient homomorphism for G-outer groups.
InstallOtherMethod(NaturalHomomorphism,
        "Quotient of G-outer groups",
              [IsGOuterGroup,IsGOuterGroup],
function(H,M)
local nat,UH,UM,Q,alpha,beta;

if not ActingGroup(H)=ActingGroup(M) then 
Print("There must be a common acting group. \n");
return fail; fi;

UH:=ActedGroup(H);
UM:=ActedGroup(M);
nat:=NaturalHomomorphismByNormalSubgroup(UH,UM);
Q:=GOuterGroup();

alpha:=OuterAction(H);

	#############################################
	beta:=function(g,a);
	return
	Image(nat,alpha(g,PreImagesRepresentative(nat,a)));
	end;
	#############################################

SetActingGroup(Q,ActingGroup(H));
SetActedGroup(Q,Image(nat));
SetOuterAction(Q,beta);
return GOuterGroupHomomorphism(H,Q,nat);
end);


#######################################################################
#######################################################################
##
##  Method for quotient \/ for G-outer groups.
InstallOtherMethod(\/,
        "Quotient of G-outer groups",
              [IsGOuterGroup,IsGOuterGroup],
function(H,M);

return Target(NaturalHomomorphism(H,M));

end);


#############################################################################
##
##  Creation empty standard2cocycle 
##
InstallMethod( StandardNCocycle,
    "method for creating a 2cocycle with no attributes set",
    [ ],

    function( )
        local N, type;
                N:= rec();
                type:= NewType(NewFamily("standard2cocycle"),
		       IsStandardNCocycle and 
                       IsComponentObjectRep and IsAttributeStoringRep);

        ObjectifyWithAttributes(N,type);
        return N;
     end);


#############################################################################
##
##  Creation standard N-cocycle
##
InstallMethod( StandardNCocycle,
    "method for creating an N-cocycle with no attributes set",
    [IsGOuterGroup,IsFunction,IsInt ],

    function(A,f,n )
        local C;
	C:=StandardNCocycle();
	SetCoefficientModule(C,A);
        SetMapping(C,f);
	SetArity(C,n);

        return C;
     end);


#####################################################################
#####################################################################
##
InstallMethod( ViewObj,
"for StandardNCocycle",
[IsStandardNCocycle],
 function(R)
Print("Standard ",R!.Arity,"-cocycle \n");
 end);

InstallMethod( PrintObj,
"for StandardNCocycle",
[IsStandardNCocycle],
 function(R)
Print("Standard ",R!.Arity,"-cocycle \n");
 end);

#######################################################################
#######################################################################













