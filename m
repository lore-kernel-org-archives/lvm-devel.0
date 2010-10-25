From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 12:59:25 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/cluster.c
Message-ID: <20101025125925.4801.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 12:59:24

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: cluster.c 

Log message:
	Fix missing initilisation to 0
	
	Add missing init value for variable 'found' which is later tested and may
	have contained some garbage value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1771&r2=1.1772
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2010/10/25 12:01:38	1.1771
+++ LVM2/WHATS_NEW	2010/10/25 12:59:24	1.1772
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix missing initilization in cluser_send() function rom cmirrord.
   Fix pointer for VG name in _pv_resize_single error code path.
   Fix warning for changed alignment requirements for dmeventd read/write func.
   Add global/metadata_read_only to use unrepaired metadata in read-only cmds.
--- LVM2/daemons/cmirrord/cluster.c	2010/07/09 15:34:40	1.15
+++ LVM2/daemons/cmirrord/cluster.c	2010/10/25 12:59:24	1.16
@@ -129,7 +129,7 @@
 {
 	int r;
 	int count=0;
-	int found;
+	int found = 0;
 	struct iovec iov;
 	struct clog_cpg *entry;
 


