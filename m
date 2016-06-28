From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:27 +0000 (UTC)
Subject: master - lvmdbusd: Correct pv_seg_start -> pvseg_start
Message-ID: <20160628192427.2E35860FC2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f26eae40f07399f11a2abe675aef850b0dd5239
Commit:        4f26eae40f07399f11a2abe675aef850b0dd5239
Parent:        0aadd6b0fb4eaa9e59d6f750f2efe2fdfdacdd8f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 27 17:07:20 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:09:28 2016 -0500

lvmdbusd: Correct pv_seg_start -> pvseg_start

Code was using the incorrect column names for pvseg_start which only
became apparent when utilizing the JSON.
---
 daemons/lvmdbusd/cmdhandler.py |    4 ++--
 daemons/lvmdbusd/lvmdb.py      |   11 +++++------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 2ca23e7..138142f 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -447,7 +447,7 @@ def lvm_full_report_json():
 					'pv_pe_alloc_count', 'pv_attr', 'pv_tags', 'vg_name',
 					'vg_uuid']
 
-	pv_seg_columns = ['pv_seg_start', 'pv_seg_size', 'segtype',
+	pv_seg_columns = ['pvseg_start', 'pvseg_size', 'segtype',
 					  'pv_uuid', 'lv_uuid', 'pv_name']
 
 	vg_columns = ['vg_name', 'vg_uuid', 'vg_fmt', 'vg_size', 'vg_free',
@@ -491,7 +491,7 @@ def pv_retrieve_with_segs(device=None):
 				'pv_used', 'dev_size', 'pv_mda_size', 'pv_mda_free',
 				'pv_ba_start', 'pv_ba_size', 'pe_start', 'pv_pe_count',
 				'pv_pe_alloc_count', 'pv_attr', 'pv_tags', 'vg_name',
-				'vg_uuid', 'pv_seg_start', 'pvseg_size', 'segtype']
+				'vg_uuid', 'pvseg_start', 'pvseg_size', 'segtype']
 
 	# Lvm has some issues where it returns failure when querying pvs when other
 	# operations are in process, see:
diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index f070bb6..51794d5 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -83,7 +83,7 @@ class DataStore(object):
 		for p in pvs:
 			DataStore._insert_record(
 				c_pvs, p['pv_uuid'], p,
-				['pv_seg_start', 'pvseg_size', 'segtype'])
+				['pvseg_start', 'pvseg_size', 'segtype'])
 
 		for p in c_pvs.values():
 			# Capture which PVs are associated with which VG
@@ -124,16 +124,15 @@ class DataStore(object):
 
 				if 'pvseg' in r:
 					for s in r['pvseg']:
-						# TODO Why is json pvseg_start, not pv_seg_start?
 						r = c_pvs[s['pv_uuid']]
-						r.setdefault('pv_seg_start', []).append(s['pvseg_start'])
+						r.setdefault('pvseg_start', []).append(s['pvseg_start'])
 						r.setdefault('pvseg_size', []).append(s['pvseg_size'])
 						r.setdefault('segtype', []).append(s['segtype'])
 
 				# TODO: Remove this bug work around when we have orphan segs.
 				for i in c_pvs.values():
-					if 'pv_seg_start' not in i:
-						i['pv_seg_start'] = '0'
+					if 'pvseg_start' not in i:
+						i['pvseg_start'] = '0'
 						i['pvseg_size'] = i['pv_pe_count']
 						i['segtype'] = 'free'
 
@@ -469,7 +468,7 @@ class DataStore(object):
 
 	def pv_pe_segments(self, pv_uuid):
 		pv = self.pvs[pv_uuid]
-		return list(zip(pv['pv_seg_start'], pv['pvseg_size']))
+		return list(zip(pv['pvseg_start'], pv['pvseg_size']))
 
 	def pv_contained_lv(self, pv_device):
 		rc = []


