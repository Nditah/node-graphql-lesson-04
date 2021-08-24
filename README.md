<!-- # node-graphql-lesson-04 -->

## Introduction

GraphQL is a query language designed to build client applications by providing an intuitive and flexible syntax and system for describing their data requirements and interactions. In the previous [lesson](https://dev.to/nditah/how-to-build-a-graphql-api-with-node-prisma-and-postgres-ajg), you learnt how use GraphQL and [Prisma](https://www.prisma.io?utm_source=Prisma+Ambassador&utm_medium=Blog+post&utm_campaign=Prisma+AP+Ndi-tah+Anyeh+Samweld) in combination as their responsibilities complement each other. 
In this lesson, you learn how to work with multiple models having complex relationships that truly mirrors a business.

## Content


🔷  Step 1 — Creating the Node.js Project

🔷  Step 2 — Setting Up Prisma with PostgreSQL

🔷  Step 3 — Creating and Migrating the Database with Prisma

🔷  Step 4 — Defining the GraphQL Schema

🔷  Step 5 — Defining the GraphQL Resolvers

🔷  Step 6 — Creating the GraphQL Server

🔷  Step 7 — Testing and Deployment



## Prerequisites

- Complete the [previous lesson](https://dev.to/nditah/how-to-build-a-graphql-api-with-node-prisma-and-postgres-ajg)
  


## 🔷  Step 1 — Creating the Node.js Project

First, create a new directory for your project, initialize npm and install dependencies:


    $ mkdir node-graphql-lesson-04

    $ cd node-graphql-lesson-04

    $ npm init --yes

    $ npm install apollo-server graphql


- *apollo-server:* [Apollo Server](https://www.apollographql.com/docs/apollo-server/) is a community-maintained open-source GraphQL server that's compatible with any GraphQL client. It's the best way to build a production-ready, self-documenting GraphQL API that can use data from any source.

- *graphql:* [GraphQL.js](https://www.npmjs.com/package/graphql) is the JavaScript reference implementation for GraphQL. It provides two important capabilities: building a type schema and serving queries against that type schema

You have created your project and installed the dependencies. In the next step you define the GraphQL schema which determines the operations that the API can handle. 


## 🔷  Step 2 — Setting Up Prisma with PostgreSQL

The [Prisma](https://www.prisma.io?utm_source=Prisma+Ambassador&utm_medium=Blog+post&utm_campaign=Prisma+AP+Ndi-tah+Anyeh+Samweld) schema is the main configuration file for your Prisma setup and contains your database schema.

Begin by installing the Prisma CLI with the following command:

    $ npm install prisma -D

The [Prisma](https://www.prisma.io?utm_source=Prisma+Ambassador&utm_medium=Blog+post&utm_campaign=Prisma+AP+Ndi-tah+Anyeh+Samweld) CLI will help with database workflows such as running database migrations and generating Prisma Client.

Next, you’ll set up your PostgreSQL database using Docker. Create a new Docker Compose file with the following command:

    $  touch docker-compose.yml

Now add the following code to the newly created file:



```yml
# node-graphql-lesson-04/docker-compose.yml

version: '3.8'
services:
  postgres:
    image: postgres:13
    restart: always
    environment:
      - POSTGRES_USER=db_user
      - POSTGRES_PASSWORD=db_password
    volumes:
      - postgres:/var/lib/postgresql/data
    ports:
      - '5432:5432'
volumes:
  postgres:

```

This Docker Compose configuration file is responsible for starting the official PostgreSQL Docker image on your machine. The POSTGRES_USER and POSTGRES_PASSWORD environment variables set the credentials for the superuser (a user with admin privileges). You will also use these credentials to connect Prisma to the database. Finally, you define a volume where PostgreSQL will store its data, and bind the 5432 port on your machine to the same port in the Docker container.

With this setup in place, go ahead and launch the PostgreSQL database server with the following command:

    $ docker-compose up -d

With the PostgreSQL container running, you can now create your Prisma setup. Run the following command from the Prisma CLI:

    $ npx prisma init

```
# node-graphql-lesson-04/prisma/.env

DATABASE_URL="postgresql://db_user:db_password@localhost:5432/college_db?schema=public"
```


## 🔷  Step 3 — Creating and Migrating the Database with Prisma


Your GraphQL API for College has a single entity named *_Student_*. In this step, you’ll evolve the API by defining a new model in the Prisma schema and adapting the GraphQL schema to make use of the new model. You will introduce a *_Teacher_*, a *_Course_* and a *_Department_* model. Also, there exist a one-to-many relation from *_Department_* to the *_Student_* model as well as betwwen a *_Teacher_*, to a *_Course_*. This will allow you to represent the Teacher of Course and associate multiple Courses to each Teacher for instance. Then you will evolve the GraphQL schema to allow creating Teacher and associating Course with teachers through the API.

First, open the Prisma schema and add the following:

The college management system basically should have the following entities:
- Students
- Teachers
- Departments
- Courses

Other entities like Lessons, Fees, Marksheet, and Classes are obviously part of the solution, however, but for the sake of this lesson would not be necessary. See the entity diangram below:

Go to node-graphql/prisma/schema.prisma Add the following model definitions to it:

```js
//* node-graphql-lesson-04/prisma/schema.prisma

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model Student {
  id        Int        @id @default(autoincrement())
  email     String     @unique @db.VarChar(255)
  fullName  String?    @db.VarChar(255)
  enrolled  Boolean    @default(false)
  dept      Department @relation(fields: [deptId], references: [id])
  deptId    Int
  createdAt DateTime   @default(now())
  updatedAt DateTime   @updatedAt

  @@map(name: "student")
}

model Department {
  id          Int       @id @default(autoincrement())
  name        String    @unique
  description String?   @db.VarChar(500)
  students    Student[]
  courses     Course[]
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  @@map(name: "department")
}

model Teacher {
  id        Int         @id @default(autoincrement())
  email     String      @unique @db.VarChar(255)
  fullName  String?     @db.VarChar(255)
  courses   Course[]
  type      TeacherType @default(FULLTIME)
  createdAt DateTime    @default(now())
  updatedAt DateTime    @updatedAt

  @@map(name: "teacher")
}

model Course {
  id          Int         @id @default(autoincrement())
  code        String      @unique
  title       String      @db.VarChar(255)
  description String?     @db.VarChar(500)
  teacher     Teacher?    @relation(fields: [teacherId], references: [id])
  teacherId   Int?
  dept        Department? @relation(fields: [deptId], references: [id])
  deptId      Int?
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt

  @@map(name: "course")
}

enum TeacherType {
  FULLTIME
  PARTTIME
}

```



You’ve added the following to the Prisma schema:

- The *Department* model to represent course Specialties.
- The *Teacher* model to represent course Instructors/Facilitators.
- The *Course* model to represent subject matters

The Student model has been modifies as follows:

- Two relation fields: dept and deptId. Relation fields define connections between models at the Prisma level and do not exist in the database. These fields are used to generate the Prisma Client and to access relations with Prisma Client.

- The deptId field, which is referenced by the @relation attribute. Prisma will create a foreign key in the database to connect Student and Department.

Note that the *dept* field in the Student model is optional, similarly to the teacher field in Course model. That means you’ll be able to create students unassociated with a department as well as a course without and associated Teacher.

The relationship makes sense because course are usually later on assigned to Teachers and also registered students are usually matriculated into a Department.

Next, create and apply the migration locally with the following command:

    $  npx prisma migrate dev

If the migration succeeds you will receive the following:

```
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Datasource "db": PostgreSQL database "college_db", schema "public" at "localhost:5432"

Database reset successful

The following migration(s) have been applied:

migrations/
  └─ 20210821201819_init/
    └─ migration.sql

✔ Generated Prisma Client (2.29.1) to ./node_modules/@prisma/client in 109ms

```

The command also generates Prisma Client so that you can make use of the new table and fields.

You will now update the GraphQL schema and resolvers to make use of the updated database schema.



With the model in place, you can now create the corresponding table in the database using Prisma Migrate. This can be done with the migrate dev command that creates the migration files and runs them.

Open up your terminal again and run the following command:

    $ npx prisma migrate dev --name "init" 

You’ve now created your database schema. Next, you will install Prisma Client.


Prisma Client is an auto-generated and type-safe Object Relational Mapper (ORM) that you can use to programmatically read and write data in a database from a Node.js application. In this step, you’ll install Prisma Client in your project.

Open up your terminal again and install the Prisma Client npm package:

    $  npm install @prisma/client

With the database and GraphQL schema created, and Prisma Client installed, you will now use Prisma Client in the GraphQL resolvers to read and write data in the database. You’ll do this by replacing the content of the database.js, which you’ve used so far to hold your data.


```js
//* node-graphql-lesson-04/src/database.js

const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient();

module.exports = {
  prisma,
}
```

Next, create a file database.js in your project src and add the students array to it as shown below:


## 🔷  Step 4 — Defining the GraphQL Schema

A schema is a collection of type definitions (hence typeDefs) that together define the shape of queries that can be executed against your API. This will convert the GraphQL schema string into the format that Apollo expects. Create a *src* directory and inside it, create the *schema.js* file.


    $ mkdir src
    $ touch src/schema.js

Now add the following code to the file:

```js
//* node-graphql-lesson-04/src/schema.js

const { gql } = require("apollo-server")

const typeDefs = gql `

 type Student {
    id: ID!
    email: String!
    fullName: String!
    dept: Department!
    enrolled: Boolean
    updatedAt: String
    createdAt: String
  }

  type Department {
    id: ID!
    name: String!
    description: String
    students: [Student]
    courses: [Course]
    updatedAt: String
    createdAt: String
  }

  type Teacher {
    id: ID!
    email: String!
    fullName: String!
    courses: [Course]
    type: TeacherType
    updatedAt: String
    createdAt: String
  }

  type Course {
    id: ID!
    code: String!
    title: String!
    description: String
    teacher: Teacher
    dept: Department
    updatedAt: String
    createdAt: String
  }

  input TeacherCreateInput {
    email: String!
    fullName: String!
    courses: [CourseCreateWithoutTeacherInput!]
  }

  input CourseCreateWithoutTeacherInput {
    code: String!
    title: String!
    description: String
  }

  type Query {
    enrollment: [Student!]
    students: [Student!]
    student(id: ID!): Student
    departments: [Department!]!
    department(id: ID!): Department
    courses: [Course!]!
    course(id: ID!): Course
    teachers: [Teacher!]!
    teacher(id: ID!): Teacher
  }

  type Mutation {
    registerStudent(email: String!, fullName: String!, deptId: Int!): Student!
    enroll(id: ID!): Student
    createTeacher(data: TeacherCreateInput!): Teacher!
    createCourse(code: String!, title: String!, teacherEmail: String): Course!
    createDepartment(name: String!, description: String): Department!
  }

enum TeacherType {
  FULLTIME
  PARTTIME
}
`

module.exports = {
    typeDefs,
  }
  
```


 In this updated code, you’re adding the following changes to the GraphQL schema:

- The *Teacher* type, which returns an array of *Course*.
- The *Department* type, which returns an array of *Student*.
- The *Course* type which has a *Teacher* type
- The dept of type *Department* field to the *Student* type.
- The createTeacher mutation, which expects the TeacherCreateInput as its input type.

- The CourseCreateWithoutTeacherInput input type used in the TeacherCreateInput input for creating teachers as part of the createTeacher mutation.

- The teacherEmail optional argument to the createCourse mutation.

With the schema created, you will now create the resolvers to match the schema.


## 🔷  Step 5 — Defining the GraphQL Resolvers


Make a sub-directory called *resolvers* inside the *src* directory.
Now, inside the *resolvers*  create three files _index.js_, _query.js_, _mutation.js_ as follows:


    $ mkdir src/resolvers
    $ touch src/resolvers/index.js
    $ touch src/resolvers/query.js
    $ touch src/resolvers/mutation.js

Inside the mutation.js file, enter the following:

```js
//* node-graphql-lesson-04/src/resolvers/mutation.js

const { prisma } = require("../database.js");

const Mutation = {
    registerStudent: (parent, args) => {
      return prisma.student.create({
        data: {
          email: args.email,
          fullName: args.fullName,
          dept: args.deptId && {
            connect: { id: args.deptId },
          },
        },
      });
    },
    enroll: (parent, args) => {
      return prisma.student.update({
        where: { id: Number(args.id) },
        data: {
          enrolled: true,
        },
      });
    },
  
    createTeacher: (parent, args) => {
      return prisma.teacher.create({
        data: {
          email: args.data.email,
          fullName: args.data.fullName,
          courses: {
            create: args.data.courses,
          },
        },
      });
    },
  
    createCourse: (parent, args) => {
      console.log(parent, args)
      return prisma.course.create({
        data: {
          code: args.code,
          title: args.title,
          teacher: args.teacherEmail && {
            connect: { email: args.teacherEmail },
          },
        },
      });
    },
  
    createDepartment: (parent, args) => {
      return prisma.department.create({
        data: {
          name: args.name,
          description: args.description,
        },
      });
    },
  };

  module.exports = {
    Mutation,
  }
  
  
```

**Inside the query.js file, enter the following:**

```js
//* node-graphql-lesson-04/src/resolvers/query.js

const { prisma } = require("../database.js");

const Query = {
    enrollment: (parent, args) => {
      return prisma.student.findMany({
        where: { enrolled: true },
      });
    },
    student: (parent, args) => {
      return prisma.student.findFirst({
        where: { id: Number(args.id) },
      });
    },
  
    students: (parent, args) => {
      return prisma.student.findMany({});
    },
  
    departments: (parent, args) => {
      return prisma.department.findMany({});
    },
  
    department: (parent, args) => {
      return prisma.department.findFirst({
        where: { id: Number(args.id) },
      });
    },
  
    courses: (parent, args) => {
      return prisma.course.findMany({});
    },
  
    course: (parent, args) => {
      return prisma.course.findFirst({
        where: { id: Number(args.id) },
      });
    },
  
    teachers: (parent, args) => {
      return prisma.teacher.findMany({});
    },
  
    teacher: (parent, args) => {
      return prisma.teacher.findFirst({
        where: { id: Number(args.id) },
      });
    },
  };
  
  module.exports = {
    Query,
  }
  
```

**And lastly, inside the index.js file, enter the following:**

```js
//* node-graphql-lesson-04/src/resolvers/index.js

const { prisma } = require("../database.js");
const { Query } = require("./query.js");
const { Mutation } = require("./mutation.js");

const Student = {
  id: (parent, args, context, info) => parent.id,
  email: (parent) => parent.email,
  fullName: (parent) => parent.fullName,
  enrolled: (parent) => parent.enrolled,
  dept: (parent, args) => {
    return prisma.department.findFirst({
      where: { id: parent.dept },
    });
  },
};

const Department = {
  id: (parent) => parent.id,
  name: (parent) => parent.name,
  description: (parent) => parent.description,
  students: (parent, args) => {
    return prisma.department.findUnique({
        where: { id: parent.id },
      }).students();
  },
  courses: (parent, args) => {
    return prisma.department.findUnique({
        where: { id: parent.id },
      }).courses();
  },
};

const Teacher = {
  id: (parent) => parent.id,
  email: (parent) => parent.email,
  fullName: (parent) => parent.fullName,
  courses: (parent, args) => {
    return prisma.teacher.findUnique({
        where: { id: parent.id },
      }).courses();
  },
};

const Course = {
  id: (parent) => parent.id,
  code: (parent) => parent.code,
  title: (parent) => parent.title,
  description: (parent) => parent.description,
  teacher: (parent, args) => {
    return prisma.course.findUnique({
        where: { id: parent.id },
      }).teacher();
  },
  dept: (parent, args) => {
    return prisma.course.findUnique({
      where: { id: parent.id },
    }).dept();
  },
};

const resolvers = {
  Student,
  Department,
  Teacher,
  Course,
  Query,
  Mutation,
};

module.exports = {
  resolvers,
};

```

Let’s break down the changes to the resolvers:

- The createCourse mutation resolver now uses the teacherEmail argument (if passed) to create a relation between the created course and an existing teacher.

- The new createTeacher mutation resolver creates a teacher and related courses using nested writes.

- The Teacher.courses and Post.teacher resolvers define how to resolve the courses and teacher fields when the Teacher or Post are queried. These use Prisma’s Fluent API to fetch the relations.




## 🔷  Step 6 — Creating the GraphQL Server

In this step, you will create the GraphQL server with Apollo Server and bind it to a port so that the server can accept connections.

First, run the following command to create the file for the server:

    $ touch src/index.js

Now add the following code to the file:

```js
//* node-graphql-lesson-04/src/index.js

const { ApolloServer } = require('apollo-server')
const { typeDefs } = require('./schema')
const { resolvers } = require('./resolvers')

const port = process.env.PORT || 9090;

const server = new ApolloServer({ resolvers, typeDefs });

server.listen({ port }, () => console.log(`Server runs at: http://localhost:${port}`));
```



Start the server to test the GraphQL API:

    $  npm start
    $  npm install nodemon -D
 

Finally, your package.json file looks like:
```json
{
  "name": "node-graphql-lesson-04",
  "version": "1.0.0",
  "description": "Graphql backend with node, prisma, postgres and docker",
  "main": "index.js",
  "scripts": {
    "start": "nodemon src/"
  },
  "keywords": [
    "Graphql",
    "Backend",
    "Prisma",
    "Postgre",
    "Docker",
    "Node.js"
  ],
  "author": "Nditah Sam <nditah@telixia.com>",
  "license": "ISC",
  "dependencies": {
    "@prisma/client": "^2.29.1",
    "apollo-server": "^3.1.2",
    "graphql": "^15.5.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.12",
    "prisma": "^2.29.1"
  }
}
```

## 🔷  Step 7 — Testing and Deployment

Test the node-graphql-prisma backend by executing the following GraphQL queries and mutations:

### Create Department

```gql
 mutation {
  createDepartment(name: "Backend Engineering", description: "Express, ApolloServer, Prisma, Docker, Postgres") {
    id
    name
    description

  }
}

mutation {
  createDepartment(name: "Frontend Development", description: "React, Angular, Vue, Gatsby, CSS, Bootstrap") {
    id
    name
    description
  }
}
```

 ### Create Course


```gql

mutation CreateCourseMutation($createCourseCode: String!, $createCourseTitle: String!) {
  createCourse(code: $createCourseCode, title: $createCourseTitle) {
    id
    code
    title
    description
    teacher {
      id
      fullName
    }
  }
}
```
 
 ### Create Teacher

```gql
mutation CreateTeacherMutation($createTeacherData: TeacherCreateInput!) {
  createTeacher(data: $createTeacherData) {
    id
    fullName
    createdAt
    courses {
      id
      code
      title
    }
  }
}
```
 

Notice that you can fetch the teacher whenever the return value of a query is Course. In this example, the Course.teacher resolver will be called.

Finally, commit your changes and push to deploy the API:

    $  git add .
    $  git commit -m "Feature: Add Teacher, Couse, Department"
    $  git push
 
You have successfully evolved your database schema with Prisma Migrate and exposed the new model in your GraphQL API.
The Github repository of this project can be found [here](https://github.com/Nditah/node-graphql-lesson-04.git).


## Conclusion

Even though this lesson is not meant to compare REST vs. Graphql, it should be highlighted that:

🔷 While GraphQL simplifies data consumption, REST design standards are strongly favoured by many sectors due to cache-ability features, security, tooling community and ultimate reliability. For this reason and its storied record, many web services favour REST design.

🔷 Regardless of their choice, backend developers must understand exactly how frontend users will interact with their APIs to make the correct design choices. Though some API styles are easier to adopt than others, with the right documentation and walk-throughs in place, backend engineers can construct a high-quality API platform that frontend developers will love, no matter what style is used.


## Further Reading

[1] [Prisma Fluent-Api](https://www.prisma.io/docs/concepts/components/prisma-client/relation-queries#fluent-api?utm_source=Prisma+Ambassador&utm_medium=Blog+post&utm_campaign=Prisma+AP+Ndi-tah+Anyeh+Samweld)
[2] [Prisma Components](https://www.prisma.io/docs/concepts/components/prisma-schema/data-model?utm_source=Prisma+Ambassador&utm_medium=Blog+post&utm_campaign=Prisma+AP+Ndi-tah+Anyeh+Samweld)
[3] [Introduction to GraphQl](https://www.howtographql.com/graphql-js/0-introduction/)
[4] [Introduction to Apollo Server](https://www.apollographql.com/docs/apollo-server/)


_**Happy Reading & Coding**_


#  💻 📓 💝 📕  💓 📗  💖  📘  💗 📙 💜 📔 📒 🎊 📚 📖 💙 🎁  🎉
