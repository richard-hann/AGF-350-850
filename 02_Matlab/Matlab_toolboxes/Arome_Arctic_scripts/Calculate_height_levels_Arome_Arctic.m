
function [height,P] = Calculate_height_levels_Arome_Arctic(hybrid,ap,b,t0,PSFC,T)

            R = 287; % ideal gas constant
            g = 9.81; % acceleration of gravity


            PSFC = squeeze(PSFC);

            clear PN TN heightt P

            % Calculating pressure levels
            for  k=1:size(T,1)
                PN(k) = ap(k)+b(k).*PSFC;
            end

            % Adding surface data as the lowest level
            PN(end+1) = PSFC;
            TN = T;
            TN(end+1) = t0;
            % 
            heightt = zeros(length(u)+1,1);


        % Calculating height levels (in metres) based on the hypsometric equation and assuming a dry atmosphere
            for n = size(T,1):-1:1
                pd = PN(n+1)./PN(n);                                
                TM = mean([TN(n),TN(n+1)]);    
                heightt(n) = heightt(n+1)+R.*TM./g.*log(pd);      
            end


            height = heightt(1:end-1);
            P = PN(1:end-1);

