From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  2 Nov 2016 21:47:55 +0000 (UTC)
Subject: master - lvmdbusd: Use timer instead of thread
Message-ID: <20161102214755.B3EEB60AD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8e8439b3dc037fd73a2eab94e7e796cfb8283a1
Commit:        c8e8439b3dc037fd73a2eab94e7e796cfb8283a1
Parent:        68e7d3496517a70e50edaceff906ad1da23821a6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 1 17:42:14 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 2 16:35:45 2016 -0500

lvmdbusd: Use timer instead of thread

We had a thread sitting around for cleaning up other processes, changed to
a periodic timer task.
---
 daemons/lvmdbusd/background.py |   21 +++++++++------------
 daemons/lvmdbusd/main.py       |    5 ++---
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 6190f0d..ab0ac2a 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -10,7 +10,6 @@
 import threading
 import subprocess
 from . import cfg
-import time
 from .cmdhandler import options_to_cli_args
 import dbus
 from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
@@ -112,17 +111,15 @@ def merge(interface_name, lv_uuid, lv_name, merge_options, job_state):
 
 
 def background_reaper():
-	while cfg.run.value != 0:
-		with _rlock:
-			num_threads = len(_thread_list) - 1
-			if num_threads >= 0:
-				for i in range(num_threads, -1, -1):
-					_thread_list[i].join(0)
-					if not _thread_list[i].is_alive():
-						log_debug("Removing thread: %s" % _thread_list[i].name)
-						_thread_list.pop(i)
-
-		time.sleep(3)
+	with _rlock:
+		num_threads = len(_thread_list) - 1
+		if num_threads >= 0:
+			for i in range(num_threads, -1, -1):
+				_thread_list[i].join(0)
+				if not _thread_list[i].is_alive():
+					log_debug("Reaping thread: %s" % _thread_list[i].name)
+					_thread_list.pop(i)
+	return True
 
 
 def background_execute(command, background_job):
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 9f7b928..2dca703 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -156,9 +156,8 @@ def main():
 
 	cfg.db = lvmdb.DataStore(cfg.args.use_json)
 
-	# Start up thread to monitor pv moves
-	thread_list.append(
-		threading.Thread(target=background_reaper, name="pv_move_reaper"))
+	# Periodically call function to reap threads that are created
+	GLib.timeout_add(5000, background_reaper)
 
 	# Using a thread to process requests.
 	thread_list.append(threading.Thread(target=process_request))


