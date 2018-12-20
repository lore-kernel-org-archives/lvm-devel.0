From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 20 Dec 2018 11:28:26 -0500
Subject: master - lvmdbusd: Handle exported VG(s)
Message-ID: <201812201628.wBKGSQif009368@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5bdcafff47ee6a2e57e0c57d18cbc36cf1a2973e
Commit:        5bdcafff47ee6a2e57e0c57d18cbc36cf1a2973e
Parent:        ab1f1a306bf8e146c1221786a1c1c24f8b71a377
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Dec 18 09:51:50 2018 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Dec 20 10:27:30 2018 -0600

lvmdbusd: Handle exported VG(s)

When a VG is exported, the 'fullreport' returns an exit code of 5, but
otherwise returns the data we are wanting.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/cmdhandler.py         |    3 ++-
 daemons/lvmdbusd/lvm_shell_proxy.py.in |    5 ++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index a9177c5..fde7f5e 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -497,7 +497,8 @@ def lvm_full_report_json():
 	])
 
 	rc, out, err = call(cmd)
-	if rc == 0:
+	# When we have an exported vg the exit code of lvs or fullreport will be 5
+	if rc == 0 or rc == 5:
 		# With the current implementation, if we are using the shell then we
 		# are using JSON and JSON is returned back to us as it was parsed to
 		# figure out if we completed OK or not
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 203de6f..b76b336 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -220,7 +220,10 @@ class LVMShellProxy(object):
 
 		# Parse the report to see what happened
 		if 'log' in report_json:
-			if report_json['log'][-1:][0]['log_ret_code'] == '1':
+			ret_code = int(report_json['log'][-1:][0]['log_ret_code'])
+			# If we have an exported vg we get a log_ret_code == 5 when
+			# we do a 'fullreport'
+			if (ret_code == 1) or (ret_code == 5 and argv[0] == 'fullreport'):
 				rc = 0
 			else:
 				error_msg = self.get_error_msg()


