From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Dec 2006 20:05:09 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20061214200509.26735.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-12-14 20:05:08

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.521&r2=1.522

--- LVM2/VERSION	2006/12/01 23:29:54	1.133
+++ LVM2/VERSION	2006/12/14 20:05:08	1.134
@@ -1 +1 @@
-2.02.17-cvs (2006-12-01)
+2.02.17-cvs (2006-12-14)
--- LVM2/WHATS_NEW	2006/12/13 18:40:22	1.521
+++ LVM2/WHATS_NEW	2006/12/14 20:05:08	1.522
@@ -1,5 +1,5 @@
-Version 2.02.17 -
-===================================
+Version 2.02.17 - 14th December 2006
+====================================
   Add missing pvremove error message when device doesn't exist.
   When lvconvert allocates a mirror log, respect parallel area constraints.
   Use loop to iterate through the now-ordered policy list in _allocate().


