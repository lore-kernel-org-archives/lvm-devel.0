From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:06:00 -0400
Subject: [PATCH 27/35] Update vgchange tool to accept --vgmetadatacopies.
In-Reply-To: <1277175968-9661-27-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-26-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-27-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-28-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update logic in vgchange to handle --vgmetadatacopies, allow
--metadatacopies as a synonym to --vgmetadatacopies,
and add these parameters to args.h and commands.h

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/args.h     |    1 +
 tools/commands.h |    4 +++-
 tools/vgchange.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 51 insertions(+), 3 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index d343689..60d99d1 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -23,6 +23,7 @@ arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
+arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", int_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 6d8d2c0..62a684b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -710,6 +710,7 @@ xx(vgchange,
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
@@ -731,7 +732,8 @@ xx(vgchange,
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
-   partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
+   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG,
+   physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
    resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e2fbaeb..fc2f44d 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -525,6 +525,45 @@ static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
 	return ECMD_PROCESSED;
 }
 
+static int _vgchange_metadata_copies(struct cmd_context *cmd,
+				     struct volume_group *vg)
+{
+	uint32_t value;
+
+	if (arg_count(cmd, vgmetadatacopies_ARG))
+		value = arg_uint_value(cmd, vgmetadatacopies_ARG,
+			DEFAULT_VGMETADATACOPIES);
+	else if (arg_count(cmd, metadatacopies_ARG))
+		value = arg_uint_value(cmd, metadatacopies_ARG,
+			DEFAULT_VGMETADATACOPIES);
+	if (value == vg_mda_copies(vg)) {
+		log_error("Metadata copies of VG %s is already %u",
+			  vg->name, value);
+		return ECMD_PROCESSED;
+	}
+
+	if (!archive(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	if (!vg_set_mda_copies(vg, value)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	backup(vg);
+
+	log_print("Volume group \"%s\" successfully changed", vg->name);
+
+	return ECMD_PROCESSED;
+}
+
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
@@ -593,6 +632,10 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	else if (arg_count(cmd, refresh_ARG))
 		r = _vgchange_refresh(cmd, vg);
 
+	else if (arg_count(cmd, vgmetadatacopies_ARG) ||
+		 arg_count(cmd, metadatacopies_ARG))
+		r = _vgchange_metadata_copies(cmd, vg);
+
 	return r;
 }
 
@@ -606,10 +649,12 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	     arg_count(cmd, physicalextentsize_ARG) +
 	     arg_count(cmd, clustered_ARG) + arg_count(cmd, alloc_ARG) +
 	     arg_count(cmd, monitor_ARG) + arg_count(cmd, poll_ARG) +
-	     arg_count(cmd, refresh_ARG))) {
+	     arg_count(cmd, refresh_ARG) + arg_count(cmd, metadatacopies_ARG) +
+	     arg_count(cmd, vgmetadatacopies_ARG))) {
 		log_error("Need 1 or more of -a, -c, -l, -p, -s, -x, "
 			  "--refresh, --uuid, --alloc, --addtag, --deltag, "
-			  "--monitor or --poll");
+			  "--monitor, --poll, --vgmetadatacopies or "
+			  "--metadatacopies");
 		return EINVALID_CMD_LINE;
 	}
 
-- 
1.6.0.6


