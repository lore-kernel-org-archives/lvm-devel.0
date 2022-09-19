From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:59 +0000 (GMT)
Subject: main - lvmdbusd: Correct typos
Message-ID: <20220919155759.058373858C2F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=068073e924246ebda66b6dff590455d648007007
Commit:        068073e924246ebda66b6dff590455d648007007
Parent:        abf22df46c53968e5b064b2a4feb7b57e08fac09
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 12:06:17 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Correct typos

---
 daemons/lvmdbusd/objectmanager.py | 4 ++--
 daemons/lvmdbusd/utils.py         | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index e40e9a14a..95d33db19 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -287,7 +287,7 @@ class ObjectManager(AutomatedProperties):
 		register it with the object manager for the specified uuid & lvm_id.
 		Note: If path create is not None, uuid and lvm_id cannot be equal
 		:param uuid: The uuid for the lvm object we are searching for
-		:param lvm_id: The lvm name (eg. pv device path, vg name, lv full name)
+		:param lvm_id: The lvm name (e.g. pv device path, vg name, lv full name)
 		:param path_create: If not None, create the path using this function if
 				we fail to find the object by uuid or lvm_id.
 		:returns None if lvm asset not found and path_create == None otherwise
@@ -308,7 +308,7 @@ class ObjectManager(AutomatedProperties):
 				# We have a uuid and a lvm_id we can do sanity checks to ensure
 				# that they are consistent
 
-				# If a PV is missing it's device path is '[unknown]' or some
+				# If a PV is missing its device path is '[unknown]' or some
 				# other text derivation of unknown.  When we find that a PV is
 				# missing we will clear out the lvm_id as it's likely not unique
 				# and thus not useful and potentially harmful for lookups.
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index e12c7fccf..75a5348f5 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -593,7 +593,7 @@ def add_no_notify(cmdline):
 	:rtype: list
 	"""
 
-	# Only after we have seen an external event will be disable lvm from sending
+	# Only after we have seen an external event will we disable lvm from sending
 	# us one when we call lvm
 	if cfg.got_external_event:
 		if 'help' in cmdline:
@@ -612,8 +612,8 @@ def add_no_notify(cmdline):
 
 
 # The methods below which start with mt_* are used to execute the desired code
-# on the the main thread of execution to alleviate any issues the dbus-python
-# library with regards to multi-threaded access.  Essentially, we are trying to
+# on the main thread of execution to alleviate any issues the dbus-python
+# library with regard to multithreaded access.  Essentially, we are trying to
 # ensure all dbus library interaction is done from the same thread!
 
 

