From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 22:22:12 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090708222212.4694.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 22:22:12

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1168&r2=1.1169

--- LVM2/WHATS_NEW	2009/07/08 14:41:00	1.1168
+++ LVM2/WHATS_NEW	2009/07/08 22:22:12	1.1169
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Make exit/cleanup code more robust when some lvm init function fails.
   Use implicit set of LCK_NONBLOCK instead of explicit vg_read() flag.
   Remove unnecessary locking and existence code from new vg_read() interface.
   Permit several segment types to be registered by a single shared object.


