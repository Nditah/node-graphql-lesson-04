//* node-graphql/src/database.js

const { PrismaClient } = require('@prisma/client')

const prisma = new PrismaClient();

module.exports = {
  prisma,
}
