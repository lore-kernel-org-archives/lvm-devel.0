From: Tony Asleson <tasleson@sourceware.org>
Date: Fri,  3 Mar 2023 18:03:28 +0000 (GMT)
Subject: main - lvmdbustest: Don't hard code to /tmp
Message-ID: <20230303180328.952AE3858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=95afd315b163143296a1a42d2cad2b1cd762725d
Commit:        95afd315b163143296a1a42d2cad2b1cd762725d
Parent:        50e6efafb92367beacc0ee85afcb1279163d601d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 15:59:14 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 15:59:18 2023 -0600

lvmdbustest: Don't hard code to /tmp

During lvm testing they use an alternative tmp directory.
---
 test/dbus/lvmdbustest.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 8d70b4477..9a3cb175a 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2301,7 +2301,7 @@ class TestDbusService(unittest.TestCase):
 			self._vdo_pool_lv(), test_ss=False)
 
 	def _log_file_option(self):
-		fn = "/tmp/%s" % rs(8, "_lvm.log")
+		fn = os.path.join(tempfile.gettempdir(), rs(8, "_lvm.log"))
 		try:
 			options = dbus.Dictionary({}, signature=dbus.Signature('sv'))
 			option_str = "log { level=7 file=%s syslog=0 }" % fn

