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
