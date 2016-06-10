From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:31 +0000 (UTC)
Subject: master - lvmdbusd: Rename get_object_path_by_lvm_id
Message-ID: <20160610210631.89E6160E5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b717e8fe1d926d6dd6e5a03354706351d90477d2
Commit:        b717e8fe1d926d6dd6e5a03354706351d90477d2
Parent:        41ebed707700e926d4224bc62289ea47014d9a0d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 10 12:03:04 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 15:28:42 2016 -0500

lvmdbusd: Rename get_object_path_by_lvm_id

Renaming to get_object_path_by_uuid_lvm_id, to clarify that both the uuid
and the lvm id are required.
---
 daemons/lvmdbusd/lv.py            |   12 ++++++------
 daemons/lvmdbusd/manager.py       |    4 ++--
 daemons/lvmdbusd/objectmanager.py |    6 +++---
 daemons/lvmdbusd/pv.py            |    8 ++++----
 daemons/lvmdbusd/vg.py            |    6 +++---
 5 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 2786f68..4638a31 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -100,7 +100,7 @@ class LvState(State):
 		rc = []
 		for pv in sorted(cfg.db.lv_contained_pv(uuid)):
 			(pv_uuid, pv_name, pv_segs) = pv
-			pv_obj = cfg.om.get_object_path_by_lvm_id(
+			pv_obj = cfg.om.get_object_path_by_uuid_lvm_id(
 				pv_uuid, pv_name, gen_new=False)
 			rc.append((pv_obj, pv_segs))
 
@@ -123,7 +123,7 @@ class LvState(State):
 
 		for l in cfg.db.hidden_lvs(self.Uuid):
 			full_name = "%s/%s" % (vg_name, l[1])
-			op = cfg.om.get_object_path_by_lvm_id(
+			op = cfg.om.get_object_path_by_uuid_lvm_id(
 				l[0], full_name, gen_new=False)
 			assert op
 			rc.append(op)
@@ -143,7 +143,7 @@ class LvState(State):
 		else:
 			self._segs.extend(set(segtypes))
 
-		self.Vg = cfg.om.get_object_path_by_lvm_id(
+		self.Vg = cfg.om.get_object_path_by_uuid_lvm_id(
 			vg_uuid, vg_name, vg_obj_path_generate)
 
 		self.Devices = LvState._pv_devices(self.Uuid)
@@ -151,7 +151,7 @@ class LvState(State):
 		if PoolLv:
 			gen = utils.lv_object_path_method(Name, (Attr, layout, role))
 
-			self.PoolLv = cfg.om.get_object_path_by_lvm_id(
+			self.PoolLv = cfg.om.get_object_path_by_uuid_lvm_id(
 				pool_lv_uuid, '%s/%s' % (vg_name, PoolLv),
 				gen)
 		else:
@@ -159,7 +159,7 @@ class LvState(State):
 
 		if OriginLv:
 			self.OriginLv = \
-				cfg.om.get_object_path_by_lvm_id(
+				cfg.om.get_object_path_by_uuid_lvm_id(
 					origin_uuid, '%s/%s' % (vg_name, OriginLv),
 					vg_obj_path_generate)
 		else:
@@ -192,7 +192,7 @@ class LvState(State):
 
 	def create_dbus_object(self, path):
 		if not path:
-			path = cfg.om.get_object_path_by_lvm_id(
+			path = cfg.om.get_object_path_by_uuid_lvm_id(
 				self.Uuid, self.lvm_id, self._object_path_create())
 
 		obj_ctor = self._object_type_create()
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index c728439..2388d8a 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -36,7 +36,7 @@ class Manager(AutomatedProperties):
 
 		# Check to see if we are already trying to create a PV for an existing
 		# PV
-		pv = cfg.om.get_object_path_by_lvm_id(
+		pv = cfg.om.get_object_path_by_uuid_lvm_id(
 			device, device, None, False)
 		if pv:
 			raise dbus.exceptions.DBusException(
@@ -159,7 +159,7 @@ class Manager(AutomatedProperties):
 		:param key: The lookup value
 		:return: Return the object path.  If object not found you will get '/'
 		"""
-		p = cfg.om.get_object_path_by_lvm_id(
+		p = cfg.om.get_object_path_by_uuid_lvm_id(
 			key, key, gen_new=False)
 		if p:
 			return p
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index f8f6d97..cd44480 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -173,7 +173,7 @@ class ObjectManager(AutomatedProperties):
 	def get_object_by_uuid_lvm_id(self, uuid, lvm_id):
 		with self.rlock:
 			return self.get_object_by_path(
-				self.get_object_path_by_lvm_id(uuid, lvm_id, None, False))
+				self.get_object_path_by_uuid_lvm_id(uuid, lvm_id, None, False))
 
 	def get_object_by_lvm_id(self, lvm_id):
 		"""
@@ -212,8 +212,8 @@ class ObjectManager(AutomatedProperties):
 		self._uuid_verify(path, uuid, lvm_identifier)
 		return path
 
-	def get_object_path_by_lvm_id(self, uuid, lvm_id, path_create=None,
-								gen_new=True):
+	def get_object_path_by_uuid_lvm_id(self, uuid, lvm_id, path_create=None,
+									   gen_new=True):
 		"""
 		For a given lvm asset return the dbus object registered to it.  If the
 		object is not found and gen_new == True and path_create is a valid
diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index 287825f..bbd76f1 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -65,7 +65,7 @@ class PvState(State):
 				full_name = "%s/%s" % (vg_name, lv_name)
 
 				path_create = lv_object_path_method(lv_name, meta)
-				lv_path = cfg.om.get_object_path_by_lvm_id(
+				lv_path = cfg.om.get_object_path_by_uuid_lvm_id(
 					lv_uuid, full_name, path_create)
 
 				rc.append((lv_path, segs))
@@ -83,7 +83,7 @@ class PvState(State):
 		self.lv = self._lv_object_list(vg_name)
 
 		if vg_name:
-			self.vg_path = cfg.om.get_object_path_by_lvm_id(
+			self.vg_path = cfg.om.get_object_path_by_uuid_lvm_id(
 				vg_uuid, vg_name, vg_obj_path_generate)
 		else:
 			self.vg_path = '/'
@@ -93,8 +93,8 @@ class PvState(State):
 
 	def create_dbus_object(self, path):
 		if not path:
-			path = cfg.om.get_object_path_by_lvm_id(self.Uuid, self.Name,
-													pv_obj_path_generate)
+			path = cfg.om.get_object_path_by_uuid_lvm_id(self.Uuid, self.Name,
+														pv_obj_path_generate)
 		return Pv(path, self)
 
 	# noinspection PyMethodMayBeStatic
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index f5b3e45..45b4030 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -66,7 +66,7 @@ class VgState(State):
 
 			gen = utils.lv_object_path_method(lv_name, meta)
 
-			lv_path = cfg.om.get_object_path_by_lvm_id(
+			lv_path = cfg.om.get_object_path_by_uuid_lvm_id(
 				lv_uuid, full_name, gen)
 			rc.append(lv_path)
 		return dbus.Array(rc, signature='o')
@@ -75,7 +75,7 @@ class VgState(State):
 		rc = []
 		for p in cfg.db.pvs_in_vg(self.Uuid):
 			(pv_name, pv_uuid) = p
-			rc.append(cfg.om.get_object_path_by_lvm_id(
+			rc.append(cfg.om.get_object_path_by_uuid_lvm_id(
 				pv_uuid, pv_name, pv_obj_path_generate))
 		return dbus.Array(rc, signature='o')
 
@@ -90,7 +90,7 @@ class VgState(State):
 
 	def create_dbus_object(self, path):
 		if not path:
-			path = cfg.om.get_object_path_by_lvm_id(
+			path = cfg.om.get_object_path_by_uuid_lvm_id(
 				self.Uuid, self.Name, vg_obj_path_generate)
 		return Vg(path, self)
 


