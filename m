From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:03 +0000 (GMT)
Subject: main - lvmdbustest: Add test for external event
Message-ID: <20220919155803.88326385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2ca4a2dbf3d35528f8173916aed77fd277f23f18
Commit:        2ca4a2dbf3d35528f8173916aed77fd277f23f18
Parent:        4a202c11fffb30ae786e69cebe11186dd4166c88
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 12:12:17 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Add test for external event

Ensure that when we trigger an external event that we don't incorrectly
handle multiple --config options.
---
 test/dbus/lvmdbustest.py | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c03e96c08..d67298fe9 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2095,6 +2095,16 @@ class TestDbusService(unittest.TestCase):
 	def test_log_file_option(self):
 		self._log_file_option()
 
+	def test_external_event(self):
+		# Call into the service to register an external event, so that we can test sending the path
+		# where we don't send notifications on the command line in addition to the logging
+		lvm_manager = dbus.Interface(bus.get_object(
+			BUS_NAME, "/com/redhat/lvmdbus1/Manager", introspect=False),
+			"com.redhat.lvmdbus1.Manager")
+		rc = lvm_manager.ExternalEvent("unit_test")
+		self.assertTrue(rc == 0)
+		self._log_file_option()
+
 class AggregateResults(object):
 
 	def __init__(self):

