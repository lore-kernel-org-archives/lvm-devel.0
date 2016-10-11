From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 11 Oct 2016 18:18:45 +0000 (UTC)
Subject: master - lvmdbusd: Disable lvm abort on too much log output
Message-ID: <20161011181845.507C660DFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2830f722882d064a6ffbe143f5a580364bcba2e6
Commit:        2830f722882d064a6ffbe143f5a580364bcba2e6
Parent:        fe437a6e7d9367eecd977d2504db82469016c780
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 11 09:36:47 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Oct 11 13:16:57 2016 -0500

lvmdbusd: Disable lvm abort on too much log output

The commit:
https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=34c55d98eefd88f85476c0f62f0649c706bde6f0

introduced an abort if lvm logs too much.  In the case of utilizing
lvm shell this is a pretty normal occurance, so we will disable
when we use lvm shell.
---
 daemons/lvmdbusd/lvm_shell_proxy.py |    4 ++++
 test/api/dbustest.sh                |    4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 6e6d52a..9edf336 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -121,6 +121,10 @@ class LVMShellProxy(object):
 		local_env["LVM_REPORT_FD"] = "32"
 		local_env["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 
+		# Disable the abort logic if lvm logs too much, which easily happens
+		# when utilizing the lvm shell.
+		local_env["LVM_LOG_FILE_MAX_LINES"] = "0"
+
 		flags = fcntl(self.report_r, F_GETFL)
 		fcntl(self.report_r, F_SETFL, flags | os.O_NONBLOCK)
 
diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 16dc186..5ffe967 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -29,8 +29,4 @@ export LVM_BINARY=$TESTOLDPWD/../tools/lvm
 
 aux prepare_lvmdbusd
 
-# Lets limit testing until the lvm SIGABRT is fixed as
-# we are running into that when using the lvm shell
-export LVM_DBUS_TEST_SHELL=0
-
 $test_data_dir/dbus/lvmdbustest.py -v


