From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 7 Jan 2010 20:55:01 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100107205501.16753.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-07 20:55:01

Modified files:
	.              : WHATS_NEW 

Log message:
	- forgot to update WHATS_NEW along with bug fix for keeping
	log type consistent when using lvconvert to change the
	number of mirror images.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1372&r2=1.1373

--- LVM2/WHATS_NEW	2010/01/07 20:01:55	1.1372
+++ LVM2/WHATS_NEW	2010/01/07 20:55:01	1.1373
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Keep log type consistent when changing mirror image count.
   Always set environment variables for an LVM2 device in 11-dm-lvm.rules.
   Add activation/udev_rules config option in lvm.conf.
   Add macro outfc() and export out_text_with_comment().


