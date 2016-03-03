From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:37 +0000 (UTC)
Subject: master - metadata: format_text: also export historical LVs
Message-ID: <20160303131937.6663E61B8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a0ef77305b179511aae6d8e5af05bbbebabee6b
Commit:        3a0ef77305b179511aae6d8e5af05bbbebabee6b
Parent:        790b2e874822767808f3c5bcc4ce1499944969ff
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:20:49 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:46:18 2016 +0100

metadata: format_text: also export historical LVs

Also export historical LVs when exporting LVM2 metadata.
This is list of all historical LVs listed in
"historical_logical_volumes" metadata section with all
the properties exported for each historical LV.

For example, we have this thin snapshot sequence:

  lvol1 --> lvol2 --> lvol3
                 \
                  --> lvol4

We end up with these metadata:

logical_volume {
  ...
  (lvol1, lvol3 and lvol4 listed here as usual - no change here)
  ...
}

historical_logical_volumes {
  lvol2 {
    id = "S0Dw1U-v5sF-LwAb-W9SI-pNOF-Madd-5dxSv5"
    creation_time = 1456919613      # 2016-03-02 12:53:33 +0100
    removal_time = 1456919620       # 2016-03-02 12:53:40 +0100
    origin = "lvol1"
    descendants = ["lvol3", "lvol4"]
  }
}

By removing lvol1 further, we end up with:

historical_logical_volumes {
  lvol2 {
    id = "S0Dw1U-v5sF-LwAb-W9SI-pNOF-Madd-5dxSv5"
    creation_time = 1456919613      # 2016-03-02 12:53:33 +0100
    removal_time = 1456919620       # 2016-03-02 12:53:40 +0100
    origin = "-lvol1"
    descendants = ["lvol3", "lvol4"]
  }

  lvol1 {
    id = "me0mes-aYnK-nRfT-vNlV-UiR1-GP7r-ojbROr"
    creation_time = 1456919608      # 2016-03-02 12:53:28 +0100
    removal_time = 1456919767       # 2016-03-02 12:56:07 +0100
  }
}
---
 lib/format_text/export.c         |  144 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    2 +
 lib/thin/thin.c                  |    1 +
 3 files changed, 147 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 99ed200..f17ccf5 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -651,6 +651,25 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 	return 1;
 }
 
+static int _print_timestamp(struct formatter *f,
+			     const char *name, time_t ts,
+			     char *buf, size_t buf_size)
+{
+	struct tm *local_tm;
+
+	if (ts) {
+		strncpy(buf, "# ", buf_size);
+		if (!(local_tm = localtime(&ts)) ||
+		    !strftime(buf + 2, buf_size - 2,
+			      "%Y-%m-%d %T %z", local_tm))
+			buf[0] = 0;
+
+		outfc(f, buf, "%s = %" PRIu64, name, ts);
+	}
+
+	return 1;
+}
+
 static int _print_lv(struct formatter *f, struct logical_volume *lv)
 {
 	struct lv_segment *seg;
@@ -774,6 +793,127 @@ static int _print_lvs(struct formatter *f, struct volume_group *vg)
 	return 1;
 }
 
+static int _alloc_printed_indirect_descendants(struct dm_list *indirect_glvs, char **buffer)
+{
+	struct glv_list *user_glvl;
+	size_t buf_size = 0;
+	int first = 1;
+	char *buf;
+
+	*buffer = NULL;
+
+	dm_list_iterate_items(user_glvl, indirect_glvs) {
+		if (user_glvl->glv->is_historical)
+			continue;
+		/* '"' + name + '"' + ',' + ' ' */
+		buf_size += strlen(user_glvl->glv->live->name) + 4;
+	}
+
+	if (!buf_size)
+		return 1;
+
+	/* '[' + ']' + '\0' */
+	buf_size += 3;
+
+	if (!(*buffer = dm_malloc(buf_size))) {
+		log_error("Could not allocate memory for ancestor list buffer.");
+		return 0;
+	}
+	buf = *buffer;
+
+	if (!emit_to_buffer(&buf, &buf_size, "["))
+		goto_bad;
+
+	dm_list_iterate_items(user_glvl, indirect_glvs) {
+		if (user_glvl->glv->is_historical)
+			continue;
+		if (!first) {
+			if (!emit_to_buffer(&buf, &buf_size, ", "))
+				goto_bad;
+		} else
+			first = 0;
+
+		if (!emit_to_buffer(&buf, &buf_size, "\"%s\"", user_glvl->glv->live->name))
+			goto_bad;
+	}
+
+	if (!emit_to_buffer(&buf, &buf_size, "]"))
+		goto_bad;
+
+	return 1;
+bad:
+	if (*buffer) {
+		dm_free(*buffer);
+		*buffer = NULL;
+	}
+	return 0;
+}
+
+static int _print_historical_lv(struct formatter *f, struct historical_logical_volume *hlv)
+{
+	char buffer[40];
+	char *descendants_buffer = NULL;
+	int r = 0;
+
+	if (!id_write_format(&hlv->lvid.id[1], buffer, sizeof(buffer)))
+		goto_out;
+
+	if (!_alloc_printed_indirect_descendants(&hlv->indirect_glvs, &descendants_buffer))
+		goto_out;
+
+	outnl(f);
+	outf(f, "%s {", hlv->name);
+	_inc_indent(f);
+
+	outf(f, "id = \"%s\"", buffer);
+
+	if (!_print_timestamp(f, "creation_time", hlv->timestamp, buffer, sizeof(buffer)))
+		goto_out;
+
+	if (!_print_timestamp(f, "removal_time", hlv->timestamp_removed, buffer, sizeof(buffer)))
+		goto_out;
+
+	if (hlv->indirect_origin) {
+		if (hlv->indirect_origin->is_historical)
+			outf(f, "origin = \"%s%s\"", HISTORICAL_LV_PREFIX, hlv->indirect_origin->historical->name);
+		else
+			outf(f, "origin = \"%s\"", hlv->indirect_origin->live->name);
+	}
+
+	if (descendants_buffer)
+		outf(f, "descendants = %s", descendants_buffer);
+
+	_dec_indent(f);
+	outf(f, "}");
+
+	r = 1;
+out:
+	if (descendants_buffer)
+		dm_free(descendants_buffer);
+	return r;
+}
+
+static int _print_historical_lvs(struct formatter *f, struct volume_group *vg)
+{
+	struct glv_list *glvl;
+
+	if (dm_list_empty(&vg->historical_lvs))
+		return 1;
+
+	outf(f, "historical_logical_volumes {");
+	_inc_indent(f);
+
+	dm_list_iterate_items(glvl, &vg->historical_lvs) {
+		if (!_print_historical_lv(f, glvl->glv->historical))
+			return_0;
+	}
+
+	_dec_indent(f);
+	outf(f, "}");
+
+	return 1;
+}
+
 /*
  * In the text format we refer to pv's as 'pv1',
  * 'pv2' etc.  This function builds a hash table
@@ -840,6 +980,10 @@ static int _text_vg_export(struct formatter *f,
 	if (!_print_lvs(f, vg))
 		goto_out;
 
+	outnl(f);
+	if (!_print_historical_lvs(f, vg))
+		goto_out;
+
 	_dec_indent(f);
 	if (!out_text(f, "}"))
 		goto_out;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 76597ba..7f1d43c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -37,6 +37,8 @@
 #define MAX_EXTENT_SIZE ((uint32_t) -1)
 #define MIN_NON_POWER2_EXTENT_SIZE (128U * 2U)	/* 128KB in sectors */
 
+#define HISTORICAL_LV_PREFIX "-"
+
 /* Layer suffix */
 #define MIRROR_SYNC_LAYER "_mimagetmp"
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 221ac48..6a19055 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -532,6 +532,7 @@ static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
 		outf(f, "external_origin = \"%s\"", seg->external_lv->name);
 	if (seg->origin)
 		outf(f, "origin = \"%s\"", seg->origin->name);
+
 	if (seg->merge_lv)
 		outf(f, "merge = \"%s\"", seg->merge_lv->name);
 


