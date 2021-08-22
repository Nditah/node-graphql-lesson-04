//* node-graphql/src/resolvers.js

const { prisma } = require("./database.js");

const Student = {
  id: (parent, args, context, info) => parent.id,
  email: (parent) => parent.email,
  fullName: (parent) => parent.fullName,
  enrolled: (parent) => parent.enrolled,
  dept: (parent, args) => {
    return prisma.department.findFirst({
      where: { id: parent.id },
    });
  },
};

const Department = {
  id: (parent) => parent.id,
  name: (parent) => parent.name,
  description: (parent) => parent.description,
  students: (parent, args) => {
    return prisma.student.findFirst({
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
    return prisma.course.findFirst({
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
    return prisma.teacher.findFirst({
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
    return prisma.department.create({
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
