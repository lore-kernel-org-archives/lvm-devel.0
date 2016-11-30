From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:44 +0000 (UTC)
Subject: master - lvmdbustest.py: Re-enable test_vg_uuid_gen
Message-ID: <20161130215944.6173960D12@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bb845cab76b6e8003673f0f4c472fff24a6ef7f4
Commit:        bb845cab76b6e8003673f0f4c472fff24a6ef7f4
Parent:        53ef4967192ce8bfe5eaebf8104a1f7cbf8ab020
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 14:16:59 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbustest.py: Re-enable test_vg_uuid_gen

This looks to be working now, not sure when it was resolved.
---
 test/dbus/lvmdbustest.py |   28 +++++++++++-----------------
 1 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 8b5c4fd..217a641 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1132,23 +1132,17 @@ class TestDbusService(unittest.TestCase):
 				"Expected %s != Actual %s" % (str(p), str(vg.MaxLv)))
 
 	def test_vg_uuid_gen(self):
-		# TODO renable test case when
-		# https://bugzilla.redhat.com/show_bug.cgi?id=1264169 gets fixed
-		# This was tested with lvmetad disabled and we passed
-		std_err_print("\nSkipping Vg.UuidGenerate until BZ: 1264169 resolved\n")
-
-		if False:
-			vg = self._vg_create().Vg
-			prev_uuid = vg.Uuid
-			rc = self.handle_return(
-				vg.UuidGenerate(
-					dbus.Int32(g_tmo),
-					EOD))
-			self.assertEqual(rc, '/')
-			vg.update()
-			self.assertTrue(
-				vg.Uuid != prev_uuid,
-				"Expected %s != Actual %s" % (vg.Uuid, prev_uuid))
+		vg = self._vg_create().Vg
+		prev_uuid = vg.Uuid
+		rc = self.handle_return(
+			vg.UuidGenerate(
+				dbus.Int32(g_tmo),
+				EOD))
+		self.assertEqual(rc, '/')
+		vg.update()
+		self.assertTrue(
+			vg.Uuid != prev_uuid,
+			"Expected %s != Actual %s" % (vg.Uuid, prev_uuid))
 
 	def test_vg_activate_deactivate(self):
 		vg = self._vg_create().Vg


