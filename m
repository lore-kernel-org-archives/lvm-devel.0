From: tasleson <tasleson@fedoraproject.org>
Date: Thu,  2 Feb 2017 16:59:18 +0000 (UTC)
Subject: master - lvmdbusd: lv.py, remove duplicate code
Message-ID: <20170202165918.BD36A6101E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83a19075861d86d7800e395f4c30f90dabc11692
Commit:        83a19075861d86d7800e395f4c30f90dabc11692
Parent:        2350ea0060cd729f36245df5622b38c4b8d9bb12
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Feb 1 15:38:55 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Feb 1 15:38:55 2017 -0600

lvmdbusd: lv.py, remove duplicate code

Move similar code to common functions, less is more!
---
 daemons/lvmdbusd/lv.py |  268 +++++++++++++++++-------------------------------
 1 files changed, 92 insertions(+), 176 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index fa54322..6c93e4d 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -272,6 +272,26 @@ class LvCommon(AutomatedProperties):
 		self.state = object_state
 		self._move_pv = self._get_move_pv()
 
+	@staticmethod
+	def handle_execute(rc, out, err):
+		if rc == 0:
+			cfg.load()
+		else:
+			# Need to work on error handling, need consistent
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'Exit code %s, stderr = %s' % (str(rc), err))
+
+	@staticmethod
+	def validate_dbus_object(lv_uuid, lv_name):
+		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+		if not dbo:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE,
+				'LV with uuid %s and name %s not present!' %
+				(lv_uuid, lv_name))
+		return dbo
+
 	@property
 	def VolumeType(self):
 		type_map = {'C': 'Cache', 'm': 'mirrored',
@@ -408,24 +428,10 @@ class Lv(LvCommon):
 	@staticmethod
 	def _remove(lv_uuid, lv_name, remove_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
-
-		if dbo:
-			# Remove the LV, if successful then remove from the model
-			rc, out, err = cmdhandler.lv_remove(lv_name, remove_options)
-
-			if rc == 0:
-				cfg.load()
-			else:
-				# Need to work on error handling, need consistent
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE,
-				'LV with uuid %s and name %s not present!' %
-				(lv_uuid, lv_name))
+		LvCommon.validate_dbus_object(lv_uuid, lv_name)
+		# Remove the LV, if successful then remove from the model
+		rc, out, err = cmdhandler.lv_remove(lv_name, remove_options)
+		LvCommon.handle_execute(rc, out, err)
 		return '/'
 
 	@dbus.service.method(
@@ -443,24 +449,11 @@ class Lv(LvCommon):
 	@staticmethod
 	def _rename(lv_uuid, lv_name, new_name, rename_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
-
-		if dbo:
-			# Rename the logical volume
-			rc, out, err = cmdhandler.lv_rename(lv_name, new_name,
-												rename_options)
-			if rc == 0:
-				cfg.load()
-			else:
-				# Need to work on error handling, need consistent
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE,
-				'LV with uuid %s and name %s not present!' %
-				(lv_uuid, lv_name))
+		LvCommon.validate_dbus_object(lv_uuid, lv_name)
+		# Rename the logical volume
+		rc, out, err = cmdhandler.lv_rename(lv_name, new_name,
+											rename_options)
+		LvCommon.handle_execute(rc, out, err)
 		return '/'
 
 	@dbus.service.method(
@@ -500,32 +493,21 @@ class Lv(LvCommon):
 	def _snap_shot(lv_uuid, lv_name, name, optional_size,
 			snapshot_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
+		# If you specify a size you get a 'thick' snapshot even if
+		# it is a thin lv
+		if not dbo.IsThinVolume:
+			if optional_size == 0:
+				space = dbo.SizeBytes / 80
+				remainder = space % 512
+				optional_size = space + 512 - remainder
+
+		rc, out, err = cmdhandler.vg_lv_snapshot(
+			lv_name, snapshot_options, name, optional_size)
+		LvCommon.handle_execute(rc, out, err)
+		full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
+		return cfg.om.get_object_path_by_lvm_id(full_name)
 
-		if dbo:
-			# If you specify a size you get a 'thick' snapshot even if
-			# it is a thin lv
-			if not dbo.IsThinVolume:
-				if optional_size == 0:
-					space = dbo.SizeBytes / 80
-					remainder = space % 512
-					optional_size = space + 512 - remainder
-
-			rc, out, err = cmdhandler.vg_lv_snapshot(
-				lv_name, snapshot_options, name, optional_size)
-			if rc == 0:
-				cfg.load()
-				full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
-				return cfg.om.get_object_path_by_lvm_id(full_name)
-			else:
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE,
-				'LV with uuid %s and name %s not present!' %
-				(lv_uuid, lv_name))
 
 	@dbus.service.method(
 		dbus_interface=LV_INTERFACE,
@@ -548,38 +530,24 @@ class Lv(LvCommon):
 				resize_options):
 		# Make sure we have a dbus object representing it
 		pv_dests = []
-		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
-
-		if dbo:
-			# If we have PVs, verify them
-			if len(pv_dests_and_ranges):
-				for pr in pv_dests_and_ranges:
-					pv_dbus_obj = cfg.om.get_object_by_path(pr[0])
-					if not pv_dbus_obj:
-						raise dbus.exceptions.DBusException(
-							LV_INTERFACE,
-							'PV Destination (%s) not found' % pr[0])
+		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
 
-					pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
+		# If we have PVs, verify them
+		if len(pv_dests_and_ranges):
+			for pr in pv_dests_and_ranges:
+				pv_dbus_obj = cfg.om.get_object_by_path(pr[0])
+				if not pv_dbus_obj:
+					raise dbus.exceptions.DBusException(
+						LV_INTERFACE,
+						'PV Destination (%s) not found' % pr[0])
 
-			size_change = new_size_bytes - dbo.SizeBytes
+				pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
 
-			rc, out, err = cmdhandler.lv_resize(dbo.lvm_id, size_change,
-												pv_dests, resize_options)
-
-			if rc == 0:
-				# Refresh what's changed
-				cfg.load()
-				return "/"
-			else:
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE,
-				'LV with uuid %s and name %s not present!' %
-				(lv_uuid, lv_name))
+		size_change = new_size_bytes - dbo.SizeBytes
+		rc, out, err = cmdhandler.lv_resize(dbo.lvm_id, size_change,
+											pv_dests, resize_options)
+		LvCommon.handle_execute(rc, out, err)
+		return "/"
 
 	@dbus.service.method(
 		dbus_interface=LV_INTERFACE,
@@ -612,23 +580,11 @@ class Lv(LvCommon):
 	def _lv_activate_deactivate(uuid, lv_name, activate, control_flags,
 								options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, lv_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.activate_deactivate(
-				'lvchange', lv_name, activate, control_flags, options)
-			if rc == 0:
-				cfg.load()
-				return '/'
-			else:
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE,
-				'LV with uuid %s and name %s not present!' %
-				(uuid, lv_name))
+		LvCommon.validate_dbus_object(uuid, lv_name)
+		rc, out, err = cmdhandler.activate_deactivate(
+			'lvchange', lv_name, activate, control_flags, options)
+		LvCommon.handle_execute(rc, out, err)
+		return '/'
 
 	@dbus.service.method(
 		dbus_interface=LV_INTERFACE,
@@ -660,25 +616,11 @@ class Lv(LvCommon):
 	@staticmethod
 	def _add_rm_tags(uuid, lv_name, tags_add, tags_del, tag_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, lv_name)
-
-		if dbo:
-
-			rc, out, err = cmdhandler.lv_tag(
-				lv_name, tags_add, tags_del, tag_options)
-			if rc == 0:
-				cfg.load()
-				return '/'
-			else:
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-
-		else:
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE,
-				'LV with uuid %s and name %s not present!' %
-				(uuid, lv_name))
+		LvCommon.validate_dbus_object(uuid, lv_name)
+		rc, out, err = cmdhandler.lv_tag(
+			lv_name, tags_add, tags_del, tag_options)
+		LvCommon.handle_execute(rc, out, err)
+		return '/'
 
 	@dbus.service.method(
 		dbus_interface=LV_INTERFACE,
@@ -736,24 +678,13 @@ class LvThinPool(Lv):
 	@staticmethod
 	def _lv_create(lv_uuid, lv_name, name, size_bytes, create_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
 
-		if dbo:
-			rc, out, err = cmdhandler.lv_lv_create(
-				lv_name, create_options, name, size_bytes)
-			if rc == 0:
-				full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
-				cfg.load()
-				return cfg.om.get_object_path_by_lvm_id(full_name)
-			else:
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE,
-				'LV with uuid %s and name %s not present!' %
-				(lv_uuid, lv_name))
+		rc, out, err = cmdhandler.lv_lv_create(
+			lv_name, create_options, name, size_bytes)
+		LvCommon.handle_execute(rc, out, err)
+		full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
+		return cfg.om.get_object_path_by_lvm_id(full_name)
 
 	@dbus.service.method(
 		dbus_interface=THIN_POOL_INTERFACE,
@@ -790,14 +721,13 @@ class LvCachePool(Lv):
 
 	@staticmethod
 	def _cache_lv(lv_uuid, lv_name, lv_object_path, cache_options):
-
 		# Make sure we have a dbus object representing cache pool
-		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
+		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
 
 		# Make sure we have dbus object representing lv to cache
 		lv_to_cache = cfg.om.get_object_by_path(lv_object_path)
 
-		if dbo and lv_to_cache:
+		if lv_to_cache:
 			fcn = lv_to_cache.lv_full_name()
 			rc, out, err = cmdhandler.lv_cache_lv(
 				dbo.lv_full_name(), fcn, cache_options)
@@ -809,22 +739,14 @@ class LvCachePool(Lv):
 				cfg.load()
 
 				lv_converted = cfg.om.get_object_path_by_lvm_id(fcn)
-
 			else:
 				raise dbus.exceptions.DBusException(
 					LV_INTERFACE,
 					'Exit code %s, stderr = %s' % (str(rc), err))
 		else:
-			msg = ""
-			if not dbo:
-				dbo += 'CachePool LV with uuid %s and name %s not present!' % \
-					(lv_uuid, lv_name)
-
-			if not lv_to_cache:
-				dbo += 'LV to cache with object path %s not present!' % \
-					(lv_object_path)
-
-			raise dbus.exceptions.DBusException(LV_INTERFACE, msg)
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE, 'LV to cache with object path %s not present!' %
+				lv_object_path)
 		return lv_converted
 
 	@dbus.service.method(
@@ -855,31 +777,25 @@ class LvCacheLv(Lv):
 	@staticmethod
 	def _detach_lv(lv_uuid, lv_name, detach_options, destroy_cache):
 		# Make sure we have a dbus object representing cache pool
-		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
-
-		if dbo:
+		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
 
-			# Get current cache name
-			cache_pool = cfg.om.get_object_by_path(dbo.CachePool)
+		# Get current cache name
+		cache_pool = cfg.om.get_object_by_path(dbo.CachePool)
 
-			rc, out, err = cmdhandler.lv_detach_cache(
-				dbo.lv_full_name(), detach_options, destroy_cache)
-			if rc == 0:
-				# The cache pool gets removed as hidden and put back to
-				# visible, so lets delete
-				mt_remove_dbus_objects((cache_pool, dbo))
-				cfg.load()
+		rc, out, err = cmdhandler.lv_detach_cache(
+			dbo.lv_full_name(), detach_options, destroy_cache)
+		if rc == 0:
+			# The cache pool gets removed as hidden and put back to
+			# visible, so lets delete
+			mt_remove_dbus_objects((cache_pool, dbo))
+			cfg.load()
 
-				uncached_lv_path = cfg.om.get_object_path_by_lvm_id(lv_name)
-			else:
-				raise dbus.exceptions.DBusException(
-					LV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
+			uncached_lv_path = cfg.om.get_object_path_by_lvm_id(lv_name)
 		else:
 			raise dbus.exceptions.DBusException(
 				LV_INTERFACE,
-				'LV with uuid %s and name %s not present!' %
-				(lv_uuid, lv_name))
+				'Exit code %s, stderr = %s' % (str(rc), err))
+
 		return uncached_lv_path
 
 	@dbus.service.method(


