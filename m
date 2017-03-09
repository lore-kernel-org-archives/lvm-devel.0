From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:41:52 -0500
Subject: master - lvmdbustest.py: Add unit test for external LV create
Message-ID: <201703092241.v29MfplZ000403@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e06e4d9355a314acc82eb568829f9696d7969b89
Commit:        e06e4d9355a314acc82eb568829f9696d7969b89
Parent:        43d0fbeba281b1f9f97bf9bcf1149e682f9e6b6d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 8 15:52:30 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbustest.py: Add unit test for external LV create

Ensure a LV created outside of the dbus service is immediately found by
service user.
---
 test/dbus/lvmdbustest.py |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 4788eb3..c2ac7df 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1750,6 +1750,16 @@ class TestDbusService(unittest.TestCase):
 		cmd.extend(pv_paths)
 		self._verify_existence(cmd, cmd[0], vg_name)
 
+	def test_external_lv_create(self):
+		# Lets create a LV outside of service and see if we correctly handle
+		# it's inclusion
+		vg = self._vg_create().Vg
+		lv_name = lv_n()
+		full_name = "%s/%s" % (vg.Name, lv_name)
+
+		cmd = ['lvcreate', '-L4M', '-n', lv_name, vg.Name]
+		self._verify_existence(cmd, cmd[0], full_name)
+
 class AggregateResults(object):
 
 	def __init__(self):


