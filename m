From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 28 Sep 2016 17:08:53 +0000 (UTC)
Subject: master - lvmdbusd: Use 'pv_missing' column instead of '[unknown]'
Message-ID: <20160928170853.E928B60640@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd96036835e088de6a59811834b5fa0747274a62
Commit:        bd96036835e088de6a59811834b5fa0747274a62
Parent:        be5eb995d356610b0748b05b65f74c34934526e4
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Sep 28 11:18:10 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Sep 28 12:07:48 2016 -0500

lvmdbusd: Use 'pv_missing' column instead of '[unknown]'

Previously using '[unknown]' for PV device path comparison which
is incorrect as it's not always true.
---
 daemons/lvmdbusd/cmdhandler.py    |    4 ++--
 daemons/lvmdbusd/lvmdb.py         |    7 +++++++
 daemons/lvmdbusd/objectmanager.py |    8 +++++---
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index c8c7baa..3cb2cbd 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -469,7 +469,7 @@ def lvm_full_report_json():
 					'pv_used', 'dev_size', 'pv_mda_size', 'pv_mda_free',
 					'pv_ba_start', 'pv_ba_size', 'pe_start', 'pv_pe_count',
 					'pv_pe_alloc_count', 'pv_attr', 'pv_tags', 'vg_name',
-					'vg_uuid']
+					'vg_uuid', 'pv_missing']
 
 	pv_seg_columns = ['pvseg_start', 'pvseg_size', 'segtype',
 						'pv_uuid', 'lv_uuid', 'pv_name']
@@ -522,7 +522,7 @@ def pv_retrieve_with_segs(device=None):
 				'pv_used', 'dev_size', 'pv_mda_size', 'pv_mda_free',
 				'pv_ba_start', 'pv_ba_size', 'pe_start', 'pv_pe_count',
 				'pv_pe_alloc_count', 'pv_attr', 'pv_tags', 'vg_name',
-				'vg_uuid', 'pvseg_start', 'pvseg_size', 'segtype']
+				'vg_uuid', 'pvseg_start', 'pvseg_size', 'segtype', 'pv_missing']
 
 	# Lvm has some issues where it returns failure when querying pvs when other
 	# operations are in process, see:
diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index ac60a80..9529e03 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -433,6 +433,12 @@ class DataStore(object):
 				rc.append(self.pvs[self.pv_path_to_uuid[s]])
 			return rc
 
+	def pv_missing(self, pv_uuid):
+		if pv_uuid in self.pvs:
+			if self.pvs[pv_uuid]['pv_missing'] == '':
+				return False
+		return True
+
 	def fetch_vgs(self, vg_name):
 		if not vg_name:
 			return self.vgs.values()
@@ -516,6 +522,7 @@ if __name__ == "__main__":
 	print("PVS")
 	for v in ds.pvs.values():
 		pp.pprint(v)
+		print('PV missing is %s' % ds.pv_missing(v['pv_uuid']))
 
 	print("VGS")
 	for v in ds.vgs.values():
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index 3284e1c..71149a5 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -320,10 +320,12 @@ class ObjectManager(AutomatedProperties):
 				# We have a uuid and a lvm_id we can do sanity checks to ensure
 				# that they are consistent
 
-				# If a PV is missing it's device path is '[unknown]'.  When
-				# we see the lvm_id as such we will re-assign to None
+				# If a PV is missing it's device path is '[unknown]' or some
+				# other text derivation of unknown.  When we find that a PV is
+				# missing we will clear out the lvm_id as it's likely not unique
+				# and thus not useful and potentially harmful for lookups.
 				if path_create == pv_obj_path_generate and \
-						lvm_id == '[unknown]':
+						cfg.db.pv_missing(uuid):
 					lvm_id = None
 
 				# Lets check for the uuid first


