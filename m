From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 9 Sep 2010 13:13:14 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archive.c
Message-ID: <20100909131314.13747.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-09-09 13:13:12

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archive.c 

Log message:
	Add random suffix to archive file names to prevent races when being created.
	
	In certain configurations, we're not under a VG rw lock while trying to write
	a new archive file with VG metadata. A common example is using "vgs" while
	having the content of backup and archive directories empty. The code scans the
	content of these directories and tries to determine the final index that should
	be used in archive name. Since we're not under a lock, we can get into a race
	while choosing the index which could end up showing errors about not being able
	to rename to final archive name. Let's add random number suffix to these archive
	file names so we can avoid the race.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1728&r2=1.1729
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2010/09/09 13:07:13	1.1728
+++ LVM2/WHATS_NEW	2010/09/09 13:13:12	1.1729
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Add random suffix to archive file names to prevent races when being created.
   Reinitialize archive and backup handling on toolcontext refresh.
   Fix opprobriously slow I/O to cluster mirrors created with --nosync.
   Make poll_mirror_progress report PROGRESS_CHECK_FAILED if LV is not a mirror.
--- LVM2/lib/format_text/archive.c	2010/08/03 13:09:22	1.38
+++ LVM2/lib/format_text/archive.c	2010/09/09 13:13:12	1.39
@@ -226,7 +226,7 @@
 	       const char *dir, const char *desc,
 	       uint32_t retain_days, uint32_t min_archive)
 {
-	int i, fd, renamed = 0;
+	int i, fd, rnum, renamed = 0;
 	uint32_t ix = 0;
 	struct archive_file *last;
 	FILE *fp = NULL;
@@ -271,9 +271,12 @@
 		ix = last->index + 1;
 	}
 
+	rnum = rand_r(&vg->cmd->rand_seed);
+
 	for (i = 0; i < 10; i++) {
 		if (dm_snprintf(archive_name, sizeof(archive_name),
-				 "%s/%s_%05u.vg", dir, vg->name, ix) < 0) {
+				 "%s/%s_%05u-%d.vg",
+				 dir, vg->name, ix, rnum) < 0) {
 			log_error("Archive file name too long.");
 			return 0;
 		}


