From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Oct 2011 09:01:04 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20111019090104.12106.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-10-19 09:01:04

Modified files:
	.              : WHATS_NEW 

Log message:
	New.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2162&r2=1.2163

--- LVM2/WHATS_NEW	2011/10/14 14:18:49	1.2162
+++ LVM2/WHATS_NEW	2011/10/19 09:01:03	1.2163
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Avoid recursive calls to dmeventd in its LVM plugins.
   Log dev name now returned to kernel for registering during cmirror CTR.
   Fix lv_info open_count test for disabled verify_udev_operations (2.02.86).
   Simplify code for lvm worker thread in clvmd.                     


