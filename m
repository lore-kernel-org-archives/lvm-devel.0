From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Jan 2008 12:28:04 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20080119122804.25098.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-19 12:28:03

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	Pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.770&r2=1.771

--- LVM2/VERSION	2008/01/18 21:56:39	1.162
+++ LVM2/VERSION	2008/01/19 12:28:03	1.163
@@ -1 +1 @@
-2.02.31-cvs (2008-01-17)
+2.02.31-cvs (2008-01-19)
--- LVM2/WHATS_NEW	2008/01/18 22:02:37	1.770
+++ LVM2/WHATS_NEW	2008/01/19 12:28:03	1.771
@@ -1,8 +1,8 @@
-Version 2.02.31 -
+Version 2.02.31 - 19th January 2008
 ===================================
   Fix lvcreate --nosync not to wait for non-happening sync. (2.02.30)
   Add very_verbose lvconvert messages.
-  Avoid error message when using default setting of lvcreate -M1. (2.02.30)
+  Avoid error message when using default setting of lvcreate -M1. (2.02.29)
 
 Version 2.02.30 - 17th January 2008
 ===================================


