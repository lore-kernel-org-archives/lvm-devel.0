From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 16 Jan 2019 17:33:03 -0500
Subject: master - lvmdbusd: Handle duplicate VG names
Message-ID: <201901162233.x0GMX3Gx027551@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f43b7bb46159d00a4eba56df92ad5e572fa2038c
Commit:        f43b7bb46159d00a4eba56df92ad5e572fa2038c
Parent:        b4c33829908015acc6ce0690ee5d33c1eb87e98e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Jan 16 15:41:27 2019 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Jan 16 16:29:05 2019 -0600

lvmdbusd: Handle duplicate VG names

Lvm can at times have duplicate names.  When this happens the daemon will
internally use vg_name:vg_uuid as the name for lookups, but display just
the vg_name externally.  If an API user uses the Manager.LookUpByLvmId and
queries the vg name they will only get returned one result as the API
can only accommodate returning 1.  The one returned is the first instance
found when sorting the volume groups by UUID.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1583510
---
 daemons/lvmdbusd/lvmdb.py.in |   30 ++++++++++++++++++++++++++----
 daemons/lvmdbusd/vg.py       |   21 ++++++++++++++++-----
 2 files changed, 42 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
index 13ee391..0155d90 100644
--- a/daemons/lvmdbusd/lvmdb.py.in
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -141,13 +141,22 @@ class DataStore(object):
 
 	@staticmethod
 	def _parse_vgs(_vgs):
-		vgs = sorted(_vgs, key=lambda vk: vk['vg_name'])
+		vgs = sorted(_vgs, key=lambda vk: vk['vg_uuid'])
 
 		c_vgs = OrderedDict()
 		c_lookup = {}
 
 		for i in vgs:
-			c_lookup[i['vg_name']] = i['vg_uuid']
+			vg_name = i['vg_name']
+
+			# Lvm allows duplicate vg names.  When this occurs, each subsequent
+			# matching VG name will be called vg_name:vg_uuid.  Note: ':' is an
+			# invalid character for lvm VG names
+			if vg_name in c_lookup:
+				vg_name = "%s:%s" % (vg_name, i['vg_uuid'])
+				i['vg_name'] = vg_name
+
+			c_lookup[vg_name] = i['vg_uuid']
 			DataStore._insert_record(c_vgs, i['vg_uuid'], i, [])
 
 		return c_vgs, c_lookup
@@ -162,13 +171,22 @@ class DataStore(object):
 				tmp_vg.extend(r['vg'])
 
 		# Sort for consistent output, however this is optional
-		vgs = sorted(tmp_vg, key=lambda vk: vk['vg_name'])
+		vgs = sorted(tmp_vg, key=lambda vk: vk['vg_uuid'])
 
 		c_vgs = OrderedDict()
 		c_lookup = {}
 
 		for i in vgs:
-			c_lookup[i['vg_name']] = i['vg_uuid']
+			vg_name = i['vg_name']
+
+			# Lvm allows duplicate vg names.  When this occurs, each subsequent
+			# matching VG name will be called vg_name:vg_uuid.  Note: ':' is an
+			# invalid character for lvm VG names
+			if vg_name in c_lookup:
+				vg_name = "%s:%s" % (vg_name, i['vg_uuid'])
+				i['vg_name'] = vg_name
+
+			c_lookup[vg_name] = i['vg_uuid']
 			c_vgs[i['vg_uuid']] = i
 
 		return c_vgs, c_lookup
@@ -521,6 +539,10 @@ if __name__ == "__main__":
 	for v in ds.vgs.values():
 		pp.pprint(v)
 
+	print("VG name to UUID")
+	for k, v in ds.vg_name_to_uuid.items():
+		print("%s: %s" % (k, v))
+
 	print("LVS")
 	for v in ds.lvs.values():
 		pp.pprint(v)
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index b9a23c2..64ad0f0 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -52,18 +52,23 @@ def load_vgs(vg_specific=None, object_path=None, refresh=False,
 
 # noinspection PyPep8Naming,PyUnresolvedReferences,PyUnusedLocal
 class VgState(State):
+
 	@property
-	def lvm_id(self):
+	def internal_name(self):
 		return self.Name
 
+	@property
+	def lvm_id(self):
+		return self.internal_name
+
 	def identifiers(self):
-		return (self.Uuid, self.Name)
+		return (self.Uuid, self.internal_name)
 
 	def _lv_paths_build(self):
 		rc = []
 		for lv in cfg.db.lvs_in_vg(self.Uuid):
 			(lv_name, meta, lv_uuid) = lv
-			full_name = "%s/%s" % (self.Name, lv_name)
+			full_name = "%s/%s" % (self.internal_name, lv_name)
 
 			gen = utils.lv_object_path_method(lv_name, meta)
 
@@ -92,7 +97,7 @@ class VgState(State):
 	def create_dbus_object(self, path):
 		if not path:
 			path = cfg.om.get_object_path_by_uuid_lvm_id(
-				self.Uuid, self.Name, vg_obj_path_generate)
+				self.Uuid, self.internal_name, vg_obj_path_generate)
 		return Vg(path, self)
 
 	# noinspection PyMethodMayBeStatic
@@ -102,7 +107,6 @@ class VgState(State):
 
 # noinspection PyPep8Naming
 @utils.dbus_property(VG_INTERFACE, 'Uuid', 's')
- at utils.dbus_property(VG_INTERFACE, 'Name', 's')
 @utils.dbus_property(VG_INTERFACE, 'Fmt', 's')
 @utils.dbus_property(VG_INTERFACE, 'SizeBytes', 't', 0)
 @utils.dbus_property(VG_INTERFACE, 'FreeBytes', 't', 0)
@@ -135,6 +139,7 @@ class Vg(AutomatedProperties):
 	_AllocNormal_meta = ('b', VG_INTERFACE)
 	_AllocAnywhere_meta = ('b', VG_INTERFACE)
 	_Clustered_meta = ('b', VG_INTERFACE)
+	_Name_meta = ('s', VG_INTERFACE)
 
 	# noinspection PyUnusedLocal,PyPep8Naming
 	def __init__(self, object_path, object_state):
@@ -730,6 +735,12 @@ class Vg(AutomatedProperties):
 		cfg.worker_q.put(r)
 
 	@property
+	def Name(self):
+		if ':' in self.state.Name:
+			return self.state.Name.split(':')[0]
+		return self.state.Name
+
+	@property
 	def Tags(self):
 		return utils.parse_tags(self.state.tags)
 


