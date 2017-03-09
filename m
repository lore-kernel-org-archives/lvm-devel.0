From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:42:25 -0500
Subject: master - lvmdbustest.py: Correct debug & assert order
Message-ID: <201703092242.v29MgPJu018272@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=97b6486b2703d8b4d7584caf24f16686dbb9dde2
Commit:        97b6486b2703d8b4d7584caf24f16686dbb9dde2
Parent:        ee7946ed82e11b5d22b02b67821661ff3e3a0993
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 16:07:14 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbustest.py: Correct debug & assert order

If we do the assert first we won't get to the print statement.
---
 test/dbus/lvmdbustest.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 6c928e2..f8a1918 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1734,10 +1734,10 @@ class TestDbusService(unittest.TestCase):
 			path = self._lookup(resource_name)
 			self.assertTrue(path != '/')
 		else:
-			self.assertTrue(ec == 0, "%s exit code = %d" % (operation, ec))
 			std_err_print(
 				"%s failed with stdout= %s, stderr= %s" %
 				(operation, stdout, stderr))
+			self.assertTrue(ec == 0, "%s exit code = %d" % (operation, ec))
 
 	def test_external_vg_create(self):
 		# We need to ensure that if a user creates something outside of lvm


