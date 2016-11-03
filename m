From: tasleson <tasleson@fedoraproject.org>
Date: Thu,  3 Nov 2016 23:43:03 +0000 (UTC)
Subject: master - lvmdbusd: Remove the periodic timer task
Message-ID: <20161103234303.BEE3D60EDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=461d340bd75556ef1f9fcda7ec29ebd5f044d861
Commit:        461d340bd75556ef1f9fcda7ec29ebd5f044d861
Parent:        ee0c9e7b2306cada41defedd0e5006b0ee2f3a21
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 3 18:27:22 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 3 18:38:10 2016 -0500

lvmdbusd: Remove the periodic timer task

This code is no longer needed because the back ground task has been
removed.  Will add back if we change the design and end up utilizing
multiple worker threads.
---
 daemons/lvmdbusd/background.py |   18 ------------------
 daemons/lvmdbusd/main.py       |    8 +++-----
 2 files changed, 3 insertions(+), 23 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index fc92b0c..f4cb539 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -7,7 +7,6 @@
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
-import threading
 import subprocess
 from . import cfg
 from .cmdhandler import options_to_cli_args
@@ -15,9 +14,6 @@ import dbus
 from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
 import os
 
-_rlock = threading.RLock()
-_thread_list = list()
-
 
 def pv_move_lv_cmd(move_options, lv_full_name,
 					pv_source, pv_source_range, pv_dest_range_list):
@@ -130,17 +126,3 @@ def merge(interface_name, lv_uuid, lv_name, merge_options, job_state):
 		raise dbus.exceptions.DBusException(
 			interface_name,
 			'LV with uuid %s and name %s not present!' % (lv_uuid, lv_name))
-
-
-def background_reaper():
-	with _rlock:
-		num_threads = len(_thread_list) - 1
-		if num_threads >= 0:
-			for i in range(num_threads, -1, -1):
-				_thread_list[i].join(0)
-				if not _thread_list[i].is_alive():
-					log_debug("Reaping thread: %s" % _thread_list[i].name)
-					_thread_list.pop(i)
-	return True
-
-
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 5fe1018..7d10bc3 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -22,7 +22,6 @@ from . import lvmdb
 from gi.repository import GLib
 from .fetch import load
 from .manager import Manager
-from .background import background_reaper
 import traceback
 import queue
 from . import udevwatch
@@ -64,6 +63,7 @@ def _discard_pending_refreshes():
 
 def process_request():
 	while cfg.run.value != 0:
+		# noinspection PyBroadException
 		try:
 			req = cfg.worker_q.get(True, 5)
 
@@ -156,10 +156,8 @@ def main():
 
 	cfg.db = lvmdb.DataStore(cfg.args.use_json)
 
-	# Periodically call function to reap threads that are created
-	GLib.timeout_add(5000, background_reaper)
-
-	# Using a thread to process requests.
+	# Using a thread to process requests, we cannot hang the dbus library
+	# thread that is handling the dbus interface
 	thread_list.append(threading.Thread(target=process_request))
 
 	cfg.load(refresh=False, emit_signal=False, need_main_thread=False)


