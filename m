From: Tony Asleson <tasleson@sourceware.org>
Date: Tue, 29 Nov 2022 19:01:36 +0000 (GMT)
Subject: main - lvmdbusd: Move get_error_msg to utils
Message-ID: <20221129190136.41A813858D20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f60c494515ddccb20e4afb804edb6b9599e65c0
Commit:        8f60c494515ddccb20e4afb804edb6b9599e65c0
Parent:        61917fbac2302e1f0c56aa75437e6ea72834b30d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 10:00:39 2022 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 29 12:56:55 2022 -0600

lvmdbusd: Move get_error_msg to utils

Moving this so we can re-use outside of lvm_shell_proxy.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 23 +++--------------------
 daemons/lvmdbusd/utils.py              | 17 +++++++++++++++++
 2 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index ac6d51e65..37d73218b 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -28,7 +28,7 @@ except ImportError:
 
 import lvmdbusd.cfg as cfg
 from lvmdbusd.utils import log_debug, log_error, add_no_notify, make_non_block,\
-			read_decoded, extract_stack_trace, LvmBug
+			read_decoded, extract_stack_trace, LvmBug, get_error_msg
 
 SHELL_PROMPT = "lvm> "
 
@@ -191,24 +191,7 @@ class LVMShellProxy(object):
 	def get_last_log(self):
 		self._write_cmd('lastlog\n')
 		report_json = self._read_response()[1]
-		return LVMShellProxy.get_error_msg(report_json)
-
-	@staticmethod
-	def get_error_msg(report_json):
-		# Get the error message from the returned JSON
-		if 'log' in report_json:
-			error_msg = ""
-			# Walk the entire log array and build an error string
-			for log_entry in report_json['log']:
-				if log_entry['log_type'] == "error":
-					if error_msg:
-						error_msg += ', ' + log_entry['log_message']
-					else:
-						error_msg = log_entry['log_message']
-
-			return error_msg
-
-		return None
+		return get_error_msg(report_json)
 
 	def call_lvm(self, argv, debug=False):
 		rc = 1
@@ -245,7 +228,7 @@ class LVMShellProxy(object):
 				# report json too.
 				error_msg = self.get_last_log()
 				if error_msg is None:
-					error_msg = LVMShellProxy.get_error_msg(report_json)
+					error_msg = get_error_msg(report_json)
 					if error_msg is None:
 						error_msg = 'No error reason provided! (missing "log" section)'
 
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 5aecb1fff..0b81591b2 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -859,3 +859,20 @@ class LvmDebugData:
 		self._close_fd()
 		# In case lvm_complete doesn't get called.
 		self._remove_file()
+
+
+def get_error_msg(report_json):
+	# Get the error message from the returned JSON
+	if 'log' in report_json:
+		error_msg = ""
+		# Walk the entire log array and build an error string
+		for log_entry in report_json['log']:
+			if log_entry['log_type'] == "error":
+				if error_msg:
+					error_msg += ', ' + log_entry['log_message']
+				else:
+					error_msg = log_entry['log_message']
+
+		return error_msg
+
+	return None

