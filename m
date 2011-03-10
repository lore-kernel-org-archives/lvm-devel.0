From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 22:39:38 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20110310223938.17113.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 22:39:37

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Missed merge fix in vg_validate patch

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.440&r2=1.441

--- LVM2/lib/metadata/metadata.c	2011/03/10 14:40:32	1.440
+++ LVM2/lib/metadata/metadata.c	2011/03/10 22:39:36	1.441
@@ -2380,8 +2380,8 @@
 			break;
 		}
 
-		if (!dm_hash_insert_binary(lvid_hash, lvl->lv->lvid.id,
-					   sizeof(lvl->lv->lvid.id), lvl->lv)) {
+		if (!dm_hash_insert_binary(lvid_hash, &lvl->lv->lvid.id[1],
+					   sizeof(lvl->lv->lvid.id[1]), lvl->lv)) {
 			log_error("Failed to hash lvid.");
 			r = 0;
 			break;


