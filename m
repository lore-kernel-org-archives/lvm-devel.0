From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:57 +0000 (GMT)
Subject: main - lvmdbusd: Handle no lastlog
Message-ID: <20220919155757.D9DCA3858C2D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=abf22df46c53968e5b064b2a4feb7b57e08fac09
Commit:        abf22df46c53968e5b064b2a4feb7b57e08fac09
Parent:        cef3c75dd496961cf7f2d2509fd694b9edf28421
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 12:05:06 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Handle no lastlog

Depending on when an occurs, it maynot have any information available for
lastlog.  In this case try to grab an error message from the original
response.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 5802d2d70..43609047b 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -164,12 +164,14 @@ class LVMShellProxy(object):
 			os.unlink(tmp_file)
 			os.rmdir(tmp_dir)
 
-	def get_error_msg(self):
-		# We got an error, lets go fetch the error message
+	def get_last_log(self):
 		self._write_cmd('lastlog\n')
+		report_json= self._read_response()[1]
+		return LVMShellProxy.get_error_msg(report_json)
 
-		# read everything from the STDOUT to the next prompt
-		stdout, report_json, stderr = self._read_response()
+	@staticmethod
+	def get_error_msg(report_json):
+		# Get the error message from the returned JSON
 		if 'log' in report_json:
 			error_msg = ""
 			# Walk the entire log array and build an error string
@@ -182,7 +184,7 @@ class LVMShellProxy(object):
 
 			return error_msg
 
-		return 'No error reason provided! (missing "log" section)'
+		return None
 
 	def call_lvm(self, argv, debug=False):
 		rc = 1
@@ -210,10 +212,18 @@ class LVMShellProxy(object):
 			ret_code = int(report_json['log'][-1:][0]['log_ret_code'])
 			# If we have an exported vg we get a log_ret_code == 5 when
 			# we do a 'fullreport'
+			# Note: 0 == error
 			if (ret_code == 1) or (ret_code == 5 and argv[0] == 'fullreport'):
 				rc = 0
 			else:
-				error_msg = self.get_error_msg()
+				# Depending on where lvm fails the command, it may not have anything
+				# to report for "lastlog", so we need to check for a message in the
+				# report json too.
+				error_msg = self.get_last_log()
+				if error_msg is None:
+					error_msg = LVMShellProxy.get_error_msg(report_json)
+					if error_msg is None:
+						error_msg = 'No error reason provided! (missing "log" section)'
 
 		if debug or rc != 0:
 			log_error(('CMD: %s' % cmd))

