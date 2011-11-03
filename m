From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:54:03 -0000
Subject: LVM2/lib/metadata metadata-exported.h thin_manip.c
Message-ID: <20111103145403.30173.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:53:58

Modified files:
	lib/metadata   : metadata-exported.h thin_manip.c 

Log message:
	Thin genering update_pool_lv function
	
	Function to trigger pool message passing via resume,
	or resize of the pool itself independently on other thins.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.219&r2=1.220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/lib/metadata/metadata-exported.h	2011/10/30 22:01:39	1.219
+++ LVM2/lib/metadata/metadata-exported.h	2011/11/03 14:53:58	1.220
@@ -560,6 +560,8 @@
 
 int detach_pool_messages(struct logical_volume *pool_lv);
 
+int update_pool_lv(struct logical_volume *lv, int activate);
+
 /*
  * Activation options
  */
--- LVM2/lib/metadata/thin_manip.c	2011/11/03 14:38:36	1.19
+++ LVM2/lib/metadata/thin_manip.c	2011/11/03 14:53:58	1.20
@@ -317,3 +317,43 @@
 
 	return 1;
 }
+
+int update_pool_lv(struct logical_volume *lv, int activate)
+{
+	if (!lv_is_thin_pool(lv)) {
+		log_error(INTERNAL_ERROR "Updated LV %s is not pool.", lv->name);
+		return 0;
+	}
+
+	if (activate) {
+		/* If the pool was not yet activated, do it */
+		if (!lv_is_active(lv) &&
+		    !activate_lv_excl(lv->vg->cmd, lv)) {
+			log_error("Failed to activate %s.", lv->name);
+			return 0;
+		}
+		/* If already active, do suspend resume
+		 *
+		 * TODO: Support pool resume without suspend,
+		 * since the real suspend is not needed here
+		 */
+		else if (!suspend_lv(lv->vg->cmd, lv)) {
+			log_error("Failed to suspend %s.", lv->name);
+			return 0;
+		} else if (!resume_lv(lv->vg->cmd, lv)) {
+			log_error("Failed to resume %s.", lv->name);
+			return 0;
+		}
+	}
+
+	if (!dm_list_empty(&first_seg(lv)->thin_messages)) {
+		dm_list_init(&first_seg(lv)->thin_messages);
+
+		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+			return_0;
+
+		backup(lv->vg);
+	}
+
+	return 1;
+}


