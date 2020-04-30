function locBsProjected = computeBsProjections(locBs,ii,blockingLanes,locCv)
% BS projections, starting from lane jj
jj = blockingLanes;
locBsProjected = (locBs' * (ii-jj) + locCv(1)* (jj-0.5))./(ii-0.5);
locBsProjected = locBsProjected.';
end

