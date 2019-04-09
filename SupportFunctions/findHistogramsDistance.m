function [D1] = findHistogramsDistance(immagini)
%this function computes the histogram distances between all the RGB imput
%images

global showHistograms

n_samples = size(immagini,4);
n_bins=4;
edges=(0:(n_bins-1))/n_bins;
histograms=zeros(n_samples,n_bins*n_bins*n_bins);
for i=1:n_samples
    
    [~,r_bins] = histc(reshape(immagini(:,:,1,i),1,[]),edges); r_bins = r_bins + 1;
    [~,g_bins] = histc(reshape(immagini(:,:,2,i),1,[]),edges); g_bins = g_bins + 1;
    [~,b_bins] = histc(reshape(immagini(:,:,3,i),1,[]),edges); b_bins = b_bins + 1;
    
    histogram=zeros(n_bins,n_bins,n_bins);
    for j=1:numel(r_bins)
        histogram(r_bins(j),g_bins(j),b_bins(j)) = histogram(r_bins(j),g_bins(j),...
            b_bins(j)) + 1;
    end
    histograms(i,:) = reshape(histogram,1,[]) / sum(histogram(:)); % normalize,
    ...better for all probabilistic methods
end


dist_func=@chi_square_statistics;
D1=pdist2(histograms,histograms,dist_func);


plot_col = ceil(size(immagini,4)./2);

if showHistograms
    figure
    for i = 1 : size(immagini,4)
        subplot(2,plot_col,i)
        imhist(immagini(:,:,:,i))
    end
end

end

