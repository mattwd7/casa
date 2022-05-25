

This guide will walk you through setting up the neccessary environment using  [WSL](https://docs.microsoft.com/en-us/windows/wsl/install) (Windows Subsystem for Linux), which will allow you to run Ubuntu on your Windows machine. 

You will need the following local tools installed:

1. WSL
2. Ruby
3. NodeJs (optional)
4. Postgres
5. Google Chrome

### WSL (Windows Subsystem for Linux)

1. **Install [WSL](https://docs.microsoft.com/en-us/windows/wsl/install)**. 

   `wsl --install`

   The above command only works if WSL is not installed at all, if you run `wsl --install `and see the WSL help text, do `--install -d Ubuntu`

2. **Run Ubuntu on Windows**
   
   You can run Ubuntu on Windows [several different ways](https://docs.microsoft.com/en-us/windows/wsl/install#ways-to-run-multiple-linux-distributions-with-wsl), but we suggest using [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/install). 

   To open an Ubuntu tab in Terminal, click the downward arrow and choose 'Ubuntu'. 

   The following commands should all be run in an Ubuntu window. 

### Ruby

Install a ruby version manager like [rbenv](https://github.com/rbenv/rbenv#installation)

  **Be sure to install the ruby version in `.ruby-version`. Right now that's Ruby 3.1.0.** 

Instructions for rbenv:

1. **Install rbenv**

   `sudo apt install rbenv`

2. **Set up rbenv in your shell**

   `rbenv init`

3. **Close your Terminal window and open a new one so your changes take effect.**

4. **Verify that rbenv is properly set up**

   `curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash`

5.  **[Install Ruby](https://github.com/rbenv/rbenv#installing-ruby-versions)**

      **Be sure to install the ruby version in `.ruby-version`. Right now that's Ruby 3.1.0.** 

      `rbenv install 3.1.0`

6. **Set a Ruby version to finish installation and start**

    `rbenv global 3.1.0` OR `rbenv local 3.1.0`


### NodeJS

The Casa package frontend leverages several javascript packages managed through `yarn`, so if you are working on those elements you will want to have node, npm, and yarn installed.

1. **(Recommended) [Install nvm](https://github.com/nvm-sh/nvm#installing-and-updating)**

   NVM is a node version manager.

2. **[Install yarn](https://classic.yarnpkg.com/en/docs/install)** 

   Expand 'Alternatives' and select 'Debian/Ubuntu' for detailed instructions.

   `curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -`
   
   `echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list`

   `sudo apt update`

   `sudo apt install yarn`

### Postgres

1. **[Install PostgresSQL](https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-postgresql) for WSL**

   `sudo apt install postgresql postgresql-contrib` - install
   
   `psql --version` - confirm installation and see version number
   
 2. **Install libpq-dev library**
 
      `sudo apt-get install libpq-dev`

3. **Start your postgresql service** 

   `sudo service postgresql start`


### Google Chrome

Many of the frontend tests are run using Google Chrome, so if you don't already have that installed you may wish to [install it](https://www.google.com/chrome/downloads/).

### Casa & Rails

Casa's install will also install the correct version of Rails. 

1. **Download the project**

   **You should create a fork in GitHub if you don't have permission to directly commit to this repo. See our [contributing guide](https://github.com/rubyforgood/casa/blob/main/doc/CONTRIBUTING.md) for more detailed instructions.**

   `git clone <git address>` - use your fork's address if you have one

   ie

   `git clone https://github.com/rubyforgood/casa.git`

2. **Installing Packages**

   `cd casa/`

   `bundle install` -  install ruby dependencies.

   `yarn` - install javascript dependencies.

3. **Database Setup**

   Be sure your postgres service is running (`sudo service postgresql start`).

   Create a postgres user that matches your Ubuntu user:

   `sudo -u postgres createuser <username>` - create user
   
   `sudo -u postgres psql` - logs in as the postgres user
   
   `psql=# alter user <username> with encrypted password '<password>';` - add password
   
   `psql=# alter user <username> CREATEDB;` - give permission to your user to create databases
 
   Set up the Casa DB

    `bin/rails db:setup`  - sets up the db
    
    `bin/rails db:seed:replant` - generates test data (can be rerun to regenerate test data)

4. **Webpacker One Time Setup** 

   `bundle exec rails webpacker:compile`

### Getting Started

See [Running the App / Verifying Installation](https://github.com/rubyforgood/casa#running-the-app--verifying-installation). 

A good option for editing files in WSL is [Visual Studio Code Remote- WSL](https://code.visualstudio.com/docs/remote/wsl)

