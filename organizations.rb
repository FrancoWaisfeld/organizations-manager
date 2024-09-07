require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'
require 'yaml'
require 'bcrypt'

require_relative 'database_persistence'

configure do
  set :erb, escape_html: true
  enable :sessions
end

before do
  @database = DatabasePersistence.new

  unless session[:username] || request.path_info == '/signin'
    session[:origin] = request.path_info
    redirect '/signin'
  end
end

# loads user credentials from user.yml file
def load_user_credentials
  user_credentials_path = File.expand_path('./users.yml')
  YAML.load_file(user_credentials_path)
end

# returns true if user credientials are correct or false if they are incorrect
def valid_credentials?(username, password)
  user_credentials = load_user_credentials

  if user_credentials.key?(username)
    encrypted_password = BCrypt::Password.new(user_credentials[username])
    encrypted_password == password
  else
    false
  end
end

# Return an error message if the name is invalid. Return nil if name is valid.
def error_for_organization_name(name)
  no_whitespace_name = name.strip

  if !(1..100).cover?(no_whitespace_name.size)
    'Organization name must be between 1 and 100 characters.'
  elsif @database.all_organizations.any? do |org|
          org[:name].downcase.strip == no_whitespace_name.downcase
        end
    'Organization name must be unique.'
  end
end

# Return an error message if the employee full name is invalid.
# Return nil if valid
def error_for_employee_full_name(name, organization_id)
  if !name.match?(/[a-zA-z]+\s[a-zA-z]+/)
    'Must include full name.'
  elsif @database.find_employees_for_organization(organization_id).any? do
          |employee|
          employee[:full_name].downcase.strip == name.downcase.strip
        end
    'Employee name must be unique.'
  end
end

# Return an error message if the employee job is invalid. Return nil is valid
def error_for_employee_job(job)
  no_whitespace_job = job.strip

  'Job must be between 1 and 100 characters.' unless
    (1..100).cover?(no_whitespace_job.size)
end

# Return an error message if the organization id is invalid. Return nil if valid
def error_for_organization_id(organization_id)
  if @database.all_organizations.none? { |org| org[:id] == organization_id }
    'Organization not found.'
  end
end

def error_for_employee_id(employee_id)
  return 'Employee not found.' unless @database.find_employee(employee_id)
end

# Returns the maximum page number for pagination, assuming each page contains 5
# units.
def find_max_page(count)
  return 0 if count.zero?

  (count / 5.0).ceil - 1
end

# Returns an error message if the page number for pagination is invalid.
# Returns nil if the page number is valid.
def error_for_page_number(page, max_page)
  # handles edge case of page being assigned to nil
  return nil if page.nil?

  return "Page number may only include numbers." if page.match?(/\D/)

  page = page.to_i

  if page > max_page || page.negative?
    case max_page
    when 0
      'Page not found. Enter page 0.'
    when 1
      "Page not found. Enter page 0 or #{max_page}."
    else
      "Page not found. Enter a page from 0 to #{max_page}."
    end
  end
end

# view sign in page
get '/signin' do
  # session[:username] is nil if not logged in
  redirect '/organizations' if session[:username]

  erb :signin, layout: :layout
end

# redirects to organizations page
get '/' do
  redirect '/organizations'
end

# redirects to organizations page
get '/favicon.ico' do
  redirect '/organizations'
end

# view all organizations
get '/organizations' do
  page = params[:page]

  organizations_count = @database.all_organizations.count

  @max_page = find_max_page(organizations_count)

  error = error_for_page_number(page, @max_page)

  # validate the page number
  if error
    session[:message] = error

    redirect '/organizations'
  else
    page = page.to_i || 0

    offset = page * 5

    @organizations = @database.five_organizations(offset)

    erb :organizations, layout: :layout
  end
end

# view all employees for an organization
get '/organizations/:id' do
  organization_id = params[:id].to_i

  error = error_for_organization_id(organization_id)

  if error
    session[:message] = error
    redirect '/organizations'
  else
    employees_count =
      @database.find_employees_for_organization(organization_id).count

    page = params[:page]

    @max_page = find_max_page(employees_count)

    error = error_for_page_number(page, @max_page)

    # validate the page number
    if error
      session[:message] = error

      redirect "/organizations/#{organization_id}"
    else
      page = page.to_i || 0

      offset = page * 5

      @organization = @database.find_organization(organization_id)

      @employees =
        @database.find_5_employees_for_organization(organization_id, offset)

      erb :organization, layout: :layout
    end
  end
end

# view edit page for organization
get '/organizations/:id/edit' do
  organization_id = params[:id].to_i

  error = error_for_organization_id(organization_id)

  if error
    session[:message] = error
    redirect '/organizations'
  else
    @organization = @database.find_organization(organization_id)

    erb :edit_organization, layout: :layout
  end
end

# view edit page for employee
get '/organizations/:id/employee/:employee_id/edit' do
  organization_id = params[:id].to_i

  employee_id = params[:employee_id].to_i

  organization_id_error = error_for_organization_id(organization_id)

  employee_id_error = error_for_employee_id(employee_id)

  if organization_id_error
    session[:message] = organization_id_error
    redirect '/organizations'
  elsif employee_id_error
    session[:message] = employee_id_error
    redirect "/organizations/#{organization_id}"
  else
    @employee = @database.find_employee(employee_id)

    erb :edit_employee, layout: :layout
  end
end

# create a new organization
post '/organizations/new' do
  organization_name = params[:new_organization]
  error = error_for_organization_name(organization_name)

  if error
    session[:message] = error
    session[:new_organization] = params[:new_organization]
  else
    @database.new_organization(organization_name)
    session[:message] = 'The organization has been created.'
  end

  redirect '/organizations'
end

# attempt to sign in
post '/signin' do
  username = params[:username]

  if valid_credentials?(username, params[:password])
    session[:username] = username

    # session[:origin] is nil if the first page visited is "/signin"
    redirect session[:origin] || '/organizations'
  else
    session[:message] = 'Incorrect username or password'
    redirect '/signin'
  end
end

# edit organization name
post '/organizations/:id/edit' do
  new_name = params[:new_organization_name]

  error = error_for_organization_name(new_name)

  organization_id = params[:id]

  if error
    session[:message] = error
    @organization = @database.find_organization(organization_id)
    erb :edit_organization, layout: :layout
  else
    @database.edit_organization_name(new_name, organization_id)
    session[:message] = 'The organization name has been updated.'
    redirect "organizations/#{organization_id}/edit"
  end
end

# delete an organization
post '/organizations/:id/delete' do
  organization_id = params[:id]

  @database.delete_organization(organization_id)

  session[:message] = 'The organization has been deleted.'
  redirect '/organizations'
end

# edit employee name or job
post '/organizations/:id/employee/:employee_id/edit' do
  organization_id = params[:id]

  employee_id = params[:employee_id]

  new_full_name = params[:full_name]

  new_job = params[:job]

  @employee = @database.find_employee(employee_id)

  if new_full_name
    error = error_for_employee_full_name(new_full_name, organization_id)

    if error
      session[:message] = error
      erb :edit_employee, layout: :layout
    else
      @database.edit_employee_full_name(new_full_name, employee_id)

      session[:message] = "The employee's full name has been changed."

      redirect "/organizations/#{organization_id}/employee/#{employee_id}/edit"
    end
  elsif new_job
    error = error_for_employee_job(new_job)

    if error
      session[:message] = error
      erb :edit_employee, layout: :layout
    else
      @database.edit_employee_job(new_job, employee_id)

      session[:message] = "The employee's job has been changed."

      redirect "/organizations/#{organization_id}/employee/#{employee_id}/edit"
    end
  end
end

# delete employee from an organization
post '/organizations/:id/employee/:employee_id/delete' do
  organization_id = params[:id]
  employee_id = params[:employee_id]

  @database.delete_employee_from_organization(employee_id)

  session[:message] = 'The employee has been removed from the organization.'

  redirect "/organizations/#{organization_id}"
end

# add new employee to an organization
post '/organizations/:id/employee/new' do
  organization_id = params[:id]
  full_name = params[:full_name]
  job = params[:job]

  full_name_error = error_for_employee_full_name(full_name, organization_id)

  job_error = error_for_employee_job(job)

  if full_name_error
    session[:message] = full_name_error
    session[:full_name] = params[:full_name]
    session[:job] = params[:job]
  elsif job_error
    session[:message] = job_error
    session[:full_name] = params[:full_name]
    session[:job] = params[:job]
  else
    @database.add_employee_to_organization(organization_id, full_name, job)
    session[:message] =
      "#{params[:full_name]} has been added to the organization."
  end

  redirect "/organizations/#{organization_id}"
end
