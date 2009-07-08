From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 14:41:01 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090708144101.23903.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 14:41:01

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for vgread cleanup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1167&r2=1.1168

--- LVM2/WHATS_NEW	2009/07/08 12:36:01	1.1167
+++ LVM2/WHATS_NEW	2009/07/08 14:41:00	1.1168
@@ -1,5 +1,7 @@
 Version 2.02.49 - 
 ================================
+  Use implicit set of LCK_NONBLOCK instead of explicit vg_read() flag.
+  Remove unnecessary locking and existence code from new vg_read() interface.
   Permit several segment types to be registered by a single shared object.
   Update the man pages to document size units uniformly.
   Allow commandline sizes to be specified in terms of bytes and sectors.


