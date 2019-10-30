From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:17 -0400
Subject: master - lvmdbustest.py: Use existing _create_lv
Message-ID: <201910301544.x9UFiHEg016707@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=69d48479759693b8118e2a32b53cab8a9758e21f
Commit:        69d48479759693b8118e2a32b53cab8a9758e21f
Parent:        293f6d27951829940f35b6728cfbf3e1b4574ab6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 15:56:45 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Use existing _create_lv

---
 test/dbus/lvmdbustest.py |   25 ++-----------------------
 1 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 082c958..497a605 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1147,17 +1147,7 @@ class TestDbusService(unittest.TestCase):
 
 	def test_lv_tags(self):
 		vg = self._vg_create().Vg
-		lv_name = lv_n()
-		lv = self._test_lv_create(
-			vg.LvCreateLinear,
-			(dbus.String(lv_name),
-			dbus.UInt64(mib(4)),
-			dbus.Boolean(False),
-			dbus.Int32(g_tmo),
-			EOD),
-			vg, LV_BASE_INT)
-
-		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
+		lv = self._create_lv(vg=vg)
 
 		t = ['Testing', 'tags']
 
@@ -1234,18 +1224,7 @@ class TestDbusService(unittest.TestCase):
 
 	def test_vg_activate_deactivate(self):
 		vg = self._vg_create().Vg
-		lv_name = lv_n()
-		lv = self._test_lv_create(
-			vg.LvCreateLinear, (
-				dbus.String(lv_name),
-				dbus.UInt64(mib(4)),
-				dbus.Boolean(False),
-				dbus.Int32(g_tmo),
-				EOD),
-			vg, LV_BASE_INT)
-
-		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
-
+		self._create_lv(vg=vg)
 		vg.update()
 
 		rc = self.handle_return(


