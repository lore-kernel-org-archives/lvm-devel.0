From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:16 +0000 (GMT)
Subject: main - lvmdbustest: Skip test_singleton_daemon running systemd svc.
Message-ID: <20220919155816.0FC573858430@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f65f7da76065b2e36920ae4f866e9e912f74dde2
Commit:        f65f7da76065b2e36920ae4f866e9e912f74dde2
Parent:        a5e6947d74f7b88f7f0df4328a923ad82a970634
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 24 15:41:03 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Skip test_singleton_daemon running systemd svc.

---
 test/dbus/lvmdbustest.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index ba93379dc..772313246 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2342,6 +2342,8 @@ class TestDbusService(unittest.TestCase):
 		# Ensure we can only have 1 daemon running at a time, daemon should exit with 114 if already running
 		di = DaemonInfo.get()
 		self.assertTrue(di is not None)
+		if di.systemd:
+			raise unittest.SkipTest('existing dameon running via systemd')
 		if di:
 			ec = di.start(True)
 			self.assertEqual(ec, 114)

