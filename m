From: meyering@sourceware.org <meyering@sourceware.org>
Date: 6 Aug 2007 09:04:24 -0000
Subject: LVM2/lib/metadata lv_manip.c metadata-exported.h
Message-ID: <20070806090424.16126.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-08-06 09:04:22

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h 

Log message:
	Make lv_rename's interface "const correct".
	* lib/metadata/lv_manip.c (lv_rename): Make char* param "const".
	* lib/metadata/metadata-exported.h: Update prototype, too.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/lib/metadata/lv_manip.c	2007/08/03 21:22:09	1.116
+++ LVM2/lib/metadata/lv_manip.c	2007/08/06 09:04:21	1.117
@@ -1466,7 +1466,7 @@
  * Returns 0 on failure, 1 on success.
  */
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
-	      char *newname)
+	      const char *newname)
 {
 	struct volume_group *vg = lv->vg;
 
--- LVM2/lib/metadata/metadata-exported.h	2007/08/03 21:22:09	1.4
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/06 09:04:21	1.5
@@ -357,7 +357,7 @@
 int lv_remove(struct logical_volume *lv);
 
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
-	      char *newname);
+	      const char *newname);
 
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);


