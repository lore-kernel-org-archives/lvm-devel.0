From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2011 17:05:21 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20110429170521.16241.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-29 17:05:21

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.277&r2=1.278
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1978&r2=1.1979
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.464&r2=1.465

--- LVM2/VERSION	2011/04/29 16:12:21	1.277
+++ LVM2/VERSION	2011/04/29 17:05:20	1.278
@@ -1 +1 @@
-2.02.85(2)-cvs (2011-04-29)
+2.02.86(2)-cvs (2011-04-29)
--- LVM2/VERSION_DM	2011/04/29 16:12:21	1.84
+++ LVM2/VERSION_DM	2011/04/29 17:05:20	1.85
@@ -1 +1 @@
-1.02.64-cvs (2011-04-29)
+1.02.65-cvs (2011-04-29)
--- LVM2/WHATS_NEW	2011/04/29 16:27:09	1.1978
+++ LVM2/WHATS_NEW	2011/04/29 17:05:20	1.1979
@@ -1,3 +1,6 @@
+Version 2.02.86 - 
+=================================
+
 Version 2.02.85 - 29th April 2011
 =================================
   Add new obtain_device_list_from_udev setting to lvm.conf.
--- LVM2/WHATS_NEW_DM	2011/04/29 16:12:21	1.464
+++ LVM2/WHATS_NEW_DM	2011/04/29 17:05:20	1.465
@@ -1,3 +1,6 @@
+Version 1.02.65 - 
+==================================
+
 Version 1.02.64 - 29th April 2011
 ==================================
   Require libudev >= 143 when compiling with udev support.

