From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:20 +0000 (GMT)
Subject: main - lvmdbusd: Handle SIGINT quietly
Message-ID: <20220919155820.930413858438@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6e874922e05e2b163b7f03b61cd4fb51e0858f6
Commit:        e6e874922e05e2b163b7f03b61cd4fb51e0858f6
Parent:        0296e56073667216e6b1d7397880b02df8df54c8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Aug 26 11:10:24 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Handle SIGINT quietly

Change how we exit on SIGINT so that we don't output needless debug.
---
 daemons/lvmdbusd/cmdhandler.py         |  2 +-
 daemons/lvmdbusd/fetch.py              |  4 ++++
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 17 +++++++++--------
 daemons/lvmdbusd/main.py               |  2 ++
 daemons/lvmdbusd/request.py            |  3 +++
 5 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 11cd0f0cd..23104e93e 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -170,7 +170,7 @@ def call_lvm(command, debug=False, line_cb=None,
 		return process.returncode, stdout_text, stderr_text
 	else:
 		if cfg.run.value == 0:
-			raise Exception("Daemon is exiting!")
+			raise SystemExit
 		# We can bail out before the lvm command finished when we get a signal
 		# which is requesting we exit
 		return -errno.EINTR, "", "operation interrupted"
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 5cb98853a..6cf64f148 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -154,6 +154,8 @@ class StateUpdate(object):
 					obj.deferred = False
 
 				if len(queued_requests) == 0 and wait:
+					# Note: If we don't have anything for 2 seconds we will
+					# get a queue.Empty exception raised here
 					queued_requests.append(obj.queue.get(True, 2))
 
 				# Ok we have one or the deferred queue has some,
@@ -192,6 +194,8 @@ class StateUpdate(object):
 
 			except queue.Empty:
 				pass
+			except SystemExit:
+				break
 			except Exception as e:
 				exception_count += 1
 				if exception_count >= 5:
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 66c90c38a..feb93fbfa 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -109,6 +109,13 @@ class LVMShellProxy(object):
 				log_debug(str(ioe))
 				pass
 
+		if keep_reading and run.value == 0:
+			# We didn't complete as we are shutting down
+			# Try to clean up lvm shell process
+			log_debug("exiting lvm shell as we are shutting down")
+			self.exit_shell()
+			raise SystemExit
+
 		return stdout, report_json, stderr
 
 	def _write_cmd(self, cmd):
@@ -226,16 +233,10 @@ class LVMShellProxy(object):
 						error_msg = 'No error reason provided! (missing "log" section)'
 
 		if debug or rc != 0:
-			log_error(('CMD: %s' % cmd))
-			log_error(("EC = %d" % rc))
+			log_error(("CMD= %s" % cmd))
+			log_error(("EC= %d" % rc))
 			log_error(("ERROR_MSG=\n %s\n" % error_msg))
 
-			if run.value == 0:
-				# Try to clean up lvm shelll process
-				log_debug("exiting lvm shell as we are shutting down")
-				self.exit_shell()
-				raise Exception("Daemon is exiting!")
-
 		return rc, report_json, error_msg
 
 	def exit_shell(self):
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 3fcabe6b6..b485e0245 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -50,6 +50,8 @@ def process_request():
 			log_debug("Method complete: %s" % str(req.method))
 		except queue.Empty:
 			pass
+		except SystemExit:
+			break
 		except Exception:
 			st = traceback.format_exc()
 			utils.log_error("process_request exception: \n%s" % st)
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 546b85b23..d6024d99e 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -71,6 +71,9 @@ class RequestEntry(object):
 		try:
 			result = self.method(*self.arguments)
 			self.register_result(result)
+		except SystemExit as se:
+			self.register_error(-1, str(se), se)
+			raise se
 		except Exception as e:
 			# Use the request entry to return the result as the client may
 			# have gotten a job by the time we hit an error

