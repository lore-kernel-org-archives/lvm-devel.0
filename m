From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 16:22:44 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120119162244.14589.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 16:22:43

Modified files:
	.              : WHATS_NEW 

Log message:
	Drop unimplemented

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2223&r2=1.2224

--- LVM2/WHATS_NEW	2012/01/19 15:31:45	1.2223
+++ LVM2/WHATS_NEW	2012/01/19 16:22:42	1.2224
@@ -136,7 +136,7 @@
   Add configure --enable-lvmetad for building the (experimental) LVMetaD.
   Fix resource leak when strdup fails in _get_device_status() (2.02.85).
   Directly allocate buffer memory in a pvck scan instead of using a mempool.
-  Add configure --with-thin for (unimplemented) segtypes "thin" and "thin_pool".
+  Add configure --with-thin for segtypes "thin" and "thin_pool".
   Fix raid shared lib segtype registration (2.02.87).
 
 Version 2.02.88 - 19th August 2011


