From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 20 Apr 2023 17:11:45 +0000 (GMT)
Subject: main - lvmdbusd: Add a flag to activate LVs in shared mode to Lv.Activate
Message-ID: <20230420171145.3D2943858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7807672975cc991720d817b4e541ca5e720df26e
Commit:        7807672975cc991720d817b4e541ca5e720df26e
Parent:        317071ec53c2f6e338c53a8964fdbb61dc3e8b57
Author:        Vojtech Trefny <vtrefny@redhat.com>
AuthorDate:    Thu Apr 20 11:49:21 2023 +0200
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Apr 20 12:09:11 2023 -0500

lvmdbusd: Add a flag to activate LVs in shared mode to Lv.Activate

---
 daemons/lvmdbusd/cmdhandler.py | 4 ++++
 test/dbus/lvmdbustest.py       | 2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index cf2a70875..cf9803e76 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -787,6 +787,10 @@ def activate_deactivate(op, name, activate, control_flags, options):
 		if (1 << 5) & control_flags:
 			cmd.append('--ignoreactivationskip')
 
+		# Shared locking (Cluster)
+		if (1 << 6) & control_flags:
+			op += 's'
+
 	if activate:
 		op += 'y'
 	else:
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 8f95757eb..475f328cb 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1243,7 +1243,7 @@ class TestDbusService(unittest.TestCase):
 			self._check_consistency()
 
 		# Try control flags
-		for i in range(0, 5):
+		for i in range(0, 6):
 
 			self.handle_return(lv_p.Lv.Activate(
 				dbus.UInt64(1 << i),

