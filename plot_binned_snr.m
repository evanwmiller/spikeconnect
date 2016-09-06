function plot_binned_snr(dff_vector , snr_vector , binrange)

colors = {'b','g','r','c','m','y','k'};
dff_vector(isnan(dff_vector)) = [];
snr_vector(isnan(snr_vector)) = [];
spaxes = {}; 
figure;
   
maxIdx = 1;
maxYlim = 0; 
for ii = 1 : numel(binrange) - 1
    tmp = snr_vector(dff_vector < binrange(ii+1) & dff_vector >= binrange(ii));
    br = -5 : 0.2 : 40;
    tmp_dist = histc(tmp , br);

    spaxes{ii} = subplot(1 , numel(binrange) - 1 , ii);

    bar(br , tmp_dist , colors{mod(ii,7) + 1});
    title([num2str(binrange(ii)) '-' num2str(binrange(ii+1))])
    yl = ylim;
    if yl(2) >maxYlim
        maxYlim = yl(2);
        maxIdx = ii;
    end
end


for jj = 1:numel(spaxes)
    set(spaxes{jj} , 'ylim' , [0 maxYlim]);
    set(spaxes{jj} , 'xlim' , [-5 40]);
end

linkaxes([spaxes{:}] , 'xy');
