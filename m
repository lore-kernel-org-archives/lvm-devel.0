From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:43:43 -0400
Subject: master - lvmdbusd: Remove use of tmp variables
Message-ID: <201910301543.x9UFhh7O016547@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1839702cb4fa4f66c41c774f46d65b8dfa7a00f0
Commit:        1839702cb4fa4f66c41c774f46d65b8dfa7a00f0
Parent:        df38eb49aba94308804efdf309c08521165664d0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 1 15:18:46 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Remove use of tmp variables

We can use tuple expansion from the command handler functions
directly.
---
 daemons/lvmdbusd/lv.py |   35 +++++++++---------------
 daemons/lvmdbusd/pv.py |   14 +++------
 daemons/lvmdbusd/vg.py |   67 ++++++++++++++++++------------------------------
 3 files changed, 43 insertions(+), 73 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index f65e7da..147e51c 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -450,8 +450,7 @@ class Lv(LvCommon):
 		# Make sure we have a dbus object representing it
 		LvCommon.validate_dbus_object(lv_uuid, lv_name)
 		# Remove the LV, if successful then remove from the model
-		rc, out, err = cmdhandler.lv_remove(lv_name, remove_options)
-		LvCommon.handle_execute(rc, out, err)
+		LvCommon.handle_execute(*cmdhandler.lv_remove(lv_name, remove_options))
 		return '/'
 
 	@dbus.service.method(
@@ -471,9 +470,8 @@ class Lv(LvCommon):
 		# Make sure we have a dbus object representing it
 		LvCommon.validate_dbus_object(lv_uuid, lv_name)
 		# Rename the logical volume
-		rc, out, err = cmdhandler.lv_rename(lv_name, new_name,
-											rename_options)
-		LvCommon.handle_execute(rc, out, err)
+		LvCommon.handle_execute(*cmdhandler.lv_rename(lv_name, new_name,
+												rename_options))
 		return '/'
 
 	@dbus.service.method(
@@ -522,13 +520,11 @@ class Lv(LvCommon):
 				remainder = space % 512
 				optional_size = space + 512 - remainder
 
-		rc, out, err = cmdhandler.vg_lv_snapshot(
-			lv_name, snapshot_options, name, optional_size)
-		LvCommon.handle_execute(rc, out, err)
+		LvCommon.handle_execute(*cmdhandler.vg_lv_snapshot(
+			lv_name, snapshot_options,name, optional_size))
 		full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
 		return cfg.om.get_object_path_by_lvm_id(full_name)
 
-
 	@dbus.service.method(
 		dbus_interface=LV_INTERFACE,
 		in_signature='stia{sv}',
@@ -564,9 +560,8 @@ class Lv(LvCommon):
 				pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
 
 		size_change = new_size_bytes - dbo.SizeBytes
-		rc, out, err = cmdhandler.lv_resize(dbo.lvm_id, size_change,
-											pv_dests, resize_options)
-		LvCommon.handle_execute(rc, out, err)
+		LvCommon.handle_execute(*cmdhandler.lv_resize(
+			dbo.lvm_id, size_change,pv_dests, resize_options))
 		return "/"
 
 	@dbus.service.method(
@@ -601,9 +596,8 @@ class Lv(LvCommon):
 								options):
 		# Make sure we have a dbus object representing it
 		LvCommon.validate_dbus_object(uuid, lv_name)
-		rc, out, err = cmdhandler.activate_deactivate(
-			'lvchange', lv_name, activate, control_flags, options)
-		LvCommon.handle_execute(rc, out, err)
+		LvCommon.handle_execute(*cmdhandler.activate_deactivate(
+			'lvchange', lv_name, activate, control_flags, options))
 		return '/'
 
 	@dbus.service.method(
@@ -637,9 +631,8 @@ class Lv(LvCommon):
 	def _add_rm_tags(uuid, lv_name, tags_add, tags_del, tag_options):
 		# Make sure we have a dbus object representing it
 		LvCommon.validate_dbus_object(uuid, lv_name)
-		rc, out, err = cmdhandler.lv_tag(
-			lv_name, tags_add, tags_del, tag_options)
-		LvCommon.handle_execute(rc, out, err)
+		LvCommon.handle_execute(*cmdhandler.lv_tag(
+			lv_name, tags_add, tags_del, tag_options))
 		return '/'
 
 	@dbus.service.method(
@@ -699,10 +692,8 @@ class LvThinPool(Lv):
 	def _lv_create(lv_uuid, lv_name, name, size_bytes, create_options):
 		# Make sure we have a dbus object representing it
 		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
-
-		rc, out, err = cmdhandler.lv_lv_create(
-			lv_name, create_options, name, size_bytes)
-		LvCommon.handle_execute(rc, out, err)
+		LvCommon.handle_execute(*cmdhandler.lv_lv_create(
+			lv_name, create_options, name, size_bytes))
 		full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
 		return cfg.om.get_object_path_by_lvm_id(full_name)
 
diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index 9c0f1b2..8a25cbf 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -138,8 +138,7 @@ class Pv(AutomatedProperties):
 		# Remove the PV, if successful then remove from the model
 		# Make sure we have a dbus object representing it
 		Pv.validate_dbus_object(pv_uuid, pv_name)
-		rc, out, err = cmdhandler.pv_remove(pv_name, remove_options)
-		Pv.handle_execute(rc, out, err)
+		Pv.handle_execute(*cmdhandler.pv_remove(pv_name, remove_options))
 		return '/'
 
 	@staticmethod
@@ -172,10 +171,8 @@ class Pv(AutomatedProperties):
 	def _resize(pv_uuid, pv_name, new_size_bytes, resize_options):
 		# Make sure we have a dbus object representing it
 		Pv.validate_dbus_object(pv_uuid, pv_name)
-
-		rc, out, err = cmdhandler.pv_resize(pv_name, new_size_bytes,
-												resize_options)
-		Pv.handle_execute(rc, out, err)
+		Pv.handle_execute(*cmdhandler.pv_resize(pv_name, new_size_bytes,
+												resize_options))
 		return '/'
 
 	@dbus.service.method(
@@ -194,9 +191,8 @@ class Pv(AutomatedProperties):
 	def _allocation_enabled(pv_uuid, pv_name, yes_no, allocation_options):
 		# Make sure we have a dbus object representing it
 		Pv.validate_dbus_object(pv_uuid, pv_name)
-		rc, out, err = cmdhandler.pv_allocatable(
-			pv_name, yes_no, allocation_options)
-		Pv.handle_execute(rc, out, err)
+		Pv.handle_execute(*cmdhandler.pv_allocatable(pv_name, yes_no,
+														allocation_options))
 		return '/'
 
 	@dbus.service.method(
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index cfcc53b..d022ff1 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -171,9 +171,8 @@ class Vg(AutomatedProperties):
 	def _rename(uuid, vg_name, new_name, rename_options):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
-		rc, out, err = cmdhandler.vg_rename(
-			uuid, new_name, rename_options)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.vg_rename(
+			uuid, new_name, rename_options))
 		return '/'
 
 	@dbus.service.method(
@@ -192,8 +191,7 @@ class Vg(AutomatedProperties):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
 		# Remove the VG, if successful then remove from the model
-		rc, out, err = cmdhandler.vg_remove(vg_name, remove_options)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.vg_remove(vg_name, remove_options))
 		return '/'
 
 	@dbus.service.method(
@@ -209,8 +207,7 @@ class Vg(AutomatedProperties):
 	@staticmethod
 	def _change(uuid, vg_name, change_options):
 		Vg.validate_dbus_object(uuid, vg_name)
-		rc, out, err = cmdhandler.vg_change(change_options, vg_name)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.vg_change(change_options, vg_name))
 		return '/'
 
 	# TODO: This should be broken into a number of different methods
@@ -246,9 +243,8 @@ class Vg(AutomatedProperties):
 						VG_INTERFACE,
 						'PV Object path not found = %s!' % pv_op)
 
-		rc, out, err = cmdhandler.vg_reduce(vg_name, missing, pv_devices,
-											reduce_options)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.vg_reduce(
+			vg_name, missing, pv_devices, reduce_options))
 		return '/'
 
 	@dbus.service.method(
@@ -278,9 +274,8 @@ class Vg(AutomatedProperties):
 					VG_INTERFACE, 'PV Object path not found = %s!' % i)
 
 		if len(extend_devices):
-			rc, out, err = cmdhandler.vg_extend(vg_name, extend_devices,
-												extend_options)
-			Vg.handle_execute(rc, out, err)
+			Vg.handle_execute(*cmdhandler.vg_extend(
+				vg_name, extend_devices, extend_options))
 		else:
 			raise dbus.exceptions.DBusException(
 				VG_INTERFACE, 'No pv_object_paths provided!')
@@ -334,10 +329,8 @@ class Vg(AutomatedProperties):
 
 				pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
 
-		rc, out, err = cmdhandler.vg_lv_create(
-			vg_name, create_options, name, size_bytes, pv_dests)
-
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.vg_lv_create(
+			vg_name, create_options, name, size_bytes, pv_dests))
 		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
@@ -375,11 +368,8 @@ class Vg(AutomatedProperties):
 			thin_pool, create_options):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
-
-		rc, out, err = cmdhandler.vg_lv_create_linear(
-			vg_name, create_options, name, size_bytes, thin_pool)
-
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.vg_lv_create_linear(
+			vg_name, create_options, name, size_bytes, thin_pool))
 		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
@@ -401,10 +391,9 @@ class Vg(AutomatedProperties):
 			stripe_size_kb, thin_pool, create_options):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
-		rc, out, err = cmdhandler.vg_lv_create_striped(
+		Vg.handle_execute(*cmdhandler.vg_lv_create_striped(
 			vg_name, create_options, name, size_bytes,
-			num_stripes, stripe_size_kb, thin_pool)
-		Vg.handle_execute(rc, out, err)
+			num_stripes, stripe_size_kb, thin_pool))
 		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
@@ -429,9 +418,8 @@ class Vg(AutomatedProperties):
 			num_copies, create_options):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
-		rc, out, err = cmdhandler.vg_lv_create_mirror(
-			vg_name, create_options, name, size_bytes, num_copies)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.vg_lv_create_mirror(
+			vg_name, create_options, name, size_bytes, num_copies))
 		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
@@ -454,10 +442,9 @@ class Vg(AutomatedProperties):
 						num_stripes, stripe_size_kb, create_options):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
-		rc, out, err = cmdhandler.vg_lv_create_raid(
+		Vg.handle_execute(*cmdhandler.vg_lv_create_raid(
 			vg_name, create_options, name, raid_type, size_bytes,
-			num_stripes, stripe_size_kb)
-		Vg.handle_execute(rc, out, err)
+			num_stripes, stripe_size_kb))
 		return Vg.fetch_new_lv(vg_name, name)
 
 	@dbus.service.method(
@@ -555,9 +542,8 @@ class Vg(AutomatedProperties):
 				raise dbus.exceptions.DBusException(
 					VG_INTERFACE, 'PV object path = %s not found' % p)
 
-		rc, out, err = cmdhandler.pv_tag(
-			pv_devices, tags_add, tags_del, tag_options)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.pv_tag(
+			pv_devices, tags_add, tags_del, tag_options))
 		return '/'
 
 	@dbus.service.method(
@@ -598,9 +584,8 @@ class Vg(AutomatedProperties):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
 
-		rc, out, err = cmdhandler.vg_tag(
-			vg_name, tags_add, tags_del, tag_options)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.vg_tag(
+			vg_name, tags_add, tags_del, tag_options))
 		return '/'
 
 	@dbus.service.method(
@@ -639,8 +624,7 @@ class Vg(AutomatedProperties):
 	def _vg_change_set(uuid, vg_name, method, value, options):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
-		rc, out, err = method(vg_name, value, options)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*method(vg_name, value, options))
 		return '/'
 
 	@dbus.service.method(
@@ -700,9 +684,8 @@ class Vg(AutomatedProperties):
 								options):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
-		rc, out, err = cmdhandler.activate_deactivate(
-			'vgchange', vg_name, activate, control_flags, options)
-		Vg.handle_execute(rc, out, err)
+		Vg.handle_execute(*cmdhandler.activate_deactivate(
+			'vgchange', vg_name, activate, control_flags, options))
 		return '/'
 
 	@dbus.service.method(


