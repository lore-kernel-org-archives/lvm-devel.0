From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:29:03 +0000 (UTC)
Subject: master - lvmdbusd/lvmdb.py: Make stand alone execution work
Message-ID: <20160829202903.DDA3860F09@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1870b3293a26f6d946e8451a10e8c9762ae9f31c
Commit:        1870b3293a26f6d946e8451a10e8c9762ae9f31c
Parent:        96a0604bd036d78af964392460d0309456b58b1a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 14:52:41 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

lvmdbusd/lvmdb.py: Make stand alone execution work

This was broken when the args were moved to cfg
---
 daemons/lvmdbusd/cmdhandler.py |   10 +++++-----
 daemons/lvmdbusd/utils.py      |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 877f17c..9b0c877 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -38,10 +38,6 @@ total_count = 0
 # at the same time.
 cmd_lock = threading.RLock()
 
-# The actual method which gets called to invoke the lvm command, can vary
-# from forking a new process to using lvm shell
-_t_call = None
-
 
 class LvmExecutionMeta(object):
 
@@ -113,12 +109,16 @@ def call_lvm(command, debug=False):
 		_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
 	if process.returncode == 0:
-		if cfg.args.debug and out[1] and len(out[1]) and 'help' not in command:
+		if cfg.args and cfg.args.debug and out[1] and len(out[1]) and \
+				'help' not in command:
 			log_error('WARNING: lvm is out-putting text to STDERR on success!')
 			_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
 	return process.returncode, stdout_text, stderr_text
 
+# The actual method which gets called to invoke the lvm command, can vary
+# from forking a new process to using lvm shell
+_t_call = call_lvm
 
 def _shell_cfg():
 	global _t_call
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 06301cd..7d217df 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -262,7 +262,7 @@ def _common_log(msg, *attributes):
 # @param msg    Message to output to stdout
 # @return None
 def log_debug(msg, *attributes):
-	if cfg.args.debug:
+	if cfg.args and cfg.args.debug:
 		_common_log(msg, *attributes)
 
 


