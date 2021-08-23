-- CreateTable
CREATE TABLE "_CourseToDepartment" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "_CourseToDepartment_AB_unique" ON "_CourseToDepartment"("A", "B");

-- CreateIndex
CREATE INDEX "_CourseToDepartment_B_index" ON "_CourseToDepartment"("B");

-- AddForeignKey
ALTER TABLE "_CourseToDepartment" ADD FOREIGN KEY ("A") REFERENCES "course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_CourseToDepartment" ADD FOREIGN KEY ("B") REFERENCES "department"("id") ON DELETE CASCADE ON UPDATE CASCADE;
