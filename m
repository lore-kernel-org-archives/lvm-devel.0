From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 11:57:06 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100519115706.26344.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 11:57:05

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1566&r2=1.1567

--- LVM2/WHATS_NEW	2010/05/19 02:36:33	1.1566
+++ LVM2/WHATS_NEW	2010/05/19 11:57:05	1.1567
@@ -1,5 +1,10 @@
 Version 2.02.66 - 
 ===============================
+  Add tests for lvm_vgname_from_{pvid|device}.
+  Add lvm2app interfaces to lookup a vgname from a pvid and pvname.
+  Update pvchange to always obtain a vg handle for each pv to process.
+  Add Add find_vgname_from_{pvname|pvid} functions.
+  Add pvid_from_devname and lvmcache_vgname_from_pvid lvmcache functions.
   Validate orphan and VG_GLOBAL lock order too.
   Accept orphan VG names as parameters to lock_vol() and related functions.
   Use is_orphan_vg in place of hard-coded prefix tests and add is_global_vg.


