From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jun 2011 17:48:37 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110615174837.12152.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-15 17:48:36

Modified files:
	.              : WHATS_NEW 

Log message:
	What's new.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2015&r2=1.2016

--- LVM2/WHATS_NEW	2011/06/15 13:29:48	1.2015
+++ LVM2/WHATS_NEW	2011/06/15 17:48:35	1.2016
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Fix a problem with inconsistent pre-commit metadata on MISSING_PV devices.
   Add proper udev library context initialization and finalization to liblvm.
   Fix last snapshot removal to avoid table reload while a device is suspended.
   Use dm_get_suspended_counter in replacement critical_section logic.


