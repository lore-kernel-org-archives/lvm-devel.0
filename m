From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed,  9 Mar 2016 13:04:37 +0000 (UTC)
Subject: master - test: Remove work-in-progress code from dbustest
Message-ID: <20160309130437.6FCC2609CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18291fd01639939812779e63de0d64a4224729ad
Commit:        18291fd01639939812779e63de0d64a4224729ad
Parent:        e72184bb761a7f2c48caf5dae64e75d57f64bfe0
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 9 14:03:17 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 9 14:04:28 2016 +0100

test: Remove work-in-progress code from dbustest

(cherry picked from commit 3189d4d50492f5b78cf3920a7f499fd1020983c6)
---
 test/api/dbustest.sh |   35 -----------------------------------
 1 files changed, 0 insertions(+), 35 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 0ef9a95..039689d 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -30,40 +30,5 @@ fi
 # Setup the python path so we can run
 export PYTHONPATH=$abs_top_builddir/daemons
 
-if true; then
-
 aux prepare_lvmdbusd
 $abs_top_builddir/test/dbus/lvmdbustest.py -v
-
-else
-
-# Start the dbus service
-$abs_top_builddir/daemons/lvmdbusd/lvmdbusd --debug --udev > debug.log_lvmdbusd 2>&1 &
-
-# Give the service some time to start before we try to run the
-# unit test
-sleep 1
-
-LVM_DBUS_PID=$(ps aux | grep lvmdbus[d] |  awk '{print $2}')
-if [ "CHK${LVM_DBUS_PID}" == "CHK" ];then
-	echo "Failed to start lvmdbusd daemon"
-	exit 1
-fi
-END
-
-# Run all the unit tests
-$abs_top_builddir/test/dbus/lvmdbustest.py -v || fail=$?
-
-# We can run individual unit tests by doing this
-# $abs_top_builddir/test/dbus/lvmdbustest.py -v TestDbusService.test_snapshot_merge
-
-echo "Stopping service"
-kill $LVM_DBUS_PID || {
-	sleep 1
-        kill -9 $LVM_DBUS_PID
-}
-wait
-
-exit ${fail:-"0"}
-
-fi


