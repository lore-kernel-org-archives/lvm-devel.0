From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Aug 2011 08:23:34 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110831082334.12126.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-31 08:23:33

Modified files:
	.              : WHATS_NEW 

Log message:
	Update for resource leak

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2085&r2=1.2086

--- LVM2/WHATS_NEW	2011/08/29 13:37:36	1.2085
+++ LVM2/WHATS_NEW	2011/08/31 08:23:33	1.2086
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix resource leak when strdup fails in _get_device_status() (2.02.85).
   Directly allocate buffer memory in a pvck scan instead of using a mempool.
   Add configure --with-thin for (unimplemented) segtypes "thin" and "thin_pool".
   Fix raid shared lib segtype registration (2.02.87).


