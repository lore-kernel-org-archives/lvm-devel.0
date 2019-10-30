From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:44 -0400
Subject: master - testlib.py: Add interface instance vars.
Message-ID: <201910301545.x9UFjhZi016977@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e15c83673436342a60b8f982e521eb32d972a0c
Commit:        9e15c83673436342a60b8f982e521eb32d972a0c
Parent:        b7aab9ba594b9b627ec09b8e0dab5cd75e7178cf
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 10 09:01:27 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

testlib.py: Add interface instance vars.

---
 test/dbus/testlib.py |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index ad2d93b..75a367d 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -243,10 +243,6 @@ class RemoteInterface(object):
 
 
 class ClientProxy(object):
-	Pv = None
-	Lv = None
-	Vg = None
-	VgVdo = None
 
 	@staticmethod
 	def _intf_short_name(nm):
@@ -270,6 +266,22 @@ class ClientProxy(object):
 	def __init__(
 			self, bus, object_path, interface_prop_hash=None,
 			interfaces=None, timelimit=-1):
+		# Instance variables which may or may not get assigned during class
+		# construction dynamically.  Assigned here so code inspection tools
+		# have knowledge of their existence.
+		self.Manager = None
+		self.Pv = None
+		self.Vg = None
+		self.Lv = None
+		self.VgVdo = None
+		self.ThinPool = None
+		self.VdoPool = None
+		self.SnapShot = None
+		self.LvCommon = None
+		self.Job = None
+		self.CachePool = None
+		self.CachedLv = None
+
 		self.object_path = object_path
 		self.short_interface_names = []
 		self.tmo = timelimit


