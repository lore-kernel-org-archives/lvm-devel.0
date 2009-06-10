From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Jun 2009 11:15:29 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20090610111529.12465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-10 11:15:29

Modified files:
	tools          : toollib.c 

Log message:
	Unlock VG in recover_vg if metadata read failed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158

--- LVM2/tools/toollib.c	2009/06/10 10:15:28	1.157
+++ LVM2/tools/toollib.c	2009/06/10 11:15:29	1.158
@@ -497,10 +497,8 @@
 			unlock_and_release_vg(cmd, vg, vg_name);
 			dev_close_all();
 			log_error("Volume group %s inconsistent", vg_name);
-			if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE))) {
-				unlock_vg(cmd, vg_name);
+			if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
 				return ECMD_FAILED;
-			}
 			consistent = 1;
 			break;
 		}
@@ -1209,6 +1207,7 @@
 				uint32_t lock_type)
 {
 	int consistent = 1;
+	struct volume_group *vg;
 
 	/* Don't attempt automatic recovery without proper locking */
 	if (lockingfailed())
@@ -1223,7 +1222,10 @@
 		return NULL;
 	}
 
-	return vg_read_internal(cmd, vgname, NULL, &consistent);
+	if (!(vg = vg_read_internal(cmd, vgname, NULL, &consistent)))
+		unlock_vg(cmd, vgname);
+
+	return vg;
 }
 
 int apply_lvname_restrictions(const char *name)


