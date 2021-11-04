From: David Teigland <teigland@sourceware.org>
Date: Thu,  4 Nov 2021 16:37:13 +0000 (GMT)
Subject: main - vgchange -aay: optimize device scan using pvs_online files
Message-ID: <20211104163713.0634D385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d558b3ad7e6086480075b3bf750eba0ee66c78ec
Commit:        d558b3ad7e6086480075b3bf750eba0ee66c78ec
Parent:        594f6ca97024fa23dfa852b6cc9da272877e1ced
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 3 12:03:29 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 4 11:08:38 2021 -0500

vgchange -aay: optimize device scan using pvs_online files

Port the old pvscan -aay scanning optimization to vgchange -aay.
The optimization uses pvs_online files created by pvscan --cache
to derive a list of devices to use when activating a VG.  This
allows autoactivation of a VG to avoid scanning all devices, and
only scan the devices used by the VG itself.  The optimization is
applied internally using the device hints interface.

The new option "--autoactivation event" is given to pvscan and
vgchange commands that are called by event activation.  This
informs the command that it is being used for event activation,
so that it can apply checks and optimizations that are specific
to event activation.  Those include:

- skipping the command if lvm.conf event_activation=0
- checking that a VG is complete before activating it
- using pvs_online files to limit device scanning
---
 test/shell/vgchange-pvs-online.sh | 98 +++++++++++++++++++++++++++++++++++++++
 tools/args.h                      |  6 +++
 tools/command-lines.in            |  8 ++--
 tools/pvscan.c                    | 34 +++++++++++++-
 tools/tools.h                     |  2 +-
 tools/vgchange.c                  | 56 +++++++++++++++++++++-
 udev/69-dm-lvm-metad.rules.in     |  2 +-
 udev/69-dm-lvm.rules.in           |  4 +-
 8 files changed, 199 insertions(+), 11 deletions(-)

diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
new file mode 100644
index 000000000..bdc481ced
--- /dev/null
+++ b/test/shell/vgchange-pvs-online.sh
@@ -0,0 +1,98 @@
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+PVS_LOOKUP_DIR="$RUNDIR/lvm/pvs_lookup"
+
+_clear_online_files() {
+        # wait till udev is finished
+        aux udev_wait
+        rm -f "$PVS_ONLINE_DIR"/*
+        rm -f "$VGS_ONLINE_DIR"/*
+        rm -f "$PVS_LOOKUP_DIR"/*
+}
+
+. lib/inittest
+
+aux prepare_devs 4
+
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3"
+pvcreate "$dev4"
+
+lvcreate -l1 -n $lv1 -an $vg1
+lvcreate -l1 -n $lv1 -an $vg2
+
+# With no pv online files, vgchange that uses online files
+# will find no PVs to activate from.
+
+_clear_online_files
+
+not vgchange -aay --autoactivation event $vg1
+not vgchange -aay --autoactivation event $vg2
+vgchange -aay --autoactivation event
+
+check lv_field $vg1/$lv1 lv_active ""
+check lv_field $vg2/$lv1 lv_active ""
+
+# incomplete vg will not be activated
+
+pvscan --cache "$dev1"
+vgchange -aay --autoactivation event $vg1
+# VG foo is incomplete
+check lv_field $vg1/$lv1 lv_active ""
+
+# complete vg is activated
+
+pvscan --cache "$dev3"
+vgchange -aay --autoactivation event $vg2
+check lv_field $vg2/$lv1 lv_active "active"
+
+pvscan --cache "$dev2"
+vgchange -aay --autoactivation event $vg1
+check lv_field $vg1/$lv1 lv_active "active"
+
+vgchange -an $vg1
+vgchange -an $vg2
+
+# the same tests but using command options matching udev rule
+
+_clear_online_files
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev1"
+vgchange -aay --autoactivation event $vg1
+# VG foo is incomplete
+check lv_field $vg1/$lv1 lv_active ""
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev3"
+vgchange -aay --autoactivation event $vg2
+check lv_field $vg2/$lv1 lv_active "active"
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev2"
+vgchange -aay --autoactivation event $vg1
+check lv_field $vg1/$lv1 lv_active "active"
+
+vgchange -an $vg1
+vgchange -an $vg2
+
+# with a full pvscan --cache
+
+_clear_online_files
+
+pvscan --cache
+check lv_field $vg1/$lv1 lv_active ""
+check lv_field $vg2/$lv1 lv_active ""
+vgchange -aay --autoactivation event $vg1
+vgchange -aay --autoactivation event $vg2
+check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg2/$lv1 lv_active "active"
+
+vgchange -an $vg1
+vgchange -an $vg2
+
+vgremove -f $vg1
+vgremove -f $vg2
+
diff --git a/tools/args.h b/tools/args.h
index 774ce33f4..2aed8afbb 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -87,6 +87,12 @@ arg(atversion_ARG, '\0', "atversion", string_VAL, 0, 0,
     "which does not contain any newer settings for which LVM would\n"
     "issue a warning message when checking the configuration.\n")
 
+arg(autoactivation_ARG, '\0', "autoactivation", string_VAL, 0, 0,
+    "Specify if autoactivation is being used from an event.\n"
+    "This allows the command to apply settings that are specific\n"
+    "to event activation, such as device scanning optimizations\n"
+    "using pvs_online files created by event-based pvscans.\n")
+
 arg(setautoactivation_ARG, '\0', "setautoactivation", bool_VAL, 0, 0,
     "Set the autoactivation property on a VG or LV.\n"
     "Display the property with vgs or lvs \"-o autoactivation\".\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 10b23e75d..d4691c686 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1642,14 +1642,15 @@ DESC: Record that a PV is online or offline.
 
 pvscan --cache_long --activate ay
 OO: --ignorelockingfailure, --reportformat ReportFmt,
---major Number, --minor Number, --noudevsync
+--major Number, --minor Number, --noudevsync, --autoactivation String
 OP: PV|String ...
 IO: --background
 ID: pvscan_cache
 DESC: Record that a PV is online and autoactivate the VG if complete.
 
 pvscan --cache_long --listvg PV
-OO: --ignorelockingfailure, --checkcomplete, --vgonline, --udevoutput
+OO: --ignorelockingfailure, --checkcomplete, --vgonline, --udevoutput,
+--autoactivation String
 ID: pvscan_cache
 DESC: Record that a PV is online and list the VG using the PV.
 
@@ -1747,7 +1748,8 @@ DESC: Start or stop processing LV conversions.
 
 vgchange --activate Active
 OO: --activationmode ActivationMode, --ignoreactivationskip, --partial, --sysinit,
---readonly, --ignorelockingfailure, --monitor Bool, --poll Bool, OO_VGCHANGE
+--readonly, --ignorelockingfailure, --monitor Bool, --poll Bool,
+--autoactivation String, OO_VGCHANGE
 OP: VG|Tag|Select ...
 IO: --ignoreskippedcluster
 ID: vgchange_activate
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 4f97e211c..d9607fdb6 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -750,7 +750,7 @@ static int _pvscan_aa_single(struct cmd_context *cmd, const char *vg_name,
 
 	log_debug("pvscan autoactivating VG %s.", vg_name);
 
-	if (!vgchange_activate(cmd, vg, CHANGE_AAY)) {
+	if (!vgchange_activate(cmd, vg, CHANGE_AAY, 1)) {
 		log_error_pvscan(cmd, "%s: autoactivation failed.", vg->name);
 		pp->activate_errors++;
 	}
@@ -1038,7 +1038,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 
 	log_debug("pvscan autoactivating VG %s.", vgname);
 
-	if (!vgchange_activate(cmd, vg, CHANGE_AAY)) {
+	if (!vgchange_activate(cmd, vg, CHANGE_AAY, 1)) {
 		log_error_pvscan(cmd, "%s: autoactivation failed.", vg->name);
 		pp->activate_errors++;
 	}
@@ -1869,12 +1869,35 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	return ret;
 }
 
+static int _get_autoactivation(struct cmd_context *cmd, int event_activation, int *skip_command)
+{
+	const char *aa_str;
+
+	if (!(aa_str = arg_str_value(cmd, autoactivation_ARG, NULL)))
+		return 1;
+
+	if (strcmp(aa_str, "event")) {
+		log_print_pvscan(cmd, "Skip pvscan for unknown autoactivation value.");
+		*skip_command = 1;
+		return 1;
+	}
+	
+	if (!event_activation) {
+		log_print_pvscan(cmd, "Skip pvscan for event with event_activation=0.");
+		*skip_command = 1;
+		return 1;
+	}
+
+	return 1;
+}
+
 int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvscan_aa_params pp = { 0 };
 	struct dm_list complete_vgnames;
 	int do_activate = arg_is_set(cmd, activate_ARG);
 	int event_activation;
+	int skip_command = 0;
 	int devno_args = 0;
 	int do_all;
 	int ret;
@@ -1946,6 +1969,13 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 			log_verbose("Ignoring pvscan --cache because event_activation is disabled.");
 			return ECMD_PROCESSED;
 		}
+
+		if (!_get_autoactivation(cmd, event_activation, &skip_command))
+			return_ECMD_FAILED;
+
+		if (skip_command)
+			return ECMD_PROCESSED;
+
 		if (!_pvscan_cache_args(cmd, argc, argv, &complete_vgnames))
 			return ECMD_FAILED;
 	}
diff --git a/tools/tools.h b/tools/tools.h
index bc98fcb09..182ff3af9 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -228,7 +228,7 @@ int mirror_remove_missing(struct cmd_context *cmd,
 
 
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
-		       activation_change_t activate);
+		       activation_change_t activate, int vg_complete_to_activate);
 
 int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg);
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e4b57dbd2..ee06c498c 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -19,6 +19,7 @@
 struct vgchange_params {
 	int lock_start_count;
 	unsigned int lock_start_sanlock : 1;
+	unsigned int vg_complete_to_activate : 1;
 };
 
 /*
@@ -195,10 +196,11 @@ int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg
 }
 
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
-		      activation_change_t activate)
+		      activation_change_t activate, int vg_complete_to_activate)
 {
 	int lv_open, active, monitored = 0, r = 1;
 	const struct lv_list *lvl;
+	struct pv_list *pvl;
 	int do_activate = is_change_activating(activate);
 
 	/*
@@ -219,6 +221,15 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		return 1;
 	}
 
+	if (do_activate && vg_complete_to_activate) {
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			if (!pvl->pv->dev) {
+				log_print("VG %s is incomplete.", vg->name);
+				return 1;
+			}
+		}
+	}
+
 	/*
 	 * Safe, since we never write out new metadata here. Required for
 	 * partial activation to work.
@@ -647,6 +658,7 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
 			    struct processing_handle *handle)
 {
+	struct vgchange_params *vp = (struct vgchange_params *)handle->custom_handle;
 	int ret = ECMD_PROCESSED;
 	unsigned i;
 	activation_change_t activate;
@@ -701,7 +713,7 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 
 	if (arg_is_set(cmd, activate_ARG)) {
 		activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, 0);
-		if (!vgchange_activate(cmd, vg, activate))
+		if (!vgchange_activate(cmd, vg, activate, vp->vg_complete_to_activate))
 			return_ECMD_FAILED;
 	} else if (arg_is_set(cmd, refresh_ARG)) {
 		/* refreshes the visible LVs (which starts polling) */
@@ -722,8 +734,38 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	return ret;
 }
 
+static int _check_autoactivation(struct cmd_context *cmd, struct vgchange_params *vp, int *skip_command)
+{
+	const char *aa;
+
+	if (!(aa = arg_str_value(cmd, autoactivation_ARG, NULL)))
+		return 1;
+
+	if (strcmp(aa, "event")) {
+		log_print("Skip vgchange for unknown autoactivation value.");
+		*skip_command = 1;
+		return 1;
+	}
+
+	if (!find_config_tree_bool(cmd, global_event_activation_CFG, NULL)) {
+		log_print("Skip vgchange for event and event_activation=0.");
+		*skip_command = 1;
+		return 1;
+	}
+
+	vp->vg_complete_to_activate = 1;
+
+	if (!arg_is_set(cmd, nohints_ARG))
+		cmd->hints_pvs_online = 1;
+	else
+		cmd->use_hints = 0;
+
+	return 1;
+}
+
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct vgchange_params vp = { 0 };
 	struct processing_handle *handle;
 	uint32_t flags = 0;
 	int ret;
@@ -837,6 +879,14 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 			cmd->lockd_vg_enforce_sh = 1;
 	}
 
+	if (arg_is_set(cmd, autoactivation_ARG)) {
+		int skip_command = 0;
+		if (!_check_autoactivation(cmd, &vp, &skip_command))
+			return ECMD_FAILED;
+		if (skip_command)
+			return ECMD_PROCESSED;
+	}
+
 	if (update)
 		flags |= READ_FOR_UPDATE;
 	else if (arg_is_set(cmd, activate_ARG))
@@ -847,6 +897,8 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	handle->custom_handle = &vp;
+
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, 0, handle, &_vgchange_single);
 
 	destroy_processing_handle(cmd, handle);
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 78f506520..a2384f2af 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -121,6 +121,6 @@ LABEL="direct_pvscan"
 #  MD    |          |      X      |       X*       |                   |
 #  loop  |          |      X      |       X*       |                   |
 #  other |    X     |             |       X        |                   |   X
-RUN+="(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major $major --minor $minor", ENV{LVM_SCANNED}="1"
+RUN+="(LVM_EXEC)/lvm pvscan --cache --aay --autoactivation event --major $major --minor $minor", ENV{LVM_SCANNED}="1"
 
 LABEL="lvm_end"
diff --git a/udev/69-dm-lvm.rules.in b/udev/69-dm-lvm.rules.in
index d6bf1e0e9..4f34b2cc2 100644
--- a/udev/69-dm-lvm.rules.in
+++ b/udev/69-dm-lvm.rules.in
@@ -79,8 +79,8 @@ ENV{SYSTEMD_READY}="1"
 # TODO: adjust the output of vgchange -aay so that
 # it's better suited to appearing in the journal.
 
-IMPORT{program}="(LVM_EXEC)/lvm pvscan --cache --listvg --checkcomplete --vgonline --udevoutput --journal=output $env{DEVNAME}"
-ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="/usr/bin/systemd-run -r --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} (LVM_EXEC)/lvm vgchange -aay --nohints $env{LVM_VG_NAME_COMPLETE}"
+IMPORT{program}="(LVM_EXEC)/lvm pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output $env{DEVNAME}"
+ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="/usr/bin/systemd-run -r --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} (LVM_EXEC)/lvm vgchange -aay --autoactivation event $env{LVM_VG_NAME_COMPLETE}"
 GOTO="lvm_end"
 
 LABEL="lvm_end"


