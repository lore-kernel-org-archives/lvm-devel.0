From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Mar 2015 00:35:40 +0000 (UTC)
Subject: master - archives: Preserve format type in file.
Message-ID: <20150304003540.9EFD360F20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e6f3e5162e06de09c38e360cbd1d348939ad7f0
Commit:        4e6f3e5162e06de09c38e360cbd1d348939ad7f0
Parent:        24774959221ab75038c336074470108a0727e672
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 4 00:30:26 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 4 00:30:26 2015 +0000

archives: Preserve format type in file.

format_text processes both lvm2 on-disk metadata and metadata read
from other sources such as backup files.  Add original_fmt field
to retain the format type of the original metadata.
Before this patch, /etc/lvm/archives would contain backups of
lvm1 metadata with format = "lvm2" unless the source was lvm1 on-disk
metadata.
---
 WHATS_NEW                     |    1 +
 lib/format_text/export.c      |    9 +++++++--
 lib/format_text/import_vsn1.c |    9 ++++++++-
 lib/metadata/vg.h             |    1 +
 4 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 87ea7b6..ae8bc70 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Preserve original format type field when processing backup files.
   Implement status action for lvm2-monitor initscript to display monitored LVs.
   Allow lvchange -p to change kernel state only if metadata state differs.
   Fix incorrect persistent .cache after report with label fields only (2.02.106).
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index d6a92c4..ddaaebb 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -393,6 +393,7 @@ static int _out_tags(struct formatter *f, struct dm_list *tagsl)
 static int _print_vg(struct formatter *f, struct volume_group *vg)
 {
 	char buffer[4096];
+	const struct format_type *fmt = NULL;
 
 	if (!id_write_format(&vg->id, buffer, sizeof(buffer)))
 		return_0;
@@ -401,8 +402,12 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 
 	outf(f, "seqno = %u", vg->seqno);
 
-	if (vg->fid && vg->fid->fmt)
-		outfc(f, "# informational", "format = \"%s\"", vg->fid->fmt->name);
+	if (vg->original_fmt)
+		fmt = vg->original_fmt;
+	else if (vg->fid)
+		fmt = vg->fid->fmt;
+	if (fmt)
+		outfc(f, "# informational", "format = \"%s\"", fmt->name);
 
 	if (!_print_flag_config(f, vg->status, VG_FLAGS))
 		return_0;
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 42ff451..366e61c 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -733,7 +733,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 {
 	const struct dm_config_node *vgn;
 	const struct dm_config_value *cv;
-	const char *str;
+	const char *str, *format_str;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	unsigned scan_done_once = use_cached_pvs;
@@ -775,6 +775,13 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	vgn = vgn->child;
 
+	/* A backup file might be a backup of a different format */
+	if (dm_config_get_str(vgn, "format", &format_str) &&
+	    !(vg->original_fmt = get_format_by_name(fid->fmt->cmd, format_str))) {
+		log_error("Unrecognised format %s for volume group %s.", format_str, vg->name);
+		goto bad;
+	}
+
 	if (dm_config_get_str(vgn, "system_id", &str))
 		strncpy(system_id, str, NAME_LEN);
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 2964b82..2467721 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -44,6 +44,7 @@ struct volume_group {
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
+	const struct format_type *original_fmt;	/* Set when processing backup files */
 	struct lvmcache_vginfo *vginfo;
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */


