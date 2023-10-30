% function result_array = findMin(A)
% 
% [m, n] = size(A);
% if 1 == m || 1 == n
%     [M, r] = min(A);
%     c = r;
% else
%     [M, I] = min(A);
%     [~, c] = min(M);
%     r = I(c);
%     M = A(r, c);
%     result_array = [M, r, c]
% end
% end

function return_value = find_min_in_row(arr)
 
   min_val = min(arr);
   min_index = find(arr == min_val, 1);
   return_value = [min_val, min_index];
end
