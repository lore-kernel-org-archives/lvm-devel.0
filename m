From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:29 +0000 (GMT)
Subject: main - lvmdbusd: Raise LvmBug exception for invalid JSON
Message-ID: <20220919155829.AB28E3858289@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4c03faa6556489444cf9402b2a35c46e7282ed3
Commit:        f4c03faa6556489444cf9402b2a35c46e7282ed3
Parent:        85fcbfd9d7697d3954c4f13a791f127205e260ee
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 31 15:08:09 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Raise LvmBug exception for invalid JSON

This will cause lvm debug data to get logged if it's available.
---
 daemons/lvmdbusd/cmdhandler.py | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 102844739..1a7943f01 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -621,9 +621,9 @@ def lvm_full_report_json():
 	rc, out, err = call(cmd)
 	# When we have an exported vg the exit code of lvs or fullreport will be 5
 	if rc == 0 or rc == 5:
-		# With the current implementation, if we are using the shell then we
-		# are using JSON and JSON is returned back to us as it was parsed to
-		# figure out if we completed OK or not
+		# If the 'call' implementation is lvmshell, the out is a dictionary as lvmshell has to
+		# parse the output to get the exit value.  When doing fork & exec, out is a string
+		# representing the JSON.  TODO: Make this consistent between implementations.
 		if cfg.SHELL_IN_USE:
 			assert(type(out) == dict)
 			return out
@@ -633,7 +633,7 @@ def lvm_full_report_json():
 			except json.decoder.JSONDecodeError as joe:
 				log_error("JSONDecodeError %s, \n JSON=\n%s\n" %
 							(str(joe), out))
-				raise joe
+				raise LvmBug("'fullreport' returned invalid JSON")
 
 	raise LvmBug("'fullreport' exited with code '%d'" % rc)
 

