From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:34 +0000 (UTC)
Subject: master - lvmdbustest.py: Support concurrent test runs
Message-ID: <20161117173634.30FE260D7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd28717f2418559e91e779628bc5ef34b9ad05c9
Commit:        cd28717f2418559e91e779628bc5ef34b9ad05c9
Parent:        72a943f720ba49517592fd4040f58517a0b65852
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Nov 11 12:34:38 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbustest.py: Support concurrent test runs

The env variable LVM_DBUSD_PV_DEVICE_LIST when present and filled in
with at least 4 physical devices will run concurrently with other
instances running as long as they specify different devices in their
env variable.

When the env variable is not present the test runs as it did before.
---
 test/dbus/lvmdbustest.py |  171 ++++++++++++++++++++++++++++------------------
 1 files changed, 104 insertions(+), 67 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 09f1b77..61d71b5 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -23,7 +23,8 @@ g_tmo = 0
 
 g_prefix = os.getenv('PREFIX', '')
 
-use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
+use_session = os.getenv('LVM_DBUSD_USE_SESSION', False)
+pv_device_list = os.getenv('LVM_DBUSD_PV_DEVICE_LIST', None)
 
 if use_session:
 	bus = dbus.SessionBus(mainloop=DBusGMainLoop())
@@ -63,16 +64,35 @@ def get_objects():
 	for object_path, val in list(objects.items()):
 		for interface, props in list(val.items()):
 			o = ClientProxy(bus, object_path, interface, props)
+
+			if interface == PV_INT:
+				# If we have a list of PVs to use, lets only use those in
+				# the list
+				if pv_device_list and not (o.Pv.Name in pv_device_list):
+					continue
+
 			rc[interface].append(o)
 
 	return rc, bus
 
 
-def set_execution(lvmshell):
+def set_execution(lvmshell, test_result):
+	if lvmshell:
+		m = 'lvm shell (non-fork)'
+	else:
+		m = "forking & exec'ing"
+
 	lvm_manager = dbus.Interface(bus.get_object(
 		BUS_NAME, "/com/redhat/lvmdbus1/Manager"),
 		"com.redhat.lvmdbus1.Manager")
-	return lvm_manager.UseLvmShell(lvmshell)
+	rc = lvm_manager.UseLvmShell(lvmshell)
+
+	if rc:
+		std_err_print('Successfully changed execution mode to "%s"' % m)
+	else:
+		std_err_print('ERROR: Failed to change execution mode to "%s"' % m)
+		test_result.register_fail()
+	return rc
 
 
 # noinspection PyUnresolvedReferences
@@ -89,9 +109,12 @@ class TestDbusService(unittest.TestCase):
 			std_err_print('Expecting a manager object!')
 			sys.exit(1)
 
-		if len(self.objs[VG_INT]) != 0:
-			std_err_print('Expecting no VGs to exist!')
-			sys.exit(1)
+		# We will skip the vg device number check if the test user
+		# has specified a PV list
+		if pv_device_list is None:
+			if len(self.objs[VG_INT]) != 0:
+				std_err_print('Expecting no VGs to exist!')
+				sys.exit(1)
 
 		self.pvs = []
 		for p in self.objs[PV_INT]:
@@ -101,9 +124,19 @@ class TestDbusService(unittest.TestCase):
 		# If we get here it means we passed setUp, so lets remove anything
 		# and everything that remains, besides the PVs themselves
 		self.objs, self.bus = get_objects()
-		for v in self.objs[VG_INT]:
-			# print "DEBUG: Removing VG= ", v.Uuid, v.Name
-			self.handle_return(v.Vg.Remove(g_tmo, {}))
+
+		if pv_device_list is None:
+			for v in self.objs[VG_INT]:
+				self.handle_return(v.Vg.Remove(g_tmo, {}))
+		else:
+			for p in self.objs[PV_INT]:
+				# When we remove a VG for a PV it could ripple across multiple
+				# VGs, so update each PV while removing each VG, to ensure
+				# the properties are current and correct.
+				p.update()
+				if p.Pv.Vg != '/':
+					v = ClientProxy(self.bus, p.Pv.Vg)
+					self.handle_return(v.Vg.Remove(g_tmo, {}))
 
 		# Check to make sure the PVs we had to start exist, else re-create
 		# them
@@ -119,6 +152,12 @@ class TestDbusService(unittest.TestCase):
 					# print('Re-creating PV=', p)
 					self._pv_create(p)
 
+	def _check_consistency(self):
+		# Only do consistency checks if we aren't running the unit tests
+		# concurrently
+		if pv_device_list is None:
+			self.assertEqual(self._refresh(), 0)
+
 	def handle_return(self, rc):
 		if isinstance(rc, (tuple, list)):
 			# We have a tuple returned
@@ -148,13 +187,12 @@ class TestDbusService(unittest.TestCase):
 		return self._manager().Manager.Refresh()
 
 	def test_refresh(self):
-		rc = self._refresh()
-		self.assertEqual(rc, 0)
+		self._check_consistency()
 
 	def test_version(self):
 		rc = self.objs[MANAGER_INT][0].Manager.Version
 		self.assertTrue(rc is not None and len(rc) > 0)
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	def _vg_create(self, pv_paths=None):
 
@@ -172,13 +210,13 @@ class TestDbusService(unittest.TestCase):
 
 	def test_vg_create(self):
 		self._vg_create()
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	def test_vg_delete(self):
 		vg = self._vg_create().Vg
 
 		self.handle_return(vg.Remove(g_tmo, {}))
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	def _pv_remove(self, pv):
 		rc = self.handle_return(pv.Pv.Remove(g_tmo, {}))
@@ -190,12 +228,12 @@ class TestDbusService(unittest.TestCase):
 		# Remove the PV
 		rc = self._pv_remove(target)
 		self.assertTrue(rc == '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		# Add it back
 		rc = self._pv_create(target.Pv.Name)[0]
 		self.assertTrue(rc == '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	def _create_raid5_thin_pool(self, vg=None):
 
@@ -281,7 +319,7 @@ class TestDbusService(unittest.TestCase):
 				vg.Extend([pv_next.object_path], g_tmo, {})
 			)
 			self.assertTrue(path == '/')
-			self.assertEqual(self._refresh(), 0)
+			self._check_consistency()
 
 	# noinspection PyUnresolvedReferences
 	def test_vg_reduce(self):
@@ -296,7 +334,7 @@ class TestDbusService(unittest.TestCase):
 				vg.Reduce(False, [vg.Pvs[0]], g_tmo, {})
 			)
 			self.assertTrue(path == '/')
-			self.assertEqual(self._refresh(), 0)
+			self._check_consistency()
 
 	# noinspection PyUnresolvedReferences
 	def test_vg_rename(self):
@@ -323,7 +361,7 @@ class TestDbusService(unittest.TestCase):
 
 		path = self.handle_return(vg.Rename(new_name, g_tmo, {}))
 		self.assertTrue(path == '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		# Do a vg lookup
 		path = mgr.LookUpByLvmId(new_name)
@@ -404,7 +442,7 @@ class TestDbusService(unittest.TestCase):
 		path = self.handle_return(vg.Rename(new_name, g_tmo, {}))
 
 		self.assertTrue(path == '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		# Go through each LV and make sure it has the correct path back to the
 		# VG
@@ -442,7 +480,7 @@ class TestDbusService(unittest.TestCase):
 		# 'I' to 'i' between the time it takes to create a RAID and it returns
 		# and when we refresh state here.  Not sure how we can handle this as
 		# we cannot just sit and poll all the time for changes...
-		# self.assertEqual(self._refresh(), 0)
+		# self._check_consistency()
 		return lv
 
 	def test_lv_create(self):
@@ -532,7 +570,7 @@ class TestDbusService(unittest.TestCase):
 
 		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(new_name)
 
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 		self.assertTrue(prev_path == path, "%s != %s" % (prev_path, path))
 
 	def test_lv_thinpool_rename(self):
@@ -545,7 +583,7 @@ class TestDbusService(unittest.TestCase):
 		new_name = 'renamed_' + tp.LvCommon.Name
 		self.handle_return(tp.Lv.Rename(new_name, g_tmo, {}))
 		tp.update()
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 		self.assertEqual(new_name, tp.LvCommon.Name)
 
 	# noinspection PyUnresolvedReferences
@@ -568,13 +606,13 @@ class TestDbusService(unittest.TestCase):
 		)
 
 		self.assertTrue(rc == '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	def test_lv_remove(self):
 		lv = self._create_lv().Lv
 		rc = self.handle_return(lv.Remove(g_tmo, {}))
 		self.assertTrue(rc == '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	def test_lv_snapshot(self):
 		lv_p = self._create_lv()
@@ -661,7 +699,7 @@ class TestDbusService(unittest.TestCase):
 						size, dbus.Array([], '(oii)'), g_tmo, {}))
 
 			self.assertEqual(rc, '/')
-			self.assertEqual(self._refresh(), 0)
+			self._check_consistency()
 
 			lv.update()
 
@@ -695,7 +733,7 @@ class TestDbusService(unittest.TestCase):
 				(0, 0),
 				dbus.Array([], '(oii)'), g_tmo, {}))
 		self.assertTrue(rc == '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		lv.update()
 		new_pv = str(lv.LvCommon.Devices[0][0])
@@ -709,13 +747,13 @@ class TestDbusService(unittest.TestCase):
 		self.handle_return(lv_p.Lv.Deactivate(0, g_tmo, {}))
 		lv_p.update()
 		self.assertFalse(lv_p.LvCommon.Active)
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		self.handle_return(lv_p.Lv.Activate(0, g_tmo, {}))
 
 		lv_p.update()
 		self.assertTrue(lv_p.LvCommon.Active)
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		# Try control flags
 		for i in range(0, 5):
@@ -723,7 +761,7 @@ class TestDbusService(unittest.TestCase):
 			self.handle_return(lv_p.Lv.Activate(1 << i, g_tmo, {}))
 
 			self.assertTrue(lv_p.LvCommon.Active)
-			self.assertEqual(self._refresh(), 0)
+			self._check_consistency()
 
 	def test_move(self):
 		lv = self._create_lv()
@@ -735,7 +773,7 @@ class TestDbusService(unittest.TestCase):
 		rc = self.handle_return(vg.Move(
 			pv_to_move, (0, 0), dbus.Array([], '(oii)'), 0, {}))
 		self.assertEqual(rc, '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		# Test Vg.Move
 		# TODO Test this more!
@@ -758,7 +796,7 @@ class TestDbusService(unittest.TestCase):
 				location, (0, 0),
 				[(dst, pv.PeCount / 2, 0), ], g_tmo, {}))
 		self.assertEqual(job, '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	def test_job_handling(self):
 		pv_paths = []
@@ -973,12 +1011,12 @@ class TestDbusService(unittest.TestCase):
 
 		rc = self.handle_return(vg.Deactivate(0, g_tmo, {}))
 		self.assertEqual(rc, '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		rc = self.handle_return(vg.Activate(0, g_tmo, {}))
 
 		self.assertEqual(rc, '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		# Try control flags
 		for i in range(0, 5):
@@ -997,12 +1035,12 @@ class TestDbusService(unittest.TestCase):
 
 			self.handle_return(pv.ReSize(new_size, g_tmo, {}))
 
-			self.assertEqual(self._refresh(), 0)
+			self._check_consistency()
 			pv.update()
 
 			self.assertTrue(pv.SizeBytes != original_size)
 			self.handle_return(pv.ReSize(0, g_tmo, {}))
-			self.assertEqual(self._refresh(), 0)
+			self._check_consistency()
 			pv.update()
 			self.assertTrue(pv.SizeBytes == original_size)
 
@@ -1027,7 +1065,7 @@ class TestDbusService(unittest.TestCase):
 		pv.update()
 		self.assertTrue(pv.Allocatable)
 
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	@staticmethod
 	def _get_devices():
@@ -1045,7 +1083,7 @@ class TestDbusService(unittest.TestCase):
 					False, True, dbus.Array([], 's'),
 					dbus.Array([], '(ii)'), g_tmo, {})), '/')
 
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 		self.assertEqual(
 			self.handle_return(
 				mgr.PvScan(
@@ -1053,7 +1091,7 @@ class TestDbusService(unittest.TestCase):
 					dbus.Array([], 's'),
 					dbus.Array([], '(ii)'), g_tmo, {})), '/')
 
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		block_path = []
 		for d in devices:
@@ -1066,7 +1104,7 @@ class TestDbusService(unittest.TestCase):
 					block_path,
 					dbus.Array([], '(ii)'), g_tmo, {})), '/')
 
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		mm = []
 		for d in devices:
@@ -1076,7 +1114,7 @@ class TestDbusService(unittest.TestCase):
 			self.handle_return(
 				mgr.PvScan(False, True, block_path, mm, g_tmo, {})), '/')
 
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 		self.assertEqual(
 			self.handle_return(
@@ -1084,7 +1122,7 @@ class TestDbusService(unittest.TestCase):
 					False, True,
 					dbus.Array([], 's'),
 					mm, g_tmo, {})), '/')
-		self.assertEqual(self._refresh(), 0)
+		self._check_consistency()
 
 	@staticmethod
 	def _write_some_data(device_path, size):
@@ -1229,7 +1267,7 @@ class TestDbusService(unittest.TestCase):
 
 		# Create a VG and try to create LVs with different bad names
 		vg_path = self.handle_return(
-			mgr.VgCreate("test", pv_paths, g_tmo, {}))
+			mgr.VgCreate(vg_n(), pv_paths, g_tmo, {}))
 
 		vg_proxy = ClientProxy(self.bus, vg_path)
 
@@ -1268,7 +1306,7 @@ class TestDbusService(unittest.TestCase):
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
 		vg_path = self.handle_return(
-			mgr.VgCreate("test", pv_paths, g_tmo, {}))
+			mgr.VgCreate(vg_n(), pv_paths, g_tmo, {}))
 		vg_proxy = ClientProxy(self.bus, vg_path)
 
 		for c in self._invalid_tag_characters():
@@ -1288,7 +1326,7 @@ class TestDbusService(unittest.TestCase):
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
 		vg_path = self.handle_return(
-			mgr.VgCreate("test", pv_paths, g_tmo, {}))
+			mgr.VgCreate(vg_n(), pv_paths, g_tmo, {}))
 		vg_proxy = ClientProxy(self.bus, vg_path)
 
 		for i in range(1, 64):
@@ -1312,7 +1350,7 @@ class TestDbusService(unittest.TestCase):
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
 		vg_path = self.handle_return(
-			mgr.VgCreate("test", pv_paths, g_tmo, {}))
+			mgr.VgCreate(vg_n(), pv_paths, g_tmo, {}))
 		vg_proxy = ClientProxy(self.bus, vg_path)
 
 		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'
@@ -1350,31 +1388,30 @@ if __name__ == '__main__':
 
 	r = AggregateResults()
 
-	# Test forking & exec new each time
+	# Default is to test all modes
 	test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 1)
 
-	# Default to no lvm shell
-	set_execution(False)
+	mode = int(test_shell)
 
-	if int(test_shell) == 0:
-		std_err_print('\n Running only lvm fork & exec test ***\n')
-		r.register_result(unittest.main(exit=False))
+	if mode == 0:
+		std_err_print('\n*** Testing only lvm fork & exec test mode ***\n')
+	elif mode == 1:
+		std_err_print('\n*** Testing fork & exec & lvm shell mode ***\n')
 	else:
-		std_err_print('\n *** Testing with lvm fork & exec *** \n')
-		r.register_result(unittest.main(exit=False))
-		g_tmo = 15
-		r.register_result(unittest.main(exit=False))
-		# Test lvm shell
-		std_err_print('\n *** Testing with lvm shell *** \n')
-		if set_execution(True):
-			g_tmo = 0
-			r.register_result(unittest.main(exit=False))
-			g_tmo = 15
-			r.register_result(unittest.main(exit=False))
+		std_err_print('\n*** Testing only lvm shell mode ***\n')
+
+	for g_tmo in [0, 15]:
+		if mode == 0:
+			if set_execution(False, r):
+				r.register_result(unittest.main(exit=False))
+		elif mode == 2:
+			if set_execution(True, r):
+				r.register_result(unittest.main(exit=False))
 		else:
-			r.register_fail()
-			std_err_print(
-				"ERROR: Unable to dynamically configure service to use "
-				"lvm shell!")
+			if set_execution(False, r):
+				r.register_result(unittest.main(exit=False))
+			# Test lvm shell
+			if set_execution(True, r):
+				r.register_result(unittest.main(exit=False))
 
 	r.exit_run()


