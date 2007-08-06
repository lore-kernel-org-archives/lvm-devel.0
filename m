From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Aug 2007 20:38:42 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070806203842.28237.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-06 20:38:41

Modified files:
	.              : WHATS_NEW 

Log message:
	Add entry for last checkin of lvrename mirror support

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.677&r2=1.678

--- LVM2/WHATS_NEW	2007/08/03 21:22:09	1.677
+++ LVM2/WHATS_NEW	2007/08/06 20:38:41	1.678
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Add support for renaming mirrored LVs.
   Factor out core of lvrename() to lv_rename lvm library function.
   Add --log argument to specify log type for mirrors.
   Don't try to monitor devices which we failed to create.


