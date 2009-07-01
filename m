From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 17:23:11 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090701172311.29327.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 17:23:10

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for vg_read commits

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1161&r2=1.1162

--- LVM2/WHATS_NEW	2009/07/01 09:31:46	1.1161
+++ LVM2/WHATS_NEW	2009/07/01 17:23:10	1.1162
@@ -1,5 +1,9 @@
 Version 2.02.49 - 
 ================================
+  Update test/t-inconsistent-metadata.sh to match new vg_read interface.
+  Add lvmcache_init() to polldaemon initialization.
+  Convert tools to use new vg_read / vg_read_for_update.
+  Fix segfault in vg_release when vg->cmd is NULL.
 
 Version 2.02.48 - 30th June 2009
 ================================


