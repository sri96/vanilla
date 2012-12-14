__author__ = 'Adhithya Rajasekaran,Renuka Rajasekaran,Sri Madhavi Rajasekaran'

import math

def start_compile(input_path_to_filtercoffee_file):

    print("Welcome to Hippo Filter Coffee Compiler.This compiler is a successor to the Octave Filter Coffee Compiler Mockup.")

    line_by_line_file = readFileLineByLine(input_path_to_filtercoffee_file)

    line_by_line_file = resolveComments(line_by_line_file)

    line_by_line_file = resolveVariables(line_by_line_file)

    line_by_line_file = resolveFormattedTextBlocks(line_by_line_file)

    line_by_line_file = resolveInlineCalculations(line_by_line_file)

    line_by_line_file = resolveInlineFormatting(line_by_line_file)

    printList(line_by_line_file)


def readFileLineByLine(input_path):

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close()

    return file_line_by_line

def printList(input_list):

    length_of_list = len(input_list)

    for x in range(0,length_of_list):

        current_item = input_list[x]

        print(current_item)

def resolveComments(input_file_contents):

    length_of_file_contents = len(input_file_contents)

    for x in range (0,length_of_file_contents):

        current_row = input_file_contents[x]

        multiline_comment_finder = current_row.find("%{")

        if multiline_comment_finder != -1:

            multiline_comment_end_finder = current_row.find("}%")

            if multiline_comment_end_finder != -1:

                input_file_contents[x] = input_file_contents[x].replace("%{","%")

                input_file_contents[x] = input_file_contents[x].replace("}%","")

            else:

                input_file_contents[x] = input_file_contents[x].replace("%{","%")

                current_index = x

                while multiline_comment_end_finder == -1:

                    current_index = current_index + 1

                    next_row = input_file_contents[current_index]

                    multiline_comment_end_finder = next_row.find("}%")

                    if multiline_comment_end_finder == -1:

                        input_file_contents[current_index] = "%" + input_file_contents[current_index]

                input_file_contents[current_index] = "%"+input_file_contents[current_index]

                input_file_contents[current_index] = input_file_contents[current_index].replace("}%","")

    return input_file_contents

def resolveVariables(input_file_contents):

    variable_names,variable_values,preamble = retrieveVariables(input_file_contents)

    end_of_preamble = 0

    if "\\begin{document}\n" in input_file_contents:

        end_of_preamble = input_file_contents.index("\\begin{document}\n")

    document_body = input_file_contents[end_of_preamble:] #document_body is all the contents of the file excluding preamble

    document_body_as_string = "".join(document_body)

    length_of_variable_names = len(variable_names)

    for x in range(0,length_of_variable_names):

        current_variable = variable_names[x].strip()

        document_body_as_string = document_body_as_string.replace(current_variable,variable_values[x].strip())

    file_id = open("C:\\Users\\Amma\\Desktop\\temp.filtercoffee","w")

    preamble_as_string = "".join(preamble)

    file_id.write(preamble_as_string + document_body_as_string)

    file_id.close()

    line_by_line_contents = readFileLineByLine("C:\\Users\\Amma\\Desktop\\temp.filtercoffee")

    return line_by_line_contents


def retrieveVariables(input_file_contents):

    end_of_preamble = 0

    if "\\begin{document}\n" in input_file_contents:

        end_of_preamble = input_file_contents.index("\\begin{document}\n")

    preamble = input_file_contents[0:end_of_preamble]

    modified_preamble = preamble[:]

    length_of_preamble = len(preamble)

    variable_list = []

    for x in range (0,length_of_preamble):

        current_row = preamble[x]

        inline_comment_finder = current_row.find("%")

        if inline_comment_finder == -1:

            text_block_finder = current_row.find("#")

            if text_block_finder == -1:

                if current_row.find("@") != -1:

                    modified_preamble.remove(current_row)

                    variable_list.append(current_row)

        else:

            operating_string = current_row[0:inline_comment_finder]

            text_block_finder = operating_string.find("#")

            if text_block_finder == -1:

                if current_row.find("@") != -1:

                    modified_preamble.remove(current_row)

                    variable_list.append(operating_string.strip())


    length_of_variable_list = len(variable_list)

    variable_names = []

    variable_values = []

    for y in range(0,length_of_variable_list):

        current_row = variable_list[y]

        variable_name_and_value = current_row.split("=")

        variable_name_and_value[1] = variable_name_and_value[1].strip()

        variable_names.append(variable_name_and_value[0])

        variable_values.append(variable_name_and_value[1])

    return variable_names,variable_values,modified_preamble

def resolveFormattedTextBlocks(input_file_contents):

    def extract_parameters(input_string):

        step_1 = input_string.split("]")

        step_2 = step_1[0].split("[")

        step_3 = step_2[1].split(",")

        return step_3

    def modify_code_block(parameter_map,input_string,code_block_parameters):

        for x in range(0,len(parameter_map)):

            input_string = input_string.replace(code_block_parameters[x],parameter_map[code_block_parameters[x]])

        return input_string



    code_block_names,code_block_values,preamble = retrieveFormattedTextBlocks(input_file_contents)

    end_of_preamble = 0

    if "\\begin{document}\n" in input_file_contents:

        end_of_preamble = input_file_contents.index("\\begin{document}\n")

    document_body = input_file_contents[end_of_preamble:] #document_body is all the contents of the file excluding preamble

    document_body_as_string = "".join(document_body)

    modified_document_body_as_string = document_body_as_string[:]

    length_of_code_block_names = len(code_block_names)

    for x in range(0,length_of_code_block_names):

        current_code_block_name = code_block_names[x]

        current_code_block_value = code_block_values[x]

        current_code_block_value = current_code_block_value[1:-1]

        code_block_parameters = extract_parameters(current_code_block_name)

        code_block_identifier = current_code_block_name.split("[")

        code_block_identifier_locations = find_all_matching_indices(document_body_as_string,code_block_identifier[0])

        for y in range(0,len(code_block_identifier_locations)):

            current_location = code_block_identifier_locations[y]

            working_string = document_body_as_string[current_location:]

            code_block_end_finder = working_string.find("]")

            code_block_usage = working_string[:code_block_end_finder+1]

            parameters_used = extract_parameters(code_block_usage)

            if len(code_block_parameters) == len(parameters_used):

                parameter_map = dict(zip(code_block_parameters,parameters_used))

                modified_code_value = current_code_block_value[:]

                modified_code_value = modify_code_block(parameter_map,modified_code_value,code_block_parameters)

                modified_document_body_as_string = modified_document_body_as_string.replace(code_block_usage,modified_code_value)


    file_id = open("C:\\Users\\Amma\\Desktop\\temp.filtercoffee","w")

    preamble_as_string = "".join(preamble)

    file_id.write(preamble_as_string + modified_document_body_as_string)

    file_id.close()

    line_by_line_contents = readFileLineByLine("C:\\Users\\Amma\\Desktop\\temp.filtercoffee")

    return line_by_line_contents


def retrieveFormattedTextBlocks(input_file_contents):

    end_of_preamble = 0

    if "\\begin{document}\n" in input_file_contents:

        end_of_preamble = input_file_contents.index("\\begin{document}\n")

    preamble = input_file_contents[0:end_of_preamble]

    modified_preamble = preamble[:]

    length_of_preamble = len(preamble)

    text_code_blocks = []

    code_block_as_string = ""

    for x in range (0,length_of_preamble):

        current_row = preamble[x]

        inline_comment_finder = current_row.find("%")

        if inline_comment_finder == -1:

            if current_row.find("#") != -1:

                text_block_name_and_code = current_row.split("=")

                text_block_code_extraction = text_block_name_and_code[1].find("[")

                if text_block_code_extraction != -1:

                    text_block_code_end_finder = text_block_name_and_code[1].find("]")

                    if text_block_code_end_finder != -1:

                        modified_preamble.remove(current_row)

                    else:

                        modified_preamble.remove(current_row)

                        code_block = [current_row]

                        current_index = x+1

                        while text_block_code_end_finder == -1:

                            current_row = preamble[current_index]

                            inline_comment_finder = current_row.find("%")

                            if inline_comment_finder == -1:

                                text_block_code_end_finder = current_row.find("]")

                                if text_block_code_end_finder != -1:

                                    code_block.append(current_row)

                                    modified_preamble.remove(current_row)

                                    code_block_as_string = "".join(code_block)

                                    break

                                else:

                                    code_block.append(current_row)

                                    modified_preamble.remove(current_row)

                            else:

                                operating_string1 = current_row[0:inline_comment_finder]

                                text_block_code_end_finder = operating_string1.find("]")

                                if text_block_code_end_finder != -1:

                                    code_block.append(operating_string1)

                                    modified_preamble.remove(current_row)

                                    code_block_as_string = "".join(code_block)

                                    break

                                else:

                                    code_block.append(operating_string1)

                                    modified_preamble.remove(current_row)

                            current_index = current_index + 1

                        text_code_blocks.append(code_block_as_string)

        else:

            operating_string = current_row[0:inline_comment_finder]

            if operating_string.find("#") != -1:

                text_block_name_and_code = operating_string.split("=")

                text_block_code_extraction = text_block_name_and_code[1].find("[")

                if text_block_code_extraction != -1:

                    text_block_code_end_finder = text_block_name_and_code[1].find("]")

                    if text_block_code_end_finder != -1:

                        text_code_blocks.append(operating_string)

                        modified_preamble.remove(current_row)

    length_of_code_blocks = len(text_code_blocks)

    code_block_names = []

    code_block_values = []

    for x in range(0,length_of_code_blocks):

        current_code_block = text_code_blocks[x]

        code_block_name_and_value = current_code_block.split("=")

        code_block_names.append(code_block_name_and_value[0].strip())

        code_block_values.append(code_block_name_and_value[1].strip())

    return code_block_names,code_block_values,modified_preamble


def resolveInlineCalculations(input_file_contents):

    length_of_file_contents = len(input_file_contents)

    for x in range (0,length_of_file_contents):

        current_row = input_file_contents[x]

        operating_string = current_row

        inline_comment_finder = current_row.find("%")

        if inline_comment_finder == -1:

            inline_calculation_finder = find_all_matching_indices(current_row,"#[")

            length_of_inline_calculation_finder = len(inline_calculation_finder)

            if length_of_inline_calculation_finder > 0:

                inline_calculation_end_finder = find_all_matching_indices(current_row,"]")

                length_of_inline_calculation_end_finder = len(inline_calculation_end_finder)

                if length_of_inline_calculation_finder == length_of_inline_calculation_end_finder:

                    for y in range(0,length_of_inline_calculation_finder):

                        inline_calculation_string = extract_inline_calculations(operating_string,inline_calculation_finder[y],inline_calculation_end_finder[y])

                        replacement_string = perform_inline_calculations(inline_calculation_string)

                        current_row = current_row.replace(inline_calculation_string,str(replacement_string))

                        input_file_contents[x] = current_row

        else:
            
            commentless_string = current_row[0:inline_comment_finder-1]

            operating_string = commentless_string

            inline_calculation_finder = find_all_matching_indices(commentless_string,"#[")

            if not inline_calculation_finder:

                inline_calculation_end_finder = find_all_matching_indices(commentless_string,"]")

                length_of_inline_calculation_finder = len(inline_calculation_finder)

                length_of_inline_calculation_end_finder = len(inline_calculation_end_finder)

                if length_of_inline_calculation_finder == length_of_inline_calculation_end_finder:

                    for y in range(0,length_of_inline_calculation_finder):

                        inline_calculation_string = extract_inline_calculations(operating_string,inline_calculation_finder[y],inline_calculation_end_finder[y])

                        replacement_string = perform_inline_calculations(inline_calculation_string)

                        current_row = current_row.replace(inline_calculation_string,replacement_string)

                        input_file_contents[x] = current_row
                
                
    return input_file_contents

def extract_inline_calculations(input_string,start,end):

    output = input_string[start:end+1]

    return output


def perform_inline_calculations(calculation_string):

    available_calculations = ["+","-","*","/","!","^"]

    solution = 0

    for x in range(0,len(available_calculations)):

      correct_calculation_finder = calculation_string.find(available_calculations[x])

      if correct_calculation_finder != -1:

          calculation_string = calculation_string[2:-1]

          calculation_tokens = calculation_string.split(available_calculations[x])

          if len(calculation_tokens) == 2:

              first_number = float(calculation_tokens[0])

              if available_calculations[x] == '+':

                  second_number = float(calculation_tokens[1])

                  solution = first_number + second_number

                  solution = removeUnwantedZeros(solution)

              elif available_calculations[x] == '-':

                  second_number = float(calculation_tokens[1])

                  solution = first_number - second_number

                  solution = removeUnwantedZeros(solution)

              elif available_calculations[x] == '*':

                  second_number = float(calculation_tokens[1])

                  solution = first_number * second_number

                  solution = removeUnwantedZeros(solution)

              elif available_calculations[x] == '/':

                  second_number = float(calculation_tokens[1])

                  if second_number != 0:

                      solution = first_number/second_number

                      solution = removeUnwantedZeros(solution)

              elif available_calculations[x] == '!':

                  first_number = int(first_number)

                  solution = math.factorial(first_number)

                  solution = removeUnwantedZeros(solution)

              elif available_calculations[x] ==  '^':

                  second_number = float(calculation_tokens[1])

                  solution = first_number**second_number

                  solution = removeUnwantedZeros(solution)


    return solution

def removeUnwantedZeros(input_number):

    if input_number == int(input_number):

        return str(int(input_number))

    else:

        input_number_as_string = str(input_number)

        decimal_point_finder = input_number_as_string.find(".")

        after_decimal_point = input_number_as_string[decimal_point_finder+1:]

        if len(after_decimal_point) > 3:

            input_number = round(input_number,2)

            return str(input_number)

        else:

            return str(input_number)


def resolveInlineFormatting(input_file_contents):

    available_formatting = ["**","//","+*","+/"]

    formatting_map = {"**":"\\textbf{","//":"\\emph{","+*":"\\mathbf{","+/":"\\mathit{"}

    document_as_a_string = "".join(input_file_contents)

    for x in range(0,len(available_formatting)):

        current_formatting = available_formatting[x]

        location_of_current_formatting = find_all_matching_indices(document_as_a_string,current_formatting)

        length_of_location_of_current_formatting = len(location_of_current_formatting)

        if len(location_of_current_formatting)%2 == 0:

            for y in range(0,int(length_of_location_of_current_formatting/2)):

                document_as_a_string = document_as_a_string.replace(current_formatting,formatting_map[current_formatting],1)

                document_as_a_string = document_as_a_string.replace(current_formatting,"}",1)

    document_as_a_string = resolveLists(document_as_a_string)

    file_id = open("C:\\Users\\Amma\\Desktop\\temp.filtercoffee","w")

    file_id.write(document_as_a_string)

    file_id.close()

    line_by_line_contents = readFileLineByLine("C:\\Users\\Amma\\Desktop\\temp.filtercoffee")

    return line_by_line_contents


def resolveLists(input_string):

    modified_input_string = input_string[:]

    def extract_list(input_string,starting_location,ending_location):

        return input_string[starting_location:ending_location]

    def is_nested_list(input_string):

        tab_finder = input_string.find("\t")

        if tab_finder != -1:

            return True

        else:

            return False

    def is_integer(s):

        try:

            int(s)

            return True

        except ValueError:

            return False

    def is_ordered_list(input_string):

        input_string_as_list = input_string.split("\n")

        int_counter = 0

        for x in range(1,len(input_string_as_list)-1):

            current_row = input_string_as_list[x]

            if is_integer(current_row[0]):

                int_counter = int_counter + 1

        if int_counter == len(input_string_as_list)-2:

            return True

        else:

            return False

    def is_unordered_list(input_string):

        input_string_as_list = input_string.split("\n")

        acceptable_indicators = ["+ ","- ","* "]

        acceptable_indicator_counter = 0

        for x in range(1,len(input_string_as_list)-1):

            current_row = input_string_as_list[x]

            for y in range(0,len(acceptable_indicators)):

                acceptable_indicator_finder = current_row.find(acceptable_indicators[y])

                if acceptable_indicator_finder != -1:

                    acceptable_indicator_counter = acceptable_indicator_counter + 1

                    break

        if acceptable_indicator_counter == len(input_string_as_list)-2:

            return True

        else:

            return False



    def convert_to_latex_ordered_list(input_string):

        input_string = input_string.replace("#(list):","\\begin{enumerate}\n")

        input_string = input_string.replace("#(endlist)","\\end{enumerate}\n")

        input_string_as_list = input_string.split("\n")

        for x in range(1,len(input_string_as_list)-1):

            current_row = input_string_as_list[x]

            if current_row.find("%") == -1:

                dot_locator = current_row.find(".")

                if dot_locator == 1:

                    current_row = current_row.replace(current_row[:dot_locator+1],"\\item") + "\n"

                    input_string_as_list[x] = current_row

        input_string_as_list[0] = input_string_as_list[0] + "\n"

        input_string_as_list[-2] = input_string_as_list[-2] + "\n"

        output_string = "".join(input_string_as_list)

        return output_string


    def convert_to_latex_unordered_list(input_string):

        input_string = input_string.replace("#(list):","\\begin{itemize}")

        input_string = input_string.replace("#(endlist)","\\end{itemize}")

        input_string_as_list = input_string.split("\n")
        
        acceptable_identifiers = ["* ","+ ","- "]

        for x in range(1,len(input_string_as_list)-1):

            current_row = input_string_as_list[x]
            
            for y in range(0,len(acceptable_identifiers)):
                
                current_row = current_row.replace(acceptable_identifiers[y],"\\item ")

            input_string_as_list[x] = current_row + "\n"

        input_string_as_list[0] = input_string_as_list[0] + "\n"

        input_string_as_list[-2] = input_string_as_list[-2] + "\n"

        output_string = "".join(input_string_as_list)

        return output_string

    def convert_to_latex_nested_list(input_string):

        def is_ordered_list_item(input_string):

            modified_string = input_string.replace("\t","")

            if is_integer(modified_string[0]):

                return True

            else:

                return False

        def is_unordered_list_item(input_string):

            modified_string = input_string.replace("\t","")

            acceptable_identifiers = ["* ","+ ","- "]

            output = False

            for x in range(0,len(acceptable_identifiers)):

                acceptable_indicator_finder = modified_string.find(acceptable_identifiers[x])

                if acceptable_indicator_finder != -1:

                    output = True

            return output

        def convert_to_list_item(input_string):

            modified_string = ""

            if is_ordered_list_item(input_string):

                modified_string = input_string.replace("\t","")

                dot_locator = modified_string.find(".")

                if dot_locator == 1:

                    modified_string = modified_string.replace(modified_string[:dot_locator+1],"\\item ") + "\n"

            elif is_unordered_list_item(input_string):

                modified_string = input_string.replace("\t","")

                acceptable_identifiers = ["* ","+ ","- "]

                for x in range(0,len(acceptable_identifiers)):

                    acceptable_indicator_finder = modified_string.find(acceptable_identifiers[x])

                    if acceptable_indicator_finder != -1:

                        modified_string = modified_string.replace(acceptable_identifiers[y],"\\item") + "\n"

            else:

                modified_string = input_string

            return modified_string

        def find_list_elements_less_than_given_condition(input_condition,input_list):

            list_of_elements_less_than_condition = [i for i,v in enumerate(input_list) if v < input_condition]

            output_list = []

            for x in range(0,len(list_of_elements_less_than_condition)):

                output_list.append(input_list[list_of_elements_less_than_condition[x]])

            return output_list


        input_string_as_list = input_string.split("\n")

        tab_counters = []

        for x in range(1,len(input_string_as_list)-1):

            current_row = input_string_as_list[x]

            tab_counter = len(find_all_matching_indices(current_row,"\t"))

            tab_counters.append(tab_counter)

        unique_tabs = list(set(tab_counters))

        input_string_as_list = input_string_as_list[1:-1]

        tab_locations = []

        for z in range(0,len(unique_tabs)):

            current_tab = unique_tabs[z]

            current_tab_location = []

            index_iterator = (i for i,v in enumerate(tab_counters) if v == current_tab)

            first_location = next(index_iterator)

            current_tab_location.append(first_location)

            while first_location != None:

                try:

                    next_location = next(index_iterator)

                    current_tab_location.append(next_location)

                except StopIteration:

                    break

            tab_locations.append(current_tab_location)

        tab_locations[0] = tab_locations[0] + []

        modified_input_string_as_list = input_string_as_list[:]

        to_be_inserted_item_start = []

        to_be_inserted_item_end = []

        for x in range(1,len(tab_locations[0])+1):

            previous_location = tab_locations[x-1]

            current_location = tab_locations[x]

            for y in range(1,len(previous_location)):

                current_condition = previous_location[y]

                qualifying_elements = find_list_elements_less_than_given_condition(current_condition,current_location)

                if qualifying_elements:

                    item_insertion_location = [i for i,v in enumerate(modified_input_string_as_list) if v == input_string_as_list[qualifying_elements[0]]]

                    enditem_insertion_location = [i for i,v in enumerate(modified_input_string_as_list) if v == input_string_as_list[qualifying_elements[-1]]]

                    to_be_inserted_item_start.append(item_insertion_location[0])

                    to_be_inserted_item_end.append(enditem_insertion_location[0])

        to_be_inserted_item_start = list(set(to_be_inserted_item_start))

        to_be_inserted_item_end = list(set(to_be_inserted_item_end))

        modified_to_be_inserted_item_start = to_be_inserted_item_start[:]

        modified_to_be_inserted_item_end = to_be_inserted_item_end[:]

        def add_to_list(input_list,to_be_added):

            for x in range(0,len(input_list)):

                current_item = input_list[x] + to_be_added

                input_list[x] = current_item

            return input_list

        modified_to_be_inserted_item_end = add_to_list(modified_to_be_inserted_item_end,1+len(modified_to_be_inserted_item_start))

        modified_to_be_inserted_item_end.sort()

        for x in range(0,len(to_be_inserted_item_start)):

            current_insertion = modified_to_be_inserted_item_start[0]

            modified_to_be_inserted_item_start.pop(0)

            modified_input_string_as_list.insert(current_insertion,"\\begin{}")

            modified_to_be_inserted_item_start = add_to_list(modified_to_be_inserted_item_start,1)

        for x in range(0,len(to_be_inserted_item_start)):

            current_insertion = modified_to_be_inserted_item_end[0]

            modified_to_be_inserted_item_end.pop(0)

            modified_input_string_as_list.insert(current_insertion,"\\end{}")

            modified_to_be_inserted_item_end = add_to_list(modified_to_be_inserted_item_end,1)

        modified_input_string_as_list.insert(0,"\\begin{}")

        modified_input_string_as_list.append("\\end{}")

        while "\\begin{}" in modified_input_string_as_list:

            begin_index = modified_input_string_as_list.index("\\begin{}")

            if is_ordered_list_item(modified_input_string_as_list[begin_index+1]):

                modified_input_string_as_list[begin_index] = "\\begin{enumerate}\n"

            else:

                modified_input_string_as_list[begin_index] = "\\begin{itemize}\n"

        while "\\end{}" in modified_input_string_as_list:

            end_index = modified_input_string_as_list.index("\\end{}")

            if is_ordered_list_item(modified_input_string_as_list[end_index-1]):

                modified_input_string_as_list[end_index] = "\\end{enumerate}\n"

            else:

                modified_input_string_as_list[end_index] = "\\end{itemize}\n"

        for x in range(0,len(modified_input_string_as_list)):

            current_item = convert_to_list_item(modified_input_string_as_list[x])

            modified_input_string_as_list[x] = current_item

        return "".join(modified_input_string_as_list)


    list_starting_location = find_all_matching_indices(input_string,"#(list):")

    list_ending_location = find_all_matching_indices(input_string,"#(endlist)")

    if len(list_starting_location) == len(list_ending_location):

        for x in range(0,len(list_starting_location)):

            current_list = extract_list(input_string,list_starting_location[x],list_ending_location[x]+10)

            if not is_nested_list(current_list):

                if is_ordered_list(current_list):

                    converted_list = convert_to_latex_ordered_list(current_list)

                    modified_input_string = modified_input_string.replace(current_list,converted_list)

                elif is_unordered_list(current_list):

                    converted_list = convert_to_latex_unordered_list(current_list)

                    modified_input_string = modified_input_string.replace(current_list,converted_list)

            else:

                converted_list = convert_to_latex_nested_list(current_list)

                modified_input_string = modified_input_string.replace(current_list,converted_list)

    return modified_input_string


def find_all_matching_indices(input_string,pattern):

    matching_indices = []

    matching_index = input_string.find(pattern)

    while matching_index != -1:

        matching_indices.append(matching_index)

        matching_index = input_string.find(pattern,matching_index+1)


    return matching_indices



def isVariableDeclaration(input_string):

    output = False

    tokens = input_string.split("=")

    if len(tokens) == 2:

        test_string = tokens[0]

        test_string = test_string.strip()

        variable_finder = test_string.find("@")

        if variable_finder == 0:

            output = True

    return output

def resolvePreambleCommands(input_file_contents):

    available_commands = ['#document_type','#font_size','#orientation','#paper_size','#margin','#margins','#font_type','#columns','#watermark','#mode']

    preamble = []

    already_resolved_preamble_commands = []

    length_of_file_contents = len(input_file_contents)

    for x in range (0,length_of_file_contents):

        current_row = input_file_contents[x]

        inline_comment_finder = current_row.find("%")

        if inline_comment_finder == -1:

            preamble_command_finder = current_row.find("#")

            if preamble_command_finder == 0:

                is_real_preamble_command = current_row.split("=")

                if len(is_real_preamble_command) == 2:

                    if is_real_preamble_command[0].strip().lower() in available_commands:

                        if is_real_preamble_command[0].strip().lower() not in already_resolved_preamble_commands:

                            already_resolved_preamble_commands.append(is_real_preamble_command[0].strip().lower())

        else:

            commentless_string = current_row[0:inline_comment_finder-1]

            operating_string = commentless_string

            preamble_command_finder = operating_string.find("#")

            if preamble_command_finder == 0:

                is_real_preamble_command = operating_string.split("=")

                if len(is_real_preamble_command) == 2:

                    is_real_preamble_command[0] = is_real_preamble_command[0].strip()

                    value_to_be_checked = is_real_preamble_command[0]

                    if is_real_preamble_command[0].strip().lower() in available_commands:

                        if is_real_preamble_command[0].strip().lower() not in already_resolved_preamble_commands:

                            already_resolved_preamble_commands.append(is_real_preamble_command[0].strip().lower())

    for x in range(0,len(already_resolved_preamble_commands)):

        preamble = find_and_add_correct_preamble_packages(preamble,already_resolved_preamble_commands[x])

    return input_file_contents

def add_correct_preamble_options(preamble,input_command,stack_no):

    duplicate_of_preamble = preamble[:]

    if stack_no == 1:

        available_options = ["article","report","proc","minimal","books","slides","memoir","letter","beamer"]

def find_and_add_correct_preamble_packages(preamble,input_command):

    available_commands = ['#document_type','#font_size','#orientation','#paper_size','#margin','#margins','#font_type','#columns','#watermark','#mode']

    document_type_stack = [1,2]

    geometry_stack = [3,4,5,6]

    font_customization_stack = [7]

    column_stack = [8]

    watermark_stack = [9]

    def is_command_in_stack(input_command_index,stack):

        try:

            stack.index(input_command_index)

            return True

        except ValueError:

            return False

    def is_preamble_package_already_added(preamble,preamble_package):

        try:

            preamble.index(preamble_package)

            return True

        except ValueError:

            return False


    input_command_index = available_commands.index(input_command)

    if is_command_in_stack(input_command_index,document_type_stack):

        preamble_package = "\documentclass[]{}\n"

        if not is_preamble_package_already_added(preamble,preamble_package):

            preamble.append(preamble_package)

    elif is_command_in_stack(input_command_index,geometry_stack):

        preamble_package = "\\usepackage[]{geometry}\n"

        if not is_preamble_package_already_added(preamble,preamble_package):

            preamble.append(preamble_package)

    elif is_command_in_stack(input_command_index,font_customization_stack):

        preamble_package = "\\usepackage[]{kpfonts}\n"

        if not is_preamble_package_already_added(preamble,preamble_package):

            preamble.append(preamble_package)

    elif is_command_in_stack(input_command_index,column_stack):

        preamble_package = "\\usepackage[]{multicol}\n"

        if not is_preamble_package_already_added(preamble,preamble_package):

            preamble.append(preamble_package)

    elif is_command_in_stack(input_command_index,watermark_stack):

        preamble_package = "\\usepackage[]{draftwatermark}\n\n\SetWatermarkText{}\n\n\SetWatermarkScale{5}\n\n"

        if not is_preamble_package_already_added(preamble,preamble_package):

            preamble.append(preamble_package)


    return preamble



start_compile()