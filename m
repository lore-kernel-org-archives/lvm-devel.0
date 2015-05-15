From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 15 May 2015 22:28:58 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150515222858.1E4B060C9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0300730cc9ba058df830d9cb0981183b90ad17db
Commit:        0300730cc9ba058df830d9cb0981183b90ad17db
Parent:        9e102ecbd9b6efc36e09c84b8f0882d993038f84
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri May 15 23:19:29 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri May 15 23:19:29 2015 +0100

pre-release

---
 VERSION                      |    2 +-
 VERSION_DM                   |    2 +-
 WHATS_NEW                    |   13 ++++++++++---
 WHATS_NEW_DM                 |    4 ++--
 lib/config/config_settings.h |    2 +-
 lib/metadata/raid_manip.c    |    6 ++++--
 6 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/VERSION b/VERSION
index adebf56..b79b8d2 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.120(2)-git (2015-05-02)
+2.02.120(2)-git (2015-05-15)
diff --git a/VERSION_DM b/VERSION_DM
index bb766e7..829a0b4 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.97-git (2015-05-02)
+1.02.97-git (2015-05-15)
diff --git a/WHATS_NEW b/WHATS_NEW
index 13a034b..ea0713f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,18 +1,25 @@
-Version 2.02.120 -
-===============================
-  add lvmpolld client mode for querying running server instance for status info.
+Version 2.02.120 - 15th May 2015
+================================
+  Make various adjustments to Makefile compilation flags.
+  Add lvmpolld debug message class.
+  Add lvmpolld client mode for querying running server instance for status info.
   Fix some libdaemon socket creation and reuse error paths.
   Daemons (libdaemon) support exit on idle also in non-systemd environment.
   Provide make dist and make rpm targets
   Configure lvm.conf for use_lvmetad and use_lvmpolld.
   Add lvpoll for cmdline communication with lvmpolld.
   Add lvmpolld acting as a free-standing version of polldaemon.
+  Avoid repeated identical lvmetad VG lookups in commands processing all VGs.
+  Handle switches to alternative duplicate PVs efficiently with lvmetad.
   Properly validate PV size for pvcreate --restorefile.
   Fix check if pvcreate wiped device (2.02.117).
   Fix storing of vgid when caching metadata (2.02.118).
   Fix recursive lvm-config man page. (2.02.119)
   Refactor polldaemon interfaces to poll every operation by VG/LV couple
   Skip wait after testing in _wait_for_single_lv when polling finished
+  Return 'None' in python for empty string properties instead of crashing.
+  Distinguish signed numerical property type in reports for lvm2app library.
+  Reread raid completion status immediately when progress appears to be zero.
   lvm2app closes locking on lvm_quit().
   Configure detects /run or /var/run.
   Add missing newline in clvmd --help output.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index cdea8c2..6f8402f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.97 - 
-==============================
+Version 1.02.97 - 15th May 2015
+===============================
   New dm_task_get_info(DM_1_02_97) supports internal_suspend state.
   New symbols are versioned and comes with versioned symbol name (DM_1_02_97).
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index a06b3e6..885a2fa 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -175,7 +175,7 @@ cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING,
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
-cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
+cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
 
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
 	"Obtain the list of available devices from udev.\n"
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0428eb0..64cfb3f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -95,8 +95,10 @@ static int _raid_in_sync(struct logical_volume *lv)
 	}
 	if (sync_percent == DM_PERCENT_0) {
 		/*
-		 * Repeat read of status once more - since buggy kernel target
-		 * sometimes reports 0 even though the array is in 100% sync
+		 * FIXME We repeat the status read here to workaround an
+		 * unresolved kernel bug when we see 0 even though the 
+		 * the array is 100% in sync.
+		 * https://bugzilla.redhat.com/1210637
 		 */
 		if (!lv_raid_percent(lv, &sync_percent)) {
 			log_error("Unable to determine sync status of %s/%s.",


