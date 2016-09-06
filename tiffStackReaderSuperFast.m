function tiffStack = tiffStackReaderSuperFast(FileTif)


InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
tiffStack=zeros(nImage,mImage,NumberImages);
FileID = tifflib('open',FileTif,'r');
rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);
 
for i=1:NumberImages
   tifflib('setDirectory',FileID,i-1);
   % Go through each strip of data.
   rps = min(rps,nImage);
   for r = 1:rps:nImage
      row_inds = r:min(nImage,r+rps-1);
      stripNum = tifflib('computeStrip',FileID,r);
      
      tmp = tifflib('readEncodedStrip',FileID,stripNum-1);
      tiffStack(row_inds,:,i) = tmp;

   end
end
tifflib('close',FileID);