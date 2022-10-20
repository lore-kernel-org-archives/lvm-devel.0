From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 20 Oct 2022 20:11:37 +0000 (GMT)
Subject: main - lvmdbustest: Add test for copy signature
Message-ID: <20221020201137.8176A384BC20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=736547e7bb306236e1ea6f4d8d9185ee0ab69638
Commit:        736547e7bb306236e1ea6f4d8d9185ee0ab69638
Parent:        8a1c73ddbe35be24cde02f77bac7e3b8b6d92242
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 20 12:48:40 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Oct 20 15:10:35 2022 -0500

lvmdbustest: Add test for copy signature

Add test to ensure we detect when a PV signature is copied to a block
device.
---
 test/dbus/lvmdbustest.py | 71 ++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 60 insertions(+), 11 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index f158da571..9582fe674 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -8,7 +8,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
-
+import os
 import signal
 # noinspection PyUnresolvedReferences
 import subprocess
@@ -2394,6 +2394,30 @@ class TestDbusService(unittest.TestCase):
 			return False
 		return True
 
+	def _block_present_absent(self, block_device, present=False):
+		start = time.time()
+		keep_looping = True
+		while keep_looping and time.time() < start + 3:
+			if present:
+				if (self._lookup(block_device) != "/"):
+					keep_looping = False
+			else:
+				if (self._lookup(block_device) == "/"):
+					keep_looping = False
+
+		if keep_looping:
+			print("Daemon failed to update")
+		else:
+			print("Note: Time for udev update = %f" % (time.time() - start))
+		if present:
+			rc = self._lookup(block_device)
+			self.assertNotEqual(rc, '/')
+			return True
+		else:
+			rc = self._lookup(block_device)
+			self.assertEqual(rc, '/')
+			return True
+
 	def test_wipefs(self):
 		# Ensure we update the status of the daemon if an external process clears a PV
 		pv = self.objs[PV_INT][0]
@@ -2404,21 +2428,46 @@ class TestDbusService(unittest.TestCase):
 
 		if wipe_result:
 			# Need to wait a bit before the daemon will reflect the change
-			start = time.time()
-			found = True
-			while found and time.time() < start + 10:
-				if (self._lookup(pv_device_path) == "/"):
-					found = False
-
-			print("Note: Time for udev update = %f" % (time.time() - start))
-			# Make sure that the service no longer has it
-			rc = self._lookup(pv_device_path)
-			self.assertEqual(rc, '/')
+			self._block_present_absent(pv_device_path, False)
 
 			# Put it back
 			pv_object_path = self._pv_create(pv_device_path)
 			self.assertNotEqual(pv_object_path, '/')
 
+	@staticmethod
+	def _write_signature(device, data=None):
+		fd = os.open(device, os.O_RDWR|os.O_EXCL|os.O_NONBLOCK)
+		existing = os.read(fd, 1024)
+		os.lseek(fd, 0, os.SEEK_SET)
+
+		if data is None:
+			data_copy = bytearray(existing)
+			# Clear lvm signature
+			data_copy[536:536+9] = bytearray(8)
+			os.write(fd, data_copy)
+		else:
+			os.write(fd, data)
+		os.sync()
+		os.close(fd)
+		return existing
+
+	def test_copy_signature(self):
+		# Ensure we update the state of the daemon if an external process copies
+		# a pv signature onto a block device
+		pv = self.objs[PV_INT][0]
+		pv_device_path = pv.Pv.Name
+
+		try:
+			existing = TestDbusService._write_signature(pv_device_path, None)
+			if self._block_present_absent(pv_device_path, False):
+				TestDbusService._write_signature(pv_device_path, existing)
+				self._block_present_absent(pv_device_path, True)
+		finally:
+			# Ensure we put the PV back for sure.
+			rc = self._lookup(pv_device_path)
+			if rc == "/":
+				self._pv_create(pv_device_path)
+
 
 class AggregateResults(object):
 

