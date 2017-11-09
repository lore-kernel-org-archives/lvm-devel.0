From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 9 Nov 2017 05:58:43 -0500
Subject: master - test: D-Bus test_nesting requires filter
Message-ID: <201711091058.vA9AwheR013760@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=512b2adc7773d302895d01dbc1bccfb66dd94d6a
Commit:        512b2adc7773d302895d01dbc1bccfb66dd94d6a
Parent:        cd3b5e60a82f745030e2a976832a1490494851dc
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 9 10:56:15 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Nov 9 11:57:59 2017 +0100

test: D-Bus test_nesting requires filter

---
 test/api/dbustest.sh     |    3 +++
 test/dbus/lvmdbustest.py |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 5817e01..9da4fe0 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -18,6 +18,9 @@ SKIP_WITH_CLVMD=1
 
 aux prepare_pvs 6
 
+# Required by test_nesting:
+aux extend_filter_LVMTEST
+
 # We need the lvmdbusd.profile for the daemon to utilize JSON
 # output
 mkdir -p "$TESTDIR/etc/profile"
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 3dca9d5..0914b7a 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1868,6 +1868,9 @@ class TestDbusService(unittest.TestCase):
 	def test_nesting(self):
 		# check to see if we handle an LV becoming a PV which has it's own
 		# LV
+		#
+		# NOTE: This needs an equivalent of aux extend_filter_LVMTEST
+		# when run from lvm2 testsuite. See dbustest.sh.
 		pv_object_path = self.objs[PV_INT][0].object_path
 
 		for i in range(0, 5):


