From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 13:45:34 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archiver.c
Message-ID: <20101222134534.18798.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 13:45:33

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archiver.c 

Log message:
	Add backtraces for archive and backup_locally
	
	If archive or back_locally fails - add stack trace.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1852&r2=1.1853
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2010/12/22 12:14:17	1.1852
+++ LVM2/WHATS_NEW	2010/12/22 13:45:33	1.1853
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Add backtraces for archive and backup_locally in check_current_backup().
   Fix memory leak in debug mode of restart_clvmd() error path.
   Log error message for pthread_join() failure in clvmd.
 
--- LVM2/lib/format_text/archiver.c	2010/12/08 20:50:49	1.35
+++ LVM2/lib/format_text/archiver.c	2010/12/22 13:45:33	1.36
@@ -452,9 +452,12 @@
 	log_suppress(old_suppress);
 
 	if (vg_backup) {
-		archive(vg_backup);
+		if (!archive(vg_backup))
+			stack;
 		free_vg(vg_backup);
 	}
-	archive(vg);
-	backup_locally(vg);
+	if (!archive(vg))
+		stack;
+	if (!backup_locally(vg))
+		stack;
 }


