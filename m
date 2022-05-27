From: David Teigland <teigland@sourceware.org>
Date: Fri, 27 May 2022 19:30:24 +0000 (GMT)
Subject: main - devices file: fail if --devicesfile filename doesn't exist
Message-ID: <20220527193024.785933827990@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bfe072e4388b530cbf5369be8a8f1305220198bf
Commit:        bfe072e4388b530cbf5369be8a8f1305220198bf
Parent:        9dfa6f38793f6b5f7de2a4148ab2f7790e3c39da
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 27 14:27:03 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 27 14:27:03 2022 -0500

devices file: fail if --devicesfile filename doesn't exist

A typo of the filename after --devicesfile should result in a
command error rather than the command falling back to using no
devices file at all.  Exception is vgcreate|pvcreate which
create a new devices file if the file name doesn't exist.
---
 lib/device/dev-cache.c          | 9 +++++++++
 test/shell/devicesfile-basic.sh | 4 ++++
 2 files changed, 13 insertions(+)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 3aaf6a2e5..ed9c726c9 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1863,6 +1863,15 @@ int setup_devices(struct cmd_context *cmd)
 
 	file_exists = devices_file_exists(cmd);
 
+	/*
+	 * Fail if user specifies a file name that doesn't exist and
+	 * the command is not creating a new devices file.
+	 */
+	if (!file_exists && !cmd->create_edit_devices_file && cmd->devicesfile && strlen(cmd->devicesfile)) {
+		log_error("Devices file not found: %s", cmd->devices_file_path);
+		return 0;
+	}
+
 	/*
 	 * Removing the devices file is another way of disabling the use of
 	 * a devices file, unless the command creates the devices file.
diff --git a/test/shell/devicesfile-basic.sh b/test/shell/devicesfile-basic.sh
index 9c3455c76..77fe265a0 100644
--- a/test/shell/devicesfile-basic.sh
+++ b/test/shell/devicesfile-basic.sh
@@ -104,6 +104,10 @@ not ls "$DFDIR/system.devices"
 vgs --devicesfile test.devices $vg1
 not vgs --devicesfile test.devices $vg2
 
+# misspelled override name fails
+not vgs --devicesfile doesnotexist $vg1
+not vgs --devicesfile doesnotexist $vg2
+
 # devicesfile and devices cannot be used together
 not vgs --devicesfile test.devices --devices "$dev1","$dev1" $vg1
 

