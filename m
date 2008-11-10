From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Nov 2008 12:39:51 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20081110123951.23618.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-10 12:39:51

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	First test release of the merged code base.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.992&r2=1.993
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.255&r2=1.256

--- LVM2/VERSION	2008/10/26 10:40:50	1.186
+++ LVM2/VERSION	2008/11/10 12:39:50	1.187
@@ -1 +1 @@
-2.02.43-cvs (2008-10-26)
+2.02.43-cvs (2008-11-10)
--- LVM2/VERSION_DM	2008/10/31 21:55:40	1.1
+++ LVM2/VERSION_DM	2008/11/10 12:39:50	1.2
@@ -1 +1 @@
-1.02.29-cvs (2008-09-18)
+1.02.29-cvs (2008-11-10)
--- LVM2/WHATS_NEW	2008/11/07 19:23:52	1.992
+++ LVM2/WHATS_NEW	2008/11/10 12:39:50	1.993
@@ -1,11 +1,11 @@
-Version 2.02.43 -
-===================================
+Version 2.02.43 - 10th November 2008
+====================================
+  Merge device-mapper into the lvm2 tree.
   Fix lvchange and lvcreate man pages permissions option.
   Fix vgdisplay return code and exit status.
   Move list.c into libdevmapper and rename functions.
   Rename a couple of variables that matched function names.
   Use simplified x.y.z version number in libdevmapper.pc.
-  Merge device-mapper into the lvm2 tree.
   Remove ancient debian directory.
   Split out lvm-logging.h from log.h and lvm-globals.[ch] from log.[ch].
 
--- LVM2/WHATS_NEW_DM	2008/10/30 17:24:03	1.255
+++ LVM2/WHATS_NEW_DM	2008/11/10 12:39:50	1.256
@@ -1,5 +1,6 @@
-Version 1.02.29 -
-=====================================
+Version 1.02.29 - 10th November 2008
+====================================
+  Merge device-mapper into the LVM2 tree.
   Split out dm-logging.h from log.h.
   Use lvm-types.h.
   Add usrsbindir to configure.


