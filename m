From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jun 2009 22:00:20 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
Message-ID: <20090606220020.21844.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-06 22:00:20

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c 

Log message:
	Round readahead more inteligently and print warning.
	
	Round readahead at least to one page up.
	Print warning instead of verbose message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1142&r2=1.1143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/WHATS_NEW	2009/06/05 20:00:52	1.1142
+++ LVM2/WHATS_NEW	2009/06/06 22:00:20	1.1143
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Round up requested readahead to at least one page and print warning.
   Try to repair vg before actual vgremove when force flag provided.
   Fix possible double release of VG after recovery.
   Add parameter to process_each_vg specifying what to do with inconsistent VG.
--- LVM2/tools/lvchange.c	2009/06/01 14:43:28	1.103
+++ LVM2/tools/lvchange.c	2009/06/06 22:00:20	1.104
@@ -370,9 +370,12 @@
 
 	if (read_ahead != DM_READ_AHEAD_AUTO &&
 	    read_ahead != DM_READ_AHEAD_NONE && read_ahead % pagesize) {
-		read_ahead = (read_ahead / pagesize) * pagesize;
-		log_verbose("Rounding down readahead to %u sectors, a multiple "
-			    "of page size %u.", read_ahead, pagesize);
+		if (read_ahead < pagesize)
+			read_ahead = pagesize;
+		else
+			read_ahead = (read_ahead / pagesize) * pagesize;
+		log_warn("WARNING: Overriding readahead to %u sectors, a multiple "
+			    "of %uK page size.", read_ahead, pagesize >> 1);
 	}
 
 	if (lv->read_ahead == read_ahead) {


