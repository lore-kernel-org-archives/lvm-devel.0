From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Nov 2010 17:16:42 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101125171642.6544.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-25 17:16:41

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1809&r2=1.1810

--- LVM2/WHATS_NEW	2010/11/24 09:53:31	1.1809
+++ LVM2/WHATS_NEW	2010/11/25 17:16:41	1.1810
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Certain lvconvert invocations are now required to be done in two steps.
   Fix missing context desctruction in err path of lvm1 fallback in lvm2_main().
   Fix memory leak in error path of parse_loop_device_name() from dmsetup.
   Fix missing dlclose in _init_formats() error path from init_format call.


