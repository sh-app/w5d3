require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do

      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      ## table_names##
      table_name = source_options.class_name.constantize.table_name
      join_table_name = through_options.class_name.constantize.table_name
      self_table = self.class.table_name

        results = DBConnection.execute(<<-SQL)
        SELECT
        #{table_name}.*
        FROM
        #{table_name}
          JOIN
          #{join_table_name}
            ON #{join_table_name}.#{source_options.foreign_key} = #{table_name}.#{source_options.primary_key}
          JOIN
          #{self_table}
            ON #{self_table}.#{through_options.foreign_key} = #{join_table_name}.#{through_options.primary_key}
          WHERE
          #{self_table}.id = #{self.id}
      SQL
      result = source_options.class_name.constantize.new(results.first)
    end
  end

end
