From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Mar 2012 20:29:47 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/cluster_locking.c
Message-ID: <20120326202947.14242.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-26 20:29:46

Modified files:
	.              : WHATS_NEW 
	lib/locking    : cluster_locking.c 

Log message:
	Remove unused and wrongly set cluster VG flag from clvmd lock query command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2367&r2=1.2368
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/WHATS_NEW	2012/03/23 16:28:40	1.2367
+++ LVM2/WHATS_NEW	2012/03/26 20:29:45	1.2368
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Remove unused and wrongly set cluster VG flag from clvmd lock query command.
   Fix pvmove for exclusively activated LV pvmove in clustered VG. (2.02.86)
   Always free hash table on update_pvid_to_vgid() in lvmetad.
   Update and fix monitoring of thin pool devices.
--- LVM2/lib/locking/cluster_locking.c	2012/01/21 05:29:52	1.64
+++ LVM2/lib/locking/cluster_locking.c	2012/03/26 20:29:46	1.65
@@ -538,7 +538,7 @@
 	strcpy(args + 2, resource);
 
 	args[0] = 0;
-	args[1] = LCK_CLUSTER_VG;
+	args[1] = 0;
 
 	status = _cluster_request(CLVMD_CMD_LOCK_QUERY, node, args, len,
 				  &response, &num_responses);


