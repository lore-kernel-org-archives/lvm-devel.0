From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Jun 2009 10:15:29 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20090610101529.12924.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-10 10:15:29

Modified files:
	tools          : toollib.c 

Log message:
	Unlock vg when requested automatic update failed.
	
	(fixes previous commit)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157

--- LVM2/tools/toollib.c	2009/06/05 20:00:52	1.156
+++ LVM2/tools/toollib.c	2009/06/10 10:15:28	1.157
@@ -497,8 +497,10 @@
 			unlock_and_release_vg(cmd, vg, vg_name);
 			dev_close_all();
 			log_error("Volume group %s inconsistent", vg_name);
-			if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
+			if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE))) {
+				unlock_vg(cmd, vg_name);
 				return ECMD_FAILED;
+			}
 			consistent = 1;
 			break;
 		}


