From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 31 Aug 2011 12:48:00 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110831124800.21271.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-31 12:48:00

Modified files:
	.              : WHATS_NEW 

Log message:
	Mention --enable-lvmetad in WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2086&r2=1.2087

--- LVM2/WHATS_NEW	2011/08/31 08:23:33	1.2086
+++ LVM2/WHATS_NEW	2011/08/31 12:47:59	1.2087
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add configure --enable-lvmetad for building the (experimental) LVMetaD.
   Fix resource leak when strdup fails in _get_device_status() (2.02.85).
   Directly allocate buffer memory in a pvck scan instead of using a mempool.
   Add configure --with-thin for (unimplemented) segtypes "thin" and "thin_pool".


