From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 17:27:47 +0000 (UTC)
Subject: master - systemid: Add built-in systemid command.
Message-ID: <20150223172747.8BC1D61260@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36a6c0df46a09657cb92908d41d272bc6b8a722d
Commit:        36a6c0df46a09657cb92908d41d272bc6b8a722d
Parent:        fcebf27a9ff52838e5730b82774effd1bf123b18
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 17:26:50 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 17:26:50 2015 +0000

systemid: Add built-in systemid command.

Make it easy to find the system ID when testing.
Also show in general debug output.
---
 WHATS_NEW          |    1 +
 man/lvm.8.in       |    2 ++
 tools/Makefile.in  |    2 +-
 tools/commands.h   |    5 +++++
 tools/lvmcmdline.c |   10 ++++++++++
 5 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7bf4dfb..fa4e2b0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Add 'lvm systemid' to display the current system ID.
   Fix configure to properly recognize --with-default-raid10-segtype option.
   Do not refresh filters/rescan if no signature is wiped during pvcreate.
   Enforce none external dev info for wiping during pvcreate to avoid races.
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 766b8aa..2faaba4 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -56,6 +56,8 @@ loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
 \fBsegtypes\fP \(em Display recognised Logical Volume segment types.
 .TP
+\fBsystemid\fP \(em Display the system ID, if any, currently set on this host.
+.TP
 \fBtags\fP \(em Display any tags defined on this host.
 .TP
 \fBversion\fP \(em Display version information.
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 6171322..5c1583f 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -166,7 +166,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|pvdata|segtypes|tags|version) *$$' > .commands
+		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/tools/commands.h b/tools/commands.h
index 15a1bb1..05ee186 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -890,6 +890,11 @@ xx(segtypes,
    PERMITTED_READ_ONLY,
    "segtypes\n")
 
+xx(systemid,
+   "Display the system ID, if any, currently set on this host",
+   PERMITTED_READ_ONLY,
+   "systemid\n")
+
 xx(tags,
    "List tags defined on this host",
    PERMITTED_READ_ONLY,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e586777..6bdb00b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -977,6 +977,15 @@ static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 	return 1;
 }
 
+int systemid(struct cmd_context *cmd __attribute__((unused)),
+	     int argc __attribute__((unused)),
+	     char **argv __attribute__((unused)))
+{
+	log_print("System ID: %s", cmd->system_id ? : "");
+
+	return ECMD_PROCESSED;
+}
+
 int version(struct cmd_context *cmd __attribute__((unused)),
 	    int argc __attribute__((unused)),
 	    char **argv __attribute__((unused)))
@@ -1456,6 +1465,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	init_dmeventd_monitor(monitoring);
 
 	log_debug("Processing: %s", cmd->cmd_line);
+	log_debug("System ID: %s", cmd->system_id ? : "");
 
 #ifdef O_DIRECT_SUPPORT
 	log_debug("O_DIRECT will be used");


