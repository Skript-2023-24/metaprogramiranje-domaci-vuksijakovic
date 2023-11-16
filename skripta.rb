require "google_drive"

class GoogleSheets
  def initialize(worksheet)
    @ws = worksheet
    found_data = false
    prvi = 0
    @x
    @y
    @values = []
    @headers = []
    (0..@ws.num_rows).each do |row_index|
      row = @ws.rows[row_index]
      next if row.nil?
      next if row.compact.any? { |cell| cell.downcase.include?('total') || cell.downcase.include?('subtotal') }
      if found_data == false
        for element in row 
          if !element.empty? && element!=""
            found_data = true;
            prvi = 1
          end
        end
      end
      if prvi > 1
        @values << row.drop(@y-1) if found_data 
      end
      if prvi == 1 
        @x = row_index + 1
        broj = 0
        for element in row 
          if element == "" 
            broj = broj + 1
          else 
            break
          end
        end  
        @y = broj + 1
        @headers << row.drop(@y-1)
        prvi = 2
      end
    end
    generate_column_methods
  end
  def cleanWs
    @ws.rows.each_with_index do |row, index|
      row.each_with_index do |cell, col_index|
        @ws[index+1, col_index + 1] = ''
      end
    end
    @ws.save
  end
  def saveWs
    cleanWs()
    niz = []
    niz.concat(@headers)
    niz.concat(@values)
    niz.each_with_index do |row, index|
      row.each_with_index do |cell, col_index|
        @ws[@x+index,@y+col_index] = cell
      end
    end
    @ws.save
  end
  def [](index)
    if index.is_a?(Integer)
      return @values[index]
    else
      header_index = @headers.flatten.index(index)
      return ColumnAccessor.new(header_index, self)
    end
  end
  
  class ColumnAccessor
    def initialize(header_index, matrix_instance)
      @header_index = header_index
      @matrix_instance = matrix_instance
    end
    def inspect
      @matrix_instance.table_values
    end
  
    def [](row_index)
      @matrix_instance.table_values[row_index][@header_index]
    end
  
    def []=(row_index, value)
      updated_values = @matrix_instance.table_values.map(&:dup)
      updated_values[row_index] = updated_values[row_index].dup
      updated_values[row_index][@header_index] = value
  
      @matrix_instance.instance_variable_set(:@values, updated_values)
      @matrix_instance.saveWs();
    end
  end
  
  
  def table_values
    @values
  end
  
  def headers
    @headers
  end
  
  def row(index)
    @values[index]
  end
  
  def ws1
    @ws1
  end
  def matrixBack
    niz = []
    niz.concat(@headers)
    niz.concat(@values)
    niz
  end
  def +(druga_tabela)
    if !druga_tabela.is_a?(GoogleSheets) || @headers != druga_tabela.headers
      return self
    end
  
    nove_vrednosti = (druga_tabela.instance_variable_get(:@values) - @values).uniq
    @values.concat(nove_vrednosti)
    saveWs()
    self
  end
  
  
  def -(druga_tabela)
    if !druga_tabela.is_a?(GoogleSheets) || @headers != druga_tabela.headers
      return self
    end
  
    @values.reject! { |row| druga_tabela.instance_variable_get(:@values).include?(row) }
    saveWs()
    self
  end
  

  include Enumerable

def each(&block)
  @values.each do |row|
    row.each(&block)
  end
end

def generate_column_methods
  @headers.flatten.each do |header|
    method_name = header.downcase.tr(" ", "")
    header_index = @headers.flatten.index(header)

    define_singleton_method(method_name) do
      niz = []
      @values.each { |row| niz << row[header_index] }
      
      ColumnOperations.add_methods_from_array(niz, @values)
      niz.extend(ColumnOperations)
      niz.extend(Enumerable)
    end
    
  end
end

module ColumnOperations
  def self.add_methods_from_array(array, values)
    array.each_with_index do |method_name, index|
      define_method(method_name) do
        values[index]
      end
    end
  end

  def sum
    niz = self
    sum = 0
    for element in niz
      sum += element.to_i
    end
    sum
  end

  def avg 
    niz = self
    suma = niz.sum
    broj = 0
    for element in niz
      br = element.to_i
      if br.to_s == element
        broj += 1
      end
    end
    if broj == 0
      broj += 1
    end
    suma.to_f / broj
  end
end

end

