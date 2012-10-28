#VAML - Vanilla Markup Language
#
#Vanilla Markup Language is a flexible markup language which brings the goodness of markdown,textile and php-markdown
#extra to latex and is completely interoperable with latex.This compiler is very barebones right now. A lot of work needs to be done.
#
#This compiler is a translation of the original hippo compiler written in Python. But a lot of algorithmic structure has been
#modified to give optimum performance.Some parts may be rewritten in the upcoming releases. The compiler written in Python is
#no longer maintained.
#
#Author: Adhithya Rajasekaran and Sri Madhavi Rajasekaran
#
#To know more about the features listed below, please read the documentation.
#
#The compiler implements the following features
# 1. Multiline Comments
# 2. Declaration of Constants
# 3. Declaration of Formatted Text Blocks
# 4. Inline Simple Calculations With Variables
# 5. Inline Formatting
# 6. Easy Lists
# 7. Verbatim Mode That Works for Both Latex and VAML
# 8. VAML Packs
# 9. VAML Formulas

def start_compile(input_vaml_file,preferred_directory) #This method starts the compilation process

  def read_file_line_by_line(input_path)

    #This method returns each line of the vaml file as a list

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  def print_list(input_list)

    #This method will print each line of the inputted list. This method is usually used to test and see whether other parts of
    #the compiler are working correctly

    length_of_list = input_list.length

    for x in 0...length_of_list

      current_item = input_list[x]

      print(current_item)

    end

  end

  def replace_fenced_code_block(input_file_contents,input_vaml_file)

    #Latex offers Verbatim mode through verbatim package to prevent code from execution.Fence code block extends the verbatim mode to include
    #VAML code also. Verbatim package is a part of our default pack so you don't have to manually import and use it.

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    def find_vaml_file_path(input_path)

      #This method is utilized to extract the path of the VAML file.

      extension_remover = input_path.split(".vaml")

      remaining_string = extension_remover[0].reverse

      path_finder = remaining_string.index("\\")

      remaining_string = remaining_string.reverse

      return remaining_string[0...remaining_string.length-path_finder]

    end

    input_file_as_string = input_file_contents.join

    locate_fenced_code_block = find_all_matching_indices(input_file_as_string,"###")

    fenced_code_block = []

    replacement_string = "@@(fenced_code_block)[]"

    if locate_fenced_code_block.length.modulo(2) == 0

      for x in 0...locate_fenced_code_block.length/2

        fenced_code_block << input_file_as_string[locate_fenced_code_block[x]..locate_fenced_code_block[x+1]+2]

        replacement_string = replacement_string.split("]")

        replacement_string = replacement_string[0] + "#{x+1}]\n"

        input_file_as_string = input_file_as_string.sub(fenced_code_block[x],replacement_string)

      end

    end

    temporary_file_path = find_vaml_file_path(input_vaml_file) + "temp.vaml"

    file_id = open(temporary_file_path, 'w')

    file_id.write(input_file_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path, fenced_code_block

  end

  def resolve_comments(input_file_contents,temporary_file_path)

    #Latex does offer support for multiline comments. But VAML makes the process easier. This method compiles
    #VAML multiline comments into several single line latex comments.Latex comments are still valid in VAML.

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    input_file_as_string = input_file_contents.join

    modified_input_string = input_file_as_string.dup

    location_of_multiline_comments_start = find_all_matching_indices(input_file_as_string,"%{")

    location_of_multiline_comments_end = find_all_matching_indices(input_file_as_string,"}%")

    if location_of_multiline_comments_start.length == location_of_multiline_comments_end.length

      for x in 0...location_of_multiline_comments_start.length

        multiline_comment = input_file_as_string[location_of_multiline_comments_start[x]..location_of_multiline_comments_end[x]+1]

        replacement_comment = multiline_comment.sub("%{","")

        replacement_comment = replacement_comment.sub("}%","")

        multiline_comment_split = replacement_comment.split("\n")

        for y in 0...multiline_comment_split.length

          multiline_comment_split[y] = "%" + multiline_comment_split[y]

        end

        replacement_comment = multiline_comment_split.join("\n")

        modified_input_string = modified_input_string.sub(multiline_comment,replacement_comment)


      end

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path

  end

  def resolve_constants(input_file_contents, temporary_file_path)

    #Latex does offer support for declaring constants. But VAML greatly simplifies the process of declaring those constants.
    #You can still use latex constants.

    #Note:VAML constants are not transformed into Latex constants. Constants stand for what they mean.They are immutable.
    #Pure mutable variables may be available in VAML in the future. Lexical Scoping of constants is similar to that in
    #programming languages. This would be imminent in the code block resolution method.

    def retrieve_constants(input_file_contents)

      #This method looks into the preamble of the document and picks up all the constant declarations. Then it splits and
      #produces an array of constant names and constant values.

      end_of_preamble = 0

      if input_file_contents.include?("\\begin{document}\n")

        end_of_preamble = input_file_contents.index("\\begin{document}\n")

      end

      preamble = input_file_contents[0...end_of_preamble]

      modified_preamble = preamble.dup

      length_of_preamble = preamble.length

      variable_list = []

      for x in 0...length_of_preamble

        current_row = preamble[x]

        if !current_row.include?("%")

          if !current_row.include?("#")

            if current_row.include?("@")

              if current_row.index("@") == 0

                if current_row.split("=").length() == 2

                  modified_preamble.delete(current_row)

                  variable_list << current_row.strip

                end

              end

            end

          end

        else

          inline_comment_finder = current_row.index("%")

          operating_string = current_row[0...inline_comment_finder]

          if !operating_string.include?("#")

            if operating_string.include?("@")

              if operating_string.index("@") == 0

                if operating_string.split("=").length() == 2

                  modified_preamble.delete(current_row)

                  variable_list << operating_string.strip

                end

              end

            end

          end

        end

      end

      variable_names = []

      variable_values = []

      for y in 0...variable_list.length

        current_row = variable_list[y]

        variable_name_and_value = current_row.split("=")

        variable_names << variable_name_and_value[0].strip

        variable_values << variable_name_and_value[1].strip


      end

      return variable_names, variable_values, modified_preamble

    end

    variable_names, variable_values, preamble = retrieve_constants(input_file_contents)

    end_of_preamble = 0

    if input_file_contents.include?("\\begin{document}\n")

      end_of_preamble = input_file_contents.index("\\begin{document}\n")

    end

    document_body = input_file_contents[end_of_preamble..-1].join

    for x in 0...variable_names.length

      current_variable = variable_names[x]

      document_body = document_body.gsub(current_variable, variable_values[x])

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(preamble.join+document_body)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path


  end

  def resolve_formatted_text_blocks(input_file_contents,temporary_file_path)

    #This method will resolve formatted text blocks. The idea of formatted code blocks was inspired by Lesscss' parametric mixins.

    #Latex doesn't offer support for formatted text blocks. So VAML provides support for it.

    def retrieve_formatted_text_blocks(input_file_contents)

      #This method will go through the preamble and will retrieve a list of declared formatted text blocks

      def remove_comments(input_string)

        #This method will remove comments from a string.This method is part of a large rewrite operation to reduce the clutter
        #in the code and also to increase performance

        if input_string.include?("%")

          output_string = input_string[0...input_string.index("%")]

        else

          output_string = input_string

        end

        return output_string

      end

      end_of_preamble = 0

      if input_file_contents.include?("\\begin{document}\n")

        end_of_preamble = input_file_contents.index("\\begin{document}\n")

      end

      preamble = input_file_contents[0...end_of_preamble]

      modified_preamble = preamble.dup

      length_of_preamble = preamble.length

      text_blocks_list = []

      for x in 0...preamble.length

        current_row = preamble[x]

        if current_row.include?("#")

          if current_row.include?("%")

            operating_string = current_row[0...current_row.index("%")]

            comment_string = current_row[current_row.index("%")..-1]

          else

            operating_string = current_row

            comment_string = ""

          end

          text_block_finder = operating_string.split("=")

          if text_block_finder.length > 1

            if text_block_finder[1].include?("[")

              if text_block_finder[1].include?("]")

                code_block = [operating_string]

                modified_preamble.delete(operating_string+comment_string)

                text_blocks_list << code_block.join("")

              else

                next_index = x

                code_block = []

                text_block_end_finder = text_block_finder[1].include?("]")

                while text_block_end_finder == false

                  code_block << preamble[next_index]

                  modified_preamble.delete(preamble[next_index])

                  next_index = next_index + 1

                  text_block_end_finder = preamble[next_index].include?("]")

                end

                code_block << remove_comments(preamble[next_index])

                modified_preamble.delete(preamble[next_index])

                text_blocks_list << code_block.join("")


              end

            end

          end

        end

      end

      code_block_names = []

      code_block_values = []

      for x in 0...text_blocks_list.length

        current_text_block = text_blocks_list[x]

        text_block_name_and_value = current_text_block.split("=")

        code_block_names << text_block_name_and_value[0].strip

        code_block_values << text_block_name_and_value[1].strip

      end

      return code_block_names,code_block_values,modified_preamble

    end

    def extract_parameters(names_with_params)

      code_block_names = []

      code_block_params = []

      for x in 0...names_with_params.length

        current_code_block_name = names_with_params[x]

        params_split = current_code_block_name.split("[")

        code_block_names << params_split[0]

        params_list = params_split[1]

        params_list = params_list[0...-1]

        code_block_params << params_list

      end

      return code_block_names,code_block_params

    end

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    block_names_params,code_block_values,preamble = retrieve_formatted_text_blocks(input_file_contents)

    code_block_names,code_block_params = extract_parameters(block_names_params)

    end_of_preamble = 0

    if input_file_contents.include?("\\begin{document}\n")

      end_of_preamble = input_file_contents.index("\\begin{document}\n")

    end

    document_body = input_file_contents[end_of_preamble..-1]

    document_body_as_string = document_body.join("")

    modified_document_as_string = document_body_as_string.dup

    for x in 0...code_block_names.length

      current_code_block_name = code_block_names[x]

      current_code_block_params = code_block_params[x]

      current_code_block_params = current_code_block_params.split(",")

      current_code_block_value = code_block_values[x]

      current_code_block_value = current_code_block_value[1...-1]

      location_of_code_block = find_all_matching_indices(document_body_as_string,current_code_block_name)

      for y in 0...location_of_code_block.length

        code_block_end_finder = document_body_as_string.index("]",location_of_code_block[y])

        text_block_string = document_body_as_string[location_of_code_block[y]..code_block_end_finder]

        param_split = text_block_string.split("[")

        text_block_params = param_split[1]

        text_block_params = text_block_params[0...-1]

        text_block_params = text_block_params.split(",")

        if text_block_params.length == current_code_block_params.length

          parameter_map = Hash[*current_code_block_params.zip(text_block_params).flatten]

          replacement_string = current_code_block_value

          for z in 0...parameter_map.length

             replacement_string = replacement_string.gsub(current_code_block_params[z],parameter_map[current_code_block_params[z]])

          end

          modified_document_as_string = modified_document_as_string.sub(text_block_string,replacement_string)

        end

      end

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(preamble.join+modified_document_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path

  end

  def resolve_formulas(input_file_contents,temporary_file_path)

    #VAML Formulas are easy way to achieve certain things which are very difficult to achieve in Latex. Writing matrices
    #is very difficult in latex. As time progresses, more formulas will be added to simplify latex typesetting.

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    def convert_to_matrix(input_list)

      #This method converts the input list to latex's bmatrix environment offered through amsmath package.

      start_string = "\\begin{bmatrix}"

      end_string = "\\end{bmatrix}"

      rows = []

      for x in 0...input_list.length

        current_row = input_list[x]

        current_row_string = current_row.split.join(" & ")

        rows << current_row_string


      end

      matrix = rows.join(" \\\\\\ ")

      matrix = start_string + matrix + end_string

      return matrix

    end

    def convert_to_determinant(input_list)

      #This method converts the input list to latex's vmatrix environment offered through amsmath package.

      start_string = "\\begin{vmatrix}"

      end_string = "\\end{vmatrix}"

      rows = []

      for x in 0...input_list.length

        current_row = input_list[x]

        current_row_string = current_row.split.join(" & ")

        rows << current_row_string


      end

      determinant = rows.join(" \\\\\\ ")

      determinant = start_string + determinant + end_string

      return determinant

    end

    available_formulas = ["$(matrix)","$(det)"]

    input_file_as_string = input_file_contents.join

    modified_input_string = input_file_as_string.dup

    for x in 0...available_formulas.length

      current_formula = available_formulas[x]

      location_of_current_formula = find_all_matching_indices(input_file_as_string,current_formula)

      for y in 0...location_of_current_formula.length

        replacement_string = ""

        extract_string = input_file_as_string[location_of_current_formula[y]..-1]

        current_formula_end = extract_string.index("]")

        formula_usage_string = extract_string[0..current_formula_end]

        formula_usage_string_split = formula_usage_string.split("[")

        formula_usage_string_split = formula_usage_string_split[1].split("]")

        formula_usage_string_split = formula_usage_string_split[0].split(";")

        if x == 0

          replacement_string = convert_to_matrix(formula_usage_string_split)

        elsif x == 1

          replacement_string = convert_to_determinant(formula_usage_string_split)

        end

        modified_input_string = modified_input_string.sub(formula_usage_string,replacement_string)

      end

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path

  end

  def resolve_inline_calculations(input_file_contents,temporary_file_path)

    #This method is used in converting inline calculations into answers. It uses ruby's eval method to achieve this.

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    for x in 0...input_file_contents.length

      current_row = input_file_contents[x]

      operating_row = current_row.dup

      comment_string = ""

      if current_row.include?("%")

        operating_row = current_row[0...current_row.index("%")]

        comment_string = current_row[current_row.index("%")...-1]

      end

      inline_calculation_start = find_all_matching_indices(operating_row,"#[")

      inline_calculation_end = find_all_matching_indices(operating_row,"]")

      if inline_calculation_start.length == inline_calculation_end.length

        for y in 0...inline_calculation_start.length

          inline_calculation_string = operating_row[inline_calculation_start[y]..inline_calculation_end[y]]

          inline_calc_ruby_string = inline_calculation_string.dup

          inline_calc_ruby_string = inline_calc_ruby_string[2...-1]

          inline_calc_ruby_string = inline_calc_ruby_string.sub("^","**").to_s()

          eval_binding = binding

          inline_calculation_answer = eval_binding.eval(inline_calc_ruby_string)

          inline_calculation_answer = inline_calculation_answer.to_s

          if inline_calculation_answer.include?(".")

            inline_calculation_answer = inline_calculation_answer.to_f.round(3).to_s

          end

          current_row = current_row.sub(inline_calculation_string,inline_calculation_answer)

        end

      end

      input_file_contents[x] = current_row

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(input_file_contents.join)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path

  end

  def resolve_ruby_scripting(input_file_contents,temporary_file_path)

    #There are two kinds of ruby scripts allowed inside a VAML document. One is using \ruby{} command and the other is
    #through #(rubycode)...#(endrubycode).Please utilize \ruby{} for very simple inline scripts and use #(rubycode) environment
    #for longer and complex scripts. Both of the scripts are evaluated using Ruby's eval method and are binded. In future
    #non-binded ruby scripting environments might be available. A detailed scripting guide will be available in the documentation.

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    input_file_as_string = input_file_contents.join

    def retrieve_ruby_environment(input_file_string)

      #This retrieves all the use cases of \ruby{} method.

      location_of_ruby_environment = find_all_matching_indices(input_file_string,"\\ruby{")

      for x in 0...location_of_ruby_environment.length

        current_location = location_of_ruby_environment[x]

        extract_string = input_file_string[current_location..-1]

        ruby_environment_end_location = extract_string.index("}")

        ruby_environment_string = input_file_string[current_location..ruby_environment_end_location]

        puts ruby_environment_string

      end


    end

    retrieve_ruby_environment(input_file_as_string)


  end

  def resolve_inline_formatting(input_file_contents,temporary_file_path)

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    document_as_string = input_file_contents.join

    available_formatting = ["**","//","+*","+/"]

    matching_formatting = {"**" => "\\textbf{","//" => "\\emph{" , "+*" => "\\mathbf{" , "+/" => "\\mathit{"}

    for x in 0...available_formatting.length

      current_formatting = available_formatting[x]

      location_of_current_formatting = find_all_matching_indices(document_as_string,current_formatting)

      if location_of_current_formatting.length.modulo(2) == 0

        for y in 0...((location_of_current_formatting.length)/2)

          document_as_string = document_as_string.sub(current_formatting,matching_formatting[current_formatting])

          document_as_string = document_as_string.sub(current_formatting,"}")

        end

      end

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(document_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path

  end

  def resolve_lists(input_file_contents,temporary_file_path)

    def extract_lists(input_file_contents)

      starting_locations = []

      ending_locations = []

      for x in 0...input_file_contents.length

        current_row = input_file_contents[x]

        if current_row.include?("#(list)")

          if current_row[0].eql?("#")

            starting_locations << x

          end

        elsif current_row.include?("#(endlist)")

          if current_row[0].eql?("#")

            ending_locations << x

          end

        end

      end

      vaml_lists =[]

      if starting_locations.length == ending_locations.length

        for y in 0...starting_locations.length

          current_starting_location = starting_locations[y]

          current_ending_location = ending_locations[y]

          current_list = input_file_contents[current_starting_location..current_ending_location]

          vaml_lists << current_list


        end

      end

      return vaml_lists

    end

    def is_ordered_list(input_list)

      output = false

      input_list_as_string = input_list.join

      unordered_list_delimiters = ["+ ","- ","* "]

      number_of_delimiters_found = 0

      if !input_list_as_string.include?("#(nlist)")

        for x in 0...unordered_list_delimiters.length

          current_delimiter = unordered_list_delimiters[x]

          if input_list_as_string.include?(current_delimiter)

            number_of_delimiters_found = number_of_delimiters_found + 1

          end

        end

        if number_of_delimiters_found == 0

          output = true

        end


      end

      return output

    end

    def is_unordered_list(input_list)

      output = false

      input_list_as_string = input_list.join

      no_of_ordered_list_elements = 0

      if !input_list_as_string.include?("#(nlist)")

        for x in 0...input_list.length

          current_row = input_list[x]

          if current_row[0].to_i.to_s == current_row[0]

            if current_row[1].eql?(".")

              no_of_ordered_list_elements = no_of_ordered_list_elements + 1

            end

          end

        end

        if no_of_ordered_list_elements == 0

          output = true

        end


      end

      return output

    end

    def is_nested_list(input_list)

      output = false

      input_list_as_string = input_list.join

      if input_list_as_string.include?("#(nlist)")

        output = true

      end

      return output

    end

    def convert_to_latex_ordered_list(input_list)

      for x in 0...input_list.length

        current_row = input_list[x]

        if current_row[0].to_i.to_s == current_row[0]

          if current_row[1].eql?(".")

            current_row[0..1] = "\\item"

          end

        end

        input_list[x] = current_row

      end

      input_list_as_string = input_list.join

      input_list_as_string = input_list_as_string.sub("#(list)","\\begin{enumerate}")

      input_list_as_string = input_list_as_string.sub("#(endlist)","\\end{enumerate}")

      return input_list_as_string

    end

    def convert_to_latex_unord_list(input_list)

      unordered_list_delimiters = ["+ ","- ","* "]

      for x in 0...input_list.length

        current_row = input_list[x]

        for y in unordered_list_delimiters

          current_delimiter = y

          if current_row.include?(current_delimiter)

            current_row = current_row.sub(current_delimiter,"\\item ")


          end

        end

        input_list[x] = current_row

      end

      input_list_as_string = input_list.join

      input_list_as_string = input_list_as_string.sub("#(list)","\\begin{itemize}")

      input_list_as_string = input_list_as_string.sub("#(endlist)","\\end{itemize}")

      return input_list_as_string

    end

    def convert_to_latex_nested_list(input_list)

      endnlist_locations = []

      for x in 0...input_list.length

        current_row = input_list[x]

        if current_row.include?("#(endnlist)")

          endnlist_locations << x

        end

      end

      modified_list = input_list.dup.join

      nlist_locations = []

      for y in endnlist_locations

        extracted_list = input_list[0..y]

        extracted_list = extracted_list.reverse

        for z in 0...extracted_list.length

          current_row = extracted_list[z]

          if current_row.include?("#(nlist)")

            nlist_locations << y-z

          end

        end

      end

      final_replacement_string = ""

      final_extracted_list = []

      nlist_locations = nlist_locations.uniq

      if endnlist_locations.length == nlist_locations.length

        replacement_string = ""

        for x in 0...endnlist_locations.length

          current_end_location = endnlist_locations[x]

          current_start_location = nlist_locations[x]

          extracted_list = input_list[current_start_location..current_end_location]

          extracted_list[0] = extracted_list[0].sub("#(nlist)","#(list)")

          extracted_list[-1] = extracted_list[-1].sub("#(endnlist)","#(endlist)")

          if x == 0

            if is_unordered_list(extracted_list)

              replacement_string = convert_to_latex_unord_list(extracted_list)

            elsif is_ordered_list(extracted_list)

              replacement_string = convert_to_latex_ordered_list(extracted_list)

            end

          else

            nlist_location = []

            endnlist_location = []

            for y in 0...extracted_list.length

              current_row = extracted_list[y]

              if current_row.include?("#(nlist)")

                nlist_location << y

              elsif current_row.include?("#(endnlist)")

                endnlist_location << y

              end

            end

            if nlist_location.length == endnlist_location.length

              if nlist_location.length > 1

                extracted_list[nlist_location[0]..endnlist_location[-1]] = replacement_string

              else

                extracted_list[nlist_location[0]..endnlist_location[0]] = replacement_string

              end

            end

            if is_unordered_list(extracted_list)

              replacement_string = convert_to_latex_unord_list(extracted_list)

            elsif is_ordered_list(extracted_list)

              replacement_string = convert_to_latex_ordered_list(extracted_list)

            end

          end

          final_replacement_string = replacement_string

        end

      end

      nlist_location = []

      endnlist_location = []

      for z in 0...input_list.length

        current_row = input_list[z]

        if current_row.include?("#(nlist)")

          nlist_location << z

        elsif current_row.include?("#(endnlist)")

          endnlist_location << z

        end

      end

      final_extracted_list = input_list.dup

      final_extracted_list[nlist_location[0]..endnlist_location[-1]] = final_replacement_string

      output_string = ""

      if is_unordered_list(final_extracted_list)

        output_string = convert_to_latex_unord_list(final_extracted_list)

      elsif is_ordered_list(final_extracted_list)

        output_string = convert_to_latex_ordered_list(final_extracted_list)

      end

      return output_string

    end

    all_lists = extract_lists(input_file_contents)

    input_file_as_string = input_file_contents.join

    for x in all_lists

      current_list = x

      if is_ordered_list(current_list)

        input_file_as_string = input_file_as_string.sub(current_list.join,convert_to_latex_ordered_list(current_list))

      elsif is_unordered_list(current_list)

        input_file_as_string = input_file_as_string.sub(current_list.join,convert_to_latex_unord_list(current_list))

      elsif is_nested_list(current_list)

        input_file_as_string = input_file_as_string.sub(current_list.join,convert_to_latex_nested_list(current_list))

      end

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(input_file_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path

  end

  def resolve_fenced_code_blocks(input_file_contents,temporary_file_path,fenced_code_blocks)

    fenced_code_block_string = "@@(fenced_code_block)[]"

    input_file_as_string = input_file_contents.join

    for x in 0...fenced_code_blocks.length

      fenced_code_block_string = fenced_code_block_string.split("]")

      fenced_code_block_string = fenced_code_block_string[0] + "#{x+1}]"

      replacement_string = fenced_code_blocks[x]

      replacement_string = replacement_string.sub("###","\\begin{verbatim}")

      replacement_string = replacement_string.sub("###","\\end{verbatim}")

      input_file_as_string = input_file_as_string.sub(fenced_code_block_string,replacement_string)

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(input_file_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path


  end

  def resolve_vaml_packs(input_file_contents,temporary_file,preference_directory)

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    default_vamlpack = [
        "\\usepackage{amsmath,amssymb,amsthm}\n\n",
        "\\usepackage[a4paper,margin = 1in]{geometry}\n\n",
        "\\usepackage{hyperref}\n\n",
        "\\usepackage{xcolor}\n\n",
        "\\usepackage{verbatim}\n\n",
        "\\usepackage{booktabs}\n\n",
        "\\usepackage{graphicx}\n\n",
        "\\usepackage{biblatex}\n\n",
        "\\usepackage{multicol}\n\n",
        "\\usepackage{cleveref}\n\n",
        "\\usepackage{siunitx}\n"]

    end_of_preamble = 0

    if input_file_contents.include?("\\begin{document}\n")

      end_of_preamble = input_file_contents.index("\\begin{document}\n")

    end

    preamble = input_file_contents[0...end_of_preamble]

    document_string = input_file_contents[end_of_preamble..-1].join

    preamble_string = preamble.join

    if !preamble_string.include?("$(importpack)") and !preamble_string.include?("\\usepackage")

      default_vamlpack_string = default_vamlpack.join

      documentclass_finder = preamble_string.index("\\documentclass")

      extract_string = preamble_string[documentclass_finder..-1]

      documentclass_end = extract_string.index("}")

      documentclass_string = extract_string[0..documentclass_end]

      replacement_string = documentclass_string + "\n\n" + default_vamlpack_string + "\n\n"

      preamble_string = preamble_string.sub(documentclass_string,replacement_string)

    elsif preamble_string.include?("$(importpack)")

      importpack_locations = find_all_matching_indices(preamble_string,"$(importpack)")

      for x in 0...importpack_locations.length

        current_location = importpack_locations[x]

        extract_string = preamble_string[current_location..-1]

        importpack_end = extract_string.index("]")

        importpack_string = extract_string[0..importpack_end]

        importpack_string_split = importpack_string.split("[")

        importpack_string_split = importpack_string_split[1].split("]")

        importpack_name = importpack_string_split[0]

        if !importpack_name.include?("\\")

          importpack_path = preference_directory + importpack_name + ".vamlpack"

        else

          importpack_path = importpack_name

        end

        vamlpack_file = read_file_line_by_line(importpack_path).join

        preamble_string = preamble_string.sub(importpack_string,vamlpack_file)


      end

    end

    file_id = open(temporary_file, 'w')

    file_id.write(preamble_string + document_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file)

    return line_by_line_contents, temporary_file


  end

  def write_latex_file(input_file_contents,temporary_file,input_vaml_file)

    input_file_as_string = input_file_contents.join

    File.delete(temporary_file)

    output_latex_file_path = input_vaml_file.split(".vaml")

    output_latex_file_path = output_latex_file_path[0] + ".tex"

    file_id = open(output_latex_file_path, 'w')

    file_id.write(input_file_as_string)

    file_id.close()

  end

  line_by_line_file = read_file_line_by_line(input_vaml_file)

  line_by_line_file, temp_file, fenced_code_blocks = replace_fenced_code_block(line_by_line_file,input_vaml_file)

  line_by_line_file, temp_file = resolve_comments(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_constants(line_by_line_file, temp_file)

  line_by_line_file, temp_file = resolve_formatted_text_blocks(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_formulas(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_inline_calculations(line_by_line_file,temp_file)

  #resolve_ruby_scripting(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_inline_formatting(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_lists(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_fenced_code_blocks(line_by_line_file,temp_file,fenced_code_blocks)

  line_by_line_file, temp_file = resolve_vaml_packs(line_by_line_file,temp_file,preferred_directory)

  write_latex_file(line_by_line_file,temp_file,input_vaml_file)

end

start_compile("C:\\Users\\amma\\Desktop\\sample.vaml","C:\\Users\\amma\\Desktop\\vaml\\")

