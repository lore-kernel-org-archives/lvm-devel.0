From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2009 15:16:48 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090715151648.1318.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-15 15:16:48

Modified files:
	.              : WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1186&r2=1.1187

--- LVM2/WHATS_NEW	2009/07/15 14:59:14	1.1186
+++ LVM2/WHATS_NEW	2009/07/15 15:16:48	1.1187
@@ -23,7 +23,7 @@
   Refactor vgchange extent_size, max_lv, max_pv, and alloc_policy for liblvm.
   Update t-vgcreate-usage.sh to test for default vg properties.
   Fix memory leak in vgsplit when re-reading the vg.
-  Make exit/cleanup code more robust when some lvm init function fails.
+  Make various exit/cleanup paths more robust after lvm init failures.
   Use LCK_NONBLOCK implicitly instead of explicit vg_read() flag.
   Remove unnecessary locking and existence tests from new vg_read() interface.
   Permit several segment types to be registered by a single shared object.


