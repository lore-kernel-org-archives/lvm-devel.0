From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:10 +0000 (GMT)
Subject: main - lvmdbustest: Add optional option to _create_num_lvs
Message-ID: <20220919155810.5A5EA3858422@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52415b5708aa26fe322b13a9ffdb8cc16904ab45
Commit:        52415b5708aa26fe322b13a9ffdb8cc16904ab45
Parent:        d05d2328e0868c60ba95d3bd87b654146c078316
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 23 10:29:26 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Add optional option to _create_num_lvs

This allows us to create the LVs async., thus queuing them up in daemon.
---
 test/dbus/lvmdbustest.py | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index bee6eb085..2f1aa98a6 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1288,24 +1288,28 @@ class TestDbusService(unittest.TestCase):
 		vg_path = self._wait_for_job(vg_job)
 		self._validate_lookup(vg_name, vg_path)
 
-	def _create_num_lvs(self, num_lvs):
+	def _create_num_lvs(self, num_lvs, no_wait=False):
 		vg_proxy = self._vg_create(self._all_pv_object_paths())
+		if no_wait:
+			tmo = 0
+		else:
+			tmo = g_tmo
 
 		for i in range(0, num_lvs):
 			lv_name = lv_n()
 			vg_proxy.update()
 			if vg_proxy.Vg.FreeCount > 0:
-				lv_path = self.handle_return(
-					vg_proxy.Vg.LvCreateLinear(
+				create_result = vg_proxy.Vg.LvCreateLinear(
 						dbus.String(lv_name),
 						dbus.UInt64(mib(4)),
 						dbus.Boolean(False),
-						dbus.Int32(g_tmo),
-						EOD))
-				self.assertTrue(lv_path != '/')
-				self._validate_lookup(
-					"%s/%s" % (vg_proxy.Vg.Name, lv_name), lv_path)
+						dbus.Int32(tmo),
+						EOD)
 
+				if not no_wait:
+					lv_path = self.handle_return(create_result)
+					self.assertTrue(lv_path != '/')
+					self._validate_lookup("%s/%s" % (vg_proxy.Vg.Name, lv_name), lv_path)
 			else:
 				# We ran out of space, test(s) may fail
 				break

