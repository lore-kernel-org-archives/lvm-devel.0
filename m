From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Dec 2009 19:26:21 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20091216192621.24022.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-12-16 19:26:21

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Revert unintended change that slipped in with last checkin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.303&r2=1.304

--- LVM2/lib/metadata/metadata.c	2009/12/16 19:22:12	1.303
+++ LVM2/lib/metadata/metadata.c	2009/12/16 19:26:20	1.304
@@ -3520,7 +3520,6 @@
 
 	/* Found vgname so cannot reserve. */
 	unlock_vg(cmd, vgname);
-	log_error("A volume group called '%s' already exists.", vg_name);
 	return FAILED_EXIST;
 }
 


