From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jun 2008 12:08:19 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20080611120819.27464.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-11 12:08:19

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.897&r2=1.898

--- LVM2/VERSION	2008/06/06 19:28:33	1.176
+++ LVM2/VERSION	2008/06/11 12:08:19	1.177
@@ -1 +1 @@
-2.02.38-cvs (2008-06-06)
+2.02.38-cvs (2008-06-11)
--- LVM2/WHATS_NEW	2008/06/11 11:02:05	1.897
+++ LVM2/WHATS_NEW	2008/06/11 12:08:19	1.898
@@ -1,10 +1,10 @@
-Version 2.02.38 - 
-=================================
+Version 2.02.38 - 11th June 2008
+================================
   Fix tracking of validity of PVs with no mdas in lvmcache.
   Fix return values for reporting commands when run with no PVs, LVs, or VGs.
   Add omitted unlock_vg() call when sigint_caught() during vg processing.
-  Fix wrong free_count on imported vg from pool device
-  Fix segfault when calling pvcreate on the pool device
+  Fix free_count when reading pool metadata.
+  Fix segfault when using pvcreate on a device containing pool metadata.
   Fix segfault after _free_vginfo by remembering to remove vginfo from list.
   Tweak detection of invalid fid after changes to PVs in VG in _vg_read.
   Revert assuming precommitted metadata is live when activating (unnecessary).


