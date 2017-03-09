From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:41:29 -0500
Subject: master - lvmdbusd: Disable notify_dbus for service command use
Message-ID: <201703092241.v29MfT9A017982@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11cfc58976df33b810e28c0b652274158d683131
Commit:        11cfc58976df33b810e28c0b652274158d683131
Parent:        e53454d6de07de56736303dd2157c3859f6fa848
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 8 15:35:53 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbusd: Disable notify_dbus for service command use

Utilizing the --config option  we will utilize global/notify_dbus=0 so
that the service itself doesn't generate change events which it then needs to
process.
---
 daemons/lvmdbusd/cmdhandler.py      |    3 ++-
 daemons/lvmdbusd/lvm_shell_proxy.py |    4 +++-
 daemons/lvmdbusd/utils.py           |   22 ++++++++++++++++++++++
 3 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 31b7c5c..cbf6036 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -16,7 +16,7 @@ import traceback
 import os
 
 from lvmdbusd import cfg
-from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error
+from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error, add_no_notify
 from lvmdbusd.lvm_shell_proxy import LVMShellProxy
 
 try:
@@ -93,6 +93,7 @@ def call_lvm(command, debug=False):
 	# Prepend the full lvm executable so that we can run different versions
 	# in different locations on the same box
 	command.insert(0, cfg.LVM_CMD)
+	command = add_no_notify(command)
 
 	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True,
 					env=os.environ)
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index f3862a1..a26dd70 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -29,7 +29,7 @@ except ImportError:
 
 
 from lvmdbusd.cfg import LVM_CMD
-from lvmdbusd.utils import log_debug, log_error
+from lvmdbusd.utils import log_debug, log_error, add_no_notify
 
 SHELL_PROMPT = "lvm> "
 
@@ -206,6 +206,8 @@ class LVMShellProxy(object):
 				self.lvm_shell.returncode,
 				"Underlying lvm shell process is not present!")
 
+		argv = add_no_notify(argv)
+
 		# create the command string
 		cmd = " ".join(_quote_arg(arg) for arg in argv)
 		cmd += "\n"
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index b95f80a..bf2552c 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -499,6 +499,28 @@ def validate_tag(interface, tag):
 			% (tag, _ALLOWABLE_TAG_CH))
 
 
+def add_no_notify(cmdline):
+	"""
+	Given a command line to execute we will see if `--config` is present, if it
+	is we will add the global/notify_dbus=0 to it, otherwise we will append it
+	to the end
+	:param cmdline:
+	:return: cmdline with notify_dbus config option present
+	"""
+
+	if 'help' in cmdline:
+		return cmdline
+
+	if '--config' in cmdline:
+		for i in range(0, len(cmdline)):
+			if cmdline[i] == '--config':
+				cmdline[i] += "global/notify_dbus=0"
+				break
+	else:
+		cmdline.extend(['--config', 'global/notify_dbus=0'])
+	return cmdline
+
+
 # The methods below which start with mt_* are used to execute the desired code
 # on the the main thread of execution to alleviate any issues the dbus-python
 # library with regards to multi-threaded access.  Essentially, we are trying to


