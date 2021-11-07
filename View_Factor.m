function VF = View_Factor(Xa,Ya,Xb,Yb,Z)
%This function calculates viewfactors between 2 rectangles in parallel
%planes, the sides of which are parallel to the X and Y axis. 
%Xa, Ya, Xb, Yb contain limits of rectangles a and b in X and Y directions. 
%Z is the distance between the rectangles.

A = (Xa(2)-Xa(1))*(Xb(2)-Xb(1));

SUM=0;
i=1;
j=1;
k=1;
l=1;

while i < 3
    while j < 3
        while k < 3
            while l < 3
                u = Xa(i)-Xb(k);
                v = Ya(j)-Yb(l);
                p = sqrt((u^2)+(Z^2));
                q = sqrt((v^2)+(Z^2));

                B = (v*p*atan(v/p))+(u*q*atan(u/q))-(((Z^2)/2)*log((u^2)+(v^2)+(Z^2)));
                SUM = SUM + (((-1)^(i+j+k+l))*B);
                l = l+1;  
            end
            l = 1;
            k=k+1;
        end
        k = 1;
        j=j+1;
    end
    j = 1;
    i=i+1;
end
VF = ((1/(2*pi*A))*SUM);
end

