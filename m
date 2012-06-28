From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Jun 2012 13:49:07 +0000 (UTC)
Subject: master - pvscan: add --activate ay option (autoactivate)
Message-ID: <20120628134907.49B5A1687@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2df8dddc8c04973a3e23b7a19e9bfbf8c45f79e
Commit:        d2df8dddc8c04973a3e23b7a19e9bfbf8c45f79e
Parent:        215a314f195ea4af5265e37999502462fcf2a341
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 27 09:35:11 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 28 09:44:03 2012 -0400

pvscan: add --activate ay option (autoactivate)

Define auto_activation_handler that activates VGs/LVs automatically
based on the activation/auto_activation_volume_list (activating all
volumes by default if the list is not defined).

The autoactivation is done within the pvscan call in 69-dm-lvmetad.rules
that watches for udev events (device appearance/removal).

For now, this works for non-clustered and complete VGs only.
---
 WHATS_NEW                     |    1 +
 tools/commands.h              |    4 +++-
 tools/pvscan.c                |   27 +++++++++++++++++++++++++++
 udev/69-dm-lvm-metad.rules.in |    2 +-
 4 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fb3279e..481e8e3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add --activate ay to pvscan.
   Add --activate ay to vgchange.
   Add support for volume autoactivation using lvmetad.
   Add --activate synonym for --available arg and prefer --activate.
diff --git a/tools/commands.h b/tools/commands.h
index 8bec092..21791f7 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -671,6 +671,7 @@ xx(pvscan,
    "List all physical volumes",
    PERMITTED_READ_ONLY,
    "pvscan " "\n"
+   "\t[-a|--activate ay]\n"
    "\t[--cache [ DevicePath | --major major --minor minor]...]\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
@@ -682,7 +683,8 @@ xx(pvscan,
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   cache_ARG, exported_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG,
+   activate_ARG, available_ARG, cache_ARG, exported_ARG,
+   ignorelockingfailure_ARG, major_ARG, minor_ARG,
    novolumegroup_ARG, partial_ARG, short_ARG, uuid_ARG)
 
 xx(segtypes,
diff --git a/tools/pvscan.c b/tools/pvscan.c
index beba174..a040899 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -97,6 +97,20 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 					   pv_pe_size(pv)));
 }
 
+static int _auto_activation_handler(struct volume_group *vg, int partial, int activate)
+{
+	/* TODO: add support for partial and clustered VGs */
+	if (partial || vg_is_clustered(vg))
+		return 1;
+
+	if (!vgchange_activate(vg->cmd, vg, activate)) {
+		log_error("%s: autoactivation failed.", vg->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler)
 {
 	struct dev_iter *iter;
@@ -136,6 +150,14 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	char *buf;
 	activation_handler handler = NULL;
 
+	if (arg_count(cmd, activate_ARG)) {
+		if (arg_uint_value(cmd, activate_ARG, CHANGE_AAY) != CHANGE_AAY) {
+			log_error("Only --activate ay allowed with pvscan.");
+			return 0;
+		}
+		handler = _auto_activation_handler;
+	}
+
 	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG))
 		devno_args = 1;
 
@@ -241,6 +263,11 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, cache_ARG))
 		return _pvscan_lvmetad(cmd, argc, argv);
 
+	if (arg_count(cmd, activate_ARG)) {
+		log_error("--activate is only valid with --cache.");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG)) {
 		log_error("--major and --minor are only valid with --cache.");
 		return EINVALID_CMD_LINE;
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 26309de..706c03b 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -21,6 +21,6 @@ SUBSYSTEM!="block", GOTO="lvm_end"
 KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
 
 # Only process devices already marked as a PV - this requires blkid to be called before.
-ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="(LVM_EXEC)/lvm pvscan --cache --major $major --minor $minor"
+ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="(LVM_EXEC)/lvm pvscan --cache --activate ay --major $major --minor $minor"
 
 LABEL="lvm_end"


