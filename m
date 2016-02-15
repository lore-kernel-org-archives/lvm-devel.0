From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:29 +0000 (UTC)
Subject: master - pv: check for the PV_EXT_USED flag and deny pvcreate/pvchange/pvremove/vgcreate on such PV (unless forced)
Message-ID: <20160215120829.C48E660509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52999133a36e5ab194dfa10d9108ca09ff1c930d
Commit:        52999133a36e5ab194dfa10d9108ca09ff1c930d
Parent:        d320d9c52bd1817daf5573b772e01a871837d2ee
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 10 11:25:14 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

pv: check for the PV_EXT_USED flag and deny pvcreate/pvchange/pvremove/vgcreate on such PV (unless forced)

Make sure we won't use a PV that is already marked as used. Normally,
VG metadata would stop us from doing that, but we can run into a
situation where such metadata is missing because PVs with MDAs
are missing and the PVs left are the ones with 0 MDAs.

(/dev/sda in this example has 0 MDAs and it belongs to a VG,
but other PVs with MDA are missing)

$ pvs -o pv_name,pv_mda_count /dev/sda
  PV         #PMda
  /dev/sda       0

$ pvcreate /dev/sda
  PV '/dev/sda' is marked as belonging to a VG but its metadata is missing.
  Can't initialize PV '/dev/sda' without -ff.

$ pvchange -u /dev/sda
  PV '/dev/sda' is marked as belonging to a VG but its metadata is missing.
  Can't change PV '/dev/sda' without -ff.
  Physical volume /dev/sda not changed
  0 physical volumes changed / 1 physical volume not changed

$ pvremove /dev/sda
  PV '/dev/sda' is marked as belonging to a VG but its metadata is missing.
  (If you are certain you need pvremove, then confirm by using --force twice.)

$ vgcreate vg /dev/sda
  Physical volume '/dev/sda' is marked as belonging to a VG but its metadata is missing.
  Unable to add physical volume '/dev/sda' to volume group 'vg'.
---
 lib/metadata/metadata.c |   30 ++++++++++++++++++++++++++----
 lib/metadata/pv_manip.c |   15 +++++++++++++--
 tools/pvchange.c        |   20 ++++++++++++++++----
 3 files changed, 55 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9c0423e..a463754 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -185,6 +185,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
 	char uuid[64] __attribute__((aligned(8)));
+	int used;
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
 		    pv_name, vg->name);
@@ -198,6 +199,15 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		log_error("Physical volume '%s' is already in volume group "
 			  "'%s'", pv_name, pv->vg_name);
 		return 0;
+	} else if (!new_pv) {
+		if ((used = is_used_pv(pv)) < 0)
+			return_0;
+
+		if (used) {
+			log_error("Physical volume '%s' is marked as belonging to a VG "
+				  "but its metadata is missing.", pv_name);
+			return 0;
+		}
 	}
 
 	if (pv->fmt != fid->fmt) {
@@ -1464,6 +1474,7 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 	int r = 0;
 	int scan_needed = 0;
 	int filter_refresh_needed = 0;
+	int used;
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
@@ -1474,10 +1485,21 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	/* Allow partial & exported VGs to be destroyed. */
 	/* We must have -ff to overwrite a non orphan */
-	if (pv && !is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
-		log_error("Can't initialize physical volume \"%s\" of "
-			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
-		goto out;
+	if (pv) {
+		if (!is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
+			log_error("Can't initialize physical volume \"%s\" of "
+				  "volume group \"%s\" without -ff.", name, pv_vg_name(pv));
+			goto out;
+		}
+
+		if ((used = is_used_pv(pv)) < 0)
+			goto_out;
+
+		if (used && pp->force != DONT_PROMPT_OVERRIDE) {
+			log_error("PV '%s' is marked as belonging to a VG but its metadata is missing.", name);
+			log_error("Can't initialize PV '%s' without -ff.", name);
+			goto out;
+		}
 	}
 
 	/* prompt */
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 7126048..423b647 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -697,11 +697,12 @@ const char _really_wipe[] =
 static int pvremove_check(struct cmd_context *cmd, const char *name,
 			  unsigned force_count, unsigned prompt, struct dm_list *pvslist)
 {
+	static const char pvremove_force_hint_msg[] = "(If you are certain you need pvremove, then confirm by using --force twice.)";
 	struct device *dev;
 	struct label *label;
 	struct pv_list *pvl;
-
 	struct physical_volume *pv = NULL;
+	int used;
 	int r = 0;
 
 	/* FIXME Check partition type is LVM unless --force is given */
@@ -731,6 +732,16 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 	}
 
 	if (is_orphan(pv)) {
+		if ((used = is_used_pv(pv)) < 0)
+			goto_out;
+
+		if (used && force_count < 2) {
+			log_error("PV '%s' is marked as belonging to a VG "
+				  "but its metadata is missing.", name);
+			log_error("%s", pvremove_force_hint_msg);
+			goto out;
+		}
+
 		r = 1;
 		goto out;
 	}
@@ -738,7 +749,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 	/* we must have -ff to overwrite a non orphan */
 	if (force_count < 2) {
 		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
-		log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
+		log_error("%s", pvremove_force_hint_msg);
 		goto out;
 	}
 
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 82b60f1..7f9aaf8 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -27,6 +27,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	const char *pv_name = pv_dev_name(pv);
 	char uuid[64] __attribute__((aligned(8)));
 	unsigned done = 0;
+	int used;
 
 	int allocatable = arg_int_value(cmd, allocatable_ARG, 0);
 	int mda_ignore = arg_int_value(cmd, metadataignore_ARG, 0);
@@ -48,10 +49,21 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		}
 		if (!archive(vg))
 			goto_bad;
-	} else if (tagargs) {
-		log_error("Can't change tag on Physical Volume %s not "
-			  "in volume group", pv_name);
-		goto bad;
+	} else {
+		if (tagargs) {
+			log_error("Can't change tag on Physical Volume %s not "
+				  "in volume group", pv_name);
+			goto bad;
+		}
+
+		if ((used = is_used_pv(pv)) < 0)
+			goto_bad;
+
+		if (used && (arg_count(cmd, force_ARG) != DONT_PROMPT_OVERRIDE)) {
+			log_error("PV '%s' is marked as belonging to a VG but its metadata is missing.", pv_name);
+			log_error("Can't change PV '%s' without -ff.", pv_name);
+			goto bad;
+		}
 	}
 
 	if (arg_count(cmd, allocatable_ARG)) {


