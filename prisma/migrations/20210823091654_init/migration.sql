-- CreateEnum
CREATE TYPE "TeacherType" AS ENUM ('FULLTIME', 'PARTTIME');

-- CreateTable
CREATE TABLE "Student" (
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
CREATE TABLE "Department" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Teacher" (
    "id" SERIAL NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "fullName" VARCHAR(255),
    "type" "TeacherType" NOT NULL DEFAULT E'FULLTIME',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Course" (
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
CREATE UNIQUE INDEX "Student.email_unique" ON "Student"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Department.name_unique" ON "Department"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Teacher.email_unique" ON "Teacher"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Course.code_unique" ON "Course"("code");

-- AddForeignKey
ALTER TABLE "Student" ADD FOREIGN KEY ("deptId") REFERENCES "Department"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Course" ADD FOREIGN KEY ("teacherId") REFERENCES "Teacher"("id") ON DELETE SET NULL ON UPDATE CASCADE;
