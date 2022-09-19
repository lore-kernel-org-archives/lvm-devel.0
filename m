From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:01 +0000 (GMT)
Subject: main - lvmdbusd: Remove unused locking functionality
Message-ID: <20220919155801.47DDA3858400@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60e4ba36e0843c9536278ff33ce6dfda9cfd8079
Commit:        60e4ba36e0843c9536278ff33ce6dfda9cfd8079
Parent:        cfc87157a4fdec39c2b570bd35ce812cda3003f6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 12:09:30 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Remove unused locking functionality

I don't think we have ever utilized this, remove.
---
 daemons/lvmdbusd/objectmanager.py | 35 -----------------------------------
 1 file changed, 35 deletions(-)

diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index 95d33db19..a0c4a50ef 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -53,15 +53,6 @@ class ObjectManager(AutomatedProperties):
 									(self, ), cb, cbe, False)
 		cfg.worker_q.put(r)
 
-	def locked(self):
-		"""
-		If some external code need to run across a number of different
-		calls into ObjectManager while blocking others they can use this method
-		to lock others out.
-		:return:
-		"""
-		return ObjectManagerLock(self.rlock)
-
 	@dbus.service.signal(
 		dbus_interface="org.freedesktop.DBus.ObjectManager",
 		signature='oa{sa{sv}}')
@@ -337,29 +328,3 @@ class ObjectManager(AutomatedProperties):
 			#	(uuid, lvm_id, str(path_create), path))
 
 			return path
-
-
-class ObjectManagerLock(object):
-	"""
-	The sole purpose of this class is to allow other code the ability to
-	lock the object manager using a `with` statement, eg.
-
-	with cfg.om.locked():
-		# Do stuff with object manager
-
-	This will ensure that the lock is always released (assuming this is done
-	correctly)
-	"""
-
-	def __init__(self, recursive_lock):
-		self._lock = recursive_lock
-
-	def __enter__(self):
-		# Acquire lock
-		self._lock.acquire()
-
-	# noinspection PyUnusedLocal
-	def __exit__(self, e_type, e_value, e_traceback):
-		# Release lock
-		self._lock.release()
-		self._lock = None

