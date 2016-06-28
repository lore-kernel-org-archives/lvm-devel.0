From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:35 +0000 (UTC)
Subject: master - lvmdbusd: Clean up ws
Message-ID: <20160628192435.8BF5661253@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e3ad37828a14924dd12f65e62194bef286a16f0
Commit:        9e3ad37828a14924dd12f65e62194bef286a16f0
Parent:        c11003c860fe9242f49ba6ccffadd964501f1d1f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 28 12:45:28 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:45:28 2016 -0500

lvmdbusd: Clean up ws

---
 daemons/lvmdbusd/cmdhandler.py    |    2 +-
 daemons/lvmdbusd/lvmdb.py         |    1 -
 daemons/lvmdbusd/objectmanager.py |    2 +-
 3 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 138142f..560b389 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -448,7 +448,7 @@ def lvm_full_report_json():
 					'vg_uuid']
 
 	pv_seg_columns = ['pvseg_start', 'pvseg_size', 'segtype',
-					  'pv_uuid', 'lv_uuid', 'pv_name']
+						'pv_uuid', 'lv_uuid', 'pv_name']
 
 	vg_columns = ['vg_name', 'vg_uuid', 'vg_fmt', 'vg_size', 'vg_free',
 					'vg_sysid', 'vg_extent_size', 'vg_extent_count',
diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index 51794d5..2dc593b 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -234,7 +234,6 @@ class DataStore(object):
 
 		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
 
-
 	@staticmethod
 	def _parse_lvs_json(_all):
 
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index c93f207..178003e 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -224,7 +224,7 @@ class ObjectManager(AutomatedProperties):
 		return path
 
 	def get_object_path_by_uuid_lvm_id(self, uuid, lvm_id, path_create=None,
-									   gen_new=True):
+										gen_new=True):
 		"""
 		For a given lvm asset return the dbus object registered to it.  If the
 		object is not found and gen_new == True and path_create is a valid


