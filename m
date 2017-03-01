From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 1 Mar 2017 18:58:51 -0500
Subject: master - lvmdbustest.py: Validate PV device
Message-ID: <201703012358.v21Nwp0h024484@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83249f332709037256bf0f3c7c3d3663addaffc6
Commit:        83249f332709037256bf0f3c7c3d3663addaffc6
Parent:        4c89d3794c64b674191bb9c767415cc2ba919e3a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 17:24:08 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 17:47:04 2017 -0600

lvmdbustest.py: Validate PV device

Validate device lookup after PV creation.
---
 test/dbus/lvmdbustest.py |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 0e27ae3..800f590 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -198,6 +198,9 @@ class TestDbusService(unittest.TestCase):
 			self.objs[MANAGER_INT][0].Manager.PvCreate(
 				dbus.String(device), dbus.Int32(g_tmo), EOD)
 		)
+
+		self._validate_lookup(device, pv_path)
+
 		self.assertTrue(pv_path is not None and len(pv_path) > 0)
 		return pv_path
 


