From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Oct 2010 12:02:01 -0000
Subject: LVM2/lib/metadata lv.h pv.h vg.h
Message-ID: <20101025120201.5650.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-25 12:02:00

Modified files:
	lib/metadata   : lv.h pv.h vg.h 

Log message:
	fix header #defines

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/metadata/lv.h	2010/10/21 14:49:31	1.15
+++ LVM2/lib/metadata/lv.h	2010/10/25 12:01:59	1.16
@@ -12,8 +12,8 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#ifndef _LV_H
-#define _LV_H
+#ifndef _LVM_LV_H
+#define _LVM_LV_H
 
 union lvid;
 struct volume_group;
@@ -64,4 +64,4 @@
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
 
-#endif
+#endif /* _LVM_LV_H */
--- LVM2/lib/metadata/pv.h	2010/09/30 20:47:18	1.7
+++ LVM2/lib/metadata/pv.h	2010/10/25 12:01:59	1.8
@@ -12,8 +12,8 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#ifndef _PV_H
-#define _PV_H
+#ifndef _LVM_PV_H
+#define _LVM_PV_H
 
 struct id;
 struct device;
@@ -80,4 +80,4 @@
 int is_missing_pv(const struct physical_volume *pv);
 int is_pv(const struct physical_volume *pv);
 
-#endif
+#endif /* _LVM_PV_H */
--- LVM2/lib/metadata/vg.h	2010/09/30 20:47:18	1.6
+++ LVM2/lib/metadata/vg.h	2010/10/25 12:01:59	1.7
@@ -12,8 +12,8 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-#ifndef _VG_H
-#define _VG_H
+#ifndef _LVM_VG_H
+#define _LVM_VG_H
 
 struct cmd_context;
 struct dm_pool;
@@ -131,4 +131,4 @@
 char *vg_uuid_dup(const struct volume_group *vg);
 char *vg_tags_dup(const struct volume_group *vg);
 
-#endif
+#endif /* _LVM_VG_H */


