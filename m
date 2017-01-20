From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:01 +0000 (UTC)
Subject: master - lvmcmd2lib: support new command
Message-ID: <20170120230401.6557B60D7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d80f9a107fc869d541a36c8c9d12c32589c34c12
Commit:        d80f9a107fc869d541a36c8c9d12c32589c34c12
Parent:        04a9cad499848cfc025d33ca28e9f657abc80ca3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 18 09:53:46 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:55:07 2017 +0100

lvmcmd2lib: support new command

Internal command which reads lvm.conf settins and passes it
via envvar to dmeventd monitoring thread.
---
 WHATS_NEW         |    1 +
 tools/lvmcmdlib.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5b735f..94411ae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support new internal command _dmeventd_thin_command.
   Introduce new dmeventd/thin_command configurable setting.
   Use new default units 'r' for displaying sizes.
   Also unmount mount point on top of MD device if using blkdeactivate -u.
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 276c8b3..0243768 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -83,7 +83,10 @@ int lvm2_run(void *handle, const char *cmdline)
 		memlock_inc_daemon(cmd);
 	} else if (!strcmp(cmdline, "_memlock_dec"))
 		memlock_dec_daemon(cmd);
-	else
+	else if (!strcmp(cmdline, "_dmeventd_thin_command")) {
+		if (setenv(cmdline, find_config_tree_str(cmd, dmeventd_thin_command_CFG, NULL), 1))
+			ret = ECMD_FAILED;
+	} else
 		ret = lvm_run_command(cmd, argc, argv);
 
       out:


