function Psd = enforce_monotonicity1(Psd_accent)
   Psd = nan(size(Psd_accent));
   Psd(1) = Psd_accent(1);
   for i= 2:length(Psd_accent)
       Psd(i) = max(Psd(i-1),Psd_accent(i));
   end
end