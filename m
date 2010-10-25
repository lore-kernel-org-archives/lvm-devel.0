From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:10:15 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101025131015.32104.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:10:13

Modified files:
	.              : WHATS_NEW 

Log message:
	ok this seems to be never ending story...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1773&r2=1.1774

--- LVM2/WHATS_NEW	2010/10/25 13:04:23	1.1773
+++ LVM2/WHATS_NEW	2010/10/25 13:10:13	1.1774
@@ -1,6 +1,6 @@
 Version 2.02.75 - 
 =====================================
-  Fix missing initilization in cluser_send() function from cmirrord.
+  Fix missing variable initialization in cluster_send() function from cmirrord.
   Fix pointer for VG name in _pv_resize_single error code path.
   Fix warning for changed alignment requirements for dmeventd read/write func.
   Add global/metadata_read_only to use unrepaired metadata in read-only cmds.


