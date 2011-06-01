From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Jun 2011 12:24:17 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20110601122417.22472.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-06-01 12:24:16

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Clarify error message when unable to convert an LV into a snapshot of an LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2000&r2=1.2001
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163

--- LVM2/WHATS_NEW	2011/05/24 14:12:36	1.2000
+++ LVM2/WHATS_NEW	2011/06/01 12:24:15	1.2001
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Clarify error message when unable to convert an LV into a snapshot of an LV.
   Add and use dev_open_readonly and variations.
   Do not log a superfluous stack message when the lv is properly processed.
   Do not issue an error message when unable to remove .cache on read-only fs.
--- LVM2/tools/lvconvert.c	2011/05/07 13:56:13	1.162
+++ LVM2/tools/lvconvert.c	2011/06/01 12:24:16	1.163
@@ -1391,7 +1391,7 @@
 	}
 
 	if (org->status & (LOCKED|PVMOVE|MIRRORED) || lv_is_cow(org)) {
-		log_error("Unable to create a snapshot of a %s LV.",
+		log_error("Unable to convert an LV into a snapshot of a %s LV.",
 			  org->status & LOCKED ? "locked" :
 			  org->status & PVMOVE ? "pvmove" :
 			  org->status & MIRRORED ? "mirrored" :


