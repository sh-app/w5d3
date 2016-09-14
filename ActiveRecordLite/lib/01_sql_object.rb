require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

    attr_reader :columns, :attributes

  def self.columns
    return @columns if @columns

    columns_list = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}

    SQL

    @columns = columns_list[0].map{ |col| col.to_sym}
  end

  def self.finalize!
    columns.each do |col|
      define_method(col) { attributes[col] }
      define_method("#{col}=") do |arg|
          attributes[col] = arg
        end
      end
  end

  def self.table_name=(table_name)
      @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    members = DBConnection.execute(<<-SQL)
      SELECT
      #{table_name}.*
      FROM
      #{table_name}
    SQL

    parse_all(members)
  end

  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    object = DBConnection.execute(<<-SQL, id)
    SELECT
    *
    FROM
    #{table_name}
    WHERE
    id = ?


    SQL
    return nil if object.empty?
    self.new(object.first)
  end

  def initialize(params = {})
    params.each do |name, val|

      getter_name = name.to_sym
      setter_name = (name.to_s + "=").to_sym

      unless self.class.columns.include?(getter_name)
        raise "unknown attribute '#{getter_name}'"
      else
        self.send(setter_name, val)
      end

    end
  end

  def attributes
    @attributes ||= {}
    # ...
  end

  def attribute_values
    @attributes.values
  end


  def insert
    column_names= self.class.columns.each {|col| col.to_s}
    cols = column_names.select{|col| col!= :id}.join(",")
    question_marks = (["?"] * attribute_values.length).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{cols})
    VALUES
      (#{question_marks})

    SQL

    attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.drop(1).map {|col| "#{col} = ?"}.join(",")
    #debugger
    attributes_update = attribute_values.drop(1) + [attribute_values.first]
    DBConnection.execute(<<-SQL, *attributes_update)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    attributes[:id] ? update : insert
  end
end
