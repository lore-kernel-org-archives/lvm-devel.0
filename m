From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:08:34 -0000
Subject: LVM2/lib/metadata vg.c vg.h
Message-ID: <20100930140834.17677.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:08:33

Modified files:
	lib/metadata   : vg.c vg.h 

Log message:
	Add supporting functions vg_name_dup, vg_fmt_dup, vg_system_id_dup.
	
	Add supporting functions for vg_name, vg_fmt, vg_system_id.
	Append "_dup" to end of supporting functions to make clear the strings
	are dup'd and to avoid namespace conflict with vg_name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/lib/metadata/vg.c	2010/09/30 14:08:20	1.5
+++ LVM2/lib/metadata/vg.c	2010/09/30 14:08:33	1.6
@@ -16,6 +16,23 @@
 #include "metadata.h"
 #include "activate.h"
 
+char *vg_fmt_dup(const struct volume_group *vg)
+{
+	if (!vg->fid || !vg->fid->fmt)
+		return NULL;
+	return dm_pool_strdup(vg->vgmem, vg->fid->fmt->name);
+}
+
+char *vg_name_dup(const struct volume_group *vg)
+{
+	return dm_pool_strdup(vg->vgmem, vg->name);
+}
+
+char *vg_system_id_dup(const struct volume_group *vg)
+{
+	return dm_pool_strdup(vg->vgmem, vg->system_id);
+}
+
 char *vg_uuid_dup(const struct volume_group *vg)
 {
 	return id_format_and_copy(vg->vgmem, &vg->id);
--- LVM2/lib/metadata/vg.h	2010/09/30 14:08:20	1.4
+++ LVM2/lib/metadata/vg.h	2010/09/30 14:08:33	1.5
@@ -93,6 +93,9 @@
 	uint32_t mda_copies; /* target number of mdas for this VG */
 };
 
+char *vg_fmt_dup(const struct volume_group *vg);
+char *vg_name_dup(const struct volume_group *vg);
+char *vg_system_id_dup(const struct volume_group *vg);
 uint32_t vg_seqno(const struct volume_group *vg);
 uint64_t vg_status(const struct volume_group *vg);
 int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);


