From: Tony Asleson <tasleson@sourceware.org>
Date: Tue, 14 Mar 2023 14:36:52 +0000 (GMT)
Subject: main - lvmdbustest: Correct env. logic
Message-ID: <20230314143652.13B753858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c73d3545b2c964cea7e74cc022d2bc599ce7739
Commit:        0c73d3545b2c964cea7e74cc022d2bc599ce7739
Parent:        baf99ff974b408c59dd4f51db6e006d659c061e7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Mar 14 08:05:57 2023 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Mar 14 09:36:38 2023 -0500

lvmdbustest: Correct env. logic

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/dbus/lvmdbustest.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 00d9303b6..8f95757eb 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2347,8 +2347,8 @@ class TestDbusService(unittest.TestCase):
 
 	def test_z_sigint(self):
 		# Issue SIGINT while daemon is processing work to ensure we shut down.
-		if not bool(int(os.getenv("LVM_DBUSD_TEST_SKIP_SIGNAL", "0"))):
-			raise unittest.SkipTest("Skipping as env. LVM_DBUSD_TEST_SKIP_SIGNAL is '0'")
+		if bool(int(os.getenv("LVM_DBUSD_TEST_SKIP_SIGNAL", "0"))):
+			raise unittest.SkipTest("Skipping as env. LVM_DBUSD_TEST_SKIP_SIGNAL is '1'")
 
 		di = DaemonInfo.get()
 		self.assertTrue(di is not None)

