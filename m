From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:41:57 -0500
Subject: master - lvmdbustest.py: Add unit test for external PV create
Message-ID: <201703092241.v29MfviA010752@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=28754145d8cdad50bfa003fb13fc46af1cbadae8
Commit:        28754145d8cdad50bfa003fb13fc46af1cbadae8
Parent:        e06e4d9355a314acc82eb568829f9696d7969b89
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 8 15:52:48 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbustest.py: Add unit test for external PV create

Ensure a PV created outside of the dbus service is immediately found by
service user.
---
 test/dbus/lvmdbustest.py |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c2ac7df..2a65466 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1760,6 +1760,24 @@ class TestDbusService(unittest.TestCase):
 		cmd = ['lvcreate', '-L4M', '-n', lv_name, vg.Name]
 		self._verify_existence(cmd, cmd[0], full_name)
 
+	def test_external_pv_create(self):
+		# Lets create a PV outside of service and see if we correctly handle
+		# it's inclusion
+		target = self.objs[PV_INT][0]
+
+		# Remove the PV
+		rc = self._pv_remove(target)
+		self.assertTrue(rc == '/')
+		self._check_consistency()
+
+		# Make sure the PV we removed no longer exists
+		self.assertTrue(self._lookup(target.Pv.Name) == '/')
+
+		# Add it back with external command line
+		cmd = ['pvcreate', target.Pv.Name]
+		self._verify_existence(cmd, cmd[0], target.Pv.Name)
+
+
 class AggregateResults(object):
 
 	def __init__(self):


