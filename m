From: tasleson <tasleson@fedoraproject.org>
Date: Fri,  4 Mar 2016 16:24:52 +0000 (UTC)
Subject: master - dbustest.sh: Get dbus test to work on buildbot
Message-ID: <20160304162452.BDEDE60D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f94fe2c91fc995e2d57f7689f01d8d15d72858cc
Commit:        f94fe2c91fc995e2d57f7689f01d8d15d72858cc
Parent:        9720898c8ee3a4035858508b38179a143d948f4f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 23 09:13:01 2016 +0100
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 4 10:11:03 2016 -0600

dbustest.sh: Get dbus test to work on buildbot

- stdout/stderr for test output
- debug.log* for daemon output
- use install instead of cp for DBus config
- use system bus
- DBus reloads on new file. Better having it created with correct
  permissions.

Notes:
- Squashed commits from mcsontos development branch
- Still disabled at this time

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/dbustest.sh |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index b4e3964..ba3173e 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -21,18 +21,17 @@ skip
 
 aux prepare_pvs 6
 
-# This allows us to run without installing
-# com.redhat.lvmdbus1.conf to /etc/dbus-1/system.d/
-# but in normal operation it needs to be on system bus
-export LVMDBUSD_USE_SESSION="True"
+# Copy the needed file to run on the system bus if it doesn't
+# already exist
+if [ ! -f /etc/dbus-1/system.d/com.redhat.lvmdbus1.conf ]; then
+	install -m 644 $abs_top_builddir/scripts/com.redhat.lvmdbus1.conf /etc/dbus-1/system.d/.
+fi
 
 # Setup the python path so we can run
 export PYTHONPATH=$abs_top_builddir/daemons
 
-# Where should we be logging the output of the daemon when not running as
-# a systemd service
 # Start the dbus service
-$abs_top_builddir/daemons/lvmdbusd/lvmdbusd --debug --udev > /tmp/lvmdbusd.log 2>&1 &
+$abs_top_builddir/daemons/lvmdbusd/lvmdbusd --debug --udev > debug.log_lvmdbusd 2>&1 &
 
 # Give the service some time to start before we try to run the
 # unit test
@@ -45,17 +44,16 @@ if [ "CHK${LVM_DBUS_PID}" == "CHK" ];then
 fi
 
 # Run all the unit tests
-# Are we already logging stdout & stderror?
-$abs_top_builddir/test/dbus/lvmdbustest.py -v > /tmp/lvmdbustest.log 2>&1
+$abs_top_builddir/test/dbus/lvmdbustest.py -v || fail=$?
 
 # We can run individual unit tests by doing this
 # $abs_top_builddir/test/dbus/lvmdbustest.py -v TestDbusService.test_snapshot_merge
 
-# I'm guessing there is a better way to handle this with the built in test env.
-if [ $? -eq 0 ]; then
-	rm -f /tmp/lvmdbusd.log
-	rm -f /tmp/lvmdbustest.log
-fi
-
 echo "Stopping service"
-kill $LVM_DBUS_PID
+kill $LVM_DBUS_PID || {
+	sleep 1
+        kill -9 $LVM_DBUS_PID
+}
+wait
+
+exit ${fail:-"0"}


