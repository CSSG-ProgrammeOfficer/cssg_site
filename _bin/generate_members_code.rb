require 'smarter_csv'

bin_path = File.expand_path(File.dirname(__FILE__))

members_csv = File.join(bin_path, 'members.csv')
print "Attempting to laod data from #{members_csv}... "
table = SmarterCSV.process(members_csv, headers: %w[last first country city region email position image institution expertise description], quote_char: '"')
puts "Done!"

members_csv_es = File.join(bin_path, 'members_es.csv')
print "Attempting to laod data from #{members_csv_es}... "
table_es = SmarterCSV.process(members_csv_es, headers: %w[last first country city region email position image institution expertise description], quote_char: '"')
puts "Done!"


# puts table

acceptable_positions = ['Co-Chair', 'Deputy Chair', 'Advisory Committee Member',
                        'Red List Authority Coordinator',
                        'Programme Officer', 'Commission Member']
categories = ['Leadership', 'Red List Authority Coordinator',
              'Programme Officer', 'Commission Members']

table.each do |member|
  unless acceptable_positions.include? member[:position]
    puts "Unacceptable position: \"#{member[:position]}\" for member:"
    puts member
  end
end

table_es.each do |member|
  unless acceptable_positions.include? member[:position]
    puts "Unacceptable position: \"#{member[:position]}\" for member:"
    puts member
  end
end

def format_li(member, img_position: :left, indent: '', text_color: nil,
              lang: :en, display_role: false)

  # maps roles to roles (does nothing in English)
  position_dictionary = case lang
  when :es
   {
      'Co-Chair' => 'Copresidenta',
      'Deputy Chair' => 'Vicepresidenta',
      'Advisory Committee Member' => 'Miembro del Comité Asesor',
      'Red List Authority Coordinator' => 'Coordinador de la Autoridad de la Lista Roja',
      'Programme Officer' => 'Oficial de Programa',
      'Commission Member' => 'Miembro de la Comisión'
    }
  else
   {
      'Co-Chair' => 'Co-Chair',
      'Deputy Chair' => 'Deputy Chair',
      'Advisory Committee Member' => 'Advisory Committee Member',
      'Red List Authority Coordinator' => 'Red List Authority Coordinator',
      'Programme Officer' => 'Programme Officer',
      'Commission Member' => 'Commission Member'
    }
  end

  res = indent + '<li class="media my-4">' + "\n"
  indent += '  '
  img_file = member[:image] || 'avatar-placeholder-sm.png'
  img_tag = '<img src="{{ site.baseurl }}/assets/images/people/' + 
            img_file + '" class="mr-3 img-fluid shadow rounded-circle"' +
            ' alt="...">'
  if img_position == :left
    res += (indent + img_tag + "\n")
  end
  res += (indent + '<div class="media-body">' + "\n")
  indent += '  '
  # puts "member is #{member}"
  # puts "keys are #{member.keys}"
  # puts "last is #{member.values[0]} and first is #{member[:first]}"
  # puts "values are #{member.values}"
  res += (indent + '<h5 class="mt-0' + (text_color.nil? ? '' : " #{text_color}") + '">' + member[:first] + ' ' + member.values[0])
  # optionally include position
  res += ", #{position_dictionary[member[:position]]}" if display_role
  res += ('</h5>' + "\n")
  res += (indent + "<p class='mb-1'>")
  res += "#{member[:description]}" || ''
  if member[:description] and member[:institution]
    unless member[:description].strip.empty? or member[:institution].strip.empty?
      res += case lang
      when :es then ' en '
      else
        ' at '
      end
    end
  end
  res += "#{member[:institution].strip}" if member[:institution]
  if member[:expertise]
    res += "</p><p class='my-0 py-0 font-italic font-weight-lighter'>#{member[:expertise]}"
  end
  res += '</p>'

  # res += "#{member[:city]}, " if member[:city]
  # res += "#{member[:country]}" if member[:country]
  # res += "</p>\n"
  # res += '<p>' + member[:expertise] + '</p>' if member[:expertise]
  # res += '<p>' + member[:description] + '</p>' if member[:description]
  # res += (indent + '<p>Cras sit amet nibh libero, in gravida nulla. Nulla vel metus scelerisque ante sollicitudin. Cras purus odio, vestibulum in vulputate at, tempus viverra turpis. Fusce condimentum nunc ac nisi vulputate fringilla. Donec lacinia congue felis in faucibus.</p>' + "\n")
  indent = indent[(0...-2)]
  res += (indent + '</div>' + "\n")
  if img_position == :right
    res += (indent + img_tag + "\n")
  end
  indent = indent[(0...-2)]
  res += (indent + '</li>' + "\n")
end

def format_list(table, category, img_position: :left, indent: '', bg_class: nil, lang: :en)
  # maps categories to their proper translation (english does nothing)
  categories_dictionary = case lang
  when :es
    {
      'Leadership' => 'Liderazgo',
      'Red List Authority Coordinator' => 'Cordinador de la Autoridad de la Lista Roja',
      'Programme Officer' => 'Oficial de Programa',
      'Commission Members' => 'Miembros de la Comisión'
    }
  else
    {
      'Leadership' => 'Leadership',
      'Red List Authority Coordinator' => 'Red List Authority Coordinator',
      'Programme Officer' => 'Programme Officer',
      'Commission Members' => 'Commission Members'
    }
  end

  # maps categories of roles to specific roles in English always
  categories_to_roles = {
    'Leadership' => ['Co-Chair', 'Deputy Chair', 'Advisory Committee Member'],
    'Red List Authority Coordinator' => ['Red List Authority Coordinator'],
    'Programme Officer' => ['Programme Officer'],
    'Commission Members' => ['Commission Member']
  }

  members = table.select do |member|
    categories_to_roles[category].include? member[:position].strip
  end
  puts "There are #{members.count} members in category #{category}"
  members.sort! { |m1, m2| [categories_to_roles[category].index(m1[:position]), m1[:last]] <=> [categories_to_roles[category].index(m2[:position]), m2[:last]] }
  unless members.count > 0
    puts "No memebers with category #{category}, which is positions #{categories_to_roles[category]}"
    return ''
  end
  res = ''
  # end previous container. Might have been main body, might be previous list
  res += (indent + "</div>\n")
  res += (indent + "<div class='bg-image #{bg_class} py-4 my-5 text-white'>")
  res += (indent + "<div class='container'>") if bg_class
  res += (indent + "<div class='row")
  res += ' my-4' unless bg_class
  res += "'>\n"
  indent += '  '
  res += (indent + "<div class='col'>\n")
  indent += '  '
  res += (indent + "<h1 class='" + (bg_class ? 'text-white' : 'text-success') +
    "'>#{categories_dictionary[category]}")
  res += "</h1>\n"
  res += (indent + "<ul class='list-unstyled'>\n")
  indent += '  '
  text_color = bg_class ? 'text-white' : nil
  members.each do |member|
    res += format_li(member, img_position: img_position, indent: indent.dup, text_color: text_color, lang: lang, display_role: category == 'Leadership')
  end
  indent = indent[(0...-2)]
  res += (indent + "</ul>\n")
  indent = indent[(0...-2)]
  res += (indent + "</div>\n")
  indent = indent[(0...-2)]
  res += (indent + "</div>\n") # leave container hanging
  # technically leaves bg color hanging, but next block
  # should take care of it, or end of the table
  res += (indent + "</div>\n") if bg_class
  res
end

def format_all(table, categories, indent: '', lang: :en)
  img_positions = [:left, :right]
  bg_classes = ['bg-light-green', 'bg-orange', 'bg-yellow', 'bg-dark-green']
  res = ''
  categories.each_with_index do |category, i|
    res += format_list(table, category, img_position: img_positions[i.modulo(img_positions.length)], indent: indent, bg_class: bg_classes[i], lang: lang)
  end
  res += (indent + '</div>' + "\n")
  res
end

File.open(File.join(bin_path, '..', '_includes', 'members_en.html'), 'w') do |f|
  f.write(format_all(table, categories, indent: ''))
end

File.open(File.join(bin_path, '..', '_includes', 'members_es.html'), 'w') do |f|
  f.write(format_all(table_es, categories, indent: '', lang: :es))
end