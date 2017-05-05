From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 5 May 2017 11:31:05 -0400
Subject: master - lvmdbusd: Correct PV lookups
Message-ID: <201705051531.v45FV5nE030022@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=405a3689bcc40c8782685a739310e337a7c268a9
Commit:        405a3689bcc40c8782685a739310e337a7c268a9
Parent:        fcce7e16601caf3941fd0d090c03c94ac83a329e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed May 3 13:06:10 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri May 5 10:30:06 2017 -0500

lvmdbusd: Correct PV lookups

When a user does a Manager.PvCreate they can specify the block device using a
device path that may be different than what lvm reports is the device path.  For
example a user could use:

/dev/disk/by-id/wwn-0x5002538500000000 instead of /dev/sdc

In this case the pvcreate will succeed, but when we query lvm we don't find the
newly created PV. We fail because it's device path is returned as /dev/sdc.  This
change re-uses an internal lookup which can accommodate this and correctly find
the newly created PV.

Corrects https://bugzilla.redhat.com/show_bug.cgi?id=1445654
---
 daemons/lvmdbusd/objectmanager.py |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index a9d13a7..563b9ec 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -223,8 +223,9 @@ class ObjectManager(AutomatedProperties):
 		:param lvm_id: The lvm identifier
 		"""
 		with self.rlock:
-			if lvm_id in self._id_to_object_path:
-				return self.get_object_by_path(self._id_to_object_path[lvm_id])
+			lookup_rc = self._id_lookup(lvm_id)
+			if lookup_rc:
+				return self.get_object_by_path(lookup_rc)
 			return None
 
 	def get_object_path_by_lvm_id(self, lvm_id):
@@ -234,8 +235,9 @@ class ObjectManager(AutomatedProperties):
 		:return: Object path or '/' if not found
 		"""
 		with self.rlock:
-			if lvm_id in self._id_to_object_path:
-				return self._id_to_object_path[lvm_id]
+			lookup_rc = self._id_lookup(lvm_id)
+			if lookup_rc:
+				return lookup_rc
 			return '/'
 
 	def _uuid_verify(self, path, uuid, lvm_id):


