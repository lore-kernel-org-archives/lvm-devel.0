From: taka@sourceware.org <taka@sourceware.org>
Date: 23 Mar 2009 21:56:33 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archiver.c
Message-ID: <20090323215633.407.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	taka at sourceware.org	2009-03-23 21:56:32

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archiver.c 

Log message:
	Fix size and error message of memory allocation at backup initialization.
	
	Author: Takahiro Yasui <tyasui@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1068&r2=1.1069
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2009/03/23 21:13:37	1.1068
+++ LVM2/WHATS_NEW	2009/03/23 21:56:32	1.1069
@@ -8,6 +8,7 @@
   Flush memory pool and fix locking in clvmd refresh and backup command.
   Fix unlocks in clvmd-corosync. Broken in 2.02.45.
   Fix error message when adding metadata directory to internal list fails.
+  Fix size and error message of memory allocation at backup initialization.
 
 Version 2.02.45 - 3rd March 2009
 ================================
--- LVM2/lib/format_text/archiver.c	2009/02/22 19:00:27	1.18
+++ LVM2/lib/format_text/archiver.c	2009/03/23 21:56:32	1.19
@@ -154,8 +154,8 @@
 		int enabled)
 {
 	if (!(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
-					       sizeof(*cmd->archive_params)))) {
-		log_error("archive_params alloc failed");
+					       sizeof(*cmd->backup_params)))) {
+		log_error("backup_params alloc failed");
 		return 0;
 	}
 


