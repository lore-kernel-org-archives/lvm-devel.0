From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:49 +0000 (GMT)
Subject: main - lvmdbustest: Correct comment spelling/grammar
Message-ID: <20220630160049.68E03386F0D6@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8fa8dfdb8c3b5310a5b43c99fd088f4f076b5903
Commit:        8fa8dfdb8c3b5310a5b43c99fd088f4f076b5903
Parent:        55059e002abb3d858e4c53ac0da078ca853ff1f4
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 09:59:59 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbustest: Correct comment spelling/grammar

---
 test/dbus/lvmdbustest.py | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index e16a484b7..ae02c5fef 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -153,7 +153,7 @@ def get_objects():
 			rc[interface].append(proxy)
 
 	# At this point we have a full population of everything, we now need to
-	# prune the the objects if we are filtering PVs with a sub selection.
+	# prune the objects if we are filtering PVs with a sub selection.
 	return _prune(rc, pv_device_list), bus
 
 
@@ -1111,7 +1111,7 @@ class TestDbusService(unittest.TestCase):
 	def _test_expired_timer(self, num_lvs):
 		rc = False
 
-		# In small configurations lvm is pretty snappy, so lets create a VG
+		# In small configurations lvm is pretty snappy, so let's create a VG
 		# add a number of LVs and then remove the VG and all the contained
 		# LVs which appears to consistently run a little slow.
 
@@ -1781,7 +1781,7 @@ class TestDbusService(unittest.TestCase):
 			self.assertTrue(ec == 0, "%s exit code = %d" % (operation, ec))
 
 	def test_external_vg_create(self):
-		# We need to ensure that if a user creates something outside of lvm
+		# We need to ensure that if a user creates something outside lvm
 		# dbus service that things are sequenced correctly so that if a dbus
 		# user calls into the service they will find the same information.
 		vg_name = vg_n()
@@ -1794,8 +1794,8 @@ class TestDbusService(unittest.TestCase):
 		self._verify_existence(cmd, cmd[0], vg_name)
 
 	def test_external_lv_create(self):
-		# Lets create a LV outside of service and see if we correctly handle
-		# it's inclusion
+		# Let's create a LV outside of service and see if we correctly handle
+		# its inclusion
 		vg = self._vg_create().Vg
 		lv_name = lv_n()
 		full_name = "%s/%s" % (vg.Name, lv_name)
@@ -1804,8 +1804,8 @@ class TestDbusService(unittest.TestCase):
 		self._verify_existence(cmd, cmd[0], full_name)
 
 	def test_external_pv_create(self):
-		# Lets create a PV outside of service and see if we correctly handle
-		# it's inclusion
+		# Let's create a PV outside of service and see if we correctly handle
+		# its inclusion
 		target = self.objs[PV_INT][0]
 
 		# Remove the PV
@@ -1851,7 +1851,7 @@ class TestDbusService(unittest.TestCase):
 		#
 		# NOTE: This needs an equivalent of aux extend_filter_LVMTEST
 		# when run from lvm2 testsuite. See dbustest.sh.
-		# Also if developing locally with actual devices one can achieve this
+		# Also, if developing locally with actual devices one can achieve this
 		# by editing lvm.conf with "devices/scan_lvs = 1"  As testing
 		# typically utilizes loopback, this test is skipped in
 		# those environments.
@@ -1866,7 +1866,7 @@ class TestDbusService(unittest.TestCase):
 			pv_object_path = self._create_nested(pv_object_path)
 
 	def test_pv_symlinks(self):
-		# Lets take one of our test PVs, pvremove it, find a symlink to it
+		# Let's take one of our test PVs, pvremove it, find a symlink to it
 		# and re-create using the symlink to ensure we return an object
 		# path to it.  Additionally, we will take the symlink and do a lookup
 		# (Manager.LookUpByLvmId) using it and the original device path to
@@ -1888,7 +1888,7 @@ class TestDbusService(unittest.TestCase):
 		rc = self._lookup(pv_device_path)
 		self.assertEqual(rc, '/')
 
-		# Lets locate a symlink for it
+		# Let's locate a symlink for it
 		devices = glob('/dev/disk/*/*')
 		rp_pv_device_path = os.path.realpath(pv_device_path)
 		for d in devices:
@@ -1953,7 +1953,7 @@ class TestDbusService(unittest.TestCase):
 			raise unittest.SkipTest('vdo not supported')
 
 		# Do this twice to ensure we are providing the correct flags to force
-		# the operation when if finds an existing vdo signature, which likely
+		# the operation when it finds an existing vdo signature, which likely
 		# shouldn't exist.
 		for _ in range(0, 2):
 			vg, _, _ = self._create_vdo_pool_and_lv()

