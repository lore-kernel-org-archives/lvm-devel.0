From: Tony Asleson <tasleson@sourceware.org>
Date: Fri,  3 Mar 2023 18:03:27 +0000 (GMT)
Subject: main - lvmdbustest: Add more output for test_log_file_option
Message-ID: <20230303180327.74C0C3858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50e6efafb92367beacc0ee85afcb1279163d601d
Commit:        50e6efafb92367beacc0ee85afcb1279163d601d
Parent:        80f6655956273b84ec2301dae7c6454ca62d124c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 15:52:23 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 15:52:23 2023 -0600

lvmdbustest: Add more output for test_log_file_option

---
 test/dbus/lvmdbustest.py | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index b98332d65..8d70b4477 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2307,7 +2307,9 @@ class TestDbusService(unittest.TestCase):
 			option_str = "log { level=7 file=%s syslog=0 }" % fn
 			options["config"] = dbus.String(option_str)
 			self._vg_create(None, None, options)
-			self.assertTrue(os.path.exists(fn))
+			self.assertTrue(os.path.exists(fn),
+							"We passed the following options %s to lvm while creating a VG and the "
+							"log file we expected to exist (%s) was not found" % (option_str, fn))
 		finally:
 			if os.path.exists(fn):
 				os.unlink(fn)

