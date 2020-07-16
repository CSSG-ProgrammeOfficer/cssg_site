require 'smarter_csv'

bin_path = File.expand_path(File.dirname(__FILE__))

members_csv = File.join(bin_path, 'members.csv')
print "Attempting to laod data from #{members_csv}... "
table = SmarterCSV.process(members_csv, headers: true, quote_char: '"')
puts "Done!"

acceptable_positions = ['Co-Chair', 'Red List Authority Coordinator',
                        'Programme Officer', 'Commission Member']
table.each do |member|
  unless acceptable_positions.include? member[:position]
    puts "Unacceptable position: \"#{member[:position]}\" for member:"
    puts member
  end
end

def format_li(member, img_position: :left, indent: '')
  res = indent + '<li class="media my-4">' + "\n"
  indent += '  '
  if img_position == :left
    res += (indent + '<img src="{{ site.baseurl }}/assets/images/avatar-placeholder-sm.png" class="mr-3 img-fluid shadow rounded-circle" alt="...">' + "\n")
  end
  res += (indent + '<div class="media-body">' + "\n")
  indent += '  '
  res += (indent + '<h5 class="mt-0">' + member[:first] + ' ' + member[:last] + '</h5>' + "\n")
  res += (indent + '<p>Cras sit amet nibh libero, in gravida nulla. Nulla vel metus scelerisque ante sollicitudin. Cras purus odio, vestibulum in vulputate at, tempus viverra turpis. Fusce condimentum nunc ac nisi vulputate fringilla. Donec lacinia congue felis in faucibus.</p>' + "\n")
  indent = indent[(0...-2)]
  res += (indent + '</div>' + "\n")
  if img_position == :right
    res += (indent + '<img src="{{ site.baseurl }}/assets/images/avatar-placeholder-sm.png" class="ml-3 img-fluid shadow rounded-circle" alt="...">' + "\n")
  end
  indent = indent[(0...-2)]
  res += (indent + '</li>' + "\n")
end

def format_list(table, position, img_position: :left, indent: '')
  members = table.select { |member| member[:position] == position }
  members.sort! { |m1, m2| m1[:last] <=> m2[:last] }
  return unless members.count > 0
  res = (indent + "<div class='row my-4'>\n")
  indent += '  '
  res += (indent + "<div class='col'>\n")
  indent += '  '
  res += (indent + "<h1 class='text-success'>#{position}")
  res += 's' if members.count > 1
  res += "</h1>\n"
  res += (indent + "<ul class='list-unstyled'>\n")
  indent += '  '
  members.each do |member|
    res += format_li(member, img_position: img_position, indent: indent.dup)
  end
  indent = indent[(0...-2)]
  res += (indent + "</ul>\n")
  indent = indent[(0...-2)]
  res += (indent + "</div>\n")
  indent = indent[(0...-2)]
  res += (indent + "</div>\n")
  res
end

def format_all(table, positions, indent: '')
  img_positions = [:left, :right]
  res = ''
  positions.each_with_index do |position, i|
    res += format_list(table, position, img_position: img_positions[i.modulo(img_positions.length)], indent: indent)
  end
  res
end

File.open(File.join(bin_path, '..', '_includes', 'members_en.html'), 'w') do |f|
  f.write(format_all(table, acceptable_positions, indent: ''))
end