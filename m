From: Tony Asleson <tasleson@sourceware.org>
Date: Fri,  3 Mar 2023 18:03:26 +0000 (GMT)
Subject: main - lvmdbustest.py: Increase udev timeout
Message-ID: <20230303180326.542743858CDB@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80f6655956273b84ec2301dae7c6454ca62d124c
Commit:        80f6655956273b84ec2301dae7c6454ca62d124c
Parent:        4cbe789f9c273cd03a3b0aff39aa43fc7674099f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 15:25:00 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 15:26:37 2023 -0600

lvmdbustest.py: Increase udev timeout

---
 test/dbus/lvmdbustest.py | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index b1c965bb7..b98332d65 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2410,7 +2410,8 @@ class TestDbusService(unittest.TestCase):
 	def _block_present_absent(self, block_device, present=False):
 		start = time.time()
 		keep_looping = True
-		while keep_looping and time.time() < start + 3:
+		max_wait = 10
+		while keep_looping and time.time() < start + max_wait:
 			if present:
 				if (self._lookup(block_device) != "/"):
 					keep_looping = False
@@ -2419,7 +2420,7 @@ class TestDbusService(unittest.TestCase):
 					keep_looping = False
 
 		if keep_looping:
-			print("Daemon failed to update")
+			print("Daemon failed to update within %d seconds!" % max_wait)
 		else:
 			print("Note: Time for udev update = %f" % (time.time() - start))
 		if present:

