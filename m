From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:43:44 -0400
Subject: master - lvmdbustest.py: Add blurb about scan_lvs = 1
Message-ID: <201910301543.x9UFhi19016552@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7c64fe8e29ffc003364da93047b9e003c35fc96
Commit:        b7c64fe8e29ffc003364da93047b9e003c35fc96
Parent:        b0286fa1277a9fc7a293916a3c8a3e460d276aa2
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 11:57:10 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add blurb about scan_lvs = 1

When developing and testing on a local system, to get the unit
test to pass the test_nesting test, editing the test conf will achieve
the success too.
---
 test/dbus/lvmdbustest.py |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 9bc1683..4ae8b25 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1871,6 +1871,10 @@ class TestDbusService(unittest.TestCase):
 		#
 		# NOTE: This needs an equivalent of aux extend_filter_LVMTEST
 		# when run from lvm2 testsuite. See dbustest.sh.
+		# Also if developing locally with actual devices one can achieve this
+		# by editing lvm.conf with "devices/scan_lvs = 1"  As testing
+		# typically utilizes loopback, this test is skipped in
+		# those environments.
 		pv_object_path = self.objs[PV_INT][0].object_path
 
 		if not self.objs[PV_INT][0].Pv.Name.startswith("/dev"):


