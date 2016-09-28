From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 28 Sep 2016 17:08:51 +0000 (UTC)
Subject: master - lvmdbusd: Remove extraneous parameter
Message-ID: <20160928170851.C1F3360640@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be5eb995d356610b0748b05b65f74c34934526e4
Commit:        be5eb995d356610b0748b05b65f74c34934526e4
Parent:        a93616cf66b15591f741dc5f1450c12bc34b3785
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Sep 28 11:16:49 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Sep 28 12:05:44 2016 -0500

lvmdbusd: Remove extraneous parameter

Remove 'gen_new' parameter as it's not needed, correct documentation.
---
 daemons/lvmdbusd/lv.py            |    9 +++------
 daemons/lvmdbusd/manager.py       |    6 ++----
 daemons/lvmdbusd/objectmanager.py |   30 +++++++++++++++++-------------
 3 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 455f371..2a8a3fb 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -101,8 +101,7 @@ class LvState(State):
 		rc = []
 		for pv in sorted(cfg.db.lv_contained_pv(uuid)):
 			(pv_uuid, pv_name, pv_segs) = pv
-			pv_obj = cfg.om.get_object_path_by_uuid_lvm_id(
-				pv_uuid, pv_name, gen_new=False)
+			pv_obj = cfg.om.get_object_path_by_uuid_lvm_id(pv_uuid, pv_name)
 
 			segs_decorate = []
 			for i in pv_segs:
@@ -131,8 +130,7 @@ class LvState(State):
 
 		for l in cfg.db.hidden_lvs(self.Uuid):
 			full_name = "%s/%s" % (vg_name, l[1])
-			op = cfg.om.get_object_path_by_uuid_lvm_id(
-				l[0], full_name, gen_new=False)
+			op = cfg.om.get_object_path_by_uuid_lvm_id(l[0], full_name)
 			assert op
 			rc.append(dbus.ObjectPath(op))
 		return rc
@@ -160,8 +158,7 @@ class LvState(State):
 			gen = utils.lv_object_path_method(Name, (Attr, layout, role))
 
 			self.PoolLv = cfg.om.get_object_path_by_uuid_lvm_id(
-				pool_lv_uuid, '%s/%s' % (vg_name, PoolLv),
-				gen)
+				pool_lv_uuid, '%s/%s' % (vg_name, PoolLv), gen)
 		else:
 			self.PoolLv = '/'
 
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 0a5fe73..e377442 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -37,8 +37,7 @@ class Manager(AutomatedProperties):
 
 		# Check to see if we are already trying to create a PV for an existing
 		# PV
-		pv = cfg.om.get_object_path_by_uuid_lvm_id(
-			device, device, None, False)
+		pv = cfg.om.get_object_path_by_uuid_lvm_id(device, device)
 		if pv:
 			raise dbus.exceptions.DBusException(
 				MANAGER_INTERFACE, "PV Already exists!")
@@ -164,8 +163,7 @@ class Manager(AutomatedProperties):
 		:param key: The lookup value
 		:return: Return the object path.  If object not found you will get '/'
 		"""
-		p = cfg.om.get_object_path_by_uuid_lvm_id(
-			key, key, gen_new=False)
+		p = cfg.om.get_object_path_by_uuid_lvm_id(key, key)
 		if p:
 			return p
 		return '/'
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index d55ca99..3284e1c 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -209,7 +209,7 @@ class ObjectManager(AutomatedProperties):
 	def get_object_by_uuid_lvm_id(self, uuid, lvm_id):
 		with self.rlock:
 			return self.get_object_by_path(
-				self.get_object_path_by_uuid_lvm_id(uuid, lvm_id, None, False))
+				self.get_object_path_by_uuid_lvm_id(uuid, lvm_id))
 
 	def get_object_by_lvm_id(self, lvm_id):
 		"""
@@ -289,23 +289,27 @@ class ObjectManager(AutomatedProperties):
 							path = self._id_to_object_path[int_lvm_id]
 		return path
 
-	def get_object_path_by_uuid_lvm_id(self, uuid, lvm_id, path_create=None,
-										gen_new=True):
+	def get_object_path_by_uuid_lvm_id(self, uuid, lvm_id, path_create=None):
 		"""
-		For a given lvm asset return the dbus object registered to it.  If the
-		object is not found and gen_new == True and path_create is a valid
-		function we will create a new path, register it and return it.
-		:param uuid: The uuid for the lvm object
-		:param lvm_id: The lvm name
-		:param path_create: If true create an object path if not found
-		:param gen_new: The function used to create the new path
+		For a given lvm asset return the dbus object path registered for it.
+		This method first looks up by uuid and then by lvm_id.  You
+		can search by just one by setting uuid == lvm_id (uuid or lvm_id).
+		If the object is not found and path_create is a not None, the
+		path_create function will be called to create a new object path and
+		register it with the object manager for the specified uuid & lvm_id.
+		Note: If path create is not None, uuid and lvm_id cannot be equal
+		:param uuid: The uuid for the lvm object we are searching for
+		:param lvm_id: The lvm name (eg. pv device path, vg name, lv full name)
+		:param path_create: If not None, create the path using this function if
+				we fail to find the object by uuid or lvm_id.
+		:returns None if lvm asset not found and path_create == None otherwise
+				a valid dbus object path
 		"""
 		with self.rlock:
 			assert lvm_id
 			assert uuid
 
-			if gen_new:
-				assert path_create
+			if path_create:
 				assert uuid != lvm_id
 
 			# Check for Manager.LookUpByLvmId query, we cannot
@@ -335,7 +339,7 @@ class ObjectManager(AutomatedProperties):
 						self._uuid_verify(path, uuid, lvm_id)
 					else:
 						# We have exhausted all lookups, let's create if we can
-						if gen_new:
+						if path_create:
 							path = path_create()
 							self._lookup_add(None, path, lvm_id, uuid)
 


