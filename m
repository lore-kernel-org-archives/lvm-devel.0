From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 10 Aug 2010 18:24:47 -0400
Subject: [PATCH 1/2] require --restorefile when using pvcreate --uuid
Message-ID: <1281479088-1553-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce --norestorefile to allow user to override the new requirement
that --restorefile be supplied when using pvcreate --uuid.

This can also be overridden with "devices/require_restorefile_with_uuid"
in lvm.conf -- however the default is 1.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
--
 doc/example.conf.in          |    3 +++
 lib/config/defaults.h        |    1 +
 test/t-pvcreate-operation.sh |   11 +++++++----
 tools/args.h                 |    1 +
 tools/commands.h             |    6 ++++--
 tools/pvcreate.c             |   10 ++++++++++
 6 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index f7dcc63..a107d2b 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -130,6 +130,9 @@ devices {
     # Set this to 1 to skip such devices.  This should only be needed
     # in recovery situations.
     ignore_suspended_devices = 0
+
+    # Allow use of pvcreate --uuid without requiring --restorefile.
+    require_restorefile_with_uuid = 1
 }
 
 # This section that allows you to configure the nature of the
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 3d8881c..dd9897d 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -30,6 +30,7 @@
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
+#define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 
diff --git a/test/t-pvcreate-operation.sh b/test/t-pvcreate-operation.sh
index a9d1a42..2c94696 100755
--- a/test/t-pvcreate-operation.sh
+++ b/test/t-pvcreate-operation.sh
@@ -95,17 +95,20 @@ uuid2=freddy-fred-fred-fred-fred-fred-fredie
 bogusuuid=fred
 
 # pvcreate rejects uuid option with less than 32 characters
-not pvcreate --uuid $bogusuuid $dev1
+not pvcreate --norestorefile --uuid $bogusuuid $dev1
+
+# pvcreate rejects uuid option without restorefile
+not pvcreate --uuid $uuid1 $dev1
 
 # pvcreate rejects uuid already in use
-pvcreate --uuid $uuid1 $dev1
-not pvcreate --uuid $uuid1 $dev2
+pvcreate --norestorefile --uuid $uuid1 $dev1
+not pvcreate --norestorefile --uuid $uuid1 $dev2
 
 # pvcreate rejects non-existent file given with restorefile
 not pvcreate --uuid $uuid1 --restorefile $backupfile $dev1
 
 # pvcreate rejects restorefile with uuid not found in file
-pvcreate --uuid $uuid1 $dev1
+pvcreate --norestorefile --uuid $uuid1 $dev1
 vgcfgbackup -f $backupfile
 not pvcreate --uuid $uuid2 --restorefile $backupfile $dev2
 
diff --git a/tools/args.h b/tools/args.h
index a23c46c..91d7b09 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -27,6 +27,7 @@ arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
+arg(norestorefile_ARG, '\0', "norestorefile", NULL, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
 arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index d9e13f4..1c11320 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -497,6 +497,7 @@ xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
    0,
    "pvcreate " "\n"
+   "\t[--norestorefile]\n"
    "\t[--restorefile file]\n"
    "\t[-d|--debug]" "\n"
    "\t[-f[f]|--force [--force]] " "\n"
@@ -517,8 +518,9 @@ xx(pvcreate,
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    dataalignment_ARG, dataalignmentoffset_ARG, force_ARG, test_ARG,
-   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
-   metadatasize_ARG, metadataignore_ARG, physicalvolumesize_ARG,
+   labelsector_ARG, metadatatype_ARG, metadatacopies_ARG,
+   metadatasize_ARG, metadataignore_ARG, norestorefile_ARG,
+   physicalvolumesize_ARG, pvmetadatacopies_ARG,
    restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
 
 xx(pvdata,
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index df7664b..23ff02f 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -36,6 +36,16 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!arg_count(cmd, restorefile_ARG) && arg_count(cmd, uuidstr_ARG)) {
+		if (!arg_count(cmd, norestorefile_ARG) &&
+		    find_config_tree_bool(cmd,
+					  "devices/require_restorefile_with_uuid",
+					  DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID)) {
+			log_error("--restorefile is required with --uuid");
+			return 0;
+		}
+	}
+
 	if (arg_count(cmd, uuidstr_ARG) && argc != 1) {
 		log_error("Can only set uuid on one volume at once");
 		return 0;


