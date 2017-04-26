From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 26 Apr 2017 09:36:37 -0400
Subject: master - lvmdbustest.py: Add nested testing
Message-ID: <201704261336.v3QDabC7009050@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e50fb06792518ff9a5a299172b77e9d22105d372
Commit:        e50fb06792518ff9a5a299172b77e9d22105d372
Parent:        6de3a9b4d060d65f4ecf9a20adc0665b301ec14e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Sat Apr 22 00:06:59 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Apr 26 07:30:45 2017 -0500

lvmdbustest.py: Add nested testing

Make sure when a LV is used as a PV the dbus service works correctly.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/dbus/lvmdbustest.py |   37 +++++++++++++++++++++++++++++++++++--
 1 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index d88a774..50f6ad4 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -75,7 +75,7 @@ def is_nested_pv(pv_name):
 def _root_pv_name(res, pv_name):
 	if not is_nested_pv(pv_name):
 		return pv_name
-	vg_name = pv_name.split('/')[2:3][0]
+	vg_name = pv_name.split('/')[2]
 	for v in res[VG_INT]:
 		if v.Vg.Name == vg_name:
 			pv = ClientProxy(bus, v.Vg.Pvs[0], interfaces=(PV_INT, ))
@@ -120,7 +120,7 @@ def get_objects():
 
 	for object_path, v in objects.items():
 		proxy = ClientProxy(bus, object_path, v)
-		for interface, prop in v.items():
+		for interface in v.keys():
 			rc[interface].append(proxy)
 
 	# At this point we have a full population of everything, we now need to
@@ -1832,6 +1832,39 @@ class TestDbusService(unittest.TestCase):
 		cmd = ['pvcreate', target.Pv.Name]
 		self._verify_existence(cmd, cmd[0], target.Pv.Name)
 
+	def _create_nested(self, pv_object_path):
+		vg = self._vg_create([pv_object_path])
+		pv = ClientProxy(self.bus, pv_object_path, interfaces=(PV_INT,))
+
+		self.assertEqual(pv.Pv.Vg, vg.object_path)
+		self.assertIn(pv_object_path, vg.Vg.Pvs,
+						"Expecting PV object path in Vg.Pvs")
+
+		lv = self._create_lv(vg=vg.Vg, size=vg.Vg.FreeBytes)
+		device_path = '/dev/%s/%s' % (vg.Vg.Name, lv.LvCommon.Name)
+		new_pv_object_path = self._pv_create(device_path)
+
+		vg.update()
+
+		self.assertEqual(lv.LvCommon.Vg, vg.object_path)
+		self.assertIn(lv.object_path, vg.Vg.Lvs,
+						"Expecting LV object path in Vg.Lvs")
+
+		new_pv_proxy = ClientProxy(self.bus,
+									new_pv_object_path,
+									interfaces=(PV_INT, ))
+		self.assertEqual(new_pv_proxy.Pv.Name, device_path)
+
+		return new_pv_object_path
+
+	def test_nesting(self):
+		# check to see if we handle an LV becoming a PV which has it's own
+		# LV
+		pv_object_path = self.objs[PV_INT][0].object_path
+
+		for i in range(0, 5):
+			pv_object_path = self._create_nested(pv_object_path)
+
 
 class AggregateResults(object):
 


