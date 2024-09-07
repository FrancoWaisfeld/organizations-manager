## Organizations

Organizations is a Sinatra application designed for tracking organizations and their employees.

### **Installation**

1. **Ruby and Browser Compatibility**:

   - Ensure you are using Ruby version 3.2.0.
   - Tested on Google Chrome version 114.0.5735.198.

2. **PostgreSQL Setup**:

   - Install PostgreSQL version 15.3.
   - Run the command `createdb organizations` in your terminal to create the required database.

3. **Database Initialization**:

   - Navigate to the 'organizations' database.
   - Execute `psql -d organizations < schema.sql` in your terminal to load the seed data.

4. **Dependencies Installation**:
   - While in the 'organizations' database, run `bundle install` from your terminal to install the necessary dependencies.

### **Usage**

- Start the application by running `ruby organizations.rb` in your terminal.
- Upon accessing any path, you will be redirected to a sign-in page.
- Use the credentials:
  - **Username**: admin
  - **Password**: demopass
- After logging in, you will be redirected to the initially requested page.

### **Features**

- **Organizations Management**:

  - View and create new organizations from the '/organizations' path.
  - Edit organization names via the "Edit Organization" hyperlink.

- **Employee Management**:
  - View all employees of an organization by clicking 'View All Employees' at the '/organizations' path.
  - Add new employees to an organization.
  - Delete employees using the 'Delete' button under their name.
  - Edit an employee's job or full name through the 'Edit Employee' hyperlink.
