require 'bundler/setup'
require 'pg'

class DatabasePersistence
  def initialize
    @database = PG.connect(dbname: "organizations")
  end

  def all_organizations
    sql = <<~SQL
      SELECT organizations.*,
      count(employees.organization_id) AS employees_count
      FROM organizations
      LEFT OUTER JOIN employees ON organizations.id = employees.organization_id
      GROUP BY organizations.id
      ORDER BY name;
    SQL

    result = @database.exec(sql)

    result.map do |tuple|
      organization_tuple_to_list_hash(tuple)
    end
  end

  def five_organizations(offset)
    sql = <<~SQL
      SELECT organizations.*,
      count(employees.organization_id) AS employees_count
      FROM organizations
      LEFT OUTER JOIN employees ON organizations.id = employees.organization_id
      GROUP BY organizations.id
      ORDER BY name
      LIMIT 5
      OFFSET $1;
    SQL

    result = @database.exec_params(sql, [offset])

    result.map do |tuple|
      organization_tuple_to_list_hash(tuple)
    end
  end

  def find_organization(id)
    sql = <<~SQL
      SELECT organizations.*,
      count(employees.organization_id) AS employees_count
      FROM organizations
      LEFT OUTER JOIN employees ON organizations.id = employees.organization_id
      WHERE organizations.id = $1
      GROUP BY organizations.id;
    SQL

    result = @database.exec_params(sql, [id])

    organization_tuple_to_list_hash(result.first)
  end

  def new_organization(name)
    sql = <<~SQL
      INSERT INTO organizations (name)
      VALUES($1);
    SQL

    @database.exec_params(sql, [name])
  end

  def delete_organization(id)
    sql = 'DELETE FROM organizations WHERE id = $1;'

    @database.exec_params(sql, [id])
  end

  def edit_organization_name(new_name, id)
    sql = <<~SQL
      UPDATE organizations SET name = $1
      WHERE id = $2;
    SQL

    @database.exec_params(sql, [new_name, id])
  end

  def find_employees_for_organization(organization_id)
    sql = <<~SQL
      SELECT * FROM employees
      WHERE organization_id = $1
      ORDER BY full_name;
    SQL

    result = @database.exec_params(sql, [organization_id])

    result.map do |tuple|
      employee_tuple_to_list_hash(tuple)
    end
  end

  def find_5_employees_for_organization(organization_id, offset)
    sql = <<~SQL
      SELECT * FROM employees
      WHERE organization_id = $1
      ORDER BY full_name
      LIMIT 5
      OFFSET $2;
    SQL

    result = @database.exec_params(sql, [organization_id, offset])

    result.map do |tuple|
      employee_tuple_to_list_hash(tuple)
    end
  end

  def find_employee(employee_id)
    sql = 'SELECT * FROM employees WHERE id = $1;'

    result = @database.exec_params(sql, [employee_id])

    result.map do |tuple|
      {
        id: tuple['id'].to_i,
        full_name: tuple['full_name'],
        job: tuple['job'],
        organization_id: tuple['organization_id'].to_i
      }
    end.first
  end

  def add_employee_to_organization(organization_id, full_name, job)
    sql = <<~SQL
      INSERT INTO employees (full_name, job, organization_id)
      VALUES ($1, $2, $3);
    SQL

    @database.exec_params(sql, [full_name, job, organization_id])
  end

  def delete_employee_from_organization(employee_id)
    sql = 'DELETE FROM employees WHERE id = $1;'

    @database.exec_params(sql, [employee_id])
  end

  def edit_employee_full_name(new_full_name, employee_id)
    sql = 'UPDATE employees SET full_name = $1 WHERE id = $2;'

    @database.exec_params(sql, [new_full_name, employee_id])
  end

  def edit_employee_job(new_job, employee_id)
    sql = 'UPDATE employees SET job = $1 WHERE id = $2;'

    @database.exec_params(sql, [new_job, employee_id])
  end

  private

  def employee_tuple_to_list_hash(tuple)
    {
      id: tuple['id'].to_i,
      full_name: tuple['full_name'],
      job: tuple['job']
    }
  end

  def organization_tuple_to_list_hash(tuple)
    {
      id: tuple['id'].to_i,
      name: tuple['name'],
      employees_count: tuple['employees_count'].to_i
    }
  end
end
