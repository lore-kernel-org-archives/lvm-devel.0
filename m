From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:52 +0000 (UTC)
Subject: master - python_lvm_unit.py: Add test for new name validate methods
Message-ID: <20131119205652.27DEB60F74@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5588a56391dd3ef61d284ea64bcb6da591a3136c
Commit:        5588a56391dd3ef61d284ea64bcb6da591a3136c
Parent:        370520a310a44e6b9a48d9507bf2136748093029
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Nov 18 15:09:09 2013 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:47 2013 -0600

python_lvm_unit.py: Add test for new name validate methods

Test naming validate names for VG and LV names.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/python_lvm_unit.py |  106 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index fc8c198..8208d91 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -17,6 +17,7 @@ import random
 import string
 import lvm
 import os
+import itertools
 
 # Set of basic unit tests for the python bindings.
 #
@@ -808,5 +809,110 @@ class TestLvm(unittest.TestCase):
 		for d in device_names:
 			lvm.pvCreate(d)
 
+	def test_vg_reduce(self):
+		# Test the case where we try to reduce a vg where the last PV has
+		# no metadata copies.  In this case the reduce should fail.
+		vg_name = TestLvm.VG_P + 'reduce_test'
+
+		device_names = TestLvm._get_pv_device_names()
+
+		for d in device_names:
+			lvm.pvRemove(d)
+
+		lvm.pvCreate(device_names[0], 0, 0)  # Size all, pvmetadatacopies 0
+		lvm.pvCreate(device_names[1])
+		lvm.pvCreate(device_names[2])
+		lvm.pvCreate(device_names[3])
+
+		vg = lvm.vgCreate(vg_name)
+
+		vg.extend(device_names[3])
+		vg.extend(device_names[2])
+		vg.extend(device_names[1])
+		vg.extend(device_names[0])
+		vg.close()
+
+		vg = None
+
+		vg = lvm.vgOpen(vg_name, 'w')
+
+		vg.reduce(device_names[3])
+		vg.reduce(device_names[2])
+
+		self.assertRaises(lvm.LibLVMError, vg.reduce, device_names[1])
+
+		vg.close()
+		vg = None
+
+		vg = lvm.vgOpen(vg_name, 'w')
+		vg.remove()
+		vg.close()
+
+	@staticmethod
+	def _test_valid_names(method):
+		sample = 'azAZ09._-+'
+
+		method('x' * 127)
+		method('.X')
+		method('..X')
+
+		for i in range(1, 7):
+			tests = (''.join(i) for i in itertools.product(sample, repeat=i))
+			for t in tests:
+				if t == '.' or t == '..':
+					t += 'X'
+				elif t.startswith('-'):
+					t = 'H' + t
+				method(t)
+
+	def _test_bad_names(self, method, dupe_name):
+		 # Test for duplicate name
+		self.assertRaises(lvm.LibLVMError, method, dupe_name)
+
+		# Test for too long a name
+		self.assertRaises(lvm.LibLVMError, method, ('x' * 128))
+
+		# Test empty
+		self.assertRaises(lvm.LibLVMError, method, '')
+
+		# Invalid characters
+		self.assertRaises(lvm.LibLVMError, method, '&invalid^char')
+
+		# Cannot start with .. and no following characters
+		self.assertRaises(lvm.LibLVMError, method, '..')
+
+		# Cannot start with . and no following characters
+		self.assertRaises(lvm.LibLVMError, method, '.')
+
+		# Cannot start with a hyphen
+		self.assertRaises(lvm.LibLVMError, method, '-not_good')
+
+	def _lv_reserved_names(self, method):
+		prefixes = ['snapshot', 'pvmove']
+		reserved = ['_mlog', '_mimage', '_pmspare', '_rimage', '_rmeta',
+					'_vorigin', '_tdata', '_tmeta']
+
+		for p in prefixes:
+			self.assertRaises(lvm.LibLVMError, method, p + rs(3))
+
+		for r in reserved:
+			self.assertRaises(lvm.LibLVMError, method, rs(3) + r + rs(1))
+			self.assertRaises(lvm.LibLVMError, method, r + rs(1))
+
+	def test_vg_lv_name_validate(self):
+		lv_name = 'vg_lv_name_validate'
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
+
+		self._test_bad_names(lvm.vgNameValidate, vg.getName())
+		self._test_bad_names(vg.lvNameValidate, lv.getName())
+
+		# Test good values
+		TestLvm._test_valid_names(lvm.vgNameValidate)
+		TestLvm._test_valid_names(vg.lvNameValidate)
+		self._lv_reserved_names(vg.lvNameValidate)
+
+		vg.close()
+
 if __name__ == "__main__":
 	unittest.main()


