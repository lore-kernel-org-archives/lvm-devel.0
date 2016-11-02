From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  2 Nov 2016 21:48:00 +0000 (UTC)
Subject: master - lvmdbusd: Execute load in main thread
Message-ID: <20161102214800.04FF760AD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38dd79307a51faedb75e092a7913781e6eb88902
Commit:        38dd79307a51faedb75e092a7913781e6eb88902
Parent:        24803bbaadd8bd497e2ca337786b01725df61736
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 1 17:50:10 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 2 16:38:49 2016 -0500

lvmdbusd: Execute load in main thread

We will fetch the lvm state in non-main thread and only process the new
data with the main thread to prevent hanging the main thread event loop.

ref. https://bugs.freedesktop.org/show_bug.cgi?id=98521
---
 daemons/lvmdbusd/fetch.py |   33 +++++++++++++++++++++++++--------
 daemons/lvmdbusd/main.py  |    2 +-
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 51f130f..7626460 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -11,20 +11,37 @@ from .pv import load_pvs
 from .vg import load_vgs
 from .lv import load_lvs
 from . import cfg
+from .utils import MThreadRunner, log_debug
 
 
-def load(refresh=True, emit_signal=True, cache_refresh=True, log=True):
+def _main_thread_load(refresh=True, emit_signal=True):
 	num_total_changes = 0
 
+	num_total_changes += load_pvs(
+		refresh=refresh,
+		emit_signal=emit_signal,
+		cache_refresh=False)[1]
+	num_total_changes += load_vgs(
+		refresh=refresh,
+		emit_signal=emit_signal,
+		cache_refresh=False)[1]
+	num_total_changes += load_lvs(
+		refresh=refresh,
+		emit_signal=emit_signal,
+		cache_refresh=False)[1]
+
+	return num_total_changes
+
+
+def load(refresh=True, emit_signal=True, cache_refresh=True, log=True,
+			need_main_thread=True):
 	# Go through and load all the PVs, VGs and LVs
 	if cache_refresh:
 		cfg.db.refresh(log)
 
-	num_total_changes += load_pvs(refresh=refresh, emit_signal=emit_signal,
-									cache_refresh=False)[1]
-	num_total_changes += load_vgs(refresh=refresh, emit_signal=emit_signal,
-									cache_refresh=False)[1]
-	num_total_changes += load_lvs(refresh=refresh, emit_signal=emit_signal,
-									cache_refresh=False)[1]
+	if need_main_thread:
+		rc = MThreadRunner(_main_thread_load, refresh, emit_signal).done()
+	else:
+		rc = _main_thread_load(refresh, emit_signal)
 
-	return num_total_changes
+	return rc
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 2dca703..93e035f 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -162,7 +162,7 @@ def main():
 	# Using a thread to process requests.
 	thread_list.append(threading.Thread(target=process_request))
 
-	cfg.load(refresh=False, emit_signal=False)
+	cfg.load(refresh=False, emit_signal=False, need_main_thread=False)
 	cfg.loop = GLib.MainLoop()
 
 	for process in thread_list:


