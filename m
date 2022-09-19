From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:30 +0000 (GMT)
Subject: main - lvmdbusd: Remove duplicate code
Message-ID: <20220919155830.CCFB6385828C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e977b70bfb0a26a8dd5cd06d581cb810e2a6f10b
Commit:        e977b70bfb0a26a8dd5cd06d581cb810e2a6f10b
Parent:        f4c03faa6556489444cf9402b2a35c46e7282ed3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 31 15:42:48 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Remove duplicate code

The logic for _cache_lv and _writecache_lv was identical except for which
underlying lvm command to run.  Factor out common.
---
 daemons/lvmdbusd/lv.py | 40 ++++++++++------------------------------
 1 file changed, 10 insertions(+), 30 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 134843346..5dd698e29 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -751,7 +751,7 @@ class Lv(LvCommon):
 		cfg.worker_q.put(r)
 
 	@staticmethod
-	def _writecache_lv(lv_uuid, lv_name, lv_object_path, cache_options):
+	def _caching_common(method, lv_uuid, lv_name, lv_object_path, cache_options):
 		# Make sure we have a dbus object representing it
 		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
 
@@ -760,7 +760,7 @@ class Lv(LvCommon):
 
 		if lv_to_cache:
 			fcn = lv_to_cache.lv_full_name()
-			rc, out, err = cmdhandler.lv_writecache_lv(
+			rc, out, err = method(
 				dbo.lv_full_name(), fcn, cache_options)
 			if rc == 0:
 				# When we cache an LV, the cache pool and the lv that is getting
@@ -777,9 +777,14 @@ class Lv(LvCommon):
 		else:
 			raise dbus.exceptions.DBusException(
 				LV_INTERFACE, 'LV to cache with object path %s not present!' %
-				lv_object_path)
+							  lv_object_path)
 		return lv_converted
 
+	@staticmethod
+	def _writecache_lv(lv_uuid, lv_name, lv_object_path, cache_options):
+		return Lv._caching_common(cmdhandler.lv_writecache_lv, lv_uuid,
+									lv_name, lv_object_path, cache_options)
+
 	@dbus.service.method(
 		dbus_interface=LV_INTERFACE,
 		in_signature='oia{sv}',
@@ -959,33 +964,8 @@ class LvCachePool(Lv):
 
 	@staticmethod
 	def _cache_lv(lv_uuid, lv_name, lv_object_path, cache_options):
-		# Make sure we have a dbus object representing cache pool
-		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
-
-		# Make sure we have dbus object representing lv to cache
-		lv_to_cache = cfg.om.get_object_by_path(lv_object_path)
-
-		if lv_to_cache:
-			fcn = lv_to_cache.lv_full_name()
-			rc, out, err = cmdhandler.lv_cache_lv(
-				dbo.lv_full_name(), fcn, cache_options)
-			if rc == 0:
-				# When we cache an LV, the cache pool and the lv that is getting
-				# cached need to be removed from the object manager and
-				# re-created as their interfaces have changed!
-				mt_remove_dbus_objects((dbo, lv_to_cache))
-				cfg.load()
-
-				lv_converted = cfg.om.get_object_path_by_lvm_id(fcn)
-			else:
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE, 'LV to cache with object path %s not present!' %
-				lv_object_path)
-		return lv_converted
+		return Lv._caching_common(cmdhandler.lv_cache_lv, lv_uuid, lv_name,
+									lv_object_path, cache_options)
 
 	@dbus.service.method(
 		dbus_interface=CACHE_POOL_INTERFACE,

