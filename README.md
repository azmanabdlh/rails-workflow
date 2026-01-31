![Rails Workflow Example](example.png)
## 📋 Project Overview

**Rails Workflow** is a learning project designed to build a recruitment job workflow management system. This project implements a modern application architecture using Ruby on Rails with the following features:

- **Candidate Management**: Track candidate data throughout the recruitment process
- **Workflow Stage Management**: Manage recruitment stages with progress tracking
- **User & Authentication**: Login system and user management for recruiters and reviewers
- **Job Posts Management**: Create and manage job openings
- **Reviewer Assignment**: Assign reviewers to evaluate candidates

## 🚀 Quick Start

### Prerequisites

- Ruby 3.0 or higher
- Rails 8.0 or higher
- SQLite3
- PostgreSQL

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd rails-workflow
```

2. Install dependencies
```bash
bundle install
```

3. Setup the database
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Start the server
```bash
rails server
```

The application will run at `http://localhost:3000`

## 🗄️ Database Models

- **User**: Recruiter and reviewer accounts
- **Post**: Job openings
- **Candidate**: Applicant data and application status
- **Stage**: Recruitment stages (Interview, Assessment, etc.)
- **Workflow**: Workflow configuration for each job post
- **Reviewer**: Reviewer assignments for candidate evaluation

## 📝 License

MIT
