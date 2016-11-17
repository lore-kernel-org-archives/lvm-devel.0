From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:46 +0000 (UTC)
Subject: master - lvmdbusd: Bubble up invalid JSON
Message-ID: <20161117173646.C5C2C60D85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1805cf336fc6608b71c9e74d9f072deb18582be
Commit:        a1805cf336fc6608b71c9e74d9f072deb18582be
Parent:        61f6be7d2b56177df4a855c048a954ced055ab0a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 16 15:45:05 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: Bubble up invalid JSON

If we get invalid JSON, lets bubble that up to the user.
---
 daemons/lvmdbusd/lvm_shell_proxy.py |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 9edf336..4cdb717 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -202,12 +202,20 @@ class LVMShellProxy(object):
 
 		# Parse the report to see what happened
 		if report and len(report):
-			json_result = json.loads(report)
-			if 'log' in json_result:
-				if json_result['log'][-1:][0]['log_ret_code'] == '1':
-					rc = 0
-				else:
-					error_msg = self.get_error_msg()
+			try:
+				json_result = json.loads(report)
+				if 'log' in json_result:
+					if json_result['log'][-1:][0]['log_ret_code'] == '1':
+						rc = 0
+					else:
+						error_msg = self.get_error_msg()
+			except ValueError:
+				# The json is bad?, lets dump out for debug
+				with open('/tmp/json_bad', 'w') as debug:
+					debug.write(report)
+
+				# Bubble up the invalid json.
+				error_msg = "Invalid json %s" % report
 
 		if debug or rc != 0:
 			log_error(('CMD: %s' % cmd))


