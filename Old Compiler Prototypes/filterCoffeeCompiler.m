function filterCoffeeCompiler(input_path)

tex_file_name = makeTexFile(input_path);

line_by_line_file = readFileLineByLine(input_path);

line_by_line_file = resolveComments(line_by_line_file);

line_by_line_file = resolveInlineCalculations(line_by_line_file);

[preamble,line_by_line_file] = resolvePreambleCommands(line_by_line_file);

if isempty(preamble)
    
    preamble = {'\\documentclass[12pt]{article}\n'; '\\usepackage[a4paper,margin = 1.0in]{geometry}\n';};
    
end

line_by_line_file = resolveInlineCalculationFormulas(line_by_line_file);

line_by_line_file_string = resolveIntextFormatting(line_by_line_file);

writeTexFile(line_by_line_file_string,preamble,tex_file_name);

fclose('all');

compileTex(tex_file_name);

fclose('all');


function printArray(input_cell_array)

size_of_input_array = size(input_cell_array);

for x = 1:size_of_input_array(1,1)
    
    input_cell_array{x}
    
end


function output = makeTexFile(input_path)

output_tex_file_name = fileNameExtractor(input_path);

output_tex_file_path = pathExtractor(input_path);

output_tex_file = [output_tex_file_path '\' output_tex_file_name '.tex'];

file_id = fopen(output_tex_file,'w');

fclose(file_id);

output = output_tex_file;


function output = readFileLineByLine(path_to_file)

%readFileLineByLine function reads any file and returns the contents of it
%as a cell array with each line of the function as cell.

file_id = fopen(path_to_file);

file_as_line_by_line_array = {};

individual_line = fgets(file_id);

file_as_line_by_line_array = [file_as_line_by_line_array ; individual_line];

while ischar(individual_line)
    
    individual_line = fgets(file_id);
    
    file_as_line_by_line_array = [file_as_line_by_line_array ;individual_line];
    
end

fclose(file_id);

file_as_line_by_line_array(end) = [];

end_of_file = file_as_line_by_line_array{end};

size_of_end_of_file = size(end_of_file);

while size_of_end_of_file(1,2) == 2
    
    file_as_line_by_line_array(end) = [];
    
    end_of_file = file_as_line_by_line_array{end};
    
    size_of_end_of_file = size(end_of_file);
    
end

output = file_as_line_by_line_array;

function output = resolveInlineCalculations(input_cell_array)

size_of_input_cell_array = size(input_cell_array);

for x = 1:size_of_input_cell_array(1,1)
    
    current_row = input_cell_array{x};
    
    if isComment(current_row) == 0
        
        length_change = 0;
        
        current_row = strtrim(current_row);
        
        current_row = regexprep(current_row,'\\n','');
        
        inline_comment_finder = strfind(current_row,'%');
        
        if isempty(inline_comment_finder)
            
            inline_calculation_finder = strfind(current_row,'#{');
            
            inline_calculation_end_finder = strfind(current_row,'}');
            
        else
            
            inline_calculation_finder = strfind(current_row(1:inline_comment_finder-1),'#{');
            
            inline_calculation_end_finder = strfind(current_row(1:inline_comment_finder-1),'}');
            
        end
        
        size_of_inline_calculation_finder = size(inline_calculation_finder);
        
        if isempty(inline_calculation_finder) == 0
            
            if size_of_inline_calculation_finder(1,2) == 1
                
                inline_calculation_answer = performInlineCalculation(current_row,inline_calculation_finder,inline_calculation_end_finder);
                
                input_cell_array{x} = replaceInlineCalculationWithAnswers(current_row,inline_calculation_finder,inline_calculation_end_finder,inline_calculation_answer);
                
            else
                
                for y = 1:size_of_inline_calculation_finder(1,2)
                    
                    inline_calculation_answer = performInlineCalculation(current_row,inline_calculation_finder(y),inline_calculation_end_finder(y));
                    
                    inline_calculation_string = current_row(inline_calculation_finder(y):inline_calculation_end_finder(y));
                    
                    input_cell_array{x} = strrep(input_cell_array{x},inline_calculation_string,inline_calculation_answer);
                    
                end
                
            end
            
        end
        
    end
    
end

output = input_cell_array;


function output = isComment(input_string)

input_string = strtrim(input_string);

full_line_comment_finder = strfind(input_string,'%');

if isempty(full_line_comment_finder) == 0
    
    if full_line_comment_finder == 1
        
        output = 1;
        
    else
        
        output = 0;
        
    end
    
else
    
    output = 0;
    
end


function output = performInlineCalculation(input_string,start_of_inline_calculation,end_of_inline_calculation)

inline_calculation_string = input_string(start_of_inline_calculation:end_of_inline_calculation);

output = findCorrectCalculation(inline_calculation_string);



function output = findCorrectCalculation(input_calculation_string)

available_calculations = ['+' '-' '*' '/' '^' '%' '!'];

[matching_calculation,IA,IB] = intersect(available_calculations,input_calculation_string);

input_calculation_string = input_calculation_string(3:end-1);

matching_calculation_index = find(available_calculations == matching_calculation);

if isempty(matching_calculation_index) == 0
    
    output = performSelectedCalculation(input_calculation_string,matching_calculation_index);
    
end



function output = performSelectedCalculation(input_string,selection)

if selection == 1
    
    [token,remain] = strtok(input_string,'+');
    
    first_number = str2double(token);
    
    [token,remain] = strtok(remain,'+');
    
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
    
    
    
end

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
    
end

%After we remove all the zeros, the following condition checks for presence
%of a decimal point in the string and removes it.

if str2double(input_as_string) == int32(str2double(input_as_string))
    
    output = input_as_string(1:end-1);
    
else
    
    output = input_as_string;
    
end


function output = resolveComments(input_cell_array)

size_of_input_cell_array = size(input_cell_array);

comment_start = {};

for x = 1:size_of_input_cell_array(1,1)
    
    current_row = input_cell_array{x};
    
    current_row = regexprep(current_row,'\\n','');
    
    comment_start_finder = strfind(current_row,'%{');
    
    if isempty(comment_start_finder) == 0
        
        comment_start = [comment_start x];
        
    end
    
end

output = filterCoffeeCommentsToLatexComments(input_cell_array,comment_start);

function output = filterCoffeeCommentsToLatexComments(input_cell_array,comment_start)

size_of_comment_start = size(comment_start);

for x = 1:size_of_comment_start(1,2)
    
    comment_end_finder = strfind(input_cell_array{comment_start{x}},'}%');
    
    if isempty(comment_end_finder)
        
        current_row_index = comment_start{x};
        
        while isempty(comment_end_finder)
            
            current_row_index = current_row_index + 1;
            
            comment_end_finder = strfind(input_cell_array{current_row_index},'}%');
            
        end
        
        commented_lines = input_cell_array(comment_start{x}:current_row_index);
        
        size_of_commented_lines = size(commented_lines);
        
        commented_lines{1} = strrep(commented_lines{1},'%{','%');
        
        commented_lines{end} = strrep(commented_lines{1},'}%','');
        
        if size_of_commented_lines(1,1) == 2
            
            commented_lines{end} = ['%' commented_lines{end}];
            
        else
            
            
            for y = 2:size_of_commented_lines(1,1)-1
                
                commented_lines{y} = ['%' commented_lines{y}];
                
            end
            
        end
        
        input_cell_array(comment_start{x}:current_row_index) = commented_lines;
        
    else
        
        input_cell_array{comment_start{x}} = strrep(input_cell_array{comment_start{x}},'%{','%');
        
        input_cell_array{comment_start{x}} = strrep(input_cell_array{comment_start{x}},'}%','');
        
    end
    
    
end

output = input_cell_array;

function output = fileNameExtractor(input_path)

%fileNameExtractor(input_path) extracts the name of the .filtercoffee file from
%the path.The process is straight forward.

filtercoffee_extension_removal = strfind(input_path,'.filtercoffee');%finding the .filtercoffee extension

remaining_string = input_path(1:filtercoffee_extension_removal-1);%removing the .m
%extension

forward_slash_finder = strfind(remaining_string,'\');%find all the forward
%slash in the remaining input path

output = input_path(forward_slash_finder(end)+1:filtercoffee_extension_removal-1);
%Extract the string from the last forward slash to start of the m
%extension. The obtained string will be the name of the function.


function output = pathExtractor(input_path)

%pathExtractor(input_path) is a reimplementation of fileNameExtractor
%function in which instead of returning the name of the file from path,
%this function just returns the remaining string after removing the
%file name and .filtercoffee extension.

filtercoffee_extension_removal = strfind(input_path,'.filtercoffee');

remaining_string = input_path(1:filtercoffee_extension_removal-1);

forward_slash_finder = strfind(remaining_string,'\');

output = input_path(1:forward_slash_finder(end)-1);


function [output,output2] = resolvePreambleCommands(input_cell_array)

available_commands = {'$document_type' '$font_size' '$orientation' '$paper_size' '$margin' '$margins' '$font_type' '$columns' '$watermark' '$mode'};

size_of_input_cell_array = size(input_cell_array);

preamble_stack = {};

added_preamble_packages = {};

resolved_preamble_commands = {};

output_cell_array = input_cell_array(1:end);

for x = 1:size_of_input_cell_array(1,1)
    
    current_row = input_cell_array{x};
    
    if isComment(current_row) == 0
        
        current_row = strtrim(current_row);
        
        current_row = regexprep(current_row,'\\n','');
        
        inline_comment_finder = strfind(current_row,'%');
        
        if isempty(inline_comment_finder)
            
            preamble_command_finder = strfind(current_row,'$');
            
            if isempty(preamble_command_finder) == 0
                
                if preamble_command_finder == 1
                    
                    [token,remain] = strtok(current_row,'=');
                    
                    if isempty(remain) == 0
                        
                        token = strtrim(token);
                        
                        if isPreambleCommandAlreadyResolved(token,resolved_preamble_commands) == 0
                            
                            resolved_preamble_commands = [resolved_preamble_commands token];
                            
                            [preamble_stack,added_preamble_packages] = findCorrectPreamblePackage(available_commands,token,preamble_stack,added_preamble_packages);
                            
                            preamble_stack = correctlyModifyPreamblePackageOptions(token,remain,preamble_stack,added_preamble_packages);
                            
                            to_be_removed = input_cell_array{x};
                            
                            [C,IA,IB] = intersect(output_cell_array,to_be_removed);
                            
                            output_cell_array(IA) = [];
                            
                            
                        end
                        
                        
                    end
                    
                end
                
            end
            
            
            
        else
            
            commentless_string = current_row(1:inline_comment_finder-1);
            
            preamble_command_finder = strfind(commentless_string,'$');
            
            if isempty(preamble_command_finder) == 0
                
                if preamble_command_finder == 1
                    
                    [token,remain] = strtok(commentless_string,'=');
                    
                    if isempty(remain) == 0
                        
                        token = strtrim(token);
                        
                        if isPreambleCommandAlreadyResolved(token,resolved_preamble_commands) == 0
                            
                            resolved_preamble_commands = [resolved_preamble_commands token];
                            
                            [preamble_stack,added_preamble_packages] = findCorrectPreamblePackage(available_commands,token,preamble_stack,added_preamble_packages);
                            
                            preamble_stack = correctlyModifyPreamblePackageOptions(token,remain,preamble_stack,added_preamble_packages);
                            
                            to_be_removed = input_cell_array{x};
                            
                            [C,IA,IB] = intersect(output_cell_array,to_be_removed);
                            
                            output_cell_array(IA) = [];
                            
                        end
                        
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    
end

output = preamble_stack;

output2 = output_cell_array;

function [output,output1] = findCorrectPreamblePackage(available_commands,input_preamble_command,preamble_stack,added_preamble_packages)

input_preamble_command = lower(input_preamble_command);

index_of_preamble_command = find(ismember(available_commands,input_preamble_command) == 1);

stack_1 = 1:2;

stack_2 = 3:6;

stack_3 = 7;

stack_4 = 8;

stack_5 = 9;


if isNumberInRange(index_of_preamble_command,stack_1)
    
    preamble_package = '\\documentclass[]{}\n';
    
    if isPreamblePackageAlreadyAdded(added_preamble_packages,preamble_package) == 0
        
        preamble_stack = [preamble_stack; preamble_package];
        
        added_preamble_packages = [added_preamble_packages; preamble_package];
        
    end
    
elseif isNumberInRange(index_of_preamble_command,stack_2)
    
    preamble_package = '\\usepackage[]{geometry}\n';
    
    if isPreamblePackageAlreadyAdded(added_preamble_packages,preamble_package) == 0
        
        preamble_stack = [preamble_stack; preamble_package];
        
        added_preamble_packages = [added_preamble_packages; preamble_package];
        
    end
    
elseif isNumberInRange(index_of_preamble_command,stack_3)
    
    preamble_package = '\\usepackage[]{kpfonts}\n';
    
    if isPreamblePackageAlreadyAdded(added_preamble_packages,preamble_package) == 0
        
        preamble_stack = [preamble_stack; preamble_package];
        
        added_preamble_packages = [added_preamble_packages; preamble_package];
        
    end
    
elseif isNumberInRange(index_of_preamble_command,stack_4)
    
    preamble_package = '\\usepackage[]{multicol}\n';
    
    if isPreamblePackageAlreadyAdded(added_preamble_packages,preamble_package) == 0
        
        preamble_stack = [preamble_stack; preamble_package];
        
        added_preamble_packages = [added_preamble_packages; preamble_package];
        
    end
    
elseif isNumberInRange(index_of_preamble_command,stack_5)
    
    preamble_package = '\\usepackage[]{draftwatermark}\n\\SetWatermarkText{}\n\SetWatermarkScale{5}\n';
    
    if isPreamblePackageAlreadyAdded(added_preamble_packages,preamble_package) == 0
        
        preamble_stack = [preamble_stack; preamble_package];
        
        added_preamble_packages = [added_preamble_packages; preamble_package];
        
    end
    
    
end

output = preamble_stack;

output1 = added_preamble_packages;

function output = isPreambleCommandAlreadyResolved(preamble_command,resolved_commands)

index_of_preamble_command = find(ismember(resolved_commands,preamble_command) == 1);

if isempty(index_of_preamble_command)
    
    output = 0;
    
else
    
    output = 1;
    
end

function output = isPreamblePackageAlreadyAdded(preamble_stack,package_name)

index_of_package_in_stack = find(ismember(preamble_stack,package_name) == 1);

if isempty(index_of_package_in_stack)
    
    output = 0;
    
else
    
    output = 1;
    
end

function output = isNumberInRange(number,range)

index = find(range == number);

output = 1;

if isempty(index)
    
    output = 0;
    
end

function output = correctlyModifyPreamblePackageOptions(preamble_command,preamble_option,preamble_stack,added_preamble_packages)

available_commands = {'$document_type' '$font_size' '$orientation' '$paper_size' '$margin' '$margins' '$font_type' '$columns' '$watermark' '$mode'};

input_preamble_command = lower(preamble_command);

input_preamble_option = lower(preamble_option);

[input_preamble_option,rem] = strtok(input_preamble_option,'=');

index_of_preamble_command = find(ismember(available_commands,preamble_command) == 1);

stack_1 = 1:2;

stack_2 = 3:6;

stack_3 = 7;

stack_4 = 8;

stack_5 = 9;

if isNumberInRange(index_of_preamble_command,stack_1)
    
    index_of_preamble_package = find(ismember(added_preamble_packages,'\\documentclass[]{}\n') == 1);
    
    if strcmpi(added_preamble_packages{index_of_preamble_package},'\\documentclass[]{}\n')
        
        if index_of_preamble_command == 2
            
            if strcmpi(preamble_stack{index_of_preamble_package},'\\documentclass[]{}\n')
                
                preamble_stack{index_of_preamble_package} = '\\documentclass[]{article}\n';
                
            end
            
        end
        
        if index_of_preamble_command == 1
            
            available_options = {'article' 'report' 'letter' 'book' 'proc' 'slides' };
            
            index_of_preamble_option = find(ismember(available_options,strtrim(input_preamble_option)) == 1);
            
            if isempty(index_of_preamble_option) == 0
                
                to_be_modified = preamble_stack{index_of_preamble_package};
                
                [token,remain] = strtok(to_be_modified,'}');
                
                preamble_stack{index_of_preamble_package} = [token available_options{index_of_preamble_option} remain];
                
            end
            
        elseif index_of_preamble_command == 2
            
            available_options = {'11pt' '12pt'};
            
            index_of_preamble_option = find(ismember(available_options,strtrim(input_preamble_option)) == 1);
            
            if isempty(index_of_preamble_option) == 0
                
                to_be_modified = preamble_stack{index_of_preamble_package};
                
                [token,remain] = strtok(to_be_modified,']');
                
                preamble_stack{index_of_preamble_package} = [token available_options{index_of_preamble_option} remain];
                
            end
            
        end
        
    end
    
elseif isNumberInRange(index_of_preamble_command,stack_2)
    
    index_of_preamble_package = find(ismember(added_preamble_packages,'\\usepackage[]{geometry}\n') == 1);
    
    if strcmpi(added_preamble_packages{index_of_preamble_package},'\\usepackage[]{geometry}\n')
        
        if index_of_preamble_command == 3
            
            available_options = {'portrait' 'landscape'};
            
            index_of_preamble_option = find(ismember(available_options,strtrim(input_preamble_option)) == 1);
            
            if isempty(index_of_preamble_option) == 0
                
                to_be_modified = preamble_stack{index_of_preamble_package};
                
                [token,remain] = strtok(to_be_modified,']');
                
                preamble_stack{index_of_preamble_package} = [token available_options{index_of_preamble_option} ',' remain];
                
            end
            
        end
        
        if index_of_preamble_command == 4
            
            available_options = {'a0' 'a1' 'a2' 'a3' 'a4' 'a5' 'a6' 'b0' 'b1' 'b2' 'b3' 'b4' 'b5' 'b6' 'c0' 'c1' 'c2' 'c3' 'c4' 'c5' 'c6' 'b0j' 'b1j' 'b2j' 'b3j' 'b4j' 'b5j' 'b6j' 'ansia' 'ansib' 'ansic' 'ansid' 'ansie' 'ansie' ...
                'legal' 'executive' 'legal'};
            
            index_of_preamble_option = find(ismember(available_options,strtrim(input_preamble_option)) == 1);
            
            if isempty(index_of_preamble_option) == 0
                
                to_be_modified = preamble_stack{index_of_preamble_package};
                
                [token,remain] = strtok(to_be_modified,']');
                
                preamble_stack{index_of_preamble_package} = [token available_options{index_of_preamble_option} 'paper,' remain];
                
            end
            
        end
        
        if index_of_preamble_command == 5
            
            available_options = {'portrait' 'landscape'};
            
            index_of_preamble_option = find(ismember(available_options,strtrim(input_preamble_option)) == 1);
            
            if isempty(index_of_preamble_option) == 0
                
                to_be_modified = preamble_stack{index_of_preamble_package};
                
                [token,remain] = strtok(to_be_modified,']');
                
                preamble_stack{index_of_preamble_package} = [token available_options{index_of_preamble_option} ',' remain];
                
            end
            
        end
        
    end
    
elseif isNumberInRange(index_of_preamble_command,stack_5)
    
    index_of_preamble_package = find(ismember(added_preamble_packages,'\\usepackage[]{draftwatermark}\n\\SetWatermarkText{}\n\SetWatermarkScale{5}\n') == 1);
    
    if strcmpi(added_preamble_packages{index_of_preamble_package},'\\usepackage[]{draftwatermark}\n\\SetWatermarkText{}\n\SetWatermarkScale{5}\n')
        
        if index_of_preamble_command == 9
            
            to_be_modified = preamble_stack{index_of_preamble_package};
            
            index_of_watermark_text = strfind(to_be_modified,'Text{');
            
            if index_of_watermark_text == 47
                
                preamble_stack{index_of_preamble_package} = [to_be_modified(1:51) strtrim(input_preamble_option) to_be_modified(52:end)];
                
            end
            
        end
        
    end
    
end

output = preamble_stack;

function output = resolveInlineCalculationFormulas(input_cell_array)

available_formulas = {'$sqrt' '$cbrt' '$nthrt'};

size_of_input_cell_array = size(input_cell_array);

for x = 1:size_of_input_cell_array(1,1)
    
    current_row = input_cell_array{x};
    
    if isComment(current_row) == 0
        
        current_row = strtrim(current_row);
        
        current_row = regexprep(current_row,'\\n','');
        
        inline_comment_finder = strfind(current_row,'%');
        
        if isempty(inline_comment_finder)
            
            inline_calculation_formula_finder = strfind(current_row,'$');
            
        else
            
            commentless_string = current_row(1:inline_comment_finder-1);
            
            current_row = commentless_string;
            
            inline_calculation_formula_finder = strfind(current_row,'$');
            
        end
        
        size_of_inline_calculation_formula_finder = size(inline_calculation_formula_finder);
        
        if isempty(inline_calculation_formula_finder) == 0
            
            if size_of_inline_calculation_formula_finder(1,2) == 1
                
                calculation_string = extractInlineCalculationFormulas(current_row,inline_calculation_formula_finder);
                
                calculation_string = lower(calculation_string);
                
                calculation_string_length = length(calculation_string);
                
                [token,remain] = strtok(calculation_string,'(');
                
                [C,matching_formula_index,IB] = intersect(available_formulas,token);
                
                answer_string = performInlineCalculationFormula(calculation_string,available_formulas{matching_formula_index});
                
                replacement_row = input_cell_array{x};
                
                replacement_row = strrep(input_cell_array{x},replacement_row(inline_calculation_formula_finder:inline_calculation_formula_finder+calculation_string_length),answer_string);
                
                input_cell_array{x} = replacement_row;
                
            else
                
                for y = 1:size_of_inline_calculation_formula_finder(1,2)
                    
                    calculation_string = extractInlineCalculationFormulas(current_row,inline_calculation_formula_finder(y));
                    
                    calculation_string = lower(calculation_string);
                    
                    calculation_string_length = length(calculation_string);
                    
                    [token,remain] = strtok(calculation_string,'(');
                    
                    [C,matching_formula_index,IB] = intersect(available_formulas,token);
                    
                    answer_string = performInlineCalculationFormula(calculation_string,available_formulas{matching_formula_index});
                    
                    replacement_row = input_cell_array{x};
                    
                    replacement_row = strrep(input_cell_array{x},current_row(inline_calculation_formula_finder(y):inline_calculation_formula_finder(y)+calculation_string_length-1),answer_string);
                    
                    input_cell_array{x} = replacement_row;
                    
                    
                end
                
                
            end
            
        end
        
        
        
    end
    
    
end





output = input_cell_array;

function output = extractInlineCalculationFormulas(input_string,formula_starting_location)

modified_input_string = input_string(formula_starting_location:end);

[token,remain] = strtok(modified_input_string,')');

token = [token ')'];

output = token;


function output = performInlineCalculationFormula(formula_string,matching_formula)

output = NaN;

if strcmpi(matching_formula,'$sqrt')
    
    [token,remain] = strtok(formula_string,'(');
    
    [token,remain] = strtok(remain,'(');
    
    [token,remain] = strtok(token,')');
    
    input_parameter = strsplit(token,',');
    
    input_parameter = str2double(input_parameter);
    
    size_of_input_parameter = size(input_parameter);
    
    if size_of_input_parameter(1,2) == 1
        
        if isnan(input_parameter(1)) == 0
            
            answer = sqrt(input_parameter(1));
            
            answer = removeZeros(answer);
            
            output = answer;
            
        end
        
    end
    
elseif strcmpi(matching_formula,'$cbrt')
    
    [token,remain] = strtok(formula_string,'(');
    
    [token,remain] = strtok(remain,'(');
    
    [token,remain] = strtok(token,')');
    
    input_parameter = strsplit(token,',');
    
    input_parameter = str2double(input_parameter);
    
    size_of_input_parameter = size(input_parameter);
    
    if size_of_input_parameter(1,2) == 1
        
        if isnan(input_parameter(1)) == 0
            
            answer = nthroot(input_parameter(1),3);
            
            answer = removeZeros(answer);
            
            output = answer;
            
        end
        
    end
    
elseif strcmpi(matching_formula,'$nthrt')
    
    [token,remain] = strtok(formula_string,'(');
    
    [token,remain] = strtok(remain,'(');
    
    [token,remain] = strtok(token,')');
    
    input_parameter = strsplit(token,',');
    
    input_parameter = str2double(input_parameter);
    
    size_of_input_parameter = size(input_parameter);
    
    if size_of_input_parameter(1,2) == 2
        
        if isnan(input_parameter(1)) == 0 && isnan(input_parameter(2)) == 0
            
            answer = nthroot(input_parameter(1),input_parameter(2));
            
            answer = removeZeros(answer);
            
            output = answer;
            
        end
        
    end
    
end

function output = strsplit(varargin)

%strsplit(varargin) is a very simple function which splits the string using
%a delimiter and outputs a cell array containing tokens of string which
%were split using the delimiter. It comes in two flavors. One is a space
%delimted strsplit function and the other is a character/string delimited strsplit
%function.It was inspired by Ruby's string split method for string class.

size_of_varargin = size(varargin);

output = {};

if size_of_varargin(1,2) == 1
    
    input_string = varargin{1};
    
    [token,remain] = strtok(input_string);
    
    output = [output token];
    
    while isempty(remain) == 0
        
        [token,remain] = strtok(remain);
        
        output = [output token];
        
    end
    
elseif size_of_varargin(1,2) == 2
    
    input_string = varargin{1};
    
    splitter_string = varargin{2};
    
    [token,remain] = strtok(input_string,splitter_string);
    
    output = [output token];
    
    while isempty(remain) == 0
        
        [token,remain] = strtok(remain,splitter_string);
        
        output = [output token];
        
    end
    
end

function output = resolveIntextFormatting(input_cell_array)

available_formattings = {'**' '//' };

regexp_formattings = {'\*\*' '\/\/'};

corresponding_latex_tag = {'\\\\textbf{','\\\\textit{'};

size_of_available_formattings = size(available_formattings);

size_of_input_cell_array = size(input_cell_array);

cell_array_as_string = '';

for x = 1:size_of_input_cell_array(1,1)
    
    current_row = input_cell_array{x};
    
    cell_array_as_string = [cell_array_as_string current_row];
    
end

cell_array_as_string = char(cell_array_as_string);

for y = 1:size_of_available_formattings(1,2)
    
    format = available_formattings{y};
    
    replacement_tag = corresponding_latex_tag{y};
    
    regexp_format = regexp_formattings{y};
    
    format_finder = strfind(cell_array_as_string,format);
    
    size_of_format_finder = size(format_finder);
    
    looping_construct = size_of_format_finder(1,2)/2;
    
    if mod(size_of_format_finder(1,2),2) == 0
        
        for z = 1:looping_construct
            
           cell_array_as_string = regexprep(cell_array_as_string,regexp_format,replacement_tag,'once');
           
           cell_array_as_string = regexprep(cell_array_as_string,regexp_format,'}','once');
           
        end 
        
    end 
       
end 

output = cell_array_as_string;

function output = cellArrayToString(input_cell_array)

cell_array_as_string = '';

size_of_input_cell_array = size(input_cell_array);

for x = 1:size_of_input_cell_array(1,1)
    
    current_row = input_cell_array{x};
    
    cell_array_as_string = [cell_array_as_string current_row];
    
end

output = cell_array_as_string;



function output = modifyToOutputTexFile(input_string)

input_string = ['\\begin{document}\n\n\n' input_string '\n\n\n\\end{document}'];

output = input_string;


function writeTexFile(input_string,preamble,tex_file_name)

preamble_string = cellArrayToString(preamble);

tex_body = modifyToOutputTexFile(input_string);

tex_body = strrep(tex_body,'%','%%');

file_id = fopen(tex_file_name,'w');

fprintf(file_id,preamble_string);

fprintf(file_id,tex_body);

fclose(file_id);

function output = pathExtractorTex(input_path)

%pathExtractor(input_path) is a reimplementation of fileNameExtractor
%function in which instead of returning the name of the file from path,
%this function just returns the remaining string after removing the
%file name and .tex extension.

filtercoffee_extension_removal = strfind(input_path,'.tex');

remaining_string = input_path(1:filtercoffee_extension_removal-1);

forward_slash_finder = strfind(remaining_string,'\');

output = input_path(1:forward_slash_finder(end)-1);

function output = fileNameExtractorTex(input_path)

%fileNameExtractor(input_path) extracts the name of the .filtercoffee file from
%the path.The process is straight forward.

filtercoffee_extension_removal = strfind(input_path,'.tex');%finding the .filtercoffee extension

remaining_string = input_path(1:filtercoffee_extension_removal-1);%removing the .m
%extension

forward_slash_finder = strfind(remaining_string,'\');%find all the forward
%slash in the remaining input path

output = input_path(forward_slash_finder(end)+1:filtercoffee_extension_removal-1);
%Extract the string from the last forward slash to start of the m
%extension. The obtained string will be the name of the function.



function compileTex(file_path)

cd_command = ['cd ' pathExtractorTex(file_path)];

system(cd_command);

command = ['pdflatex ' file_path];

system(command);

current_directory = pwd;

source = [current_directory '\' fileNameExtractorTex(file_path) '.pdf'];

delete([fileNameExtractorTex(file_path) '.aux'],[fileNameExtractorTex(file_path) '.log'],[fileNameExtractorTex(file_path) '.bib']);

movefile(source,pathExtractorTex(file_path),'f');








