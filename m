From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 26 Apr 2017 09:36:36 -0400
Subject: master - lvmdbustest.py: Handle nested setUp & tearDown
Message-ID: <201704261336.v3QDaaVc009039@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6de3a9b4d060d65f4ecf9a20adc0665b301ec14e
Commit:        6de3a9b4d060d65f4ecf9a20adc0665b301ec14e
Parent:        e78329e281db780cc4a9acce20b0f58dc9221fab
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Sat Apr 22 00:06:16 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Apr 26 07:10:18 2017 -0500

lvmdbustest.py: Handle nested setUp & tearDown

Handle cleaning up correctly if a LV is used as a PV.
---
 test/dbus/lvmdbustest.py |  109 ++++++++++++++++++++++++++++++++++------------
 1 files changed, 81 insertions(+), 28 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index f8a1918..d88a774 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -68,6 +68,42 @@ def lv_n(suffix=None):
 	return g_prefix + rs(8, s)
 
 
+def is_nested_pv(pv_name):
+	return pv_name.count('/') == 3
+
+
+def _root_pv_name(res, pv_name):
+	if not is_nested_pv(pv_name):
+		return pv_name
+	vg_name = pv_name.split('/')[2:3][0]
+	for v in res[VG_INT]:
+		if v.Vg.Name == vg_name:
+			pv = ClientProxy(bus, v.Vg.Pvs[0], interfaces=(PV_INT, ))
+			return _root_pv_name(res, pv.Pv.Name)
+
+
+def _prune(res, pv_filter):
+	if pv_filter:
+		pv_lookup = {}
+
+		pv_list = []
+		for p in res[PV_INT]:
+			if _root_pv_name(res, p.Pv.Name) in pv_filter:
+				pv_list.append(p)
+				pv_lookup[p.object_path] = p
+
+		res[PV_INT] = pv_list
+
+		vg_list = []
+		for v in res[VG_INT]:
+			# Only need to validate one of the PVs is in the selection set
+			if v.Vg.Pvs[0] in pv_lookup:
+				vg_list.append(v)
+
+		res[VG_INT] = vg_list
+	return res
+
+
 def get_objects():
 	rc = {
 		MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
@@ -85,15 +121,11 @@ def get_objects():
 	for object_path, v in objects.items():
 		proxy = ClientProxy(bus, object_path, v)
 		for interface, prop in v.items():
-			if interface == PV_INT:
-				# If we have a list of PVs to use, lets only use those in
-				# the list
-				# noinspection PyUnresolvedReferences
-				if pv_device_list and not (proxy.Pv.Name in pv_device_list):
-					continue
 			rc[interface].append(proxy)
 
-	return rc, bus
+	# At this point we have a full population of everything, we now need to
+	# prune the PV list and the VG list if we are using a sub selection
+	return _prune(rc, pv_device_list), bus
 
 
 def set_execution(lvmshell, test_result):
@@ -151,38 +183,59 @@ class TestDbusService(unittest.TestCase):
 			std_err_print('Expecting a manager object!')
 			sys.exit(1)
 
-		# We will skip the vg device number check if the test user
-		# has specified a PV list
-		if pv_device_list is None:
-			if len(self.objs[VG_INT]) != 0:
-				std_err_print('Expecting no VGs to exist!')
-				sys.exit(1)
+		if len(self.objs[VG_INT]) != 0:
+			std_err_print('Expecting no VGs to exist!')
+			sys.exit(1)
 
 		self.pvs = []
 		for p in self.objs[PV_INT]:
 			self.pvs.append(p.Pv.Name)
 
+	def _recurse_vg_delete(self, vg_proxy, pv_proxy, nested_pv_hash):
+
+		for pv_device_name, t in nested_pv_hash.items():
+			vg_name = str(vg_proxy.Vg.Name)
+			if vg_name in pv_device_name:
+				self._recurse_vg_delete(t[0], t[1], nested_pv_hash)
+				break
+
+		vg_proxy.update()
+
+		self.handle_return(vg_proxy.Vg.Remove(dbus.Int32(g_tmo), EOD))
+		if is_nested_pv(pv_proxy.Pv.Name):
+			rc = self._pv_remove(pv_proxy)
+			self.assertTrue(rc == '/')
+
 	def tearDown(self):
 		# If we get here it means we passed setUp, so lets remove anything
 		# and everything that remains, besides the PVs themselves
 		self.objs, self.bus = get_objects()
 
-		if pv_device_list is None:
-			for v in self.objs[VG_INT]:
-				self.handle_return(
-					v.Vg.Remove(
-						dbus.Int32(g_tmo),
-						EOD))
-		else:
-			for p in self.objs[PV_INT]:
-				# When we remove a VG for a PV it could ripple across multiple
-				# VGs, so update each PV while removing each VG, to ensure
-				# the properties are current and correct.
-				p.update()
+		# The self.objs[PV_INT] list only contains those which we should be
+		# mucking with, lets remove any embedded/nested PVs first, then proceed
+		# to walk the base PVs and remove the VGs
+		nested_pvs = {}
+		non_nested = []
+
+		for p in self.objs[PV_INT]:
+			if is_nested_pv(p.Pv.Name):
 				if p.Pv.Vg != '/':
-					v = ClientProxy(self.bus, p.Pv.Vg, interfaces=(VG_INT, ))
-					self.handle_return(
-						v.Vg.Remove(dbus.Int32(g_tmo), EOD))
+					v = ClientProxy(self.bus, p.Pv.Vg, interfaces=(VG_INT,))
+					nested_pvs[p.Pv.Name] = (v, p)
+				else:
+					# Nested PV with no VG, so just simply remove it!
+					self._pv_remove(p)
+			else:
+				non_nested.append(p)
+
+		for p in non_nested:
+			# When we remove a VG for a PV it could ripple across multiple
+			# PVs, so update each PV while removing each VG, to ensure
+			# the properties are current and correct.
+			p.update()
+			if p.Pv.Vg != '/':
+				v = ClientProxy(self.bus, p.Pv.Vg, interfaces=(VG_INT, ))
+				self._recurse_vg_delete(v, p, nested_pvs)
 
 		# Check to make sure the PVs we had to start exist, else re-create
 		# them


