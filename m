From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 30 Jan 2014 13:13:13 +0000 (UTC)
Subject: master - tools: Add internal tags command.
Message-ID: <20140130131313.D074760EFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83358d4c039a36d5ef4b42b2213d73bb72ea7c26
Commit:        83358d4c039a36d5ef4b42b2213d73bb72ea7c26
Parent:        e833d84e67f62b9be4f5900381f6e32c4ecf66ca
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 30 13:09:15 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 30 13:09:15 2014 +0000

tools: Add internal tags command.

---
 WHATS_NEW             |    1 +
 lib/display/display.c |    9 +++++++++
 lib/display/display.h |    1 +
 man/lvm.8.in          |    2 ++
 tools/Makefile.in     |    3 ++-
 tools/commands.h      |    5 +++++
 tools/tags.c          |   23 +++++++++++++++++++++++
 7 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d28ec3c..25293e6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add internal tags command to display any tags defined on the host.
   Prohibit use of external origin with size incompatible with thin pool.
   Avoid trying to convert single to thin pool and volume at the same time.
   Add support for partitions on ZFS zvol.
diff --git a/lib/display/display.c b/lib/display/display.c
index 1babffc..9b4f828 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -921,6 +921,15 @@ void display_segtypes(const struct cmd_context *cmd)
 	}
 }
 
+void display_tags(const struct cmd_context *cmd)
+{
+	const struct str_list *sl;
+
+	dm_list_iterate_items(sl, &cmd->tags) {
+		log_print("%s", sl->str);
+	}
+}
+
 void display_name_error(name_error_t name_error)
 {
 	if (name_error != NAME_VALID) {
diff --git a/lib/display/display.h b/lib/display/display.h
index 077fff4..c58df45 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -53,6 +53,7 @@ void vgdisplay_short(const struct volume_group *vg);
 
 void display_formats(const struct cmd_context *cmd);
 void display_segtypes(const struct cmd_context *cmd);
+void display_tags(const struct cmd_context *cmd);
 
 void display_name_error(name_error_t name_error);
 
diff --git a/man/lvm.8.in b/man/lvm.8.in
index c377b35..564e98b 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -56,6 +56,8 @@ loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
 \fBsegtypes\fP \(em Display recognised Logical Volume segment types.
 .TP
+\fBtags\fP \(em Display any tags defined on this host.
+.TP
 \fBversion\fP \(em Display version information.
 .LP
 .SH COMMANDS
diff --git a/tools/Makefile.in b/tools/Makefile.in
index f18d3ea..253c404 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -43,6 +43,7 @@ SOURCES =\
 	pvscan.c \
 	reporter.c \
 	segtypes.c \
+	tags.c \
 	toollib.c \
 	vgcfgbackup.c \
 	vgcfgrestore.c \
@@ -166,7 +167,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
+		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|pvdata|segtypes|tags|version) *$$' > .commands
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/tools/commands.h b/tools/commands.h
index 938898b..b4ae6de 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -789,6 +789,11 @@ xx(segtypes,
    PERMITTED_READ_ONLY,
    "segtypes\n")
 
+xx(tags,
+   "List tags defined on this host",
+   PERMITTED_READ_ONLY,
+   "tags\n")
+
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
    PERMITTED_READ_ONLY,
diff --git a/tools/tags.c b/tools/tags.c
new file mode 100644
index 0000000..bbb446a
--- /dev/null
+++ b/tools/tags.c
@@ -0,0 +1,23 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "tools.h"
+
+int tags(struct cmd_context *cmd, int argc __attribute__((unused)),
+	     char **argv __attribute__((unused)))
+{
+	display_tags(cmd);
+
+	return ECMD_PROCESSED;
+}


