From: taka@sourceware.org <taka@sourceware.org>
Date: 23 Mar 2009 22:57:27 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archiver.c
Message-ID: <20090323225727.8354.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	taka at sourceware.org	2009-03-23 22:57:27

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archiver.c 

Log message:
	Restore log_suppress state when metadata backup file is up-to-date.
	
	Author: Takahiro Yasui <tyasui@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1070&r2=1.1071
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2009/03/23 22:29:06	1.1070
+++ LVM2/WHATS_NEW	2009/03/23 22:57:27	1.1071
@@ -10,6 +10,7 @@
   Fix error message when adding metadata directory to internal list fails.
   Fix size and error message of memory allocation at backup initialization.
   Remove old metadata backup file after renaming vg.
+  Restore log_suppress state when metadata backup file is up-to-date.
 
 Version 2.02.45 - 3rd March 2009
 ================================
--- LVM2/lib/format_text/archiver.c	2009/03/23 21:56:32	1.19
+++ LVM2/lib/format_text/archiver.c	2009/03/23 22:57:27	1.20
@@ -405,8 +405,10 @@
 	/* Up-to-date backup exists? */
 	if ((vg_backup = backup_read_vg(vg->cmd, vg->name, path)) &&
 	    (vg->seqno == vg_backup->seqno) &&
-	    (id_equal(&vg->id, &vg_backup->id)))
+	    (id_equal(&vg->id, &vg_backup->id))) {
+		log_suppress(0);
 		return;
+	}
 	log_suppress(0);
 
 	if (vg_backup)


