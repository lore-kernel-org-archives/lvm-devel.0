From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:53:07 -0400
Subject: [PATCH 36/38] Allow 'all' and 'unmanaged' values for --vgmetadatacopies.
In-Reply-To: <1277520789-6808-36-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-19-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-20-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-21-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-22-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-23-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-24-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-25-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-26-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-27-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-28-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-29-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-30-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-31-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-32-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-33-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-34-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-35-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-36-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-37-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allowing an 'all' and 'unmanaged' value is more intuitive, and
provides a simple way for users to get back to original LVM behavior
of metadata written to all PVs in the volume group.

If the user requests "--vgmetadatacopies unmanaged", this instructs
LVM not to manage the ignore bits to achieve a specific number of
metadata copies in the volume group.  The user is free to use
"pvchange --metadataignore" to control the mdas on a per-PV basis.
If the user requests "--vgmetadatacopies all", this instructs LVM
to do 2 things: 1) clear all ignore bits, and 2) set the "unmanaged"
policy going forward.

Internally, we use the special MAX_UINT32 value to indicate 'all'.
This 'just' works since it's the largest value possible for the
field and so all 'ignore' bits on all mdas in the VG will get
cleared inside _vg_metadata_balance().  However, after we've
called the _vg_metadata_balance function, we check for the special
'all' value, and if set, we write the "unmanaged" value into the
metadata.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |    8 ++++++++
 lib/report/report.c              |    5 +++++
 tools/args.h                     |    2 +-
 tools/lvmcmdline.c               |   28 ++++++++++++++++++++++++++++
 tools/tools.h                    |    2 ++
 6 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d41688e..ecc5305 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -876,6 +876,8 @@ uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_used_count(const struct volume_group *vg);
+#define VGMETADATACOPIES_ALL UINT32_MAX
+#define VGMETADATACOPIES_UNMANAGED 0
 uint32_t vg_mda_copies(const struct volume_group *vg);
 int vg_set_mda_copies(struct volume_group *vg, uint32_t value);
 int vg_check_write_mode(struct volume_group *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a50b89f..977dcec 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1075,6 +1075,14 @@ static int _vg_metadata_balance(struct volume_group *vg)
 			count = vg->mda_copies - mda_copies;
 		ret = _vg_unignore_mdas(vg, count);
 	}
+	/*
+	 * 'All' is really a special cmdline value that means 2 things:
+	 * 1. clear all ignore bits in all mdas in this vg
+	 * 2. set the "unmanaged" policy going forward for metadata balancing
+	 */
+	if (vg->mda_copies == VGMETADATACOPIES_ALL)
+		vg->mda_copies = VGMETADATACOPIES_UNMANAGED;
+
 	if (!ret)
 		return ret;
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 4663106..28672f6 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -926,6 +926,11 @@ static int _vgmda_copies_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	count = vg_mda_copies(vg);
 
+	if (count == VGMETADATACOPIES_UNMANAGED) {
+		dm_report_field_set_value(field, "unmanaged", &_minusone64);
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
index 45762b5..4652888 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -473,6 +473,34 @@ int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 	return 1;
 }
 
+/*
+ * Non-zero, positive integer, "all", or "unmanaged"
+ */
+int vgmetadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
+			 struct arg *a)
+{
+	if (!strcasecmp(a->value, "all")) {
+		a->ui_value = VGMETADATACOPIES_ALL;
+		return 1;
+	}
+
+	if (!strcasecmp(a->value, "unmanaged")) {
+		a->ui_value = VGMETADATACOPIES_UNMANAGED;
+		return 1;
+	}
+
+	if (!_size_arg(cmd, a, 1))
+		return 0;
+
+	if (a->sign == SIGN_MINUS)
+		return 0;
+
+	if (!a->ui_value)
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


