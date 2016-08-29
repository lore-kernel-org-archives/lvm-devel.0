From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:32 +0000 (UTC)
Subject: master - lvmdbusd: Always fork & exec background commands
Message-ID: <20160829202832.17CEF60359@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e37e7fde4e683572fa3d9a640821ba9bd4bb3d0
Commit:        7e37e7fde4e683572fa3d9a640821ba9bd4bb3d0
Parent:        784b46ef2a3b674def64a1185733122b300bb22c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Aug 12 15:19:03 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:55 2016 -0500

lvmdbusd: Always fork & exec background commands

Our background job support requires a separate instance of lvm.  Use the
full lvm command to do so.
---
 daemons/lvmdbusd/background.py |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 8078b66..0c0b509 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -15,6 +15,7 @@ from .cmdhandler import options_to_cli_args
 import dbus
 from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
 import traceback
+import os
 
 _rlock = threading.RLock()
 _thread_list = list()
@@ -130,8 +131,16 @@ def background_execute(command, background_job):
 	# hit a code bug we will silently exit this thread without anyone being
 	# the wiser.
 	try:
+		# We need to execute these command stand alone by forking & exec'ing
+		# the command always!
+		command.insert(0, cfg.LVM_CMD)
 		process = subprocess.Popen(command, stdout=subprocess.PIPE,
+								   env=os.environ,
 									stderr=subprocess.PIPE, close_fds=True)
+
+		log_debug("Background process for %s is %d" %
+				  (str(command), process.pid))
+
 		lines_iterator = iter(process.stdout.readline, b"")
 		for line in lines_iterator:
 			line_str = line.decode("utf-8")
@@ -150,8 +159,12 @@ def background_execute(command, background_job):
 
 		if process.returncode == 0:
 			background_job.Percent = 100
+		else:
+			log_error("Failed to execute background job %s, STDERR= %s"
+					  % (str(command), out[1]))
 
 		background_job.set_result(process.returncode, out[1])
+		log_debug("Background process %d complete!" % process.pid)
 
 	except Exception:
 		# In the unlikely event that we blow up, we need to unblock caller which


