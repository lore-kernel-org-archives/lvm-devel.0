From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:36 +0000 (GMT)
Subject: main - lvmdbustest: Move signals to last
Message-ID: <20220919155836.844023858293@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ead80d134dd6afb288453bd20c5ab25daa450b06
Commit:        ead80d134dd6afb288453bd20c5ab25daa450b06
Parent:        9fc24b1d3b205af1b2e3c4799c575e72a8640842
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 8 15:28:52 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Move signals to last

When we do the signal testing we default back to fork & exec.  Put these
on the end to maximize our lvm shell testing until we fix this proper.
---
 test/dbus/lvmdbustest.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 0d06177c0..18cac35d6 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2314,7 +2314,7 @@ class TestDbusService(unittest.TestCase):
 				self.assertTrue('Job is not complete!' in str(e))
 				raise e
 
-	def test_sigint(self):
+	def test_z_sigint(self):
 		# Issue SIGINT while daemon is processing work to ensure we shut down.
 		di = DaemonInfo.get()
 		self.assertTrue(di is not None)
@@ -2349,7 +2349,7 @@ class TestDbusService(unittest.TestCase):
 								"Failed to exit after sending signal %f seconds after "
 								"queuing up work for signal %d" % (sleep_amt, signal.SIGINT))
 
-	def test_singleton_daemon(self):
+	def test_z_singleton_daemon(self):
 		# Ensure we can only have 1 daemon running at a time, daemon should exit with 114 if already running
 		di = DaemonInfo.get()
 		self.assertTrue(di is not None)

