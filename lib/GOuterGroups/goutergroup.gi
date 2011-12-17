#(C) 2008 Graham Ellis

#############################################################################
##
#W  goutergroup.gi                 HAP                        


#############################################################################
##
##  Method for viewing GOuterGroups.  
##
InstallMethod( ViewObj,
        "for GOuterGroups",
        [IsGOuterGroup], 
    function(N)
    Print("G-outer group ", ActedGroup(N), " with actor ", ActingGroup(N), "\n");
end);

InstallMethod( PrintObj,
        "for GOuterGroups",
        [IsGOuterGroup],
    function(N)
    Print("G-outer group ", ActedGroup(N), " with actor ", ActingGroup(N), "\n");
end);

InstallMethod( ViewObj,
        "for GOuterGroupHomomorphisms",
        [IsGOuterGroupHomomorphism],
    function(phi)
    Print("G-outer group homomorphism A ----> B \n");
end);

InstallMethod( PrintObj,
        "for GOuterGroupHomomorphisms",
        [IsGOuterGroupHomomorphism],
    function(phi)
    Print("G-outer group homomorphism A ----> B \n");
end);

#############################################################################
##
##  Creation empty G-Outer group. Attributes must be set later. There
##  is no method for printing an empty G-Outer group (nor should there be).
##
InstallMethod( GOuterGroup,
    "method for creating a GOuterGroup with no attributes set",
    [ ],

    function( )
        local N, type;
 		N:= rec();
        	type:= NewType(NewFamily("gog"),
                       IsGOuterGroup and
                       IsComponentObjectRep and IsAttributeStoringRep);

        ObjectifyWithAttributes(N,type);
        return N;
     end);


#############################################################################
##
##  Creation of a G-Outer N group from a group E (Extension) with 
##  normal subgroup A.
##
##      A --> E --> G
##
InstallMethod( GOuterGroup,
    "basic method for creating a GOuterGroup",
    [ IsGroup, IsGroup ],

    function( E, A )
        local 
	      N, type,
              alpha,     ## Action of G on A
              nat;       ## Natural homomorphism from E to G

        if not IsNormal(E,A) then
            Error("A must be a normal subgroup of E");
        fi;
  
        nat := NaturalHomomorphismByNormalSubgroup(E,A);

        alpha := function(g,a); 
            return 
            Representative(PreImages(nat,g))
                           *a*
            Representative(PreImages(nat,g))^-1; 
            end;

 	N:=GOuterGroup(); 
               SetActingGroup(N,Image(nat));
               SetActedGroup(N,A);
               SetOuterAction(N,alpha);
        return N;
    end);


#############################################################################
##
##  The centre of the acted group of a G-outer group is a G-module. We 
##  return this centre as a G-outer group.
##
##
InstallOtherMethod( Center,
    "method for returning the centre of a G-outer group as a G-outer group.",
    [ IsGOuterGroup ], 

    function( N )
    local C, type;
    
 	C:=GOuterGroup(); 
               SetActingGroup(C,ActingGroup(N));
               SetActedGroup(C,Center(ActedGroup(N)));
               SetOuterAction(C,OuterAction(N));
        return C;
    end );


    
#############################################################################
##
##  Test to see if a group homomorphism is a G-outer group homomorphism.
##  The test is clumsy, only treats finite G, and the
##  definition of homomorphism used here may not be the most appropriate in
##  the case when the G-outer group B is non-commutative.
##
InstallMethod( GOuterHomomorphismTester,
    "basic method for creating a GOuterGroup",
    [ IsGOuterGroup, IsGOuterGroup, IsGroupHomomorphism ],

    function(A,B, phi )
     local OA,OB,G,alpha,beta,a,g;

        if not
        (HasActingGroup(A) and HasActingGroup(B))
        then return false; fi;
        if not ActingGroup(A)=ActingGroup(B)  then
        return false;
        fi;
        OA:=Source(phi);
        OB:=Target(phi);
        if not (ActedGroup(A)=OA and ActedGroup(B)=OB) then
        return false; fi;
        G:=ActingGroup(A);
        alpha:=OuterAction(A);
        beta:=OuterAction(B);

        if (not IsFinite(G))
        then TryNextMethod(); fi;

        for a in GeneratorsOfGroup(OA) do
        for g in G do
        if not
        Image(phi,alpha(g,a)) = beta(g,Image(phi,a))   
        then return false; fi;
        od; 
        od;
      return true;
     end);



#########################################################################
##
##  Constructor for an empty GOuterGroup homomorphism. No method to print
##  such an empty homomorphism (nor should there be).
##
InstallMethod( GOuterGroupHomomorphism,
    "method for constructing an empty GOuterGroup homomorphism",
    [ ],

    function()
    local PHI, type;
        PHI:=rec();
        type:= NewType(NewFamily("gogh"),
               IsGOuterGroupHomomorphism and
               IsComponentObjectRep and IsAttributeStoringRep);
	ObjectifyWithAttributes( PHI,type);
        return PHI;
    end);

#########################################################################
##
##  Constructor for a GOuterGroup homomorphism. 
##  
##
InstallMethod( GOuterGroupHomomorphism,
    "method for constructing GOuterGroup homomorphisms",
    [ IsGOuterGroup, IsGOuterGroup, IsGroupHomomorphism ],

    function( A, B, phi  )
    local PHI, type;

        PHI:=GOuterGroupHomomorphism(); 
               SetSource(PHI,A);
               SetTarget(PHI, B);
               SetMapping(PHI, phi);
        return PHI;
    end );

#########################################################################
##
##  Install method of arrow composition on *
##
InstallOtherMethod( \*,
    "basic method for composing GOuterGroup Homomorphisms",
    [ IsGOuterGroupHomomorphism, IsGOuterGroupHomomorphism ],

  function(PHI,THETA)
     local phi, theta, thetaphi;

        if not (Source(PHI)=Target(THETA)) then
        Print("Arrows and not composable. \n");
        return fail;
        fi;
        phi:=Mapping(PHI);
        theta:=Mapping(THETA);
        thetaphi:=GroupHomomorphismByFunction(
        Source(theta), Target(phi),
        x-> Image(phi,Image(theta,x)) );

        return
        GOuterGroupHomomorphism(Source(THETA),Target(PHI),thetaphi);
        end);

######################################################################
##
##  Install method of arrow addition on +. This won't be a homomorphism
##  unless the images of PHI and THETA are abelian groups. 
##
InstallOtherMethod( \+,
    "method for adding GOuterGroup Homomorphisms",
    [ IsGOuterGroupHomomorphism, IsGOuterGroupHomomorphism ],

  function(PHI,THETA)
     local phi, theta, thetaphi;

        if not ( 
        Source(PHI)=Target(THETA)
        and 
        Target(PHI)=Target(THETA)
        ) then
        Print("Arrows can not be added \n");
        return fail;
        fi;
        phi:=Mapping(PHI);
        theta:=Mapping(THETA);
        thetaphi:=GroupHomomorphismByFunction(
        Source(theta), Target(phi),
        x-> Image(phi,x) * Image(theta,x) );

        return
        GOuterGroupHomomorphism(Source(THETA),Target(PHI),thetaphi);
        end);

######################################################################
##
##  Install method of arrow subtraction on \-. This won't be a homomorphism
##  unless the images of PHI and THETA are abelian groups.
##
InstallOtherMethod( \-,
    "method for subtracting GOuterGroup Homomorphisms",
    [ IsGOuterGroupHomomorphism, IsGOuterGroupHomomorphism ],

  function(PHI,THETA)
     local phi, theta, thetaphi;

        if not (
        Source(PHI)=Target(THETA)
        and
        Target(PHI)=Target(THETA)
        ) then
        Print("Arrows can not be added \n");
        return fail;
        fi;
        phi:=Mapping(PHI);
        theta:=Mapping(THETA);
        thetaphi:=GroupHomomorphismByFunction(
        Source(theta), Target(phi),
        x-> Image(phi,x) * Image(theta,x)^-1 );

        return
        GOuterGroupHomomorphism(Source(THETA),Target(PHI),thetaphi);
        end);



######################################################################
##
##  Install method for DirectProduct of two GOuter groups, with commin
##  acting group and diagonal action 
##
InstallOtherMethod( DirectProductGog,
    "method for direct product of two GOuterGroups",
    [ IsGOuterGroup, IsGOuterGroup ],

  function(M,N)
     local A,B,C,G,MN,alpha,beta,gamma,
           i1,i2,p1,p2;

	if not ActingGroup(M)=ActingGroup(N) then
	TryNextMethod(); fi;

	A:=ActedGroup(M);
	B:=ActedGroup(N);
	G:=ActingGroup(M);
	alpha:=OuterAction(M);
	beta:=OuterAction(N);

	C:=DirectProduct(A,B);
	i1:=Embedding(C,1);
	i2:=Embedding(C,2);
	p1:=Projection(C,1);
	p2:=Projection(C,2);

	gamma:=function(g,x)
	return
         Image(i1,alpha(g,Image(p1,x)))
		*
	 Image(i2,beta(g,Image(p2,x)));	
	end;

	MN:=GOuterGroup();
 	SetActedGroup(MN,C);
	SetActingGroup(MN,G);
	SetOuterAction(MN,gamma);

	#We'll later construct the two embeddings and two projections.

	#MN!.e1:=GOuterGroupHomomorphism(M,MN,Embedding(C,1));
	#MN!.e2:=GOuterGroupHomomorphism(M,MN,Embedding(C,2));
	#MN!.p1:=GOuterGroupHomomorphism(M,MN,Projection(C,1));
        #MN!.p2:=GOuterGroupHomomorphism(M,MN,Projection(C,2));

	return MN;	
	end);

######################################################################
##
##  Install method for DirectProduct embeddings for GOuter groups.
##
InstallOtherMethod( Embedding,
    "method for direct product embeddings",
    [ IsGOuterGroup, IsInt ],

  function(D,n)
	local A,e,p,beta;
	e:=Embedding(ActedGroup(D),n);
	p:=Projection(ActedGroup(D),n);
	A:=GOuterGroup();
	SetActedGroup(A,Source(e));
	SetActingGroup(A,ActingGroup(D));
	beta:=function(g,a);
	      return Image(p,OuterAction(g,Image(e,a)));  
	end;
	SetOuterAction(A,beta);
	
	return GOuterGroupHomomorphism(A,D,e);
  end);

######################################################################
##
##  Install method for DirectProduct projections for GOuter groups.
##
InstallOtherMethod( Projection,
    "method for direct product Projections",
    [ IsGOuterGroup, IsInt ],

  function(D,n)
        local A,e,p,beta;
        e:=Embedding(ActedGroup(D),n);
        p:=Projection(ActedGroup(D),n);
        A:=GOuterGroup();
        SetActedGroup(A,Source(e));
        SetActingGroup(A,ActingGroup(D));
        beta:=function(g,a);
              return Image(p,OuterAction(g,Image(e,a)));
        end;
        SetOuterAction(A,beta);

        return GOuterGroupHomomorphism(D,A,p);
  end);


######################################################################
##
##  Install method for DirectProductGog of a list of GOuter groups.
##   It inputs a list Lst of GOuter groups. 
##
InstallOtherMethod( DirectProductGog,
    "method for direct product of list of G-outer groups",
    [ IsList ],

  function(Lst)
        local D,UD,G,alpha,beta;

	if Length(Lst)=0 then TryNextMethod(); fi;
	if not IsGOuterGroup(Lst[1]) then 
	Print("Must be a list of G-outer groups.\n");
	return fail; fi;

        #Are all acting groups identical. If not, try another method.
	if not Length(SSortedList(List(Lst,ActingGroup)))=1 then 
	TryNextMethod(); fi;

	G:=ActingGroup(Lst[1]);
        UD:=DirectProductOp(List(Lst,ActedGroup), ActedGroup(Lst[1]));	

	beta:=function(g,a)
	local answer;
	answer:=
	List([1..Length(Lst)], i->Image(Projection(UD,i),a));
	answer:=
	List([1..Length(Lst)], i-> OuterAction(Lst[i])(g,answer[i]));
	answer:=
	List([1..Length(Lst)], i-> Image(Embedding(UD,i),answer[i]));
	answer:=Product(answer);
	return answer; 
	end;

	D:=GOuterGroup();
	SetActingGroup(D,G);
	SetActedGroup(D,UD);
	SetOuterAction(D,beta);

	return D;
  end);

