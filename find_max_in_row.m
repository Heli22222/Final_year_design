% a = [10,2,34,555,443.44,5,767,888, 0, 999999, 400; 10,2,34,555,443.44,5,767,888, 0, 99, 400]
% b = findMaxf(a)

% function result_array = find_Max(A)
% 
% [m, n] = size(A);
% if 1 == m || 1 == n
%     [M, r] = max(A);
%     c = r;
% else
%     [M, I] = max(A);
%     [~, c] = max(M);
%     r = I(c);
%     M = A(r, c);
% end
% 
% result_array = [M, r, c] %only return colum now, the index of array while row == 1
% end

function return_value = find_max_in_row(matrix, row_index)

%max_value = max(matrix(row_index,:));
    [max_value, max_col] = max(matrix(row_index,:));
    return_value = [max_value, max_col];
    %[~, max_row] = max(matrix(:, max_col));

end