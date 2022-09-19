From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:09 +0000 (GMT)
Subject: main - lvmdbustest: Factor out tearDown implementation for re-use
Message-ID: <20220919155809.3A14B3858421@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d05d2328e0868c60ba95d3bd87b654146c078316
Commit:        d05d2328e0868c60ba95d3bd87b654146c078316
Parent:        de0258a60054166fd3a2b1732d74e7bae85e92f5
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 23 10:28:27 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Factor out tearDown implementation for re-use

---
 test/dbus/lvmdbustest.py | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 5c352313d..bee6eb085 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -419,9 +419,7 @@ class TestDbusService(unittest.TestCase):
 			rc = self._pv_remove(pv_proxy)
 			self.assertTrue(rc == '/')
 
-	def tearDown(self):
-		# If we get here it means we passed setUp, so lets remove anything
-		# and everything that remains, besides the PVs themselves
+	def clean_up(self):
 		self.objs, self.bus = get_objects()
 
 		# The self.objs[PV_INT] list only contains those which we should be
@@ -447,7 +445,7 @@ class TestDbusService(unittest.TestCase):
 			# the properties are current and correct.
 			p.update()
 			if p.Pv.Vg != '/':
-				v = ClientProxy(self.bus, p.Pv.Vg, interfaces=(VG_INT, ))
+				v = ClientProxy(self.bus, p.Pv.Vg, interfaces=(VG_INT,))
 				self._recurse_vg_delete(v, p, nested_pvs)
 
 		# Check to make sure the PVs we had to start exist, else re-create
@@ -465,6 +463,11 @@ class TestDbusService(unittest.TestCase):
 					# print('Re-creating PV=', p)
 					self._pv_create(p)
 
+	def tearDown(self):
+		# If we get here it means we passed setUp, so lets remove anything
+		# and everything that remains, besides the PVs themselves
+		self.clean_up()
+
 	def _check_consistency(self):
 		# Only do consistency checks if we aren't running the unit tests
 		# concurrently

