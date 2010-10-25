From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:35:14 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20101025133514.14757.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:35:13

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Fix constness warning for _vg_read_by_vgid() uuid usage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.406&r2=1.407

--- LVM2/lib/metadata/metadata.c	2010/10/25 11:20:56	1.406
+++ LVM2/lib/metadata/metadata.c	2010/10/25 13:35:13	1.407
@@ -3154,7 +3154,7 @@
 	lvid = (const union lvid *) lvid_s;
 
 	log_very_verbose("Finding volume group for uuid %s", lvid_s);
-	if (!(vg = _vg_read_by_vgid(cmd, (char *)lvid->id[0].uuid, precommitted))) {
+	if (!(vg = _vg_read_by_vgid(cmd, (const char *)lvid->id[0].uuid, precommitted))) {
 		log_error("Volume group for uuid not found: %s", lvid_s);
 		return NULL;
 	}


