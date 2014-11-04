function d = dijkstra_heap_m(am, source, goal)

am_3col = sparse_to_3col(am);
n = size(am, 1);
d = dijkstra_heap(am_3col', n, source, goal);
% the reason for the transpose in the call is that C indexes matrices
% by column, so for easier-to-understand C code I wanted to have
% each edge triple (start, end, weight) as a column rather than a row