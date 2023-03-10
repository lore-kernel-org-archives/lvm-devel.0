From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:36 +0000 (GMT)
Subject: main - lvmdbustest: Add env. variable to skip signal testing
Message-ID: <20230310185236.A995F385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c550d7124d4bc1954f7d1d7efc372e1d996b570
Commit:        1c550d7124d4bc1954f7d1d7efc372e1d996b570
Parent:        f8876290bfc8d11400901e9eac32f6d613b0ed70
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Mar 10 10:43:02 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbustest: Add env. variable to skip signal testing

This is currently need if we are collecting code coverage data as we don't
handle this unit test correctly.
---
 test/dbus/lvmdbustest.py | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index b7224df96..e1c994e90 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2347,6 +2347,9 @@ class TestDbusService(unittest.TestCase):
 
 	def test_z_sigint(self):
 		# Issue SIGINT while daemon is processing work to ensure we shut down.
+		if not bool(int(os.getenv("LVM_DBUSD_TEST_SKIP_SIGNAL", "0"))):
+			raise unittest.SkipTest("Skipping as env. LVM_DBUSD_TEST_SKIP_SIGNAL is '0'")
+
 		di = DaemonInfo.get()
 		self.assertTrue(di is not None)
 		if di:

