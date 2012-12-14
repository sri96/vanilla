function filterCoffeeCompilerOctave(input_path)

makeTexFile(input_path);

line_by_line_file = readFileLineByLine(input_path);

line_by_line_file = resolveInlineCalculations(line_by_line_file);

printArray(line_by_line_file)



endfunction
function printArray(input_cell_array)

size_of_input_array = size(input_cell_array);

for x = 1:size_of_input_array(1,1)

    input_cell_array{x}

endfor


endfunction
function makeTexFile(input_path)

output_tex_file_name = fileNameExtractor(input_path);

output_tex_file_path = pathExtractor(input_path);

output_tex_file = [output_tex_file_path '\' output_tex_file_name '.tex'];

file_id = fopen(output_tex_file,'w');

fclose(file_id);


endfunction
function output = readFileLineByLine(path_to_file)

%readFileLineByLine function reads any file and returns the contents of it
%as a cell array with each line of the function as cell.

file_id = fopen(path_to_file);

file_as_line_by_line_array = {};

individual_line = fgets(file_id);

file_as_line_by_line_array = [{file_as_line_by_line_array} ; {individual_line}];

while ischar(individual_line)

    individual_line = fgets(file_id);
    file_as_line_by_line_array = [{file_as_line_by_line_array} ;{individual_line}];

endwhile

fclose(file_id);

file_as_line_by_line_array(end) = [];

end_of_file = file_as_line_by_line_array{end};

size_of_end_of_file = size(end_of_file);

while size_of_end_of_file(1,2) == 2

    file_as_line_by_line_array(end) = [];

    end_of_file = file_as_line_by_line_array{end};

    size_of_end_of_file = size(end_of_file);

endwhile

output = file_as_line_by_line_array;

endfunction
function output = resolveInlineCalculations(input_cell_array)

size_of_input_cell_array = size(input_cell_array);

for x = 1:size_of_input_cell_array(1,1)

    current_row = input_cell_array{x};

    if isFullLineComment(current_row) == 0

        current_row = strtrim(current_row);

        current_row = regexprep(current_row,'\\n','');

        inline_comment_finder = strfind(current_row,'%{');

        if isempty(inline_comment_finder)

            inline_calculation_finder = strfind(current_row,'#{');

        else

            inline_calculation_finder = strfind(current_row(1:inline_comment_finder-1),'#{');

        endif

        if isempty(inline_calculation_finder) == 0

            inline_calculation_answer = performInlineCalculation(current_row,inline_calculation_finder);

            input_cell_array{x} = replaceInlineCalculationWithAnswers(current_row,inline_calculation_finder,inline_calculation_answer);

        endif

    endif

endfor

output = input_cell_array;


endfunction
function output = isFullLineComment(input_string)

input_string = strtrim(input_string);

full_line_comment_finder = strfind(input_string,'%{');

if isempty(full_line_comment_finder) == 0

    if full_line_comment_finder == 1

        output = 1;

    else

        output = 0;

    endif

else

    output = 0;

endif



endfunction
function output = replaceInlineCalculationWithAnswers(input_string,start_of_inline_calculation,replacement_string)

extract_inline_calculation = input_string(start_of_inline_calculation:end);

end_of_inline_calculation = strfind(extract_inline_calculation,'}');

inline_calculation_string = input_string(start_of_inline_calculation:start_of_inline_calculation+end_of_inline_calculation-1);

output = strrep(input_string,inline_calculation_string,replacement_string);


endfunction
function output = performInlineCalculation(input_string,start_of_inline_calculation)

extract_inline_calculation = input_string(start_of_inline_calculation:end);

end_of_inline_calculation = strfind(extract_inline_calculation,'}');

inline_calculation_string = input_string(start_of_inline_calculation:start_of_inline_calculation+end_of_inline_calculation);

output = findCorrectCalculation(inline_calculation_string);



endfunction
function output = findCorrectCalculation(input_calculation_string)

available_brews = ['+' '-' '*' '/' '^' '%' '!'];

[token,remain] = strtok(input_calculation_string,'#{');

calculation_string = token(1:end-2);

calculation_string_as_integers = int32(calculation_string);

[C,IA,IB] = intersect(calculation_string_as_integers,int32(available_brews));

matching_brew = char(C);

index_matching_brew = find(available_brews == matching_brew);

output = performSelectedCalculation(calculation_string,index_matching_brew);



endfunction
function output = performSelectedCalculation(input_string,selection)

if selection == 1

    [token,remain] = strtok(input_string,'+')

    first_number = str2double(token);

    [token,remain] = strtok(remain,'+')

    second_number = str2double(token);

    output = removeZeros(first_number+second_number);

elseif selection == 2


    [token,remain] = strtok(input_string,'-');

    first_number = str2double(token);

    [token,remain] = strtok(remain,'-');

    second_number = str2double(token);

    output = removeZeros(first_number-second_number);


elseif selection == 3


    [token,remain] = strtok(input_string,'*');

    first_number = str2double(token);

    [token,remain] = strtok(remain,'*');

    second_number = str2double(token);

    output = removeZeros(first_number*second_number);


elseif selection == 4

    [token,remain] = strtok(input_string,'/');

    first_number = str2double(token);

    [token,remain] = strtok(remain,'/');

    second_number = str2double(token);

    output = removeZeros(first_number+second_number);


elseif selection == 5

    [token,remain] = strtok(input_string,'^');

    first_number = str2double(token);

    [token,remain] = strtok(remain,'^');

    second_number = str2double(token);

    output = removeZeros(first_number^second_number);


elseif selection == 6

    [token,remain] = strtok(input_string,'%');

    first_number = str2double(token);

    [token,remain] = strtok(remain,'%');

    second_number = str2double(token);

    output = removeZeros(mod(first_number,second_number));


elseif selection == 7

    [token,remain] = strtok(input_string,'!');

    factorial_number = str2double(token);

    output = removeZeros(factorial(factorial_number));



endif

endfunction
function output = removeZeros(input_number)

%removeZeros(A) removes all zeros after the decimal point from the entered
%number and will output a string with 'removed' zeros. For example 3.000
%will become '3' and 3.2500 will become '3.25'.
%
%This code is copyrighted to Adhithya Rajasekaran.This code is released
%under General Public License Version 3.
%
%
%
%     Copyright (C) 2012  <Adhithya Rajasekaran,Renuka Rajasekaran,Sri Madhavi Rajasekaran>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%
%



input_as_string = sprintf('%f',input_number); %The number which is a double is converted
%into a string.

last_character = input_as_string(end);%The last character of the string is a zero. So we
%keep removing the zeros using the following while loop.

while last_character == '0'

    input_as_string = input_as_string(1:end-1);

    last_character = input_as_string(end);

endwhile

%After we remove all the zeros, the following condition checks for presence
%of a decimal point in the string and removes it.

if str2double(input_as_string) == int32(str2double(input_as_string))

    output = input_as_string(1:end-1);

else

    output = input_as_string;

endif


endfunction
function output = resolveComments(input_cell_array)

size_of_input_cell_array = size(input_cell_array);

for x = 1:size_of_input_cell_array(1,1)

    current_row = input_cell_array{x}

endfor

endfunction
function output = fileNameExtractor(input_path)

%fileNameExtractor(input_path) extracts the name of the .filtercoffee file from
%the path.The process is straight forward.

m_extension_removal = strfind(input_path,'.filtercoffee');%finding the .filtercoffee extension

remaining_string = input_path(1:m_extension_removal-1);%removing the .m
%extension

forward_slash_finder = strfind(remaining_string,'\');%find all the forward
%slash in the remaining input path

output = input_path(forward_slash_finder(end)+1:m_extension_removal-1);
%Extract the string from the last forward slash to start of the m
%extension. The obtained string will be the name of the function.


endfunction
function output = pathExtractor(input_path)

%pathExtractor(input_path) is a reimplementation of fileNameExtractor
%function in which instead of returning the name of the file from path,
%this function just returns the remaining string after removing the
%file name and .filtercoffee extension.

m_extension_removal = strfind(input_path,'.filtercoffee');

remaining_string = input_path(1:m_extension_removal-1);

forward_slash_finder = strfind(remaining_string,'\');

output = input_path(1:forward_slash_finder(end)-1);

endfunction
