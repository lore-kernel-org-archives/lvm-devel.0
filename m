From: Tony Asleson <tasleson@sourceware.org>
Date: Tue, 20 Sep 2022 21:38:10 +0000 (GMT)
Subject: main - lvmdbusd: Correct get_object_path_by_uuid_lvm_id
Message-ID: <20220920213810.4B8013858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d88998f5163f84aa7305edfeb9ec51dc5b0c6733
Commit:        d88998f5163f84aa7305edfeb9ec51dc5b0c6733
Parent:        a0fc61177e1fc39a312c623c4fa3639f8b96f7b2
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Sep 20 11:40:15 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Sep 20 16:36:53 2022 -0500

lvmdbusd: Correct get_object_path_by_uuid_lvm_id

When checking to see if the PV is missing we incorrectly checked that the
path_create was equal to PV creation.  However, there are cases where we
are doing a lookup where the path_create == None.  In this case, we would
fail to set lvm_id == None which caused a problem as we had more than 1
PV that was missing.  When this occurred, the second lookup matched the
first missing PV that was added to the object manager.  This resulted in
the following:

Traceback (most recent call last):
  File "/usr/lib/python3.9/site-packages/lvmdbusd/utils.py", line 667, in _run
    self.rc = self.f(*self.args)
  File "/usr/lib/python3.9/site-packages/lvmdbusd/fetch.py", line 25, in _main_thread_load
    (changes, remove) = load_pvs(
  File "/usr/lib/python3.9/site-packages/lvmdbusd/pv.py", line 46, in load_pvs
    return common(
  File "/usr/lib/python3.9/site-packages/lvmdbusd/loader.py", line 55, in common
    del existing_paths[dbus_object.dbus_object_path()]

Because we expect to find the object in existing_paths if we found it in
the lookup.

resolves: https://bugzilla.redhat.com/show_bug.cgi?id=2085078
---
 daemons/lvmdbusd/lvmdb.py.in      | 5 ++++-
 daemons/lvmdbusd/objectmanager.py | 7 +++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
index 8d0cc59e1..41fedb80f 100644
--- a/daemons/lvmdbusd/lvmdb.py.in
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -360,10 +360,13 @@ class DataStore(object):
 			return rc
 
 	def pv_missing(self, pv_uuid):
+		# The uuid might not be a PV, default to false
 		if pv_uuid in self.pvs:
 			if self.pvs[pv_uuid]['pv_missing'] == '':
 				return False
-		return True
+			else:
+				return True
+		return False
 
 	def fetch_vgs(self, vg_name):
 		if not vg_name:
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index b84e16904..f9586ec9a 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -300,10 +300,9 @@ class ObjectManager(AutomatedProperties):
 
 				# If a PV is missing its device path is '[unknown]' or some
 				# other text derivation of unknown.  When we find that a PV is
-				# missing we will clear out the lvm_id as it's likely not unique
-				# and thus not useful and potentially harmful for lookups.
-				if path_create == pv_obj_path_generate and \
-						cfg.db.pv_missing(uuid):
+				# missing we will clear out the lvm_id as it's not unique
+				# and thus not useful and harmful for lookups.
+				if cfg.db.pv_missing(uuid):
 					lvm_id = None
 
 				# Lets check for the uuid first

