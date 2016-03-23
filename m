From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed, 23 Mar 2016 11:30:53 +0000 (UTC)
Subject: master - test: Move bus configuration to prepare function
Message-ID: <20160323113053.4697460D17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82d92009ae37bea3cd6a3f754c25d56b12959676
Commit:        82d92009ae37bea3cd6a3f754c25d56b12959676
Parent:        1b0775916b78e1270872d3649a2c9abf0a1bb790
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 22 09:15:40 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 23 12:27:34 2016 +0100

test: Move bus configuration to prepare function

---
 test/api/dbustest.sh |    9 ---------
 test/lib/aux.sh      |    8 ++++++++
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 79e3224..8741eb9 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -16,16 +16,7 @@ SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
-# Will default to skip until we can get this reviewed
-#skip
-
 aux prepare_pvs 6
 
-# Copy the needed file to run on the system bus if it doesn't
-# already exist
-if [ ! -f /etc/dbus-1/system.d/com.redhat.lvmdbus1.conf ]; then
-	install -m 644 $abs_top_builddir/scripts/com.redhat.lvmdbus1.conf /etc/dbus-1/system.d/.
-fi
-
 aux prepare_lvmdbusd
 $test_data_dir/dbus/lvmdbustest.py -v
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2767880..9fd1922 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -306,6 +306,7 @@ prepare_lvmdbusd() {
 
 	kill_sleep_kill_ LOCAL_LVMDBUSD 0
 
+        # FIXME: This is not correct! Daemon is auto started.
 	echo "checking lvmdbusd is NOT running..."
 	if ps -elf | grep lvmdbusd | grep python3; then
 		echo "Cannot run while existing lvmdbusd process exists"
@@ -327,6 +328,13 @@ prepare_lvmdbusd() {
 	which python3 >/dev/null || skip "Missing python3"
 	python3 -c "import pyudev, dbus, gi.repository" || skip "Missing python modules"
 
+        # TODO: Tests should use session bus instead of system bus
+	# Copy the needed file to run on the system bus if it doesn't
+	# already exist
+	if [ ! -f /etc/dbus-1/system.d/com.redhat.lvmdbus1.conf ]; then
+		install -m 644 $abs_top_builddir/scripts/com.redhat.lvmdbus1.conf /etc/dbus-1/system.d/
+	fi
+
 	echo "preparing lvmdbusd..."
 	"$daemon" --debug --udev > debug.log_LVMDBUSD_out 2>&1 &
 	local pid=$!


