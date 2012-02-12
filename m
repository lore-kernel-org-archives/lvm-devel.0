From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2012 23:02:52 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20120212230252.8302.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-12 23:02:52

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2277&r2=1.2278
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.549&r2=1.550
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.290&r2=1.291
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW	2012/02/12 22:37:24	1.2277
+++ LVM2/WHATS_NEW	2012/02/12 23:02:52	1.2278
@@ -1,5 +1,5 @@
-Version 2.02.91 -
-===================================
+Version 2.02.91 - 12th February 2012
+====================================
   Remove PV-based format instances (which are no longer needed).
   Link all orphan PVs directly to a per-format global orphan VG.
   Refactor lvmcache around an internal API.
--- LVM2/WHATS_NEW_DM	2012/02/10 15:17:52	1.549
+++ LVM2/WHATS_NEW_DM	2012/02/12 23:02:52	1.550
@@ -1,5 +1,5 @@
-Version 1.02.70 - 
-===================================
+Version 1.02.70 - 12th February 2012
+====================================
   Fix dm_event_get_version() check.
   Add pointer test for dependency check in _add_dev().
   Validate name and uuid params of dm_tree_add_new_dev_with_udev_flags().
--- LVM2/VERSION	2012/02/01 18:46:57	1.290
+++ LVM2/VERSION	2012/02/12 23:02:52	1.291
@@ -1 +1 @@
-2.02.91(2)-cvs (2012-02-01)
+2.02.91(2)-cvs (2012-02-12)
--- LVM2/VERSION_DM	2012/02/01 18:46:57	1.95
+++ LVM2/VERSION_DM	2012/02/12 23:02:52	1.96
@@ -1 +1 @@
-1.02.70-cvs (2012-02-01)
+1.02.70-cvs (2012-02-12)


