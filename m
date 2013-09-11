From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 11 Sep 2013 18:15:21 -0500
Subject: [PATCH] python-lvm: Update and enable unit test case
Message-ID: <1378941321-17701-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Added tests for lvm.pvCreate and enable the test suite.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/pytest.sh          |  4 --
 test/api/python_lvm_unit.py | 99 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 99 insertions(+), 4 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 791c9dc..67e224c 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -27,8 +27,4 @@ export PYTHONPATH=`dirname $python_lib`:$PYTHONPATH
 #Setup which devices the unit test can use.
 export PY_UNIT_PVS=$(cat DEVICES)
 
-
-#We will skip until we can ensure it is correct.
-skip
-
 python_lvm_unit.py -v -f
diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index eab9575..6c13149 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -27,6 +27,17 @@ import os
 # production system.  Therefore it is strongly advised that this unit test
 # not be run on a system that contains data of value.
 
+fh = None
+
+
+def l(txt):
+	if os.environ.get('PY_UNIT_LOG') is not None:
+		global fh
+		if fh is None:
+			fh = open('/tmp/lvm_py_unit_test_' + rs(10), "a")
+		fh.write(txt + "\n")
+		fh.flush()
+
 
 def rs(l=10):
 	"""
@@ -693,5 +704,93 @@ class TestLvm(unittest.TestCase):
 			self._testTags(vg)
 			vg.close()
 
+	def testListing(self):
+
+		env = os.environ
+
+		for k, v in env.items():
+			l("%s:%s" % (k, v))
+
+		with lvm.listPvs() as pvs:
+			for p in pvs:
+				l('pv= %s' % p.getName())
+
+		l('Checking for VG')
+		for v in lvm.listVgNames():
+			l('vg= %s' % v)
+
+	def testPVemptylisting(self):
+		#We had a bug where we would seg. fault if we had no PVs.
+
+		l('testPVemptylisting entry')
+
+		device_names = self._get_pv_device_names()
+
+		for d in device_names:
+			l("Removing %s" % d)
+			lvm.pvRemove(d)
+
+		count = 0
+
+		with lvm.listPvs() as pvs:
+			for p in pvs:
+				count += 1
+				l('pv= %s' % p.getName())
+
+		self.assertTrue(count == 0)
+
+		for d in device_names:
+			lvm.pvCreate(d)
+
+	def testPVCreate(self):
+		size = [0, 1024*1024*4]
+		pvmeta_copies = [0, 1, 2]
+		pvmeta_size = [0, 255, 512, 1024]
+		data_alignment = [0, 2048, 4096]
+		data_alignment_offset = [1, 1, 1]
+		zero = [0, 1]
+
+		device_names = self._get_pv_device_names()
+
+		for d in device_names:
+			lvm.pvRemove(d)
+
+		d = device_names[0]
+
+		#Test some error cases
+		self.assertRaises(TypeError, lvm.pvCreate, None)
+		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, '')
+		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 4)
+		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 0, 4)
+		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 0, 0, 0, 2**34)
+		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 0, 0, 0, 4096,
+						  2**34)
+
+		#Try a number of combinations and permutations
+		for s in size:
+			lvm.pvCreate(d, s)
+			lvm.pvRemove(d)
+			for copies in pvmeta_copies:
+				lvm.pvCreate(d, s, copies)
+				lvm.pvRemove(d)
+				for pv_size in pvmeta_size:
+					lvm.pvCreate(d, s, copies, pv_size)
+					lvm.pvRemove(d)
+					for align in data_alignment:
+						lvm.pvCreate(d, s, copies, pv_size, align)
+						lvm.pvRemove(d)
+						for align_offset in data_alignment_offset:
+							lvm.pvCreate(d, s, copies, pv_size, align,
+										 align * align_offset)
+							lvm.pvRemove(d)
+							for z in zero:
+								lvm.pvCreate(d, s, copies, pv_size, align,
+											 align * align_offset, z)
+								lvm.pvRemove(d)
+
+		#Restore
+		for d in device_names:
+			lvm.pvCreate(d)
+
 if __name__ == "__main__":
 	unittest.main()
-- 
1.8.2.1


