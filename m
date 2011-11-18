From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2011 19:28:01 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20111118192801.18399.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-18 19:28:01

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Unlock memory for vg_write
	
	For write we do not need to hold memory locked.
	This relaxes many conditions and avoid problems when allocating
	a lot of memory for writting metadata buffers.
	(In case of huge MDA size this would lead to mismatch between
	locked and unlocked memory region size).
	
	Add also internal check we are not writing in critical section.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2189&r2=1.2190
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.472&r2=1.473

--- LVM2/WHATS_NEW	2011/11/18 19:25:20	1.2189
+++ LVM2/WHATS_NEW	2011/11/18 19:28:00	1.2190
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Unlock memory before writing metadata.
   Add query before removing snapshots when inactive snapshot origin is removed.
   Allow changing availability state of snapshots.
   Skip non-virtual snapshots for availability change for lvchange with vg name.
--- LVM2/lib/metadata/metadata.c	2011/11/04 22:49:53	1.472
+++ LVM2/lib/metadata/metadata.c	2011/11/18 19:28:01	1.473
@@ -2573,6 +2573,12 @@
 		return 0;
 	}
 
+	if (critical_section())
+		log_error(INTERNAL_ERROR
+			  "Writing metadata in critical section.");
+
+	/* Unlock memory if possible */
+	memlock_unlock(vg->cmd);
 	vg->seqno++;
 
         dm_list_iterate_items(pv_to_create, &vg->pvs_to_create) {


