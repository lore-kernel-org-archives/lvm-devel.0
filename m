From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:45 +0000 (GMT)
Subject: main - lvmdbusd: Include lvm debug output for lvmshell
Message-ID: <20220919155845.9D689385829F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11c033c222bde7122b974464dbfb8d3c8734b19b
Commit:        11c033c222bde7122b974464dbfb8d3c8734b19b
Parent:        a4b7f988d88afa81fd8f1934482444f97a08d9dd
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Sep 9 10:03:35 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Include lvm debug output for lvmshell

Move the option to add the debug file into lvm_full_report_json so that
we collect the debug data when we fork & exec lvm and when we use lvm
shell.
---
 daemons/lvmdbusd/cmdhandler.py | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 1a7943f01..0e344d3ca 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -121,12 +121,6 @@ def call_lvm(command, debug=False, line_cb=None,
 	command.insert(0, cfg.LVM_CMD)
 	command = add_no_notify(command)
 
-	# If we are running the fullreport command, we will ask lvm to output the debug
-	# data, so we can have the required information for lvm to debug the fullreport failures.
-	if "fullreport" in command:
-		fn = cfg.lvmdebug.setup()
-		add_config_option(command, "--config", "log {level=7 file=%s syslog=0}" % fn)
-
 	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True,
 					env=os.environ)
 
@@ -618,6 +612,11 @@ def lvm_full_report_json():
 		'--reportformat', 'json'
 	])
 
+	# We are running the fullreport command, we will ask lvm to output the debug
+	# data, so we can have the required information for lvm to debug the fullreport failures.
+	fn = cfg.lvmdebug.setup()
+	add_config_option(cmd, "--config", "log {level=7 file=%s syslog=0}" % fn)
+
 	rc, out, err = call(cmd)
 	# When we have an exported vg the exit code of lvs or fullreport will be 5
 	if rc == 0 or rc == 5:

