/*
  Warnings:

  - You are about to drop the `Course` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Department` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Student` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Teacher` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "Course" DROP CONSTRAINT "Course_teacherId_fkey";

-- DropForeignKey
ALTER TABLE "Student" DROP CONSTRAINT "Student_deptId_fkey";

-- DropTable
DROP TABLE "Course";

-- DropTable
DROP TABLE "Department";

-- DropTable
DROP TABLE "Student";

-- DropTable
DROP TABLE "Teacher";

-- CreateTable
CREATE TABLE "student" (
    "id" SERIAL NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "fullName" VARCHAR(255),
    "enrolled" BOOLEAN NOT NULL DEFAULT false,
    "deptId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "department" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "teacher" (
    "id" SERIAL NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "fullName" VARCHAR(255),
    "type" "TeacherType" NOT NULL DEFAULT E'FULLTIME',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "course" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "teacherId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "student.email_unique" ON "student"("email");

-- CreateIndex
CREATE UNIQUE INDEX "department.name_unique" ON "department"("name");

-- CreateIndex
CREATE UNIQUE INDEX "teacher.email_unique" ON "teacher"("email");

-- CreateIndex
CREATE UNIQUE INDEX "course.code_unique" ON "course"("code");

-- AddForeignKey
ALTER TABLE "student" ADD FOREIGN KEY ("deptId") REFERENCES "department"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "course" ADD FOREIGN KEY ("teacherId") REFERENCES "teacher"("id") ON DELETE SET NULL ON UPDATE CASCADE;
