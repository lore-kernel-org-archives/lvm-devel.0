From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  5 Oct 2016 20:57:33 +0000 (UTC)
Subject: master - lvmdbusd: Add LvCommon.MovePv
Message-ID: <20161005205733.40FA5605B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d54ffcfcd12981a8e046aca0a82d529221015b30
Commit:        d54ffcfcd12981a8e046aca0a82d529221015b30
Parent:        a3f24aaf5cfe9983a59ce200d0a0d8050658c8b8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 5 15:28:42 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 5 15:28:42 2016 -0500

lvmdbusd: Add LvCommon.MovePv

Needed for feature parity for lvm2app.
---
 daemons/lvmdbusd/cmdhandler.py |    4 ++--
 daemons/lvmdbusd/lv.py         |   24 ++++++++++++++++++++++--
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index a5fbad2..4bdbee5 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -487,7 +487,7 @@ def lvm_full_report_json():
 				'lv_attr', 'lv_tags', 'vg_uuid', 'lv_active', 'data_lv',
 				'metadata_lv', 'lv_parent', 'lv_role', 'lv_layout',
 				'snap_percent', 'metadata_percent', 'copy_percent',
-				'sync_percent', 'lv_metadata_size']
+				'sync_percent', 'lv_metadata_size', 'move_pv', 'move_pv_uuid']
 
 	lv_seg_columns = ['seg_pe_ranges', 'segtype', 'lv_uuid']
 
@@ -739,7 +739,7 @@ def lv_retrieve_with_segments():
 				'metadata_lv', 'seg_pe_ranges', 'segtype', 'lv_parent',
 				'lv_role', 'lv_layout',
 			    'snap_percent', 'metadata_percent', 'copy_percent',
-			    'sync_percent', 'lv_metadata_size']
+			    'sync_percent', 'lv_metadata_size', 'move_pv', 'move_pv_uuid']
 
 	cmd = _dc('lvs', ['-a', '-o', ','.join(columns)])
 	rc, out, err = call(cmd)
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 24c901c..c2312b7 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -86,7 +86,9 @@ def lvs_state_retrieve(selection, cache_refresh=True):
 			n32(l['metadata_percent']),
 			n32(l['copy_percent']),
 			n32(l['sync_percent']),
-			n(l['lv_metadata_size'])))
+			n(l['lv_metadata_size']),
+			l['move_pv'],
+			l['move_pv_uuid']))
 	return rc
 
 
@@ -144,7 +146,8 @@ class LvState(State):
 			vg_name, vg_uuid, pool_lv_uuid, PoolLv,
 			origin_uuid, OriginLv, DataPercent, Attr, Tags, active,
 			data_lv, metadata_lv, segtypes, role, layout, SnapPercent,
-			MetaDataPercent, CopyPercent, SyncPercent, MetaDataSizeBytes):
+			MetaDataPercent, CopyPercent, SyncPercent, MetaDataSizeBytes,
+			move_pv, move_pv_uuid):
 		utils.init_class_from_arguments(self)
 
 		# The segtypes is possibly an array with potentially dupes or a single
@@ -248,12 +251,25 @@ class LvCommon(AutomatedProperties):
 	_FixedMinor_meta = ('b', LV_COMMON_INTERFACE)
 	_ZeroBlocks_meta = ('b', LV_COMMON_INTERFACE)
 	_SkipActivation_meta = ('b', LV_COMMON_INTERFACE)
+	_MovePv_meta = ('o', LV_COMMON_INTERFACE)
+
+	def _get_move_pv(self):
+		path = None
+
+		# It's likely that the move_pv is empty
+		if self.state.move_pv_uuid and self.state.move_pv:
+			path = cfg.om.get_object_path_by_uuid_lvm_id(
+				self.state.move_pv_uuid, self.state.move_pv)
+		if not path:
+			path = '/'
+		return path
 
 	# noinspection PyUnusedLocal,PyPep8Naming
 	def __init__(self, object_path, object_state):
 		super(LvCommon, self).__init__(object_path, lvs_state_retrieve)
 		self.set_interface(LV_COMMON_INTERFACE)
 		self.state = object_state
+		self._move_pv = self._get_move_pv()
 
 	@property
 	def VolumeType(self):
@@ -363,6 +379,10 @@ class LvCommon(AutomatedProperties):
 	def Active(self):
 		return dbus.Boolean(self.state.active == "active")
 
+	@property
+	def MovePv(self):
+		return dbus.ObjectPath(self._move_pv)
+
 
 # noinspection PyPep8Naming
 class Lv(LvCommon):


