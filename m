From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Jan 2017 13:56:46 +0000 (UTC)
Subject: master - toolcontext: action for LVM_RUN_BY_DMEVENTD env var
Message-ID: <20170123135646.C789360727@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec93f37b86977380b59080981fb912ff30dd80ab
Commit:        ec93f37b86977380b59080981fb912ff30dd80ab
Parent:        836eb122cec35c1f00281968d92f9d85e67652d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 23 14:24:27 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 23 14:55:47 2017 +0100

toolcontext: action for LVM_RUN_BY_DMEVENTD env var

When LVM_RUN_BY_DMEVENTD is set to 1, ensure there will
be no interaction with dmeventd.
---
 lib/commands/toolcontext.c |    3 +++
 man/lvm.8.in               |    5 +++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 2843bf8..678ee8a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -192,6 +192,9 @@ static int _get_env_vars(struct cmd_context *cmd)
 		}
 	}
 
+	if (strcmp((getenv("LVM_RUN_BY_DMEVENTD") ? : "0"), "1") == 0)
+		init_run_by_dmeventd(cmd);
+
 	return 1;
 }
 
diff --git a/man/lvm.8.in b/man/lvm.8.in
index f1ffc7a..cad724b 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -668,6 +668,11 @@ File descriptor to use for report output from LVM commands.
 Name of default command profile to use for LVM commands. This profile
 is overriden by direct use of \fB\-\-commandprofile\fP command line option.
 .TP
+.B LVM_RUN_BY_DMEVENTD
+This variable is normally set by dmeventd plugin to inform lvm2 command
+it is running from dmeventd plugin so lvm2 takes some extra action
+to avoid comunication and deadlocks with dmeventd.
+.TP
 .B LVM_SYSTEM_DIR
 Directory containing \fBlvm.conf\fP(5) and other LVM system files.
 Defaults to "\fI#DEFAULT_SYS_DIR#\fP".


