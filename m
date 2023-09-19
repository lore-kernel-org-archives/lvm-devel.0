From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Tue, 19 Sep 2023 12:57:28 +0000
Subject: [Git][lvmteam/lvm2][main] 4 commits: pvmove: fix building sibling raid lv name
Message-ID: <65099ab83161e_28a546090386@gitlab-sidekiq-low-urgency-cpu-bound-v2-6486775c7f-xzqf4.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
e2f29c49 by Zdenek Kabelac at 2023-09-19T14:47:27+02:00
pvmove: fix building sibling raid lv name

Make a local copy of the &#39;idx&#39; string to avoid
overlapping during the rebuild of name.

This fixes cases where users specified raid
component LVs for moving.

Reported-by: kotarou3 at github.com

- - - - -
c7c51329 by Zdenek Kabelac at 2023-09-19T14:54:51+02:00
tests: check pvmove with raid legs

Check pvmove correctly handles raid legs on input
(testing previous pvmove fix).

- - - - -
984c024e by Zdenek Kabelac at 2023-09-19T14:54:51+02:00
typos: misc

- - - - -
fc2feabe by Zdenek Kabelac at 2023-09-19T14:54:51+02:00
WHATS_NEW: updates

- - - - -


8 changed files:

- WHATS_NEW
- daemons/lvmpolld/lvmpolld-data-utils.h
- device_mapper/libdm-string.c
- libdm/libdm-string.c
- test/Makefile.in
- test/lib/aux.sh
- test/shell/pvmove-raid-segtypes.sh
- tools/pvmove.c


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,5 +1,6 @@
 version 2.03.23 - 
 ==================================
+  Fix pvmove when specifying raid components as moved LVs.
   Enhance error detection for lvm_import_vdo.
   Support PV lists with thin lvconvert.
   Fix support for lvm_import_vdo with SCSI VDO volumes.


=====================================
daemons/lvmpolld/lvmpolld-data-utils.h
=====================================
@@ -66,7 +66,7 @@ struct lvmpolld_lv {
 
 	/* block of shared variables protected by lock */
 	struct lvmpolld_cmd_stat cmd_state;
-	unsigned init_rq_count; /* for debuging purposes only */
+	unsigned init_rq_count; /* for debugging purposes only */
 	unsigned polling_finished:1; /* no more updates */
 	unsigned error:1; /* unrecoverable error occured in lvmpolld */
 };


=====================================
device_mapper/libdm-string.c
=====================================
@@ -192,7 +192,7 @@ int dm_asprintf(char **result, const char *format, ...)
 }
 
 /*
- * Count occurences of 'c' in 'str' until we reach a null char.
+ * Count occurrences of 'c' in 'str' until we reach a null char.
  *
  * Returns:
  *  len - incremented for each char we encounter.


=====================================
libdm/libdm-string.c
=====================================
@@ -192,7 +192,7 @@ int dm_asprintf(char **result, const char *format, ...)
 }
 
 /*
- * Count occurences of 'c' in 'str' until we reach a null char.
+ * Count occurrences of 'c' in 'str' until we reach a null char.
  *
  * Returns:
  *  len - incremented for each char we encounter.


=====================================
test/Makefile.in
=====================================
@@ -110,7 +110,7 @@ help:
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
 	@echo "  LVM_TEST_LVMPOLLD	Start lvmpolld"
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
-	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
+	@echo "  LVM_TEST_PARALLEL	May skip agressive wipe of LVMTEST resources."
 	@echo "  LVM_TEST_RESULTS	Where to create result files [results]."
 	@echo "  LVM_TEST_THIN_CHECK_CMD   Command for thin_check   [$(LVM_TEST_THIN_CHECK_CMD)]."
 	@echo "  LVM_TEST_THIN_DUMP_CMD    Command for thin_dump    [$(LVM_TEST_THIN_DUMP_CMD)]."
@@ -126,7 +126,7 @@ help:
 	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
 	@echo "  LVM_VALGRIND_LVMPOLLD	Enable valgrind testing of lvmpolld (1)."
 	@echo "  LVM_STRACE		Enable strace logging."
-	@echo "  LVM_DEBUG_LEVEL	Sets debuging level for valgrind/strace (use > 0)."
+	@echo "  LVM_DEBUG_LEVEL	Sets debugging level for valgrind/strace (use > 0)."
 	@echo "  LVM_DEBUG_LVMDBUS	Run lvmdbus with --debug option."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
 	@echo "  LVM_LOG_FILE_MAX_LINES	Maximum number of logged lines for lvm2 command [1000000]."


=====================================
test/lib/aux.sh
=====================================
@@ -24,7 +24,7 @@ expect_failure() {
 }
 
 check_daemon_in_builddir() {
-	# skip if we don't have our own deamon...
+	# skip if we don't have our own daemon...
 	if test -z "${installed_testsuite+varset}"; then
 		(which "$1" 2>/dev/null | grep "$abs_builddir" >/dev/null ) || skip "$1 is not in executed path."
 	fi


=====================================
test/shell/pvmove-raid-segtypes.sh
=====================================
@@ -46,6 +46,20 @@ pvmove $mode -n $lv1 "$dev5" "$dev4"
 check lv_tree_on $vg $lv1 "$dev2" "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
+
+# Check moving raid component LVs
+pvmove $mode -n ${lv1}_rimage_0 "$dev4" "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2"
+check lv_on $vg ${lv1}_rimage_0 "$dev1"
+check lv_on $vg ${lv1}_rmeta_0 "$dev4"
+check dev_md5sum $vg $lv1
+lvs -ao+devices  $vg
+
+pvmove $mode -n ${lv1}_rmeta_0 "$dev4" "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2"
+check lv_on $vg ${lv1}_rimage_0 "$dev1"
+check lv_on $vg ${lv1}_rmeta_0 "$dev1"
+check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
 # Testing pvmove of RAID10 LV


=====================================
tools/pvmove.c
=====================================
@@ -141,6 +141,7 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 	char *idx, *suffix;
 	const char *sibling;
 	char sublv_name[NAME_LEN];
+	char idx_buf[16];
 	struct logical_volume *sublv;
 	struct dm_list untrim_list, *pvh1, *pvh2;
 	struct pv_list *pvl1, *pvl2;
@@ -174,9 +175,15 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 	}
 	idx++;
 
+        /* Copy idx to local buffer */
+	if (!dm_strncpy(idx_buf, idx, sizeof(idx_buf))) {
+		log_error(INTERNAL_ERROR "Unexpected LV index %s.", idx);
+		return 0;
+	}
+
 	/* Create the siblings name (e.g. "raidlv_rmeta_N" -> "raidlv_rimage_N" */
 	if (dm_snprintf(suffix + 2, sizeof(sublv_name) - 2 - (suffix - sublv_name),
-			"%s_%s", sibling, idx) < 0) {
+			"%s_%s", sibling, idx_buf) < 0) {
 		log_error("Raid sublv for name %s too long.", lv_name);
 		return 0;
 	}



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/970e4d295eddb47d4540bb0762e35bd17b07841f...fc2feabef7507108311c01e48c6262606caf37fd

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/970e4d295eddb47d4540bb0762e35bd17b07841f...fc2feabef7507108311c01e48c6262606caf37fd
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230919/337422fa/attachment-0001.htm>
