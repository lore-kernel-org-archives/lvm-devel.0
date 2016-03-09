From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed,  9 Mar 2016 10:10:39 +0000 (UTC)
Subject: master - test: Add prepare_lvmdbusd
Message-ID: <20160309101039.6A21B607B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e655ccb418d942889aae5c83af25ca8d085825b8
Commit:        e655ccb418d942889aae5c83af25ca8d085825b8
Parent:        d7ca164597ec5f334c061ffbad78677c4b36f281
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 1 11:49:05 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 9 10:58:21 2016 +0100

test: Add prepare_lvmdbusd

- Check for running lvmdbusd at start
- Add teardown for lvmdbusd
---
 test/api/dbustest.sh |   12 +++++++++++-
 test/lib/aux.sh      |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index ba3173e..0ef9a95 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -30,6 +30,13 @@ fi
 # Setup the python path so we can run
 export PYTHONPATH=$abs_top_builddir/daemons
 
+if true; then
+
+aux prepare_lvmdbusd
+$abs_top_builddir/test/dbus/lvmdbustest.py -v
+
+else
+
 # Start the dbus service
 $abs_top_builddir/daemons/lvmdbusd/lvmdbusd --debug --udev > debug.log_lvmdbusd 2>&1 &
 
@@ -39,9 +46,10 @@ sleep 1
 
 LVM_DBUS_PID=$(ps aux | grep lvmdbus[d] |  awk '{print $2}')
 if [ "CHK${LVM_DBUS_PID}" == "CHK" ];then
-	echo "Failed to start lsmdbusd daemon"
+	echo "Failed to start lvmdbusd daemon"
 	exit 1
 fi
+END
 
 # Run all the unit tests
 $abs_top_builddir/test/dbus/lvmdbustest.py -v || fail=$?
@@ -57,3 +65,5 @@ kill $LVM_DBUS_PID || {
 wait
 
 exit ${fail:-"0"}
+
+fi
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 021eb81..af6b25a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -300,6 +300,42 @@ lvmpolld_dump() {
 	(echo 'request="dump"'; echo '##') | lvmpolld_talk "$@"
 }
 
+prepare_lvmdbusd() {
+	rm -f debug.log_LVMDBUSD_out
+
+	echo "checking lvmdbusd is NOT running..."
+	if ps -elf | grep lvmdbusd | grep python3; then
+		echo "Cannot run while existing lvmdbusd process exists"
+		return 1
+	fi
+	echo ok
+
+	# skip if we don't have our own lvmdbusd...
+        # TODO: lvmdbusd is not in PATH
+	#(which lvmdbusd 2>/dev/null | grep "$abs_builddir") || skip
+	[[ -x $abs_top_builddir/daemons/lvmdbusd/lvmdbusd ]] || skip
+
+	kill_sleep_kill_ LOCAL_LVMDBUSD 0
+
+	echo "preparing lvmdbusd..."
+	$abs_top_builddir/daemons/lvmdbusd/lvmdbusd --debug --udev > debug.log_LVMDBUSD_out 2>&1 &
+	local pid=$!
+
+	sleep 1
+	echo "checking lvmdbusd IS running..."
+	if ! ps -elf | grep lvmdbusd | grep python3; then
+		echo "Failed to start lvmdbusd daemon"
+		return 1
+	fi
+	# TODO: Is there a better check than wait 1 second and check pid?
+	if ! ps -p $pid -o comm= >/dev/null || [[ $(ps -p $pid -o comm=) != python3 ]]; then
+		echo "Failed to start lvmdbusd daemon"
+		return 1
+	fi
+	echo $pid > LOCAL_LVMDBUSD
+	echo ok
+}
+
 teardown_devs_prefixed() {
 	local prefix=$1
 	local stray=${2:-0}
@@ -464,6 +500,10 @@ teardown() {
 		fi
 	}
 
+	kill_sleep_kill_ LOCAL_LVMDBUSD 0
+
+	echo -n .
+
 	kill_sleep_kill_ LOCAL_LVMPOLLD ${LVM_VALGRIND_LVMPOLLD:-0}
 
 	echo -n .


