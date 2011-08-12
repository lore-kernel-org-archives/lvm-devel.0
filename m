From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Aug 2011 02:34:09 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20110812023409.27886.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-12 02:34:08

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.283&r2=1.284
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2071&r2=1.2072
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.491&r2=1.492

--- LVM2/VERSION	2011/08/12 01:34:11	1.283
+++ LVM2/VERSION	2011/08/12 02:34:08	1.284
@@ -1 +1 @@
-2.02.87(2)-cvs (2011-08-12)
+2.02.88(2)-cvs (2011-08-12)
--- LVM2/VERSION_DM	2011/08/12 01:34:11	1.88
+++ LVM2/VERSION_DM	2011/08/12 02:34:08	1.89
@@ -1 +1 @@
-1.02.66-cvs (2011-08-12)
+1.02.67-cvs (2011-08-12)
--- LVM2/WHATS_NEW	2011/08/12 01:34:11	1.2071
+++ LVM2/WHATS_NEW	2011/08/12 02:34:08	1.2072
@@ -1,3 +1,6 @@
+Version 2.02.88 - 
+==================================
+
 Version 2.02.87 - 12th August 2011
 ==================================
   Add global/detect_internal_vg_cache_corruption to lvm.conf.
@@ -18,6 +21,7 @@
   Remove meaningless const type qualifiers on cast type.
   Add test for fcntl error in singlenode client code.
   Remove --force option from lvrename manpage.
+  Add global/mirror_segtype_default to pick md raid or dm mirror as default.
   Add configure --with-raid for new segtype 'raid' for MD RAID 1/4/5/6 support.
   Change DEFAULT_UDEV_SYNC to 1 so udev_sync is used if there is no config file.
   Add systemd unit file to provide lvm2 monitoring.
--- LVM2/WHATS_NEW_DM	2011/08/12 01:34:11	1.491
+++ LVM2/WHATS_NEW_DM	2011/08/12 02:34:08	1.492
@@ -1,3 +1,6 @@
+Version 1.02.67 - 
+==================================
+
 Version 1.02.66 - 12th August 2011
 ==================================
   Release geometry buffer in dm_task_destroy.


