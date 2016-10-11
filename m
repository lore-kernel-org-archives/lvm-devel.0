From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Oct 2016 11:39:36 +0000 (UTC)
Subject: master - tests: notify dbus only for dbus test
Message-ID: <20161011113936.8A2F260F0F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe437a6e7d9367eecd977d2504db82469016c780
Commit:        fe437a6e7d9367eecd977d2504db82469016c780
Parent:        8f300691603c57388a4fa092f18f121d7504e3c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 5 11:48:03 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 11 13:37:44 2016 +0200

tests: notify dbus only for dbus test

---
 test/lib/aux.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3d84e86..e523123 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -325,8 +325,8 @@ prepare_lvmdbusd() {
 		daemon="$(which lvmdbusd || :)"
 	fi
 	[[ -n $daemon && -x $daemon ]] || skip "The daemon is missing"
-
 	which python3 >/dev/null || skip "Missing python3"
+
 	python3 -c "import pyudev, dbus, gi.repository" || skip "Missing python modules"
 
 	# Copy the needed file to run on the system bus if it doesn't
@@ -336,6 +336,8 @@ prepare_lvmdbusd() {
 	fi
 
 	echo "preparing lvmdbusd..."
+	lvmconf "global/notify_dbus = 1"
+
 	"$daemon" --debug  > debug.log_LVMDBUSD_out 2>&1 &
 	local pid=$!
 
@@ -1079,6 +1081,7 @@ devices/global_filter = [ "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/md_component_detection  = 0
 devices/scan = "$DM_DEV_DIR"
 devices/sysfs_scan = 1
+devices/write_cache_state = 0
 global/abort_on_internal_errors = 1
 global/cache_check_executable = "$LVM_TEST_CACHE_CHECK_CMD"
 global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
@@ -1088,6 +1091,7 @@ global/fallback_to_local_locking = 0
 global/library_dir = "$TESTDIR/lib"
 global/locking_dir = "$TESTDIR/var/lock/lvm"
 global/locking_type=$LVM_TEST_LOCKING
+global/notify_dbus = 0
 global/si_unit_consistency = 1
 global/thin_check_executable = "$LVM_TEST_THIN_CHECK_CMD"
 global/thin_dump_executable = "$LVM_TEST_THIN_DUMP_CMD"


