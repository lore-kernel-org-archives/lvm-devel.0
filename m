From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 15:34:00 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090728153400.20501.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 15:33:59

Modified files:
	liblvm         : lvm.h 

Log message:
	Add doxygen mainpage tag to lvm.h

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/liblvm/lvm.h	2009/07/28 13:17:04	1.40
+++ LVM2/liblvm/lvm.h	2009/07/28 15:33:59	1.41
@@ -30,7 +30,9 @@
 
 /*************************** Design Overview ********************************/
 
-/*
+/**
+ * \mainpage LVM library API
+ *
  * The API is designed around the following basic LVM objects:
  * 1) Physical Volume (PV) 2) Volume Group (VG) 3) Logical Volume (LV).
  *


