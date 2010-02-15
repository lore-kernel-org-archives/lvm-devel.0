From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Feb 2010 19:55:49 -0000
Subject: LVM2/liblvm lvm2app.h
Message-ID: <20100215195549.19848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-15 19:55:49

Modified files:
	liblvm         : lvm2app.h 

Log message:
	Update lvm2app.h comments to remove hidden VG comment list vgnames/vgids.
	
	Peter recently fixed lvm_list_vg_names() and lvm_list_vg_uuids() so they
	no longer return hidden names.  Remove the comment in lvm2app.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/liblvm/lvm2app.h	2010/02/14 03:21:38	1.10
+++ LVM2/liblvm/lvm2app.h	2010/02/15 19:55:49	1.11
@@ -281,8 +281,6 @@
  *
  * NOTE: This function normally does not scan devices in the system for LVM
  * metadata.  To scan the system, use lvm_scan.
- * NOTE: This function currently returns hidden VG names.  These names always
- * begin with a "#" and should be filtered out and not used.
  *
  * To process the list, use the dm_list iterator functions.  For example:
  *      vg_t vg;
@@ -315,8 +313,6 @@
  *
  * NOTE: This function normally does not scan devices in the system for LVM
  * metadata.  To scan the system, use lvm_scan.
- * NOTE: This function currently returns hidden VG names.  These names always
- * begin with a "#" and should be filtered out and not used.
  *
  * \param   libh
  * Handle obtained from lvm_init.


