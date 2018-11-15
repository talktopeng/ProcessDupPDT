Author: Peng Wang
Date: 15/11/2018

This project process duplicate Product, Determination and Technique in AIMS Database.

Remote Repository
--------------------------------
pwang@SYD-PWANG3 MINGW64 /g/NATAWorks/CodeRepo/AIMSDB/ProcessDuplicatePDTSln
$ git init /K/ProcessDupPDT.git --bare  # K: is a network drive mapping to //vmapnrh32/CodeRepo

Initial Command
--------------------------------
$ git commit -m "First Commit"
[master (root-commit) b9212df] First Commit
 10 files changed, 981 insertions(+)
 create mode 100644 .vs/ProcessDuplicatePDTSln/v14/.ssms_suo
 create mode 100644 ProcessDuplicatePDTProj/CreateDBSnapshot.sql
 create mode 100644 ProcessDuplicatePDTProj/CreateTableOnAIMSPROD.sql
 create mode 100644 ProcessDuplicatePDTProj/CreateTableOnUAT.sql
 create mode 100644 ProcessDuplicatePDTProj/LoadExcelFiles.sql
 create mode 100644 ProcessDuplicatePDTProj/MainScript.sql
 create mode 100644 ProcessDuplicatePDTProj/ProcessDuplicatePDTProj.ssmssqlproj
 create mode 100644 ProcessDuplicatePDTProj/SanityCheck.sql
 create mode 100644 ProcessDuplicatePDTSln.ssmssln
 create mode 100644 Readme.md
 
 Push to Remote
 ---------------------------------
 $ git push origin master
Enumerating objects: 19, done.
Counting objects: 100% (19/19), done.
Delta compression using up to 8 threads
Compressing objects: 100% (16/16), done.
Writing objects: 100% (19/19), 9.48 KiB | 66.00 KiB/s, done.
Total 19 (delta 4), reused 0 (delta 0)
To K:/ProcessDupPDT.git
 * [new branch]      master -> master
