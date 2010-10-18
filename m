From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Oct 2010 17:27:11 -0000
Subject: LVM2/tools vgextend.c
Message-ID: <20101018172711.3334.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-18 17:27:10

Modified files:
	tools          : vgextend.c 

Log message:
	Avoid an extraneous orphans unlock in vgextend --restoremissing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/tools/vgextend.c	2010/10/13 10:34:32	1.60
+++ LVM2/tools/vgextend.c	2010/10/18 17:27:10	1.61
@@ -133,7 +133,8 @@
 	r = ECMD_PROCESSED;
 
 bad:
-	unlock_vg(cmd, VG_ORPHANS);
+	if (!arg_count(cmd, restoremissing_ARG))
+		unlock_vg(cmd, VG_ORPHANS);
 	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }


