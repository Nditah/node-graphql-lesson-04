/*
  Warnings:

  - You are about to drop the `_CourseToDepartment` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "_CourseToDepartment" DROP CONSTRAINT "_CourseToDepartment_A_fkey";

-- DropForeignKey
ALTER TABLE "_CourseToDepartment" DROP CONSTRAINT "_CourseToDepartment_B_fkey";

-- AlterTable
ALTER TABLE "course" ADD COLUMN     "deptId" INTEGER;

-- DropTable
DROP TABLE "_CourseToDepartment";

-- AddForeignKey
ALTER TABLE "course" ADD FOREIGN KEY ("deptId") REFERENCES "department"("id") ON DELETE SET NULL ON UPDATE CASCADE;
