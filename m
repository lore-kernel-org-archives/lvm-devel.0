From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:25 -0400
Subject: master - lvmdbustest.py: Remove 2 TODOs
Message-ID: <201910301544.x9UFiPsJ016734@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ceb808d26f56ebd75baa379780ad55163197a20f
Commit:        ceb808d26f56ebd75baa379780ad55163197a20f
Parent:        c5f4f2efb64944ea8a1eae0eee46069d8328324f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 17:01:27 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Remove 2 TODOs

This issue has been resolved, sizes > 2**32-1 not supported.
---
 test/dbus/lvmdbustest.py |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 92e4331..d703a0a 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1181,9 +1181,6 @@ class TestDbusService(unittest.TestCase):
 
 	def test_vg_max_pv(self):
 		vg = self._vg_create().Vg
-
-		# BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
-		# TODO: Add a test back for larger values here when bug is resolved
 		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
 			rc = self.handle_return(
 				vg.MaxPvSet(
@@ -1196,9 +1193,6 @@ class TestDbusService(unittest.TestCase):
 
 	def test_vg_max_lv(self):
 		vg = self._vg_create().Vg
-
-		# BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
-		# TODO: Add a test back for larger values here when bug is resolved
 		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
 			rc = self.handle_return(
 				vg.MaxLvSet(


