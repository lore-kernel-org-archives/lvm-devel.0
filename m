From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 10 Oct 2016 21:35:20 +0000 (UTC)
Subject: master - lvmdbustest.py: Denote failure if set_execution fails
Message-ID: <20161010213520.D2A2960C40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e45285b403bdcbf744f21eba6d6aa3a70628e71
Commit:        3e45285b403bdcbf744f21eba6d6aa3a70628e71
Parent:        0c51f369a49f489d082c5439967eb6ca49e9a7fd
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 7 15:30:18 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Oct 10 16:31:00 2016 -0500

lvmdbustest.py: Denote failure if set_execution fails

---
 test/dbus/lvmdbustest.py |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index ef2c07a..37ce1d4 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1298,6 +1298,7 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(tag in vg_proxy.Vg.Tags, "%s not in %s" %
 						(tag, str(vg_proxy.Vg.Tags)))
 
+
 class AggregateResults(object):
 
 	def __init__(self):
@@ -1307,6 +1308,9 @@ class AggregateResults(object):
 		if not result.result.wasSuccessful():
 			self.no_errors = False
 
+	def register_fail(self):
+		self.no_errors = False
+
 	def exit_run(self):
 		if self.no_errors:
 			sys.exit(0)
@@ -1339,6 +1343,7 @@ if __name__ == '__main__':
 			g_tmo = 15
 			r.register_result(unittest.main(exit=False))
 		else:
+			r.register_fail()
 			std_err_print("ERROR: Unable to dynamically configure "
 				"service to use lvm shell!")
 


