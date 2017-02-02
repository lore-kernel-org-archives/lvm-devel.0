From: tasleson <tasleson@fedoraproject.org>
Date: Thu,  2 Feb 2017 16:59:20 +0000 (UTC)
Subject: master - lvmdbusd: vg.py, remove duplicate code
Message-ID: <20170202165920.CFB466024A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a010cede6e69fcb9301d0b1f4e282a2b04d15430
Commit:        a010cede6e69fcb9301d0b1f4e282a2b04d15430
Parent:        83a19075861d86d7800e395f4c30f90dabc11692
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Feb 1 16:37:03 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Feb 1 16:37:03 2017 -0600

lvmdbusd: vg.py, remove duplicate code

Move similar code to common functions, less is more!
---
 daemons/lvmdbusd/vg.py |  418 +++++++++++++++---------------------------------
 1 files changed, 128 insertions(+), 290 deletions(-)

diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 9b1df4e..c00084d 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -145,29 +145,35 @@ class Vg(AutomatedProperties):
 
 	@staticmethod
 	def fetch_new_lv(vg_name, lv_name):
-		cfg.load()
 		return cfg.om.get_object_path_by_lvm_id("%s/%s" % (vg_name, lv_name))
 
 	@staticmethod
-	def _rename(uuid, vg_name, new_name, rename_options):
-		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.vg_rename(vg_name, new_name,
-												rename_options)
-			if rc == 0:
-				cfg.load()
-			else:
-				# Need to work on error handling, need consistent
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
+	def handle_execute(rc, out, err):
+		if rc == 0:
+			cfg.load()
 		else:
+			# Need to work on error handling, need consistent
+			raise dbus.exceptions.DBusException(
+				VG_INTERFACE,
+				'Exit code %s, stderr = %s' % (str(rc), err))
+
+	@staticmethod
+	def validate_dbus_object(vg_uuid, vg_name):
+		dbo = cfg.om.get_object_by_uuid_lvm_id(vg_uuid, vg_name)
+		if not dbo:
 			raise dbus.exceptions.DBusException(
 				VG_INTERFACE,
 				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+				(vg_uuid, vg_name))
+		return dbo
+
+	@staticmethod
+	def _rename(uuid, vg_name, new_name, rename_options):
+		# Make sure we have a dbus object representing it
+		Vg.validate_dbus_object(uuid, vg_name)
+		rc, out, err = cmdhandler.vg_rename(
+			vg_name, new_name, rename_options)
+		Vg.handle_execute(rc, out, err)
 		return '/'
 
 	@dbus.service.method(
@@ -184,24 +190,10 @@ class Vg(AutomatedProperties):
 	@staticmethod
 	def _remove(uuid, vg_name, remove_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			# Remove the VG, if successful then remove from the model
-			rc, out, err = cmdhandler.vg_remove(vg_name, remove_options)
-
-			if rc == 0:
-				cfg.load()
-			else:
-				# Need to work on error handling, need consistent
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		Vg.validate_dbus_object(uuid, vg_name)
+		# Remove the VG, if successful then remove from the model
+		rc, out, err = cmdhandler.vg_remove(vg_name, remove_options)
+		Vg.handle_execute(rc, out, err)
 		return '/'
 
 	@dbus.service.method(
@@ -216,26 +208,9 @@ class Vg(AutomatedProperties):
 
 	@staticmethod
 	def _change(uuid, vg_name, change_options):
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.vg_change(change_options, vg_name)
-
-			# To use an example with d-feet (Method input)
-			# {"activate": __import__('gi.repository.GLib', globals(),
-			# locals(), ['Variant']).Variant("s", "n")}
-
-			if rc == 0:
-				cfg.load()
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		Vg.validate_dbus_object(uuid, vg_name)
+		rc, out, err = cmdhandler.vg_change(change_options, vg_name)
+		Vg.handle_execute(rc, out, err)
 		return '/'
 
 	# TODO: This should be broken into a number of different methods
@@ -256,34 +231,24 @@ class Vg(AutomatedProperties):
 	@staticmethod
 	def _reduce(uuid, vg_name, missing, pv_object_paths, reduce_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			pv_devices = []
-
-			# If pv_object_paths is not empty, then get the device paths
-			if pv_object_paths and len(pv_object_paths) > 0:
-				for pv_op in pv_object_paths:
-					pv = cfg.om.get_object_by_path(pv_op)
-					if pv:
-						pv_devices.append(pv.lvm_id)
-					else:
-						raise dbus.exceptions.DBusException(
-							VG_INTERFACE,
-							'PV Object path not found = %s!' % pv_op)
-
-			rc, out, err = cmdhandler.vg_reduce(vg_name, missing, pv_devices,
-												reduce_options)
-			if rc == 0:
-				cfg.load()
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE, 'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		Vg.validate_dbus_object(uuid, vg_name)
+
+		pv_devices = []
+
+		# If pv_object_paths is not empty, then get the device paths
+		if pv_object_paths and len(pv_object_paths) > 0:
+			for pv_op in pv_object_paths:
+				pv = cfg.om.get_object_by_path(pv_op)
+				if pv:
+					pv_devices.append(pv.lvm_id)
+				else:
+					raise dbus.exceptions.DBusException(
+						VG_INTERFACE,
+						'PV Object path not found = %s!' % pv_op)
+
+		rc, out, err = cmdhandler.vg_reduce(vg_name, missing, pv_devices,
+											reduce_options)
+		Vg.handle_execute(rc, out, err)
 		return '/'
 
 	@dbus.service.method(
@@ -300,36 +265,26 @@ class Vg(AutomatedProperties):
 	@staticmethod
 	def _extend(uuid, vg_name, pv_object_paths, extend_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			extend_devices = []
+		Vg.validate_dbus_object(uuid, vg_name)
 
-			for i in pv_object_paths:
-				pv = cfg.om.get_object_by_path(i)
-				if pv:
-					extend_devices.append(pv.lvm_id)
-				else:
-					raise dbus.exceptions.DBusException(
-						VG_INTERFACE, 'PV Object path not found = %s!' % i)
+		extend_devices = []
 
-			if len(extend_devices):
-				rc, out, err = cmdhandler.vg_extend(vg_name, extend_devices,
-													extend_options)
-				if rc == 0:
-					cfg.load()
-				else:
-					raise dbus.exceptions.DBusException(
-						VG_INTERFACE,
-						'Exit code %s, stderr = %s' % (str(rc), err))
+		for i in pv_object_paths:
+			pv = cfg.om.get_object_by_path(i)
+			if pv:
+				extend_devices.append(pv.lvm_id)
 			else:
 				raise dbus.exceptions.DBusException(
-					VG_INTERFACE, 'No pv_object_paths provided!')
+					VG_INTERFACE, 'PV Object path not found = %s!' % i)
+
+		if len(extend_devices):
+			rc, out, err = cmdhandler.vg_extend(vg_name, extend_devices,
+												extend_options)
+			Vg.handle_execute(rc, out, err)
 		else:
 			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+				VG_INTERFACE, 'No pv_object_paths provided!')
+
 		return '/'
 
 	@dbus.service.method(
@@ -366,33 +321,24 @@ class Vg(AutomatedProperties):
 			create_options):
 		# Make sure we have a dbus object representing it
 		pv_dests = []
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
 
-		if dbo:
-			if len(pv_dests_and_ranges):
-				for pr in pv_dests_and_ranges:
-					pv_dbus_obj = cfg.om.get_object_by_path(pr[0])
-					if not pv_dbus_obj:
-						raise dbus.exceptions.DBusException(
-							VG_INTERFACE,
-							'PV Destination (%s) not found' % pr[0])
+		Vg.validate_dbus_object(uuid, vg_name)
 
-					pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
+		if len(pv_dests_and_ranges):
+			for pr in pv_dests_and_ranges:
+				pv_dbus_obj = cfg.om.get_object_by_path(pr[0])
+				if not pv_dbus_obj:
+					raise dbus.exceptions.DBusException(
+						VG_INTERFACE,
+						'PV Destination (%s) not found' % pr[0])
 
-			rc, out, err = cmdhandler.vg_lv_create(
-				vg_name, create_options, name, size_bytes, pv_dests)
+				pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
 
-			if rc == 0:
-				return Vg.fetch_new_lv(vg_name, name)
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		rc, out, err = cmdhandler.vg_lv_create(
+			vg_name, create_options, name, size_bytes, pv_dests)
+
+		Vg.handle_execute(rc, out, err)
+		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -428,25 +374,13 @@ class Vg(AutomatedProperties):
 	def _lv_create_linear(uuid, vg_name, name, size_bytes,
 			thin_pool, create_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.vg_lv_create_linear(
-				vg_name, create_options, name, size_bytes, thin_pool)
+		Vg.validate_dbus_object(uuid, vg_name)
 
-			if rc == 0:
-				created_lv = Vg.fetch_new_lv(vg_name, name)
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		rc, out, err = cmdhandler.vg_lv_create_linear(
+			vg_name, create_options, name, size_bytes, thin_pool)
 
-		return created_lv
+		Vg.handle_execute(rc, out, err)
+		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -466,24 +400,12 @@ class Vg(AutomatedProperties):
 	def _lv_create_striped(uuid, vg_name, name, size_bytes, num_stripes,
 			stripe_size_kb, thin_pool, create_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.vg_lv_create_striped(
-				vg_name, create_options, name, size_bytes,
-				num_stripes, stripe_size_kb, thin_pool)
-			if rc == 0:
-				created_lv = Vg.fetch_new_lv(vg_name, name)
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE, 'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
-
-		return created_lv
+		Vg.validate_dbus_object(uuid, vg_name)
+		rc, out, err = cmdhandler.vg_lv_create_striped(
+			vg_name, create_options, name, size_bytes,
+			num_stripes, stripe_size_kb, thin_pool)
+		Vg.handle_execute(rc, out, err)
+		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -506,25 +428,11 @@ class Vg(AutomatedProperties):
 	def _lv_create_mirror(uuid, vg_name, name, size_bytes,
 			num_copies, create_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.vg_lv_create_mirror(
-				vg_name, create_options, name, size_bytes, num_copies)
-			if rc == 0:
-				created_lv = Vg.fetch_new_lv(vg_name, name)
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
-
-		return created_lv
+		Vg.validate_dbus_object(uuid, vg_name)
+		rc, out, err = cmdhandler.vg_lv_create_mirror(
+			vg_name, create_options, name, size_bytes, num_copies)
+		Vg.handle_execute(rc, out, err)
+		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -545,26 +453,12 @@ class Vg(AutomatedProperties):
 	def _lv_create_raid(uuid, vg_name, name, raid_type, size_bytes,
 						num_stripes, stripe_size_kb, create_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.vg_lv_create_raid(
-				vg_name, create_options, name, raid_type, size_bytes,
-				num_stripes, stripe_size_kb)
-			if rc == 0:
-				created_lv = Vg.fetch_new_lv(vg_name, name)
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
-
-		return created_lv
+		Vg.validate_dbus_object(uuid, vg_name)
+		rc, out, err = cmdhandler.vg_lv_create_raid(
+			vg_name, create_options, name, raid_type, size_bytes,
+			num_stripes, stripe_size_kb)
+		Vg.handle_execute(rc, out, err)
+		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -585,33 +479,27 @@ class Vg(AutomatedProperties):
 	def _create_pool(uuid, vg_name, meta_data_lv, data_lv,
 						create_options, create_method):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+		Vg.validate_dbus_object(uuid, vg_name)
 
 		# Retrieve the full names for the metadata and data lv
 		md = cfg.om.get_object_by_path(meta_data_lv)
 		data = cfg.om.get_object_by_path(data_lv)
 
-		if dbo and md and data:
+		if md and data:
 
 			new_name = data.Name
 
 			rc, out, err = create_method(
 				md.lv_full_name(), data.lv_full_name(), create_options)
+
 			if rc == 0:
 				mt_remove_dbus_objects((md, data))
-				cache_pool_lv = Vg.fetch_new_lv(vg_name, new_name)
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
+
+			Vg.handle_execute(rc, out, err)
 
 		else:
 			msg = ""
 
-			if not dbo:
-				msg += 'VG with uuid %s and name %s not present!' % \
-					(uuid, vg_name)
-
 			if not md:
 				msg += 'Meta data LV with object path %s not present!' % \
 					(meta_data_lv)
@@ -622,7 +510,7 @@ class Vg(AutomatedProperties):
 
 			raise dbus.exceptions.DBusException(VG_INTERFACE, msg)
 
-		return cache_pool_lv
+		return Vg.fetch_new_lv(vg_name, new_name)
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -656,33 +544,21 @@ class Vg(AutomatedProperties):
 		pv_devices = []
 
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			# Check for existence of pv object paths
-			for p in pv_object_paths:
-				pv = cfg.om.get_object_by_path(p)
-				if pv:
-					pv_devices.append(pv.Name)
-				else:
-					raise dbus.exceptions.DBusException(
-						VG_INTERFACE, 'PV object path = %s not found' % p)
+		Vg.validate_dbus_object(uuid, vg_name)
 
-			rc, out, err = cmdhandler.pv_tag(
-				pv_devices, tags_add, tags_del, tag_options)
-			if rc == 0:
-				cfg.load()
-				return '/'
+		# Check for existence of pv object paths
+		for p in pv_object_paths:
+			pv = cfg.om.get_object_by_path(p)
+			if pv:
+				pv_devices.append(pv.Name)
 			else:
 				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
+					VG_INTERFACE, 'PV object path = %s not found' % p)
 
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		rc, out, err = cmdhandler.pv_tag(
+			pv_devices, tags_add, tags_del, tag_options)
+		Vg.handle_execute(rc, out, err)
+		return '/'
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -720,25 +596,12 @@ class Vg(AutomatedProperties):
 	@staticmethod
 	def _vg_add_rm_tags(uuid, vg_name, tags_add, tags_del, tag_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
+		Vg.validate_dbus_object(uuid, vg_name)
 
-		if dbo:
-
-			rc, out, err = cmdhandler.vg_tag(
-				vg_name, tags_add, tags_del, tag_options)
-			if rc == 0:
-				cfg.load()
-				return '/'
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		rc, out, err = cmdhandler.vg_tag(
+			vg_name, tags_add, tags_del, tag_options)
+		Vg.handle_execute(rc, out, err)
+		return '/'
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -775,23 +638,10 @@ class Vg(AutomatedProperties):
 	@staticmethod
 	def _vg_change_set(uuid, vg_name, method, value, options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			rc, out, err = method(vg_name, value, options)
-			if rc == 0:
-				cfg.load()
-				return '/'
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		Vg.validate_dbus_object(uuid, vg_name)
+		rc, out, err = method(vg_name, value, options)
+		Vg.handle_execute(rc, out, err)
+		return '/'
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
@@ -849,23 +699,11 @@ class Vg(AutomatedProperties):
 	def _vg_activate_deactivate(uuid, vg_name, activate, control_flags,
 								options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(uuid, vg_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.activate_deactivate(
-				'vgchange', vg_name, activate, control_flags, options)
-			if rc == 0:
-				cfg.load()
-				return '/'
-			else:
-				raise dbus.exceptions.DBusException(
-					VG_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'VG with uuid %s and name %s not present!' %
-				(uuid, vg_name))
+		Vg.validate_dbus_object(uuid, vg_name)
+		rc, out, err = cmdhandler.activate_deactivate(
+			'vgchange', vg_name, activate, control_flags, options)
+		Vg.handle_execute(rc, out, err)
+		return '/'
 
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,


