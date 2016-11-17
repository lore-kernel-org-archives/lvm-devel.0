From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:32 +0000 (UTC)
Subject: master - lvmdbusd: Long running operations use own thread
Message-ID: <20161117173632.04524605B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72a943f720ba49517592fd4040f58517a0b65852
Commit:        72a943f720ba49517592fd4040f58517a0b65852
Parent:        fa444906bbe5eda22aa5823ef2f9e196b0c15602
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Nov 11 09:46:12 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: Long running operations use own thread

Anything that ends up using polld will be done in a unique thread
so that we don't hold off other operations from running concurrently.
---
 daemons/lvmdbusd/background.py |   14 ++++++++++++++
 daemons/lvmdbusd/fetch.py      |    4 +++-
 daemons/lvmdbusd/lv.py         |    4 ++--
 daemons/lvmdbusd/main.py       |    4 ++--
 4 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index f4cb539..19a2e6c 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -13,6 +13,7 @@ from .cmdhandler import options_to_cli_args
 import dbus
 from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
 import os
+import threading
 
 
 def pv_move_lv_cmd(move_options, lv_full_name,
@@ -126,3 +127,16 @@ def merge(interface_name, lv_uuid, lv_name, merge_options, job_state):
 		raise dbus.exceptions.DBusException(
 			interface_name,
 			'LV with uuid %s and name %s not present!' % (lv_uuid, lv_name))
+
+
+def _run_cmd(req):
+	log_debug(
+		"_run_cmd: Running method: %s with args %s" %
+		(str(req.method), str(req.arguments)))
+	req.run_cmd()
+	log_debug("_run_cmd: complete!")
+
+
+def cmd_runner(request):
+	t = threading.Thread(target=_run_cmd, args=(request,))
+	t.start()
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 409b19d..78c3a4b 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -108,7 +108,9 @@ class StateUpdate(object):
 				except queue.Empty:
 					pass
 
-				log_debug("Processing %d updates!" % len(queued_requests))
+				if len(queued_requests) > 1:
+					log_debug("Processing %d updates!" % len(queued_requests),
+							'bg_black', 'fg_light_green')
 
 				# We have what we can, run the update with the needed options
 				for i in queued_requests:
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index e130ae4..fd7aa1e 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -494,7 +494,7 @@ class Lv(LvCommon):
 				pv_dests_and_ranges, move_options, job_state), cb, cbe, False,
 				job_state)
 
-		cfg.worker_q.put(r)
+		background.cmd_runner(r)
 
 	@staticmethod
 	def _snap_shot(lv_uuid, lv_name, name, optional_size,
@@ -916,4 +916,4 @@ class LvSnapShot(Lv):
 							(SNAPSHOT_INTERFACE, self.Uuid, self.lvm_id,
 							merge_options, job_state), cb, cbe, False,
 							job_state)
-		cfg.worker_q.put(r)
+		background.cmd_runner(r)
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 6e782d2..4b9f94e 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -87,8 +87,6 @@ def main():
 		log_error("You cannot specify --lvmshell and --nojson")
 		sys.exit(1)
 
-	cmdhandler.set_execution(cfg.args.use_lvm_shell)
-
 	# List of threads that we start up
 	thread_list = []
 
@@ -102,6 +100,8 @@ def main():
 	dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
 	dbus.mainloop.glib.threads_init()
 
+	cmdhandler.set_execution(cfg.args.use_lvm_shell)
+
 	if use_session:
 		cfg.bus = dbus.SessionBus()
 	else:


