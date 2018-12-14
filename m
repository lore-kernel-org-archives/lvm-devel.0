From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 14 Dec 2018 09:31:03 -0500
Subject: master - lvmdbusd: Handle missing lv_attr table lookups
Message-ID: <201812141431.wBEEV3lH011970@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51f08efaa700550740254093bacea270325f2ccf
Commit:        51f08efaa700550740254093bacea270325f2ccf
Parent:        f1684bf8e89b87d7f04e0a963def66f76634766d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Dec 11 11:21:50 2018 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Dec 14 08:28:02 2018 -0600

lvmdbusd: Handle missing lv_attr table lookups

If we don't know the meaning we will return the key with default text
instead of raising an exception and taking the daemon out in the
process.

Resolves: rhbz1657950
---
 daemons/lvmdbusd/lv.py |   35 ++++++++++++++++++++++++-----------
 1 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index ba9499f..a80675f 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -10,7 +10,7 @@
 from .automatedproperties import AutomatedProperties
 
 from . import utils
-from .utils import vg_obj_path_generate
+from .utils import vg_obj_path_generate, log_error
 import dbus
 from . import cmdhandler
 from . import cfg
@@ -24,6 +24,8 @@ from . import background
 from .utils import round_size, mt_remove_dbus_objects
 from .job import JobState
 
+import traceback
+
 
 # Try and build a key for a LV, so that we sort the LVs with least dependencies
 # first.  This may be error prone because of the flexibility LVM
@@ -291,6 +293,22 @@ class LvCommon(AutomatedProperties):
 				(lv_uuid, lv_name))
 		return dbo
 
+	def attr_struct(self, index, type_map, default='undisclosed'):
+		try:
+			if self.state.Attr[index] not in type_map:
+				log_error("LV %s %s with lv_attr %s, lv_attr[%d] = "
+					"'%s' is not known" %
+					(self.Uuid, self.Name, self.Attr, index,
+					self.state.Attr[index]))
+
+			return dbus.Struct((self.state.Attr[index],
+				type_map.get(self.state.Attr[index], default)),
+								signature="(ss)")
+		except BaseException:
+			st = traceback.format_exc()
+			log_error("attr_struct: \n%s" % st)
+			return dbus.Struct(('?', 'Unavailable'), signature="(ss)")
+
 	@property
 	def VolumeType(self):
 		type_map = {'C': 'Cache', 'm': 'mirrored',
@@ -304,16 +322,14 @@ class LvCommon(AutomatedProperties):
 					'V': 'thin Volume', 't': 'thin pool', 'T': 'Thin pool data',
 					'e': 'raid or pool metadata or pool metadata spare',
 					'-': 'Unspecified'}
-		return dbus.Struct((self.state.Attr[0], type_map[self.state.Attr[0]]),
-						signature="as")
+		return self.attr_struct(0, type_map)
 
 	@property
 	def Permissions(self):
 		type_map = {'w': 'writable', 'r': 'read-only',
 					'R': 'Read-only activation of non-read-only volume',
 					'-': 'Unspecified'}
-		return dbus.Struct((self.state.Attr[1], type_map[self.state.Attr[1]]),
-						signature="(ss)")
+		return self.attr_struct(1, type_map)
 
 	@property
 	def AllocationPolicy(self):
@@ -322,8 +338,7 @@ class LvCommon(AutomatedProperties):
 					'i': 'inherited', 'I': 'inherited locked',
 					'l': 'cling', 'L': 'cling locked',
 					'n': 'normal', 'N': 'normal locked', '-': 'Unspecified'}
-		return dbus.Struct((self.state.Attr[2], type_map[self.state.Attr[2]]),
-						signature="(ss)")
+		return self.attr_struct(2, type_map)
 
 	@property
 	def FixedMinor(self):
@@ -338,8 +353,7 @@ class LvCommon(AutomatedProperties):
 					'd': 'mapped device present without  tables',
 					'i': 'mapped device present with inactive table',
 					'X': 'unknown', '-': 'Unspecified'}
-		return dbus.Struct((self.state.Attr[4], type_map[self.state.Attr[4]]),
-						signature="(ss)")
+		return self.attr_struct(4, type_map)
 
 	@property
 	def TargetType(self):
@@ -358,8 +372,7 @@ class LvCommon(AutomatedProperties):
 		type_map = {'p': 'partial', 'r': 'refresh',
 					'm': 'mismatches', 'w': 'writemostly',
 					'X': 'X unknown', '-': 'Unspecified'}
-		return dbus.Struct((self.state.Attr[8], type_map[self.state.Attr[8]]),
-					signature="(ss)")
+		return self.attr_struct(8, type_map)
 
 	@property
 	def SkipActivation(self):


