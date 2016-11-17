From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:40 +0000 (UTC)
Subject: master - lvmdbusd: WS corrections
Message-ID: <20161117173640.73D4060D85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fbb90e4033518f2fbd6d2de45125381f01e1cbe
Commit:        2fbb90e4033518f2fbd6d2de45125381f01e1cbe
Parent:        dcdef9647b8de6aa958ad988de038c067a1f7199
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 16 10:46:09 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: WS corrections

Fix mixed spaces & tabs and other ws issues.
---
 daemons/lvmdbusd/cmdhandler.py |    4 ++--
 daemons/lvmdbusd/utils.py      |    2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index fa34a7a..dff91ad 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -732,8 +732,8 @@ def lv_retrieve_with_segments():
 				'lv_attr', 'lv_tags', 'vg_uuid', 'lv_active', 'data_lv',
 				'metadata_lv', 'seg_pe_ranges', 'segtype', 'lv_parent',
 				'lv_role', 'lv_layout',
-			    'snap_percent', 'metadata_percent', 'copy_percent',
-			    'sync_percent', 'lv_metadata_size', 'move_pv', 'move_pv_uuid']
+				'snap_percent', 'metadata_percent', 'copy_percent',
+				'sync_percent', 'lv_metadata_size', 'move_pv', 'move_pv_uuid']
 
 	cmd = _dc('lvs', ['-a', '-o', ','.join(columns)])
 	rc, out, err = call(cmd)
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 12b797e..561b158 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -17,6 +17,7 @@ import datetime
 
 import dbus
 from lvmdbusd import cfg
+# noinspection PyUnresolvedReferences
 from gi.repository import GLib
 import threading
 
@@ -508,6 +509,7 @@ def _async_result(call_back, results):
 	log_debug('Results = %s' % str(results))
 	call_back(results)
 
+
 # Return result in main thread
 def mt_async_result(call_back, results):
 	GLib.idle_add(_async_result, call_back, results)


