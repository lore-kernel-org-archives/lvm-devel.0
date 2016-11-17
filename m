From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:48 +0000 (UTC)
Subject: master - lvmdbusd: Extra report FD read on no data
Message-ID: <20161117173648.D44C5605F8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df92d330aaab92445cf93e42db4778757b424792
Commit:        df92d330aaab92445cf93e42db4778757b424792
Parent:        a1805cf336fc6608b71c9e74d9f072deb18582be
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 16 15:57:04 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: Extra report FD read on no data

Our expectation was that when using the lvm shell that when the lvm prompt
was read from stdout, that all other ouput had been written and flushed.
However, this doesn't appear to be the case.  Add extra read passes to
retrieve delayed report data.
---
 daemons/lvmdbusd/lvm_shell_proxy.py |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 4cdb717..193c844 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -42,16 +42,19 @@ def _quote_arg(arg):
 
 
 class LVMShellProxy(object):
-	def _read_until_prompt(self):
+	def _read_until_prompt(self, no_output=False):
 		stdout = ""
 		report = ""
 		stderr = ""
+		keep_reading = True
+		extra_passes = 2
 
 		# Try reading from all FDs to prevent one from filling up and causing
-		# a hang.  We are also assuming that we won't get the lvm prompt back
+		# a hang.  We were assuming that we won't get the lvm prompt back
 		# until we have already received all the output from stderr and the
-		# report descriptor too.
-		while not stdout.endswith(SHELL_PROMPT):
+		# report descriptor too, this is an incorrect assumption.  Lvm will
+		# return the prompt before we get the report!
+		while keep_reading:
 			try:
 				rd_fd = [
 					self.lvm_shell.stdout.fileno(),
@@ -90,6 +93,22 @@ class LVMShellProxy(object):
 				if self.lvm_shell.poll():
 					raise Exception(self.lvm_shell.returncode, "%s" % stderr)
 
+				if stdout.endswith(SHELL_PROMPT):
+					# It appears that lvm doesn't write the report and flush
+					# that before it writes the shell prompt as occasionally
+					# we get the prompt with no report.
+					if no_output:
+						keep_reading = False
+					else:
+						# Most of the time we have data, if we have none lets
+						# take another spin and hope we get it.
+						if len(report) != 0:
+							keep_reading = False
+						else:
+							extra_passes -= 1
+							if extra_passes <= 0:
+								keep_reading = False
+
 			except IOError as ioe:
 				log_debug(str(ioe))
 				pass
@@ -141,7 +160,7 @@ class LVMShellProxy(object):
 			fcntl(self.lvm_shell.stderr, F_SETFL, flags | os.O_NONBLOCK)
 
 			# wait for the first prompt
-			errors = self._read_until_prompt()[2]
+			errors = self._read_until_prompt(no_output=True)[2]
 			if errors and len(errors):
 				raise RuntimeError(errors)
 		except:


