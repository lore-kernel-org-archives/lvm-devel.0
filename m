From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:04:24 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101025130424.8476.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:04:23

Modified files:
	.              : WHATS_NEW 

Log message:
	rom -> from

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1772&r2=1.1773

--- LVM2/WHATS_NEW	2010/10/25 12:59:24	1.1772
+++ LVM2/WHATS_NEW	2010/10/25 13:04:23	1.1773
@@ -1,6 +1,6 @@
 Version 2.02.75 - 
 =====================================
-  Fix missing initilization in cluser_send() function rom cmirrord.
+  Fix missing initilization in cluser_send() function from cmirrord.
   Fix pointer for VG name in _pv_resize_single error code path.
   Fix warning for changed alignment requirements for dmeventd read/write func.
   Add global/metadata_read_only to use unrepaired metadata in read-only cmds.


