require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    values = params.values
    keys = params.keys.map { |name| "#{name} = ?"}.join(" AND ")


    results = DBConnection.execute(<<-SQL, values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{keys}
    SQL

    results.map! { |hash| self.new(hash)}

  end
end

class SQLObject
  extend Searchable
end
