From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  5 Oct 2016 20:57:31 +0000 (UTC)
Subject: master - lvmdbusd: Add properties to LvCommon
Message-ID: <20161005205731.28777605B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3f24aaf5cfe9983a59ce200d0a0d8050658c8b8
Commit:        a3f24aaf5cfe9983a59ce200d0a0d8050658c8b8
Parent:        bf5d0a2651e199bf7f2b737ebcfd5bbe17878d0f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 5 13:59:38 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 5 13:59:38 2016 -0500

lvmdbusd: Add properties to LvCommon

The following LvCommon properties were added so that the API
would have the same functionality as lvm2app has.

LvCommon.MetaDataSizeBytes
LvCommon.Attr
LvCommon.MetaDataPercent
LvCommon.CopyPercent
LvCommon.SnapPercent
LvCommon.SyncPercent
---
 daemons/lvmdbusd/cmdhandler.py |    8 ++++++--
 daemons/lvmdbusd/lv.py         |   18 +++++++++++++++---
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 3cb2cbd..a5fbad2 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -485,7 +485,9 @@ def lvm_full_report_json():
 				'vg_name', 'pool_lv_uuid', 'pool_lv', 'origin_uuid',
 				'origin', 'data_percent',
 				'lv_attr', 'lv_tags', 'vg_uuid', 'lv_active', 'data_lv',
-				'metadata_lv', 'lv_parent', 'lv_role', 'lv_layout']
+				'metadata_lv', 'lv_parent', 'lv_role', 'lv_layout',
+				'snap_percent', 'metadata_percent', 'copy_percent',
+				'sync_percent', 'lv_metadata_size']
 
 	lv_seg_columns = ['seg_pe_ranges', 'segtype', 'lv_uuid']
 
@@ -735,7 +737,9 @@ def lv_retrieve_with_segments():
 				'origin', 'data_percent',
 				'lv_attr', 'lv_tags', 'vg_uuid', 'lv_active', 'data_lv',
 				'metadata_lv', 'seg_pe_ranges', 'segtype', 'lv_parent',
-				'lv_role', 'lv_layout']
+				'lv_role', 'lv_layout',
+			    'snap_percent', 'metadata_percent', 'copy_percent',
+			    'sync_percent', 'lv_metadata_size']
 
 	cmd = _dc('lvs', ['-a', '-o', ','.join(columns)])
 	rc, out, err = call(cmd)
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 2a8a3fb..24c901c 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -81,7 +81,12 @@ def lvs_state_retrieve(selection, cache_refresh=True):
 			n32(l['data_percent']), l['lv_attr'],
 			l['lv_tags'], l['lv_active'], l['data_lv'],
 			l['metadata_lv'], l['segtype'], l['lv_role'],
-			l['lv_layout']))
+			l['lv_layout'],
+			n32(l['snap_percent']),
+			n32(l['metadata_percent']),
+			n32(l['copy_percent']),
+			n32(l['sync_percent']),
+			n(l['lv_metadata_size'])))
 	return rc
 
 
@@ -138,7 +143,8 @@ class LvState(State):
 	def __init__(self, Uuid, Name, Path, SizeBytes,
 			vg_name, vg_uuid, pool_lv_uuid, PoolLv,
 			origin_uuid, OriginLv, DataPercent, Attr, Tags, active,
-			data_lv, metadata_lv, segtypes, role, layout):
+			data_lv, metadata_lv, segtypes, role, layout, SnapPercent,
+			MetaDataPercent, CopyPercent, SyncPercent, MetaDataSizeBytes):
 		utils.init_class_from_arguments(self)
 
 		# The segtypes is possibly an array with potentially dupes or a single
@@ -214,13 +220,19 @@ class LvState(State):
 @utils.dbus_property(LV_COMMON_INTERFACE, 'Name', 's')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'Path', 's')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'SizeBytes', 't')
- at utils.dbus_property(LV_COMMON_INTERFACE, 'DataPercent', 'u')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'SegType', 'as')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'Vg', 'o')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'OriginLv', 'o')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'PoolLv', 'o')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'Devices', "a(oa(tts))")
 @utils.dbus_property(LV_COMMON_INTERFACE, 'HiddenLvs', "ao")
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'Attr', 's')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'DataPercent', 'u')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'SnapPercent', 'u')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'MetaDataPercent', 'u')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'CopyPercent', 'u')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'SyncPercent', 'u')
+ at utils.dbus_property(LV_COMMON_INTERFACE, 'MetaDataSizeBytes', 't')
 class LvCommon(AutomatedProperties):
 	_Tags_meta = ("as", LV_COMMON_INTERFACE)
 	_Roles_meta = ("as", LV_COMMON_INTERFACE)


