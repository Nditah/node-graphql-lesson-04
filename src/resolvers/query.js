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
  