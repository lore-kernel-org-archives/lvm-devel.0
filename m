From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 18 Feb 2016 01:05:20 +0000 (UTC)
Subject: master - lvmdbus: resync latest changes with original repo
Message-ID: <20160218010520.39A126036B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f353e205389180808557688c03b9565b6da0509
Commit:        0f353e205389180808557688c03b9565b6da0509
Parent:        545e58fd180cb891744a34a4d79440c447e5744b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Feb 18 00:27:57 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 18 00:27:57 2016 +0000

lvmdbus: resync latest changes with original repo

---
 daemons/lvmdbusd/lv.py      |   15 +++++++
 daemons/lvmdbusd/manager.py |    5 ++
 daemons/lvmdbusd/request.py |    2 +-
 daemons/lvmdbusd/utils.py   |   96 +++++++++++++++++++++++++++++++++++++++++++
 daemons/lvmdbusd/vg.py      |   22 ++++++++++
 5 files changed, 139 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 81ef20c..42219b3 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -377,6 +377,8 @@ class Lv(LvCommon):
 		out_signature='o',
 		async_callbacks=('cb', 'cbe'))
 	def Rename(self, name, tmo, rename_options, cb, cbe):
+		utils.validate_lv_name(LV_INTERFACE, self.vg_name_lookup(), name)
+
 		r = RequestEntry(
 			tmo, Lv._rename,
 			(self.Uuid, self.lvm_id, name, rename_options),
@@ -441,6 +443,9 @@ class Lv(LvCommon):
 		async_callbacks=('cb', 'cbe'))
 	def Snapshot(self, name, optional_size, tmo,
 			snapshot_options, cb, cbe):
+
+		utils.validate_lv_name(LV_INTERFACE, self.vg_name_lookup(), name)
+
 		r = RequestEntry(
 			tmo, Lv._snap_shot,
 			(self.Uuid, self.lvm_id, name,
@@ -590,6 +595,10 @@ class Lv(LvCommon):
 		out_signature='o',
 		async_callbacks=('cb', 'cbe'))
 	def TagsAdd(self, tags, tmo, tag_options, cb, cbe):
+
+		for t in tags:
+			utils.validate_tag(LV_INTERFACE, t)
+
 		r = RequestEntry(
 			tmo, Lv._add_rm_tags,
 			(self.state.Uuid, self.state.lvm_id,
@@ -603,6 +612,10 @@ class Lv(LvCommon):
 		out_signature='o',
 		async_callbacks=('cb', 'cbe'))
 	def TagsDel(self, tags, tmo, tag_options, cb, cbe):
+
+		for t in tags:
+			utils.validate_tag(LV_INTERFACE, t)
+
 		r = RequestEntry(
 			tmo, Lv._add_rm_tags,
 			(self.state.Uuid, self.state.lvm_id,
@@ -678,6 +691,8 @@ class LvThinPool(Lv):
 		out_signature='(oo)',
 		async_callbacks=('cb', 'cbe'))
 	def LvCreate(self, name, size_bytes, tmo, create_options, cb, cbe):
+		utils.validate_lv_name(THIN_POOL_INTERFACE, self.vg_name_lookup(), name)
+
 		r = RequestEntry(
 			tmo, LvThinPool._lv_create,
 			(self.Uuid, self.lvm_id, name,
diff --git a/daemons/lvmdbusd/lvmdbusd b/daemons/lvmdbusd/lvmdbusd
old mode 100644
new mode 100755
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index f7d194d..c728439 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -61,6 +61,7 @@ class Manager(AutomatedProperties):
 		out_signature='(oo)',
 		async_callbacks=('cb', 'cbe'))
 	def PvCreate(self, device, tmo, create_options, cb, cbe):
+		utils.validate_device_path(MANAGER_INTERFACE, device)
 		r = RequestEntry(
 			tmo, Manager._pv_create,
 			(device, create_options), cb, cbe)
@@ -100,6 +101,7 @@ class Manager(AutomatedProperties):
 		out_signature='(oo)',
 		async_callbacks=('cb', 'cbe'))
 	def VgCreate(self, name, pv_object_paths, tmo, create_options, cb, cbe):
+		utils.validate_vg_name(MANAGER_INTERFACE, name)
 		r = RequestEntry(
 			tmo, Manager._create_vg,
 			(name, pv_object_paths, create_options,),
@@ -219,6 +221,9 @@ class Manager(AutomatedProperties):
 		:param cbe: Not visible in API (used for async. error callback)
 		:return: '/' if operation done, else job path
 		"""
+		for d in device_paths:
+			utils.validate_device_path(MANAGER_INTERFACE, d)
+
 		r = RequestEntry(
 			tmo, Manager._pv_scan,
 			(activate, cache, device_paths, major_minors,
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 15d852e..fba6580 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -34,7 +34,7 @@ class RequestEntry(object):
 		self._rc_error = None
 		self._return_tuple = return_tuple
 
-		if self.tmo == -1:
+		if self.tmo < 0:
 			# Client is willing to block forever
 			pass
 		elif tmo == 0:
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 389f213..dacd0ef 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -12,6 +12,7 @@ import sys
 import inspect
 import ctypes
 import os
+import string
 
 import dbus
 import dbus.service
@@ -386,3 +387,98 @@ def round_size(size_bytes):
 	if not remainder:
 		return size_bytes
 	return size_bytes + bs - remainder
+
+
+_ALLOWABLE_CH = string.ascii_letters + string.digits + '#+.:=@_\/%'
+_ALLOWABLE_CH_SET = set(_ALLOWABLE_CH)
+
+_ALLOWABLE_VG_LV_CH = string.ascii_letters + string.digits + '.-_+'
+_ALLOWABLE_VG_LV_CH_SET = set(_ALLOWABLE_VG_LV_CH)
+_LV_NAME_RESERVED = ("_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
+	"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta", "_vorigin")
+
+# Tags can have the characters, based on the code
+# a-zA-Z0-9._-+/=!:&#
+_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
+_ALLOWABLE_TAG_CH_SET = set(_ALLOWABLE_TAG_CH)
+
+
+def _allowable_tag(tag_name):
+	# LVM should impose a length restriction
+	return set(tag_name) <= _ALLOWABLE_TAG_CH_SET
+
+
+def _allowable_vg_name(vg_name):
+	if vg_name is None:
+		raise ValueError("VG name is None or empty")
+
+	vg_len = len(vg_name)
+	if vg_len == 0 or vg_len > 127:
+		raise ValueError("VG name (%s) length (%d) not in the domain 1..127" %
+			(vg_name, vg_len))
+
+	if not set(vg_name) <= _ALLOWABLE_VG_LV_CH_SET:
+		raise ValueError("VG name (%s) contains invalid character, "
+			"allowable set(%s)" % (vg_name, _ALLOWABLE_VG_LV_CH))
+
+	if vg_name == "." or vg_name == "..":
+		raise ValueError('VG name (%s) cannot be "." or ".."' % (vg_name))
+
+
+def _allowable_lv_name(vg_name, lv_name):
+
+	if lv_name is None:
+		raise ValueError("LV name is None or empty")
+
+	lv_len = len(lv_name)
+
+	# This length is derived from empirical testing
+	if lv_len == 0 or (len(vg_name) + lv_len) > 125:
+		raise ValueError("LV name (%s) length (%d) + VG name length "
+			"not in the domain 1..125" % (lv_name, lv_len))
+
+	if not set(lv_name) <= _ALLOWABLE_VG_LV_CH_SET:
+		raise ValueError("LV name (%s) contains invalid character, "
+			"allowable (%s)" % (lv_name, _ALLOWABLE_VG_LV_CH))
+
+	if any(x in lv_name for x in _LV_NAME_RESERVED):
+		raise ValueError("LV name (%s) contains a reserved word, "
+			"reserved set(%s)" % (lv_name, str(_LV_NAME_RESERVED)))
+
+	if lv_name.startswith("snapshot") or lv_name.startswith("pvmove"):
+		raise ValueError("LV name (%s) starts with a reserved word, "
+			"reserved set(%s)" % (lv_name, str(["snapshot", "pvmove"])))
+
+	if lv_name[0] == '-':
+		raise ValueError("LV name (%s) cannot start with a '-' "
+				"character" % lv_name)
+
+
+def validate_device_path(interface, device):
+	if not set(device) <= _ALLOWABLE_CH_SET:
+		raise dbus.exceptions.DBusException(
+			interface, 'Device path (%s) has invalid characters, '
+			'allowable (%s)' % (device, _ALLOWABLE_CH))
+
+
+def validate_vg_name(interface, vg_name):
+	try:
+		_allowable_vg_name(vg_name)
+	except ValueError as ve:
+		raise dbus.exceptions.DBusException(
+			interface, str(ve))
+
+
+def validate_lv_name(interface, vg_name, lv_name):
+	try:
+		_allowable_lv_name(vg_name, lv_name)
+	except ValueError as ve:
+		raise dbus.exceptions.DBusException(
+			interface, str(ve))
+
+
+def validate_tag(interface, tag):
+	if not _allowable_tag(tag):
+		raise dbus.exceptions.DBusException(
+			interface, 'tag (%s) contains invalid character, allowable set(%s)'
+			% (tag, _ALLOWABLE_TAG_CH))
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index c277412..b39f703 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -179,6 +179,7 @@ class Vg(AutomatedProperties):
 		in_signature='sia{sv}', out_signature='o',
 		async_callbacks=('cb', 'cbe'))
 	def Rename(self, name, tmo, rename_options, cb, cbe):
+		utils.validate_vg_name(VG_INTERFACE, name)
 		r = RequestEntry(tmo, Vg._rename,
 				(self.state.Uuid, self.state.lvm_id, name,
 				rename_options), cb, cbe, False)
@@ -422,6 +423,7 @@ class Vg(AutomatedProperties):
 					job object path if created.  Each == '/' when it doesn't
 					apply.
 		"""
+		utils.validate_lv_name(VG_INTERFACE, self.Name, name)
 		r = RequestEntry(tmo, Vg._lv_create,
 				(self.state.Uuid, self.state.lvm_id,
 				name, round_size(size_bytes), pv_dests_and_ranges,
@@ -459,6 +461,7 @@ class Vg(AutomatedProperties):
 		async_callbacks=('cb', 'cbe'))
 	def LvCreateLinear(self, name, size_bytes,
 			thin_pool, tmo, create_options, cb, cbe):
+		utils.validate_lv_name(VG_INTERFACE, self.Name, name)
 		r = RequestEntry(tmo, Vg._lv_create_linear,
 						(self.state.Uuid, self.state.lvm_id,
 						name, round_size(size_bytes), thin_pool,
@@ -496,6 +499,7 @@ class Vg(AutomatedProperties):
 	def LvCreateStriped(self, name, size_bytes, num_stripes,
 						stripe_size_kb, thin_pool, tmo, create_options,
 						cb, cbe):
+		utils.validate_lv_name(VG_INTERFACE, self.Name, name)
 		r = RequestEntry(
 				tmo, Vg._lv_create_striped,
 				(self.state.Uuid, self.state.lvm_id, name,
@@ -535,6 +539,7 @@ class Vg(AutomatedProperties):
 		async_callbacks=('cb', 'cbe'))
 	def LvCreateMirror(self, name, size_bytes, num_copies,
 			tmo, create_options, cb, cbe):
+		utils.validate_lv_name(VG_INTERFACE, self.Name, name)
 		r = RequestEntry(
 			tmo, Vg._lv_create_mirror,
 			(self.state.Uuid, self.state.lvm_id, name,
@@ -575,6 +580,7 @@ class Vg(AutomatedProperties):
 	def LvCreateRaid(self, name, raid_type, size_bytes,
 			num_stripes, stripe_size_kb, tmo,
 			create_options, cb, cbe):
+		utils.validate_lv_name(VG_INTERFACE, self.Name, name)
 		r = RequestEntry(tmo, Vg._lv_create_raid,
 				(self.state.Uuid, self.state.lvm_id, name,
 				raid_type, round_size(size_bytes), num_stripes,
@@ -692,6 +698,10 @@ class Vg(AutomatedProperties):
 		out_signature='o',
 		async_callbacks=('cb', 'cbe'))
 	def PvTagsAdd(self, pvs, tags, tmo, tag_options, cb, cbe):
+
+		for t in tags:
+			utils.validate_tag(VG_INTERFACE, t)
+
 		r = RequestEntry(tmo, Vg._pv_add_rm_tags,
 				(self.state.Uuid, self.state.lvm_id,
 				pvs, tags, None, tag_options),
@@ -704,6 +714,10 @@ class Vg(AutomatedProperties):
 		out_signature='o',
 		async_callbacks=('cb', 'cbe'))
 	def PvTagsDel(self, pvs, tags, tmo, tag_options, cb, cbe):
+
+		for t in tags:
+			utils.validate_tag(VG_INTERFACE, t)
+
 		r = RequestEntry(
 			tmo, Vg._pv_add_rm_tags,
 			(self.state.Uuid, self.state.lvm_id,
@@ -740,6 +754,10 @@ class Vg(AutomatedProperties):
 		out_signature='o',
 		async_callbacks=('cb', 'cbe'))
 	def TagsAdd(self, tags, tmo, tag_options, cb, cbe):
+
+		for t in tags:
+			utils.validate_tag(VG_INTERFACE, t)
+
 		r = RequestEntry(tmo, Vg._vg_add_rm_tags,
 				(self.state.Uuid, self.state.lvm_id,
 				tags, None, tag_options),
@@ -752,6 +770,10 @@ class Vg(AutomatedProperties):
 		out_signature='o',
 		async_callbacks=('cb', 'cbe'))
 	def TagsDel(self, tags, tmo, tag_options, cb, cbe):
+
+		for t in tags:
+			utils.validate_tag(VG_INTERFACE, t)
+
 		r = RequestEntry(tmo, Vg._vg_add_rm_tags,
 				(self.state.Uuid, self.state.lvm_id,
 				None, tags, tag_options),


