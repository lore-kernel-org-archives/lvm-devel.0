From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Oct 2008 17:42:13 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20081017174213.29438.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-17 17:42:10

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.977&r2=1.978

--- LVM2/VERSION	2008/09/19 15:44:03	1.182
+++ LVM2/VERSION	2008/10/17 17:42:08	1.183
@@ -1 +1 @@
-2.02.41-cvs (2008-09-19)
+2.02.41-cvs (2008-10-17)
--- LVM2/WHATS_NEW	2008/10/17 10:57:14	1.977
+++ LVM2/WHATS_NEW	2008/10/17 17:42:08	1.978
@@ -1,5 +1,5 @@
-Version 2.02.41 -
-=====================================
+Version 2.02.41 - 17th October 2008
+===================================
   Use temp table to set device size when converting mirrors.
   In resume_mirror_images replace activate_lv with resume_lv as workaround.
   Avoid overwriting in-use on-disk text metadata by forgetting MDA_HEADER_SIZE.


