From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 13:11:13 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100630131113.21830.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 13:11:13

Modified files:
	.              : WHATS_NEW 

Log message:
	Update nightly tests for vgextend --metadataignore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1639&r2=1.1640

--- LVM2/WHATS_NEW	2010/06/29 12:06:14	1.1639
+++ LVM2/WHATS_NEW	2010/06/30 13:11:12	1.1640
@@ -1,5 +1,6 @@
 Version 2.02.69 - 
 ================================
+  Add --metadataignore to pvcreate and vgextend and define in lvm.conf.
   Add {pv|vg}_mda_used_count which displays a count of mdas w/ignored bit clear.
   Add vg_mda_copies which displays the value of --vgmetadatacopies.
   Describe --vgmetadatacopies in lvm.conf and other man pages.


