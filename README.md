# node-graphql-lesson-04

## Introduction

In the previous lesson, you learnt how use GraphQL and Prisma in combination as their responsibilities complement each other. 
In this lesson, you will add advance features to the backend application. 

## Content


🔷  Step 10 — Modifying the Student Model and Adding the More Models

The Github repository of this project can be found [here](https://github.com/Nditah/node-graphql-lesson-04.git).


## Prerequisites

- Complete Lesson!
  

## Step 10 — Modifying the Student Model and Adding the More Models

Your GraphQL API for College has a single entity named *_Student_*. In this step, you’ll evolve the API by defining a new model in the Prisma schema and adapting the GraphQL schema to make use of the new model. You will introduce a *_Teacher_*, a *_Course_* and a *_Department_* model. Also, there exist a one-to-many relation from *_Department_* to the *_Student_* model as well as betwwen a *_Teacher_*, to a *_Course_*. This will allow you to represent the Teacher of Course and associate multiple Courses to each Teacher for instance. Then you will evolve the GraphQL schema to allow creating Teacher and associating Course with teachers through the API.

First, open the Prisma schema and add the following:

```js
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

// node-graphql/prisma/schema.prisma

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model Student {
  id        Int         @id @default(autoincrement())
  email     String      @unique
  fullName  String?
  enrolled  Boolean     @default(false)
  dept      Department @relation(fields: [deptId], references: [id])
  deptId    Int
  createdAt DateTime    @default(now())
}

model Department {
  id          Int       @id @default(autoincrement())
  name        String    @unique
  description String?
  students    Student[]
  createdAt   DateTime  @default(now())
}

model Teacher {
  id        Int         @id @default(autoincrement())
  email     String      @unique
  fullName  String
  courses   Course[]
  type      TeacherType @default(FULLTIME)
  createdAt DateTime    @default(now())
}

model Course {
  id          Int      @id @default(autoincrement())
  code        String   @unique
  title       String
  description String?
  teacher     Teacher? @relation(fields: [teacherId], references: [id])
  teacherId   Int?
  createdAt   DateTime @default(now())
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

    $  npx prisma migrate reset  --force

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

Open the src/schema.js file and add update typeDefs as follows:


```js
//* node-graphql/src/schema.js

const { gql } = require("apollo-server")

const typeDefs = gql `

 type Student {
    id: ID!
    email: String!
    fullName: String!
    dept: Department!
    enrolled: Boolean
  }

  type Department {
    id: ID!
    name: String!
    description: String!
    students: [Student!]
  }

  type Teacher {
    id: ID!
    email: String!
    fullName: String!
    courses: [Course!]
  }

  type Course {
    id: ID!
    code: String!
    title: String!
    description: String
    teacher: Teacher
  }

  input TeacherCreateInput {
    email: String!
    fullName: String
    courses: [CourseCreateWithoutTeacherInput!]
  }

  input CourseCreateWithoutTeacherInput {
    code: String!
    name: String!
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
    createCourse(code: String!, title: String!, teacherEmail: String!): Course!
    createDepartment(name: String!, description: String): Department!
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

With the schema updated, you will now update the resolvers to match the schema.

Update the resolvers object as follows:


```js
//* node-graphql/src/resolvers.js

const { prisma } = require("./database.js");

const Student = {
  id: (parent, args, context, info) => parent.id,
  email: (parent) => parent.email,
  fullName: (parent) => parent.fullName,
  enrolled: (parent) => parent.enrolled,
  dept: (parent, args) => {
    return prisma.department.findOne({
      where: { id: parent.id },
    });
  },
};

const Department = {
  id: (parent) => parent.id,
  name: (parent) => parent.name,
  description: (parent) => parent.description,
  students: (parent, args) => {
    return prisma.department
      .findOne({
        where: { id: parent.id },
      })
      .students();
  },
};

const Teacher = {
  id: (parent) => parent.id,
  email: (parent) => parent.email,
  fullName: (parent) => parent.fullName,
  courses: (parent, args) => {
    return prisma.teacher
      .findOne({
        where: { id: parent.id },
      })
      .courses();
  },
};

const Course = {
  id: (parent) => parent.id,
  code: (parent) => parent.code,
  title: (parent) => parent.title,
  description: (parent) => parent.description,
  teacher: (parent, args) => {
    return prisma.course
      .findOne({
        where: { id: parent.id },
      })
      .teacher();
  },
};

const Query = {
  enrollment: (parent, args) => {
    return prisma.student.findMany({
      where: { enrolled: true },
    });
  },
  student: (parent, args) => {
    return prisma.student.findOne({
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
    return prisma.department.findOne({
      where: { id: Number(args.id) },
    });
  },

  courses: (parent, args) => {
    return prisma.course.findMany({});
  },

  course: (parent, args) => {
    return prisma.course.findOne({
      where: { id: Number(args.id) },
    });
  },

  teachers: (parent, args) => {
    return prisma.teacher.findMany({});
  },

  teacher: (parent, args) => {
    return prisma.teacher.findOne({
      where: { id: Number(args.id) },
    });
  },
};

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
        email: args.email,
        fullName: args.fullName,
        courses: {
          create: args.data.courses,
        },
      },
    });
  },

  createCourse: (parent, args) => {
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
    return prisma.student.create({
      data: {
        name: args.name,
        description: args.description,
      },
    });
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

Start the server to test the GraphQL API:

    $  npm start
 

## Tetsing 

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

mutation {
  createCourse(
    teacherEmail: "yohanne@telixia.com"
    code: "DAML"
    name: "Data Analytics and Machine Learning"
    description: "Data Analytics and Machine Learning with PowerBi, Tableau, and AutoML"
  ) {
    id
    code
    name
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
mutation {
  createTeacher(data: { 
    email: "yohanne@telixia.com",
    fullName: "Yohanne"
  }) {
    id
    email
    fullName
  }
}
```
 

Notice that you can fetch the teacher whenever the return value of a query is Course. In this example, the Course.teacher resolver will be called.

Finally, commit your changes and push to deploy the API:

    $  git add .
    $  git commit -m "Feature: Add Teacher, Couse, Department"
    $  git push
 
You have successfully evolved your database schema with Prisma Migrate and exposed the new model in your GraphQL API.


## Conclusion

Even though this lesson is not meant to compare REST vs. Graphql, it should be highlighted that:

🔷 While GraphQL simplifies data consumption, REST design standards are strongly favoured by many sectors due to cache-ability features, security, tooling community and ultimate reliability. For this reason and its storied record, many web services favour REST design.

🔷 Regardless of their choice, backend developers must understand exactly how frontend users will interact with their APIs to make the correct design choices. Though some API styles are easier to adopt than others, with the right documentation and walk-throughs in place, backend engineers can construct a high-quality API platform that frontend developers will love, no matter what style is used.
