From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:25 +0000 (UTC)
Subject: master - lvmdbusd: Add data_lv and metadata_lv to cache pool interface
Message-ID: <20160610210625.376F660362@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e04705b305626d37cbd076b47d6ad37c9b1b282e
Commit:        e04705b305626d37cbd076b47d6ad37c9b1b282e
Parent:        3bf43a65fefbda1b2628fbbc77ad40e3780a8d84
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 15:03:02 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 15:28:42 2016 -0500

lvmdbusd: Add data_lv and metadata_lv to cache pool interface

See: https://bugzilla.redhat.com/show_bug.cgi?id=1342558
---
 daemons/lvmdbusd/lv.py |   46 +++++++++++++++++++++++++++++-----------------
 1 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 149547f..61cf7d3 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -311,6 +311,23 @@ class LvCommon(AutomatedProperties):
 
 # noinspection PyPep8Naming
 class Lv(LvCommon):
+	def _fetch_hidden(self, name):
+
+		# The name is vg/name
+		full_name = "%s/%s" % (self.vg_name_lookup(), name)
+
+		o = cfg.om.get_object_by_lvm_id(full_name)
+		if o:
+			return o.dbus_object_path()
+
+		return '/'
+
+	def _get_data_meta(self):
+
+		# Get the data
+		return (self._fetch_hidden(self.state.data_lv),
+				self._fetch_hidden(self.state.metadata_lv))
+
 	# noinspection PyUnusedLocal,PyPep8Naming
 	def __init__(self, object_path, object_state):
 		super(Lv, self).__init__(object_path, object_state)
@@ -634,23 +651,6 @@ class LvThinPool(Lv):
 	_DataLv_meta = ("o", THIN_POOL_INTERFACE)
 	_MetaDataLv_meta = ("o", THIN_POOL_INTERFACE)
 
-	def _fetch_hidden(self, name):
-
-		# The name is vg/name
-		full_name = "%s/%s" % (self.vg_name_lookup(), name)
-
-		o = cfg.om.get_object_by_lvm_id(full_name)
-		if o:
-			return o.dbus_object_path()
-
-		return '/'
-
-	def _get_data_meta(self):
-
-		# Get the data
-		return (self._fetch_hidden(self.state.data_lv),
-				self._fetch_hidden(self.state.metadata_lv))
-
 	def __init__(self, object_path, object_state):
 		super(LvThinPool, self).__init__(object_path, object_state)
 		self.set_interface(THIN_POOL_INTERFACE)
@@ -707,9 +707,21 @@ class LvThinPool(Lv):
 
 # noinspection PyPep8Naming
 class LvCachePool(Lv):
+	_DataLv_meta = ("o", CACHE_POOL_INTERFACE)
+	_MetaDataLv_meta = ("o", CACHE_POOL_INTERFACE)
+
 	def __init__(self, object_path, object_state):
 		super(LvCachePool, self).__init__(object_path, object_state)
 		self.set_interface(CACHE_POOL_INTERFACE)
+		self._data_lv, self._metadata_lv = self._get_data_meta()
+
+	@property
+	def DataLv(self):
+		return self._data_lv
+
+	@property
+	def MetaDataLv(self):
+		return self._metadata_lv
 
 	@staticmethod
 	def _cache_lv(lv_uuid, lv_name, lv_object_path, cache_options):


