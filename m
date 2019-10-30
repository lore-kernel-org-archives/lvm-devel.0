From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:31 -0400
Subject: master - lvmdbusd: Add cfg.vdo_support
Message-ID: <201910301544.x9UFiVHv016749@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d2ef05c5d0b57139d8405a2af947091f2c13942
Commit:        9d2ef05c5d0b57139d8405a2af947091f2c13942
Parent:        ceb808d26f56ebd75baa379780ad55163197a20f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Oct 7 16:57:05 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Add cfg.vdo_support

Will be used to add vdo interfaces on demand.
---
 daemons/lvmdbusd/cfg.py  |    3 +++
 daemons/lvmdbusd/main.py |    6 +++++-
 test/dbus/lvmdbustest.py |    2 +-
 test/dbus/testlib.py     |    1 +
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index be497d0..13143ef 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -79,6 +79,9 @@ hidden_lv = itertools.count()
 load = None
 event = None
 
+# Boolean to denote if lvm supports VDO integration
+vdo_support = False
+
 # Global cached state
 db = None
 
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 7f0a028..de384ce 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -29,7 +29,7 @@ from .utils import log_debug, log_error
 import argparse
 import os
 import sys
-from .cmdhandler import LvmFlightRecorder
+from .cmdhandler import LvmFlightRecorder, supports_vdo
 from .request import RequestEntry
 
 
@@ -127,6 +127,10 @@ def main():
 		log_error("You cannot specify --lvmshell and --nojson")
 		sys.exit(1)
 
+	# We will dynamically add interfaces which support vdo if it
+	# exists.
+	cfg.vdo_support = supports_vdo()
+
 	# List of threads that we start up
 	thread_list = []
 
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index d703a0a..1e4d40d 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -114,7 +114,7 @@ def get_objects():
 	rc = {
 		MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
 		THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
-		CACHE_POOL_INT: [], CACHE_LV_INT: []}
+		CACHE_POOL_INT: [], CACHE_LV_INT: [], VG_VDO_INT: []}
 
 	object_manager_object = bus.get_object(
 		BUS_NAME, "/com/redhat/lvmdbus1", introspect=False)
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 08f612c..872ed80 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -24,6 +24,7 @@ MANAGER_INT = BASE_INTERFACE + '.Manager'
 MANAGER_OBJ = '/' + BASE_INTERFACE.replace('.', '/') + '/Manager'
 PV_INT = BASE_INTERFACE + ".Pv"
 VG_INT = BASE_INTERFACE + ".Vg"
+VG_VDO_INT = BASE_INTERFACE + ".VgVdo"
 LV_INT = BASE_INTERFACE + ".Lv"
 THINPOOL_INT = BASE_INTERFACE + ".ThinPool"
 SNAPSHOT_INT = BASE_INTERFACE + ".Snapshot"


