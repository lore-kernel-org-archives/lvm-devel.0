From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:00 -0400
Subject: master - lvmdbustest.py: Remove duplicate setup code
Message-ID: <201910301544.x9UFi0rY016626@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=62136c056a506568ede876ce41e826478399085b
Commit:        62136c056a506568ede876ce41e826478399085b
Parent:        12c47e0c98a24de619af63a8756a458cf6c069b3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 14:55:51 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Remove duplicate setup code

Remove the same copy & pasted code which simply creates a VG to
use.
---
 test/dbus/lvmdbustest.py |   40 +++-------------------------------------
 1 files changed, 3 insertions(+), 37 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 31dc4ff..da1fc69 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1697,19 +1697,7 @@ class TestDbusService(unittest.TestCase):
 		return ''.join(bad_tag_ch_set)
 
 	def test_invalid_tags(self):
-		mgr = self.objs[MANAGER_INT][0].Manager
-		pv_paths = [self.objs[PV_INT][0].object_path]
-		vg_name = vg_n()
-
-		vg_path = self.handle_return(
-			mgr.VgCreate(
-				dbus.String(vg_name),
-				dbus.Array(pv_paths, 'o'),
-				dbus.Int32(g_tmo),
-				EOD))
-		self._validate_lookup(vg_name, vg_path)
-
-		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
+		vg_proxy = self._vg_create()
 
 		for c in self._invalid_tag_characters():
 			with self.assertRaises(dbus.exceptions.DBusException):
@@ -1728,18 +1716,7 @@ class TestDbusService(unittest.TestCase):
 						EOD))
 
 	def test_tag_names(self):
-		mgr = self.objs[MANAGER_INT][0].Manager
-		pv_paths = [self.objs[PV_INT][0].object_path]
-		vg_name = vg_n()
-
-		vg_path = self.handle_return(
-			mgr.VgCreate(
-				dbus.String(vg_name),
-				dbus.Array(pv_paths, 'o'),
-				dbus.Int32(g_tmo),
-				EOD))
-		self._validate_lookup(vg_name, vg_path)
-		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
+		vg_proxy = self._vg_create()
 
 		for i in range(1, 64):
 			tag = rs(i, "", self._ALLOWABLE_TAG_CH)
@@ -1761,18 +1738,7 @@ class TestDbusService(unittest.TestCase):
 				"%d != %d" % (i, len(vg_proxy.Vg.Tags)))
 
 	def test_tag_regression(self):
-		mgr = self.objs[MANAGER_INT][0].Manager
-		pv_paths = [self.objs[PV_INT][0].object_path]
-		vg_name = vg_n()
-
-		vg_path = self.handle_return(
-			mgr.VgCreate(
-				dbus.String(vg_name),
-				dbus.Array(pv_paths, 'o'),
-				dbus.Int32(g_tmo),
-				EOD))
-		self._validate_lookup(vg_name, vg_path)
-		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
+		vg_proxy = self._vg_create()
 
 		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'
 


