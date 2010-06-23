From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 23 Jun 2010 15:05:32 -0400
Subject: [PATCH] Allow 'all' value for --vgmetadatacopies.
Message-ID: <1277319932-7048-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allowing an 'all' value is more user-friendly, and provides a simple
and intuitive way for users to get back to original LVM behavior
of metadata written to all PVs in the volume group.
Internally, we use the special MAX_UINT32 value to indicate 'all'.
This 'just' works since it's the largest value possible for the
field and so all 'ignore' bits on all mdas in the VG will get
cleared inside _vg_metadata_balance().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/report/report.c              |    5 +++++
 tools/args.h                     |    2 +-
 tools/lvmcmdline.c               |   17 +++++++++++++++++
 tools/tools.h                    |    2 ++
 5 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3414d8c..c98fee0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -878,6 +878,7 @@ uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_count_ignored(const struct volume_group *vg);
+#define VGMETADATACOPIES_ALL UINT32_MAX
 uint32_t vg_mda_copies(const struct volume_group *vg);
 int vg_set_mda_copies(struct volume_group *vg, uint32_t value);
 int vg_check_write_mode(struct volume_group *vg);
diff --git a/lib/report/report.c b/lib/report/report.c
index 9c3177a..9bd234b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -926,6 +926,11 @@ static int _vgmda_copies_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	count = vg_mda_copies(vg);
 
+	if (count == VGMETADATACOPIES_ALL) {
+		dm_report_field_set_value(field, "all", &_minusone64);
+		return 1;
+	}
+
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
diff --git a/tools/args.h b/tools/args.h
index 60d99d1..ebce252 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -23,7 +23,7 @@ arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
-arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", int_arg, 0)
+arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", vgmetadatacopies_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 45762b5..49ac377 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -473,6 +473,23 @@ int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 	return 1;
 }
 
+/*
+ * Positive integer, or "all"
+ */
+int vgmetadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
+			 struct arg *a)
+{
+	if (!strcasecmp(a->value, "all")) {
+		a->ui_value = VGMETADATACOPIES_ALL;
+		return 1;
+	}
+
+	if (!_size_arg(cmd, a, 1))
+		return 0;
+
+	return 1;
+}
+
 static void __alloc(int size)
 {
 	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
diff --git a/tools/tools.h b/tools/tools.h
index d96b8dc..a09fa8e 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -152,6 +152,8 @@ int units_arg(struct cmd_context *cmd, struct arg *a);
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
+int vgmetadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
+			 struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
-- 
1.6.0.6


