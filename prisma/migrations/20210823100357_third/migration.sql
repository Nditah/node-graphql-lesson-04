/*
  Warnings:

  - You are about to alter the column `title` on the `course` table. The data in that column could be lost. The data in that column will be cast from `Text` to `VarChar(255)`.
  - You are about to alter the column `description` on the `course` table. The data in that column could be lost. The data in that column will be cast from `Text` to `VarChar(500)`.
  - You are about to alter the column `description` on the `department` table. The data in that column could be lost. The data in that column will be cast from `Text` to `VarChar(500)`.

*/
-- AlterTable
ALTER TABLE "course" ALTER COLUMN "title" SET DATA TYPE VARCHAR(255),
ALTER COLUMN "description" SET DATA TYPE VARCHAR(500);

-- AlterTable
ALTER TABLE "department" ALTER COLUMN "description" SET DATA TYPE VARCHAR(500);
