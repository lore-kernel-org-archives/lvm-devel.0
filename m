From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:33 +0000 (UTC)
Subject: master - lvmdbusd: Add method get_object_path_by_lvm_id
Message-ID: <20160610210633.9A4E660E5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b81186e535f0c93ef8b276cfb2b7bcf55268aec0
Commit:        b81186e535f0c93ef8b276cfb2b7bcf55268aec0
Parent:        b717e8fe1d926d6dd6e5a03354706351d90477d2
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 10 12:05:52 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 16:04:43 2016 -0500

lvmdbusd: Add method get_object_path_by_lvm_id

The object manager method get_object_by_lvm_id was used in many cases for
the sole reason of getting the object path for the object.  Instead of
retrieving the object and then calling 'dbus_object_path' on the object, we
are adding a method which returns the object path.
---
 daemons/lvmdbusd/lv.py            |   14 +++-----------
 daemons/lvmdbusd/objectmanager.py |   11 +++++++++++
 daemons/lvmdbusd/vg.py            |    7 +------
 3 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 4638a31..e32f8e5 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -354,12 +354,7 @@ class Lv(LvCommon):
 
 		# The name is vg/name
 		full_name = "%s/%s" % (self.vg_name_lookup(), name)
-
-		o = cfg.om.get_object_by_lvm_id(full_name)
-		if o:
-			return o.dbus_object_path()
-
-		return '/'
+		return cfg.om.get_object_path_by_lvm_id(full_name)
 
 	def _get_data_meta(self):
 
@@ -783,8 +778,7 @@ class LvCachePool(Lv):
 				cfg.om.remove_object(lv_to_cache, emit_signal=True)
 				cfg.load()
 
-				lv_converted = \
-					cfg.om.get_object_by_lvm_id(fcn).dbus_object_path()
+				lv_converted = cfg.om.get_object_path_by_lvm_id(fcn)
 
 			else:
 				raise dbus.exceptions.DBusException(
@@ -847,9 +841,7 @@ class LvCacheLv(Lv):
 				cfg.om.remove_object(dbo, emit_signal=True)
 				cfg.load()
 
-				uncached_lv_path = \
-					cfg.om.get_object_by_lvm_id(lv_name).dbus_object_path()
-
+				uncached_lv_path = cfg.om.get_object_path_by_lvm_id(lv_name)
 			else:
 				raise dbus.exceptions.DBusException(
 					LV_INTERFACE,
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index cd44480..c93f207 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -185,6 +185,17 @@ class ObjectManager(AutomatedProperties):
 				return self.get_object_by_path(self._id_to_object_path[lvm_id])
 			return None
 
+	def get_object_path_by_lvm_id(self, lvm_id):
+		"""
+		Given an lvm identifier, return the object path for it
+		:param lvm_id: The lvm identifier
+		:return: Object path or '/' if not found
+		"""
+		with self.rlock:
+			if lvm_id in self._id_to_object_path:
+				return self._id_to_object_path[lvm_id]
+			return '/'
+
 	def _uuid_verify(self, path, uuid, lvm_id):
 		"""
 		Ensure uuid is present for a successful lvm_id lookup
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 45b4030..c700667 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -144,13 +144,8 @@ class Vg(AutomatedProperties):
 
 	@staticmethod
 	def fetch_new_lv(vg_name, lv_name):
-		full_name = "%s/%s" % (vg_name, lv_name)
-
 		cfg.load()
-		l = cfg.om.get_object_by_lvm_id(full_name)
-		created_lv = l.dbus_object_path()
-
-		return created_lv
+		return cfg.om.get_object_by_lvm_id("%s/%s" % (vg_name, lv_name))
 
 	@staticmethod
 	def _rename(uuid, vg_name, new_name, rename_options):


