From: David Teigland <teigland@sourceware.org>
Date: Mon,  8 Nov 2021 21:32:56 +0000 (GMT)
Subject: main - vgchange -aay: improve unexpected command variations
Message-ID: <20211108213256.C00913858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=024ce50f06feff2dae53dce83398911bef071a6e
Commit:        024ce50f06feff2dae53dce83398911bef071a6e
Parent:        14b68ea313865041433e18bac92a6dfcf6128b15
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 8 11:30:25 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 8 15:19:25 2021 -0600

vgchange -aay: improve unexpected command variations

For completeness and consistency, adjust the behavior
for some variations of:

  vgchange -aay --autoactivation event [vgname]

The current standard use is with a VG name arg, and the
command is only called when all pvs_online files exist.
This is the optimal case, in which only pvs_online devs
are read.  This remains the same.

Clean up behaviors for some other unexpected uses of the
command:

. With no VG name arg, the command activates any VGs
  that are complete according to pvs_online.  If no
  pvs_online files exist, it does nothing.

. If a VG name is used but no PVs online files exist for
  the VG, or the PVs online files are incomplete, then
  consider there could be a problem with the pvs_online
  files, and fall back to a full label scan prior to
  attempting the activation.
---
 lib/device/dev-cache.c            |   2 +-
 lib/device/online.c               |   6 ++
 lib/label/label.c                 |  48 +++++++++++-----
 lib/label/label.h                 |   4 +-
 test/shell/vgchange-pvs-online.sh | 112 +++++++++++++++++++++++++++++++-------
 tools/vgchange.c                  |  47 ++++++++++++++--
 6 files changed, 178 insertions(+), 41 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index e71cef38d..525dae31e 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -2164,7 +2164,7 @@ static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
 		}
 
 		if (devname[0]) {
-			log_debug("Found %s for %d:%d from sys", devname, major, minor);
+			log_debug("Found %s for %d:%d from sys dm", devname, major, minor);
 			return _strdup(devname);
 		}
 		return NULL;
diff --git a/lib/device/online.c b/lib/device/online.c
index cd89d72e3..58696871e 100644
--- a/lib/device/online.c
+++ b/lib/device/online.c
@@ -134,8 +134,12 @@ int get_pvs_online(struct dm_list *pvs_online, const char *vgname)
 
 		dm_list_add(pvs_online, &po->list);
 	}
+
 	if (closedir(dir))
 		log_sys_debug("closedir", PVS_ONLINE_DIR);
+
+	log_debug("PVs online found %d for %s", dm_list_size(pvs_online), vgname ?: "all");
+
 	return 1;
 }
 
@@ -355,6 +359,8 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 		dm_list_add(pvs_online, &po->list);
 	}
 
+	log_debug("PVs online lookup found %d for %s", dm_list_size(pvs_online), vgname);
+
 	fclose(fp);
 	return 1;
 
diff --git a/lib/label/label.c b/lib/label/label.c
index 2f9b5c371..9875b5f02 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1023,13 +1023,13 @@ int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev
 
 /*
  * Use files under /run/lvm/, created by pvscan --cache autoactivation,
- * to optimize device setup/scanning for a command that is run for a
- * specific vg name.  autoactivation happens during system startup
- * when the hints file is not useful, so this uses the online files as
- * an alternative.
- */ 
-
-int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
+ * to optimize device setup/scanning.  autoactivation happens during
+ * system startup when the hints file is not useful, but he pvs_online
+ * files can provide a similar optimization to the hints file.
+ */
+ 
+int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
+			 int *found_none, int *found_all, int *found_incomplete)
 {
 	struct dm_list pvs_online;
 	struct dm_list devs;
@@ -1042,6 +1042,8 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
 	dm_list_init(&pvs_online);
 	dm_list_init(&devs);
 
+	log_debug_devs("Finding online devices to scan");
+
 	/* reads devices file, does not populate dev-cache */
 	if (!setup_devices_for_online_autoactivation(cmd))
 		return 0;
@@ -1055,11 +1057,21 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
 	 * info from the online files tell us which devices those PVs are
 	 * located on.
 	 */
-	if (!get_pvs_lookup(&pvs_online, vgname)) {
-		if (!get_pvs_online(&pvs_online, vgname))
+	if (vgname) {
+		if (!get_pvs_lookup(&pvs_online, vgname)) {
+			if (!get_pvs_online(&pvs_online, vgname))
+				goto bad;
+		}
+	} else {
+		if (!get_pvs_online(&pvs_online, NULL))
 			goto bad;
 	}
 
+	if (dm_list_empty(&pvs_online)) {
+		*found_none = 1;
+		return 1;
+	}
+
 	/*
 	 * For each po devno add a struct dev to dev-cache.  This is a faster
 	 * alternative to the usual dev_cache_scan() which looks at all
@@ -1201,8 +1213,10 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
 
 	free_po_list(&pvs_online);
 
-	if (dm_list_empty(&devs))
+	if (dm_list_empty(&devs)) {
+		*found_none = 1;
 		return 1;
+	}
 
 	/*
 	 * Scan devs to populate lvmcache info, which includes the mda info that's
@@ -1220,13 +1234,17 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
 	 * be able to fall back to a standard label scan if the online hints
 	 * gave fewer PVs than listed in VG metadata.
 	 */
-	metadata_pv_count = lvmcache_pvsummary_count(vgname);
-	if (metadata_pv_count != dm_list_size(&devs)) {
-		log_debug("Incorrect PV list from online files %d metadata %d.",
-			   dm_list_size(&devs), metadata_pv_count);
-		return 0;
+	if (vgname) {
+		metadata_pv_count = lvmcache_pvsummary_count(vgname);
+		if (metadata_pv_count > dm_list_size(&devs)) {
+			log_debug("Incomplete PV list from online files %d metadata %d.",
+				  dm_list_size(&devs), metadata_pv_count);
+			*found_incomplete = 1;
+			return 1;
+		}
 	}
 
+	*found_all = 1;
 	return 1;
 bad:
 	free_po_list(&pvs_online);
diff --git a/lib/label/label.h b/lib/label/label.h
index 55ebfde45..3cda1818c 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -118,7 +118,9 @@ int label_scan_open_excl(struct device *dev);
 int label_scan_open_rw(struct device *dev);
 int label_scan_reopen_rw(struct device *dev);
 int label_read_pvid(struct device *dev, int *has_pvid);
-int label_scan_vg_online(struct cmd_context *cmd, const char *vgname);
+int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
+			 int *found_none, int *found_all, int *found_incomplete);
+
 
 int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev_out);
 
diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
index bdc481ced..c2ebe7327 100644
--- a/test/shell/vgchange-pvs-online.sh
+++ b/test/shell/vgchange-pvs-online.sh
@@ -19,61 +19,135 @@ _clear_online_files() {
 
 aux prepare_devs 4
 
+# Because mapping devno to devname gets dm name from sysfs
+aux lvmconf 'devices/scan = "/dev"'
+base1=$(basename $dev1)
+base2=$(basename $dev2)
+base3=$(basename $dev3)
+base4=$(basename $dev4)
+aux extend_filter "a|/dev/mapper/$base1|"
+aux extend_filter "a|/dev/mapper/$base2|"
+aux extend_filter "a|/dev/mapper/$base3|"
+aux extend_filter "a|/dev/mapper/$base4|"
+
 vgcreate $vg1 "$dev1" "$dev2"
 vgcreate $vg2 "$dev3"
 pvcreate "$dev4"
 
 lvcreate -l1 -n $lv1 -an $vg1
+lvcreate -l1 -n $lv2 -an $vg1
 lvcreate -l1 -n $lv1 -an $vg2
 
-# With no pv online files, vgchange that uses online files
-# will find no PVs to activate from.
+# Expected use, with vg name and all online files exist for vgchange.
 
 _clear_online_files
 
-not vgchange -aay --autoactivation event $vg1
-not vgchange -aay --autoactivation event $vg2
-vgchange -aay --autoactivation event
+pvscan --cache "$dev1"
+pvscan --cache "$dev2"
+vgchange -aay --autoactivation event $vg1
+check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv2 lv_active "active"
+check lv_field $vg2/$lv1 lv_active ""
+
+pvscan --cache "$dev3"
+vgchange -aay --autoactivation event $vg2
+check lv_field $vg2/$lv1 lv_active "active"
+
+# Count io to check the pvs_online optimization 
+# is working to limit scanning.
+
+vgchange -an
+_clear_online_files
+
+pvscan --cache "$dev1"
+pvscan --cache "$dev2"
+strace -e io_submit vgchange -aay --autoactivation event $vg1 2>&1|tee trace.out
+test "$(grep io_submit trace.out | wc -l)" -eq 4
+rm trace.out
+
+strace -e io_submit pvscan --cache "$dev3" 2>&1|tee trace.out
+test "$(grep io_submit trace.out | wc -l)" -eq 1
+rm trace.out
+
+strace -e io_submit vgchange -aay --autoactivation event $vg2 2>&1|tee trace.out
+test "$(grep io_submit trace.out | wc -l)" -eq 2
+rm trace.out
 
+# non-standard usage: no VG name arg, vgchange will only used pvs_online files
+
+vgchange -an
+_clear_online_files
+
+vgchange -aay --autoactivation event
 check lv_field $vg1/$lv1 lv_active ""
+check lv_field $vg1/$lv2 lv_active ""
 check lv_field $vg2/$lv1 lv_active ""
 
-# incomplete vg will not be activated
-
 pvscan --cache "$dev1"
-vgchange -aay --autoactivation event $vg1
-# VG foo is incomplete
+vgchange -aay --autoactivation event
 check lv_field $vg1/$lv1 lv_active ""
+check lv_field $vg1/$lv2 lv_active ""
+check lv_field $vg2/$lv1 lv_active ""
 
-# complete vg is activated
+pvscan --cache "$dev2"
+vgchange -aay --autoactivation event
+check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv2 lv_active "active"
+check lv_field $vg2/$lv1 lv_active ""
 
 pvscan --cache "$dev3"
-vgchange -aay --autoactivation event $vg2
+vgchange -aay --autoactivation event
 check lv_field $vg2/$lv1 lv_active "active"
 
-pvscan --cache "$dev2"
+# non-standard usage: include VG name arg, but missing or incomplete pvs_online files
+
+vgchange -an
+_clear_online_files
+
+# all missing pvs_online, vgchange falls back to full label scan
 vgchange -aay --autoactivation event $vg1
 check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv2 lv_active "active"
 
-vgchange -an $vg1
-vgchange -an $vg2
+vgchange -an
+_clear_online_files
 
-# the same tests but using command options matching udev rule
+# incomplete pvs_online, vgchange falls back to full label scan
+pvscan --cache "$dev1"
+vgchange -aay --autoactivation event $vg1
+check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv2 lv_active "active"
 
+vgchange -an
 _clear_online_files
 
-pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev1"
+# incomplete pvs_online, pvs_online from different vg,
+# no pvs_online found for vg arg so vgchange falls back to full label scan
+
+pvscan --cache "$dev3"
 vgchange -aay --autoactivation event $vg1
-# VG foo is incomplete
-check lv_field $vg1/$lv1 lv_active ""
+check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv2 lv_active "active"
+check lv_field $vg2/$lv1 lv_active ""
 
-pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev3"
 vgchange -aay --autoactivation event $vg2
 check lv_field $vg2/$lv1 lv_active "active"
 
+vgchange -an
+_clear_online_files
+
+# same tests but using command options matching udev rule
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev1"
 pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev2"
 vgchange -aay --autoactivation event $vg1
 check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv2 lv_active "active"
+check lv_field $vg2/$lv1 lv_active ""
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output "$dev3"
+vgchange -aay --autoactivation event $vg2
+check lv_field $vg2/$lv1 lv_active "active"
 
 vgchange -an $vg1
 vgchange -an $vg2
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e20026e4d..acdde97a8 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -879,7 +879,9 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (arg_is_set(cmd, autoactivation_ARG)) {
+		int found_none = 0, found_all = 0, found_incomplete = 0;
 		int skip_command = 0;
+
 		if (!_check_autoactivation(cmd, &vp, &skip_command))
 			return ECMD_FAILED;
 		if (skip_command)
@@ -889,14 +891,49 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		 * Special label scan optimized for autoactivation
 		 * that is based on info read from /run/lvm/ files
 		 * created by pvscan --cache during autoactivation.
-		 * (Add an option to disable this optimization?)
+		 * Add an option to disable this optimization?  e.g.
+		 * "online_skip" in --autoactivation / auto_activation_settings
+		 *
+		 * In some cases it might be useful to strictly follow
+		 * the online files, and not fall back to a standard
+		 * label scan when no pvs or incomplete pvs are found
+		 * from the online files.  Add option for that?  e.g.
+		 * "online_only" in --autoactivation / auto_activation_settings
+		 *
+		 * Generally the way that vgchange -aay --autoactivation event
+		 * is currently used, it will not be called until pvscan --cache
+		 * has found the VG is complete, so it will not generally be
+		 * following the paths that fall back to standard label_scan.
+		 *
+		 * TODO: Like pvscan_aa_quick, this could do lock_vol(vgname)
+		 * before label_scan_vg_online, then set cmd->can_use_one_scan=1
+		 * to avoid rescanning in _vg_read called by process_each_vg.
 		 */
 		get_single_vgname_cmd_arg(cmd, NULL, &vgname);
-		if (vgname) {
-			if (!label_scan_vg_online(cmd, vgname))
-				log_debug("Standard label_scan required in place of online scan.");
-			else
+		if (!label_scan_vg_online(cmd, vgname, &found_none, &found_all, &found_incomplete)) {
+			log_print("PVs online error%s%s, using all devices.", vgname ? " for VG " : "", vgname ?: "");
+		} else {
+			if (!vgname) {
+				/* Not expected usage, activate any VGs that are complete based on pvs_online. */
+				flags |= PROCESS_SKIP_SCAN;
+			} else if (found_all) {
+				/* The expected and optimal usage, only online PVs are read. */
 				flags |= PROCESS_SKIP_SCAN;
+			/*
+			} else if (online_only) {
+				log_print("PVs online %s.", found_none ? "not found" : "incomplete");
+				return vgname ? ECMD_FAILED : ECMD_PROCESSED;
+			*/
+			} else if (found_none) {
+				/* Not expected usage, use full label_scan in process_each */
+				log_print("PVs online not found for VG %s, using all devices.", vgname);
+			} else if (found_incomplete) {
+				/* Not expected usage, use full label_scan in process_each */
+				log_print("PVs online incomplete for VG %s, using all devicess.", vgname);
+			} else {
+				/* Shouldn't happen */
+				log_print("PVs online unknown for VG %s, using all devices.", vgname);
+			}
 		}
 	}
 


