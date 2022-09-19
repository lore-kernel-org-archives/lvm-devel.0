From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:12 +0000 (GMT)
Subject: main - lvmdbustest: Add test for ensuring only 1 instance of daemon
Message-ID: <20220919155812.9D32E3858425@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f252e05aaeb1a34598cc9d93e3c65ce2e311621b
Commit:        f252e05aaeb1a34598cc9d93e3c65ce2e311621b
Parent:        d16c0a3e2bc1d36fc11ed763ac32184f09c6c67c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 23 10:31:31 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Add test for ensuring only 1 instance of daemon

---
 test/dbus/lvmdbustest.py | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 7a03c46a2..72a75edea 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2338,6 +2338,14 @@ class TestDbusService(unittest.TestCase):
 								"Failed to exit after sending signal %f seconds after "
 								"queuing up work for signal %d" % (sleep_amt, signal.SIGINT))
 
+	def test_singleton_daemon(self):
+		# Ensure we can only have 1 daemon running at a time, daemon should exit with 114 if already running
+		di = DaemonInfo.get()
+		self.assertTrue(di is not None)
+		if di:
+			ec = di.start(True)
+			self.assertEqual(ec, 114)
+
 
 class AggregateResults(object):
 

