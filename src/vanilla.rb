#Vanilla is a simple yet powerful preprocessor for LaTex
#
#The project is hosted at http://github.com/adhithyan15/vanilla
#
#This compiler is a translation of the original compiler written in Python. But a lot of algorithmic structure has been
#modified to give optimum performance.Some parts may be rewritten in the upcoming releases.
#
#The prototype compilers written in Matlab and Python are now available in the Old Compiler Prototypes directory
#
#Authors: Adhithya Rajasekaran and Sri Madhavi Rajasekaran
#
#To know more about the features implemented in this compiler, please read the documentation.
#
#Abbrevations: VAL => Vanilla Flavored LaTex

require 'FileUtils'

require 'optparse'

def start_compile(input_val_file) #This method starts the compilation process

  def read_file_line_by_line(input_path)

    #This method returns each line of the VAL  file as a list

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end
  
  #The following are undocumented features mostly written to write the documentation. 

  def replace_fenced_code_block(input_file_contents,input_val_file)

    #Latex offers Verbatim mode through verbatim package to prevent code from execution.Fence code block extends the verbatim mode to include
    #VAL code also. Verbatim package is a part of our default pack so you don't have to manually import and use it.

    #This method replaces all the declared fenced code blocks with @@fenced_code_block[identifier]
    #This is done to prevent compile time error prevention.

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    def find_val_file_path(input_path)

      #This method is utilized to extract the path of the VAL file.

      extension_remover = input_path.split(".tex")

      remaining_string = extension_remover[0].reverse

      path_finder = remaining_string.index("/")

      remaining_string = remaining_string.reverse

      return remaining_string[0...remaining_string.length-path_finder]

    end

    input_file_as_string = input_file_contents.join

    modified_input_string = input_file_as_string.dup

    preferred_directory = find_val_file_path(input_val_file)

    locate_fenced_code_block = find_all_matching_indices(input_file_as_string,"###")

    fenced_code_block = []

    start_location = 0

    end_location = 1

    if locate_fenced_code_block.length.modulo(2) == 0

      for x in 0...locate_fenced_code_block.length/2

        fenced_code_block_string = input_file_as_string[locate_fenced_code_block[start_location]..locate_fenced_code_block[end_location]+2]

        fenced_code_block << fenced_code_block_string

        replacement_string = "@@fenced_code_block[#{x+1}]"

        modified_input_string = modified_input_string.sub(fenced_code_block_string,replacement_string)

        start_location = start_location + 2

        end_location = end_location + 2

      end

    end

    temporary_file_path = find_val_file_path(input_val_file) + "temp.tex"

    file_id = open(temporary_file_path, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path, fenced_code_block,preferred_directory

  end

  def replace_inline_fenced_code(input_file_contents,temporary_file_path)

    #This method will prevent inline VAL code from being compiled. This will only prevent VAL code from being
    #compiled. If the inline code contains LaTex code, then LaTex compiler will compile it into PDF.
    #This method was mainly written for presenting VAL code in the Vanilla documentation.
    
    #This uses the same methodology as the fenced code block. Tt replaces inline code blocks with
    #@@inline_code_bloc[identifier]

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

    locate_inline_code_block = find_all_matching_indices(input_file_as_string,"%%")

    inline_code_block = []

    start_location = 0

    end_location = 1

    if locate_inline_code_block.length.modulo(2) == 0

      for x in 0...locate_inline_code_block.length/2

        inline_code_block_string = input_file_as_string[locate_inline_code_block[start_location]..locate_inline_code_block[end_location]+1]

        inline_code_block << inline_code_block_string

        replacement_string = "@@inline_code_block[#{x+1}]"

        modified_input_string = modified_input_string.sub(inline_code_block_string,replacement_string)

        start_location = start_location + 2

        end_location = end_location + 2

      end

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path, inline_code_block

  end
  
  #The following features are documented features.

  def resolve_comments(input_file_contents,temporary_file_path)

    #Latex does offer support for multiline comments. But VAL makes the process easier. This method compiles
    #VAL multiline comments into several single line latex comments.Latex comments are still valid in VAL.

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

    #Latex does offer support for declaring constants. But VAL greatly simplifies the process of declaring those constants.
    #You can still use latex constants.

    #Note:VAL constants are not transformed into Latex constants. Constants stand for what they mean.They are immutable.
    #Pure mutable variables may be available in VAL in the future. Lexical Scoping of constants is similar to that in
    #programming languages. This would be imminent in the code block resolution method.

    #Updates 2/16/2012 -> Constants now support what our user called "Computed Properties". So users can now include
    #calculations and reference other constants while declaring constants.

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

      modified_variable_values = []

      variable_values.each do |value|

        if value.include? "@("

          new_value = value.dup

          variable_names.each do |name|

            if new_value.include? name

              new_value = new_value.sub(name,variable_values[variable_names.index(name)])

            end

          end

          ruby_binding = binding

          val = ruby_binding.eval(new_value).to_s

          modified_variable_values << val

        else

          modified_variable_values << value

        end

      end

      return variable_names, modified_variable_values, modified_preamble

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

    #Latex doesn't offer support for formatted text blocks. So VAL provides support for it.

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

    #VAL Formulas are easy way to achieve certain things which are very difficult to achieve in Latex. Writing matrices
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

      start_string = "$\\begin{bmatrix}"

      end_string = "\\end{bmatrix}$"

      rows = []

      for x in 0...input_list.length

        current_row = input_list[x]

        current_row_string = current_row.split.join(" & ")

        rows << current_row_string


      end

      matrix = rows.join(" \\\\\\\\\\\\\\\\ ")

      matrix = "$" + start_string + matrix + end_string + "$"

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

      determinant = rows.join(" \\\\\\\\\\\\\\\\ ")

      determinant = "$" + start_string + determinant + end_string + "$"

      return determinant

    end

    def capitalize(input_string)

      #This method will capitalize every single word in a string

      input_string_split = input_string.split

      for x in 0...input_string_split.length

        current_word = input_string_split[x]

        if current_word.length > 1

          current_word = current_word[0].upcase + current_word[1..-1]

        else

          current_word = current_word.upcase

        end

        input_string_split[x] = current_word

      end

      return input_string_split.join(" ")

    end

    def image(input_string_split,temp_file_path)

      def find_file_path(input_path,file_extension)

        extension_remover = input_path.split(file_extension)

        remaining_string = extension_remover[0].reverse

        if remaining_string.include?("\\")

          path_finder = remaining_string.index("\\")

        elsif remaining_string.include?("/")

          path_finder = remaining_string.index("/")

        end

        remaining_string = remaining_string.reverse

        return remaining_string[0...remaining_string.length-path_finder]

      end

      def find_file_name(input_path,file_extension)

        extension_remover = input_path.split(file_extension)

        remaining_string = extension_remover[0].reverse

        path_finder = remaining_string.index("\\")

        remaining_string = remaining_string.reverse

        return remaining_string[remaining_string.length-path_finder..-1]

      end

      def find_file_extension(input_path)

        extension_start = input_path.index(".")

        return input_path[extension_start..-1]

      end

      available_options = ["scale","width","height","angle","page"]

      image_path = input_string_split[0]

      options = input_string_split[1]

      current_destination = find_file_path(image_path,find_file_extension(image_path))

      to_be_moved_destination = find_file_path(temp_file_path,".tex")

      to_be_moved_dest = to_be_moved_destination + "/#{find_file_name(image_path,"#{find_file_extension(image_path)}")}#{find_file_extension(image_path)}"

      if !current_destination.eql? to_be_moved_destination

        FileUtils.cp image_path,to_be_moved_dest

        eval_binding = binding

        options_hash = eval_binding.eval(options)

        option_values = []

        available_options.each do |option|

          if options_hash.has_key?(option.to_sym)

            option_values <<  option + " = #{options_hash[option.to_sym]}"

          end

        end

        return_string = "\\\\includegraphics[#{option_values.join(",")}]{#{find_file_name(image_path,"#{find_file_extension(image_path)}")}}"

      else

        eval_binding = binding

        options_hash = eval_binding.eval(options)

        option_values = []

        available_options.each do |option|

          option_values <<  option + " = #{options_hash[option.to_sym]}"

        end

        return_string = "\\\\includegraphics[#{option_values.join(",")}]{#{find_file_name(image_path,".#{find_file_extension(image_path)}")}}"

      end

      return return_string


    end

    available_formulas = ["$(matrix)","$(det)","$(cap)","$(image)"]

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

        if x == 0

          formula_usage_string_split = formula_usage_string_split[0].split(";")

          replacement_string = convert_to_matrix(formula_usage_string_split)

        elsif x == 1

          formula_usage_string_split = formula_usage_string_split[0].split(";")

          replacement_string = convert_to_determinant(formula_usage_string_split)

        elsif x == 2

          replacement_string = capitalize(formula_usage_string_split[0])


        elsif x == 3

          replacement_string = image(formula_usage_string_split[0].split(","),temporary_file_path)

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

      inline_calculation_strings = operating_row.match /!\[.{1,}\]/

      inline_calculation_strings = inline_calculation_strings.to_a

      for y in 0...inline_calculation_strings.length

        inline_calculation_string = inline_calculation_strings[y]

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

      input_file_contents[x] = current_row

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(input_file_contents.join)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path

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

    available_formatting = ["**","///","+*","+/","___","~~~"]

    matching_formatting = {"**" => "\\textbf{","///" => "\\emph{" , "+*" => "\\mathbf{" , "+/" => "\\mathit{", "___" => "\\underline{","~~~" => "\\sout{"}

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

  def resolve_fenced_code_blocks(input_file_contents,temporary_file_path,fenced_code_blocks)

    input_file_as_string = input_file_contents.join

    for x in 0...fenced_code_blocks.length

      fenced_code_block_string = "@@fenced_code_block[#{x+1}]"

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

  def resolve_inline_fenced_code(input_file_contents,temporary_file_path,inline_code_blocks)

    input_file_as_string = input_file_contents.join

    for x in 0...inline_code_blocks.length

      fenced_code_block_string = "@@inline_code_block[#{x+1}]"

      replacement_string = inline_code_blocks[x]

      input_file_as_string = input_file_as_string.sub(fenced_code_block_string,replacement_string[2...-2])

    end

    file_id = open(temporary_file_path, 'w')

    file_id.write(input_file_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file_path)

    return line_by_line_contents, temporary_file_path


  end


  def resolve_tex_packs(input_file_contents,temporary_file,preference_directory)

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    default_texpack = [
        "\\usepackage{amsmath,amssymb,amsthm}\n\n",
        "\\usepackage[a4paper,margin = 1in]{geometry}\n\n",
        "\\usepackage{hyperref}\n\n",
        "\\usepackage[normalem]{ulem}\n\n",
        "\\usepackage{xcolor}\n\n",
        "\\usepackage{verbatim}\n\n",
        "\\usepackage{booktabs}\n\n",
        "\\usepackage{graphicx}\n\n",
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

      default_texpack_string = default_texpack.join

      documentclass_finder = preamble_string.index("\\documentclass")

      extract_string = preamble_string[documentclass_finder..-1]

      documentclass_end = extract_string.index("}")

      documentclass_string = extract_string[0..documentclass_end]

      replacement_string = documentclass_string + "\n\n" + default_texpack_string + "\n\n"

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

          importpack_path = preference_directory + importpack_name + ".texpack"

        else

          importpack_path = importpack_name

        end

        texpack_file = read_file_line_by_line(importpack_path).join

        preamble_string = preamble_string.sub(importpack_string,texpack_file)


      end

    end

    file_id = open(temporary_file, 'w')

    file_id.write(preamble_string + document_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file)

    return line_by_line_contents, temporary_file


  end

  def resolve_bare_urls(input_file_contents,temporary_file)

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    def modify_urls(input_url_string)

      return_string = "\\url{#{input_url_string}}"

      return return_string

    end

    input_file_as_string = input_file_contents.join

    modified_input_string = input_file_as_string.dup

    url_identifiers = ["http","www"]

    replacements = ["@@http[]","@@www[]"]

    identifier_matches = []

    replacement_strings = []

    for x in 0...url_identifiers.length

      current_identifier = url_identifiers[x]

      current_replacement = replacements[x]

      current_replacement_split = current_replacement.split("]")

      location_of_current_identifer = find_all_matching_indices(input_file_as_string,current_identifier)

      current_identifier_matches = []

      current_replacement_strings = []

      for y in 0...location_of_current_identifer.length

        current_location = location_of_current_identifer[y]

        extract_string = input_file_as_string[current_location..-1]

        url_extract = extract_string.split(" ",2)

        current_identifier_matches << url_extract[0]

        replacement_string = current_replacement_split[0] + (y+1).to_s + "]"

        current_replacement_strings << replacement_string

        modified_input_string = modified_input_string.sub(url_extract[0],replacement_string)

      end

      identifier_matches << current_identifier_matches

      replacement_strings << current_replacement_strings

    end

    for x in 0...identifier_matches.length

      current_identifer_match = identifier_matches[x]

      replacement_string_array = replacement_strings[x]

      for y in 0...current_identifer_match.length

        urls = current_identifer_match[y]

        interim_replacement = replacement_string_array[y]

        replacement_urls = modify_urls(urls)

        modified_input_string = modified_input_string.sub(interim_replacement,replacement_urls)


      end


    end

    file_id = open(temporary_file, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file)

    return line_by_line_contents, temporary_file

  end

  def replace_descriptive_urls(input_file_contents,temporary_file)

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    def process_urls(input_string)

      core_string = input_string[2...-1]

      split_string = core_string.split("=>")

      return "\\href{#{split_string[1].strip}}{#{split_string[0].strip}}"

    end

    input_file_as_string = input_file_contents.join

    modified_input_string = input_file_as_string.dup

    descriptive_url_locations = find_all_matching_indices(input_file_as_string,"*[")

    replacement_string = "@@descript[]"

    replacement_urls = []

    replacement_strings = []

    for x in 0...descriptive_url_locations.length

      current_location = descriptive_url_locations[x]

      extract_string = input_file_as_string[current_location..-1]

      end_finder = extract_string.index("]")

      descriptive_url = extract_string[0..end_finder]

      replacement_url = process_urls(descriptive_url)

      replacement_urls << replacement_url

      current_replacement_string = replacement_string.sub("]","#{x+1}]")

      replacement_strings << current_replacement_string

      modified_input_string = modified_input_string.sub(descriptive_url,current_replacement_string)

    end

    to_be_replaced = [replacement_strings,replacement_urls]

    file_id = open(temporary_file, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file)

    return line_by_line_contents, temporary_file, to_be_replaced

  end

  def resolve_descriptive_urls(input_file_contents,temporary_file,replacement_array)

    input_file_as_string = input_file_contents.join

    modified_input_string = input_file_as_string.dup

    interim_strings = replacement_array[0]

    descriptive_urls = replacement_array[1]

    for x in 0...interim_strings.length

      current_interim_string = interim_strings[x]

      current_descriptive_url = descriptive_urls[x]

      modified_input_string = modified_input_string.sub(current_interim_string,current_descriptive_url)

    end

    file_id = open(temporary_file, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file)

    return line_by_line_contents, temporary_file

  end

  #The following methods implements some features of Smarty Pants

  #http://daringfireball.net/projects/smartypants/


  def resolve_double_quotes(input_file_contents,temporary_file)

    #This feature implements the double quotes features in smarty pants

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

    opening_quotes_locations = find_all_matching_indices(input_file_as_string,"\"")

    if opening_quotes_locations.length.modulo(2) == 0

      for x in 0...(opening_quotes_locations.length)/2

        modified_input_string = modified_input_string.sub("\"","``")

        modified_input_string = modified_input_string.sub("\"","''")

      end

    end

    file_id = open(temporary_file, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file)

    return line_by_line_contents, temporary_file

  end

  def convert_to_latex_commands(input_file_contents,temporary_file)

    #This method is designed to be more general than just the features available in smarty pants

    #This method currently implements ellipses

    vanilla_commands = ["...."]

    latex_commands = {"...." => "\\ldots"}

    input_file_as_string = input_file_contents.join

    modified_input_string = input_file_as_string.dup

    vanilla_commands.each do |command|

      modified_input_string = modified_input_string.gsub(command,latex_commands[command])

    end

    file_id = open(temporary_file, 'w')

    file_id.write(modified_input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_file)

    return line_by_line_contents, temporary_file

  end

  #The following methods are for writing the output LaTex code.

  def write_latex_file(input_file_contents,temporary_file,input_val_file)

    input_file_as_string = input_file_contents.join

    File.delete(temporary_file)

    output_latex_file_path = input_val_file.split(".tex")

    output_latex_file_path = output_latex_file_path[0] + ".tex"

    file_id = open(output_latex_file_path, 'w')

    file_id.write(input_file_as_string)

    file_id.close()

  end

  #The following method compiles the output .tex file into PDF and then overwrites the .tex file with the
  #original content

  def compile_to_pdf(input_file_path,raw_file_as_string)

    #The method first compiles the .tex file into PDF using PDFLatex

    latex_compiler_output = `pdflatex -interaction=nonstopmode #{input_file_path}`

    file_id = open(input_file_path,'w')

    file_id.write(raw_file_as_string)

    file_id.close()

    return latex_compiler_output

  end


  #The following methods are used only for testing and debugging purposes


  def print_list(input_list)

    #This method will print each line of the inputted list. This method is usually used to test and see whether other parts of
    #the compiler are working correctly

    length_of_list = input_list.length

    for x in 0...length_of_list

      current_item = input_list[x]

      print(current_item)

    end

  end


  line_by_line_file = read_file_line_by_line(input_val_file)

  raw_file = line_by_line_file.dup

  line_by_line_file, temp_file, fenced_code_blocks, preferred_directory = replace_fenced_code_block(line_by_line_file,input_val_file)

  line_by_line_file, temp_file, inline_code_blocks  = replace_inline_fenced_code(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_comments(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_constants(line_by_line_file, temp_file)

  line_by_line_file, temp_file = resolve_formatted_text_blocks(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_formulas(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_inline_calculations(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_inline_formatting(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_tex_packs(line_by_line_file,temp_file,preferred_directory)

  line_by_line_file, temp_file, replacement_array = replace_descriptive_urls(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_bare_urls(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_descriptive_urls(line_by_line_file,temp_file,replacement_array)

  line_by_line_file, temp_file = resolve_double_quotes(line_by_line_file,temp_file)

  line_by_line_file, temp_file = convert_to_latex_commands(line_by_line_file,temp_file)

  line_by_line_file, temp_file = resolve_fenced_code_blocks(line_by_line_file,temp_file,fenced_code_blocks)

  line_by_line_file, temp_file = resolve_inline_fenced_code(line_by_line_file,temp_file,inline_code_blocks)

  write_latex_file(line_by_line_file,temp_file,input_val_file)

  pdflatex_output = compile_to_pdf(input_val_file,raw_file.join)

  return pdflatex_output

end

#This script creates a windows executable using the Ocra gem and a mac
#version using shabang syntax.

def create_executable(input_file)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  windows_output = `ocra --add-all-core #{input_file}`

  mac_file_contents = ["#!/usr/bin/env ruby\n\n"] + read_file_line_by_line(input_file)

  mac_file_path = input_file.sub(".rb","")

  file_id = open(mac_file_path,"w")

  file_id.write(mac_file_contents.join)

  file_id.close

end

def create_mac_executable(input_file)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  mac_file_contents = ["#!/usr/bin/env ruby\n\n"] + read_file_line_by_line(input_file)

  mac_file_path = input_file.sub(".rb", "")

  file_id = open(mac_file_path, "w")

  file_id.write(mac_file_contents.join)

  file_id.close

end

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: vanilla [options] TEX_FILE"

  opts.on("-c", "--compile FILE", "Compile to PDF") do |file|
    current_directory = Dir.pwd
    file_path = current_directory + "/" + file
    latex_compiler_output = start_compile(file_path)
    puts latex_compiler_output

  end

  opts.on("-b", "--build FILE", "Builds Itself") do |file|

    file_path = Dir.pwd + "/src/vanilla.rb"

    create_mac_executable(file_path)

    FileUtils.mv("#{file_path[0...-3]}", "#{Dir.pwd}/bin/vanilla")

    puts "Build Successful!"

  end

end.parse!
