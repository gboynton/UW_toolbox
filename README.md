# UW Toolbox 

This is a work in progress

Functions that are in reasonable shape are described in the read me. Use other stuff at your own peril.

Contains Matlab tools for vision/fmri/psychophysics resarch.  

misc

nansem: equivalent of nanstd, but calculated the sem

rmspaces: removes space in a string or cell array

translatingtime: utility for converting pre- post-natal ages across species

timeLeftBar: variant of waitbar that shows the predicted amount of time left (instead of the percent complete)

xls2struct: reads in a excel file and passes each column into a struct field
xls2structDemo




Backwards compatibility

nonanean - removed, use Matlab's nanmean instead

nonanstd - removed, use Matlab's nanstd instead

nonansem - renamed nansem, moved to misc folder and made compatible with Matlab's nanmean

NormalCDF - removed, replaced with normcdf and normcdfS2P
 
rmSpaces - renamed to rmspaces

Weibull - renamed to weibull



---

# Contributors

Creator: Geoffrey Boynton - @gboynton 

Ione Fine - @ionefine - ionefine@uw.edu

Kelly Chang - @kellychang4 - kchang4@uw.edu