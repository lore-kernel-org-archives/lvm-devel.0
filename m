From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 10 Oct 2016 21:35:16 +0000 (UTC)
Subject: master - lvmdbustest.py: Ensure we exit non-zero on fail
Message-ID: <20161010213516.933D260640@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb4e26dcb3aa49128d76eb61495c2ee165974ad9
Commit:        cb4e26dcb3aa49128d76eb61495c2ee165974ad9
Parent:        9f0195ec1ec1113695abdb1ada82dc138bc7488b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 7 14:55:36 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Oct 10 16:31:00 2016 -0500

lvmdbustest.py: Ensure we exit non-zero on fail

If you run multiple runs of unittest.main, unless you don't pass exit=true
the test case always ends with a 0 exit code.  Add ability to store the
result of each invocation of the test and exit with a non-zero exit code
if anyone of them fail.
---
 test/dbus/lvmdbustest.py |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 819d096..e9b27a0 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1294,8 +1294,25 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(tag in vg_proxy.Vg.Tags, "%s not in %s" %
 						(tag, str(vg_proxy.Vg.Tags)))
 
+class AggregateResults(object):
+
+	def __init__(self):
+		self.no_errors = True
+
+	def register_result(self, result):
+		if not result.result.wasSuccessful():
+			self.no_errors = False
+
+	def exit_run(self):
+		if self.no_errors:
+			sys.exit(0)
+		sys.exit(1)
+
 
 if __name__ == '__main__':
+
+	r = AggregateResults()
+
 	# Test forking & exec new each time
 	test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 1)
 
@@ -1304,19 +1321,21 @@ if __name__ == '__main__':
 
 	if int(test_shell) == 0:
 		print('\n Shortened fork & exec test ***\n')
-		unittest.main(exit=True)
+		r.register_result(unittest.main(exit=False))
 	else:
 		print('\n *** Testing fork & exec *** \n')
-		unittest.main(exit=False)
+		r.register_result(unittest.main(exit=False))
 		g_tmo = 15
-		unittest.main(exit=False)
+		r.register_result(unittest.main(exit=False))
 		# Test lvm shell
 		print('\n *** Testing lvm shell *** \n')
 		if set_execution(True):
 			g_tmo = 0
-			unittest.main(exit=False)
+			r.register_result(unittest.main(exit=False))
 			g_tmo = 15
-			unittest.main()
+			r.register_result(unittest.main(exit=False))
 		else:
 			print("WARNING: Unable to dynamically configure "
 				"service to use lvm shell!")
+
+	r.exit_run()


