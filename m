From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:40 +0000 (UTC)
Subject: master - lvmdbusd: Be more explicit on return values
Message-ID: <20160829202840.B0272618DE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2bb09b4015ec85bb11b68a52e326a01ce3c8f98f
Commit:        2bb09b4015ec85bb11b68a52e326a01ce3c8f98f
Parent:        4902034c895d26423564175c0636cff8ba4112e1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 24 18:31:15 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:55 2016 -0500

lvmdbusd: Be more explicit on return values

The python dbus library tries to make best on what the dbus type is based on
python data type.  Some times it gets this wrong, so we will be explicit.
---
 daemons/lvmdbusd/job.py     |    8 ++++----
 daemons/lvmdbusd/lv.py      |   40 +++++++++++++++++++++++-----------------
 daemons/lvmdbusd/manager.py |    4 ++--
 daemons/lvmdbusd/pv.py      |   22 ++++++++--------------
 daemons/lvmdbusd/utils.py   |    2 +-
 daemons/lvmdbusd/vg.py      |   10 ++++------
 6 files changed, 42 insertions(+), 44 deletions(-)

diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index 520f9a8..7299583 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -121,7 +121,7 @@ class Job(AutomatedProperties):
 
 	@property
 	def Percent(self):
-		return self.state.Percent
+		return dbus.Byte(int(self.state.Percent))
 
 	@Percent.setter
 	def Percent(self, value):
@@ -129,7 +129,7 @@ class Job(AutomatedProperties):
 
 	@property
 	def Complete(self):
-		return self.state.Complete
+		return dbus.Boolean(self.state.Complete)
 
 	@Complete.setter
 	def Complete(self, value):
@@ -137,7 +137,7 @@ class Job(AutomatedProperties):
 
 	@property
 	def GetError(self):
-		return self.state.GetError
+		return dbus.Struct(self.state.GetError, signature="(is)")
 
 	def set_result(self, ec, msg):
 		self.state.set_result(ec, msg)
@@ -160,7 +160,7 @@ class Job(AutomatedProperties):
 
 	@property
 	def Result(self):
-		return self.state.Result
+		return dbus.ObjectPath(self.state.Result)
 
 	@property
 	def lvm_id(self):
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 5658d29..6d994ac 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -252,14 +252,16 @@ class LvCommon(AutomatedProperties):
 					'V': 'thin Volume', 't': 'thin pool', 'T': 'Thin pool data',
 					'e': 'raid or pool metadata or pool metadata spare',
 					'-': 'Unspecified'}
-		return (self.state.Attr[0], type_map[self.state.Attr[0]])
+		return dbus.Struct((self.state.Attr[0], type_map[self.state.Attr[0]]),
+						   signature="as")
 
 	@property
 	def Permissions(self):
 		type_map = {'w': 'writable', 'r': 'read-only',
 					'R': 'Read-only activation of non-read-only volume',
 					'-': 'Unspecified'}
-		return (self.state.Attr[1], type_map[self.state.Attr[1]])
+		return dbus.Struct((self.state.Attr[1], type_map[self.state.Attr[1]]),
+						   signature="(ss)")
 
 	@property
 	def AllocationPolicy(self):
@@ -268,11 +270,12 @@ class LvCommon(AutomatedProperties):
 					'i': 'inherited', 'I': 'inherited locked',
 					'l': 'cling', 'L': 'cling locked',
 					'n': 'normal', 'N': 'normal locked', '-': 'Unspecified'}
-		return (self.state.Attr[2], type_map[self.state.Attr[2]])
+		return dbus.Struct((self.state.Attr[2], type_map[self.state.Attr[2]]),
+						   signature="(ss)")
 
 	@property
 	def FixedMinor(self):
-		return self.state.Attr[3] == 'm'
+		return dbus.Boolean(self.state.Attr[3] == 'm')
 
 	@property
 	def State(self):
@@ -283,29 +286,32 @@ class LvCommon(AutomatedProperties):
 					'd': 'mapped device present without  tables',
 					'i': 'mapped device present with inactive table',
 					'X': 'unknown', '-': 'Unspecified'}
-		return (self.state.Attr[4], type_map[self.state.Attr[4]])
+		return dbus.Struct((self.state.Attr[4], type_map[self.state.Attr[4]]),
+						   signature="(ss)")
 
 	@property
 	def TargetType(self):
 		type_map = {'C': 'Cache', 'm': 'mirror', 'r': 'raid',
 					's': 'snapshot', 't': 'thin', 'u': 'unknown',
 					'v': 'virtual', '-': 'Unspecified'}
-		return (self.state.Attr[6], type_map[self.state.Attr[6]])
+		return dbus.Struct((self.state.Attr[6], type_map[self.state.Attr[6]]),
+						   signature="(ss)")
 
 	@property
 	def ZeroBlocks(self):
-		return self.state.Attr[7] == 'z'
+		return dbus.Boolean(self.state.Attr[7] == 'z')
 
 	@property
 	def Health(self):
 		type_map = {'p': 'partial', 'r': 'refresh',
 					'm': 'mismatches', 'w': 'writemostly',
 					'X': 'X unknown', '-': 'Unspecified'}
-		return (self.state.Attr[8], type_map[self.state.Attr[8]])
+		return dbus.Struct((self.state.Attr[8], type_map[self.state.Attr[8]]),
+						   signature="(ss)")
 
 	@property
 	def SkipActivation(self):
-		return self.state.Attr[9] == 'k'
+		return dbus.Boolean(self.state.Attr[9] == 'k')
 
 	def vg_name_lookup(self):
 		return self.state.vg_name_lookup()
@@ -331,15 +337,15 @@ class LvCommon(AutomatedProperties):
 
 	@property
 	def IsThinVolume(self):
-		return self.state.Attr[0] == 'V'
+		return dbus.Boolean(self.state.Attr[0] == 'V')
 
 	@property
 	def IsThinPool(self):
-		return self.state.Attr[0] == 't'
+		return dbus.Boolean(self.state.Attr[0] == 't')
 
 	@property
 	def Active(self):
-		return self.state.active == "active"
+		return dbus.Boolean(self.state.active == "active")
 
 	@dbus.service.method(
 		dbus_interface=LV_COMMON_INTERFACE,
@@ -698,11 +704,11 @@ class LvThinPool(Lv):
 
 	@property
 	def DataLv(self):
-		return self._data_lv
+		return dbus.ObjectPath(self._data_lv)
 
 	@property
 	def MetaDataLv(self):
-		return self._metadata_lv
+		return dbus.ObjectPath(self._metadata_lv)
 
 	@staticmethod
 	def _lv_create(lv_uuid, lv_name, name, size_bytes, create_options):
@@ -757,11 +763,11 @@ class LvCachePool(Lv):
 
 	@property
 	def DataLv(self):
-		return self._data_lv
+		return dbus.ObjectPath(self._data_lv)
 
 	@property
 	def MetaDataLv(self):
-		return self._metadata_lv
+		return dbus.ObjectPath(self._metadata_lv)
 
 	@staticmethod
 	def _cache_lv(lv_uuid, lv_name, lv_object_path, cache_options):
@@ -826,7 +832,7 @@ class LvCacheLv(Lv):
 
 	@property
 	def CachePool(self):
-		return self.state.PoolLv
+		return dbus.ObjectPath(self.state.PoolLv)
 
 	@staticmethod
 	def _detach_lv(lv_uuid, lv_name, detach_options, destroy_cache):
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 79254fe..e0da824 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -21,7 +21,7 @@ from . import udevwatch
 
 # noinspection PyPep8Naming
 class Manager(AutomatedProperties):
-	_Version_meta = ("t", MANAGER_INTERFACE)
+	_Version_meta = ("s", MANAGER_INTERFACE)
 
 	def __init__(self, object_path):
 		super(Manager, self).__init__(object_path)
@@ -29,7 +29,7 @@ class Manager(AutomatedProperties):
 
 	@property
 	def Version(self):
-		return '1.0.0'
+		return dbus.String('1.0.0')
 
 	@staticmethod
 	def _pv_create(device, create_options):
diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index bbd76f1..0780179 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -69,7 +69,7 @@ class PvState(State):
 					lv_uuid, full_name, path_create)
 
 				rc.append((lv_path, segs))
-		return dbus.Array(rc, signature="(oa(tts))")
+		return rc
 
 	# noinspection PyUnusedLocal,PyPep8Naming
 	def __init__(self, lvm_path, Uuid, Name,
@@ -241,26 +241,20 @@ class Pv(AutomatedProperties):
 	@property
 	def PeSegments(self):
 		if len(self.state.pe_segments):
-			return self.state.pe_segments
-		return dbus.Array([], '(tt)')
+			return dbus.Array(self.state.pe_segments, signature='(tt)')
+		return dbus.Array([], 'a(tt)')
 
 	@property
 	def Exportable(self):
-		if self.state.attr[1] == 'x':
-			return True
-		return False
+		return dbus.Boolean(self.state.attr[1] == 'x')
 
 	@property
 	def Allocatable(self):
-		if self.state.attr[0] == 'a':
-			return True
-		return False
+		return dbus.Boolean(self.state.attr[0] == 'a')
 
 	@property
 	def Missing(self):
-		if self.state.attr[2] == 'm':
-			return True
-		return False
+		return dbus.Boolean(self.state.attr[2] == 'm')
 
 	def object_path(self):
 		return self._object_path
@@ -275,8 +269,8 @@ class Pv(AutomatedProperties):
 
 	@property
 	def Lv(self):
-		return self.state.lv
+		return dbus.Array(self.state.lv, signature="(oa(tts))")
 
 	@property
 	def Vg(self):
-		return self.state.vg_path
+		return dbus.ObjectPath(self.state.vg_path)
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 65668fc..c80290f 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -236,7 +236,7 @@ def parse_tags(tags):
 	if len(tags):
 		if ',' in tags:
 			return tags.split(',')
-		return sorted([tags])
+		return dbus.Array(sorted([tags]), signature='s')
 	return dbus.Array([], signature='s')
 
 
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 4cc938e..3b35873 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -78,7 +78,7 @@ class VgState(State):
 			(pv_name, pv_uuid) = p
 			rc.append(cfg.om.get_object_path_by_uuid_lvm_id(
 				pv_uuid, pv_name, pv_obj_path_generate))
-		return dbus.Array(rc, signature='o')
+		return rc
 
 	def __init__(self, Uuid, Name, Fmt,
 			SizeBytes, FreeBytes, SysId, ExtentSizeBytes,
@@ -840,9 +840,7 @@ class Vg(AutomatedProperties):
 		cfg.worker_q.put(r)
 
 	def _attribute(self, pos, ch):
-		if self.state.attr[pos] == ch:
-			return True
-		return False
+		return dbus.Boolean(self.state.attr[pos] == ch)
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -908,11 +906,11 @@ class Vg(AutomatedProperties):
 
 	@property
 	def Pvs(self):
-		return self.state.Pvs
+		return dbus.Array(self.state.Pvs, signature='o')
 
 	@property
 	def Lvs(self):
-		return self.state.Lvs
+		return dbus.Array(self.state.Lvs, signature='o')
 
 	@property
 	def lvm_id(self):


