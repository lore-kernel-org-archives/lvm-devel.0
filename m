From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 09:48:05 -0000
Subject: LVM2 lib/metadata/metadata.c ./WHATS_NEW
Message-ID: <20080606094805.13580.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 09:48:04

Modified files:
	lib/metadata   : metadata.c 
	.              : WHATS_NEW 

Log message:
	Allow for vginfo changing during _vg_read.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.884&r2=1.885

--- LVM2/lib/metadata/metadata.c	2008/06/03 17:56:54	1.176
+++ LVM2/lib/metadata/metadata.c	2008/06/06 09:48:04	1.177
@@ -1757,7 +1757,7 @@
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
-					  "inconsistent", vginfo->vgname);
+					  "inconsistent", vg->name);
 				if (!partial_mode())
 					return NULL;
 			}
--- LVM2/WHATS_NEW	2008/06/05 14:24:27	1.884
+++ LVM2/WHATS_NEW	2008/06/06 09:48:04	1.885
@@ -9,6 +9,7 @@
 
 Version 2.02.37 - 
 =================================
+  Allow for vginfo changing during _vg_read.
   Decode numbers in clvmd debugging output.
   Add missing deactivation after activation failure in lvcreate -Zy.
   When activating, if precommitted metadata is still cached, assume it's live.


