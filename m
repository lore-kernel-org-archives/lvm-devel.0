From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 30 Jan 2014 12:06:41 +0000 (UTC)
Subject: master - tools: Add internal hosttags command.
Message-ID: <20140130120641.EF5B4611E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a9e7a57e37d6fbab2dcd3c03192fd092811756f
Commit:        7a9e7a57e37d6fbab2dcd3c03192fd092811756f
Parent:        e833d84e67f62b9be4f5900381f6e32c4ecf66ca
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 30 12:06:15 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 30 12:06:15 2014 +0000

tools: Add internal hosttags command.

diff --git a/lib/display/display.c b/lib/display/display.c
index 1babffc..9f52f0b 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -912,6 +912,15 @@ void display_formats(const struct cmd_context *cmd)
 	}
 }

+void display_hosttags(const struct cmd_context *cmd)
+{
+	const struct str_list *sl;
+
+	dm_list_iterate_items(sl, &cmd->tags) {
+		log_print("%s", sl->str);
+	}
+}
+
 void display_segtypes(const struct cmd_context *cmd)
 {
 	const struct segment_type *segtype;
diff --git a/lib/display/display.h b/lib/display/display.h
index 077fff4..cfac354 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -52,6 +52,7 @@ void vgdisplay_colons(const struct volume_group *vg);
 void vgdisplay_short(const struct volume_group *vg);

 void display_formats(const struct cmd_context *cmd);
+void display_hosttags(const struct cmd_context *cmd);
 void display_segtypes(const struct cmd_context *cmd);

 void display_name_error(name_error_t name_error);
diff --git a/man/lvm.8.in b/man/lvm.8.in
index c377b35..34f6764 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -52,6 +52,8 @@ loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
 \fBhelp\fP \(em Display the help text.
 .TP
+\fBhosttags\fP \(em Display any tags defined on this host.
+.TP
 \fBpvdata\fP \(em Not implemented in LVM2.
 .TP
 \fBsegtypes\fP \(em Display recognised Logical Volume segment types.
diff --git a/tools/Makefile.in b/tools/Makefile.in
index f18d3ea..32f5844 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -19,6 +19,7 @@ top_builddir = @top_builddir@
 SOURCES =\
 	dumpconfig.c \
 	formats.c \
+	hosttags.c \
 	lvchange.c \
 	lvconvert.c \
 	lvcreate.c \
@@ -166,7 +167,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)

 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
+		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|hosttags|pvdata|segtypes|version) *$$' > .commands

 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/tools/commands.h b/tools/commands.h
index 938898b..08aae9a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -80,6 +80,11 @@ xx(help,
    PERMITTED_READ_ONLY,
    "help <command>" "\n")

+xx(hosttags,
+   "List tags defined on this host",
+   PERMITTED_READ_ONLY,
+   "hosttags\n")
+
 /*********
 xx(lvactivate,
    "Activate logical volume on given partition(s)",
diff --git a/tools/hosttags.c b/tools/hosttags.c
new file mode 100644
index 0000000..09ff8d0
--- /dev/null
+++ b/tools/hosttags.c
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
+int hosttags(struct cmd_context *cmd, int argc __attribute__((unused)),
+	     char **argv __attribute__((unused)))
+{
+	display_hosttags(cmd);
+
+	return ECMD_PROCESSED;
+}
---
 lib/display/display.c |    9 +++++++++
 lib/display/display.h |    1 +
 man/lvm.8.in          |    2 ++
 tools/Makefile.in     |    3 ++-
 tools/commands.h      |    5 +++++
 5 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 1babffc..9f52f0b 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -912,6 +912,15 @@ void display_formats(const struct cmd_context *cmd)
 	}
 }
 
+void display_hosttags(const struct cmd_context *cmd)
+{
+	const struct str_list *sl;
+
+	dm_list_iterate_items(sl, &cmd->tags) {
+		log_print("%s", sl->str);
+	}
+}
+
 void display_segtypes(const struct cmd_context *cmd)
 {
 	const struct segment_type *segtype;
diff --git a/lib/display/display.h b/lib/display/display.h
index 077fff4..cfac354 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -52,6 +52,7 @@ void vgdisplay_colons(const struct volume_group *vg);
 void vgdisplay_short(const struct volume_group *vg);
 
 void display_formats(const struct cmd_context *cmd);
+void display_hosttags(const struct cmd_context *cmd);
 void display_segtypes(const struct cmd_context *cmd);
 
 void display_name_error(name_error_t name_error);
diff --git a/man/lvm.8.in b/man/lvm.8.in
index c377b35..34f6764 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -52,6 +52,8 @@ loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
 \fBhelp\fP \(em Display the help text.
 .TP
+\fBhosttags\fP \(em Display any tags defined on this host.
+.TP
 \fBpvdata\fP \(em Not implemented in LVM2.
 .TP
 \fBsegtypes\fP \(em Display recognised Logical Volume segment types.
diff --git a/tools/Makefile.in b/tools/Makefile.in
index f18d3ea..32f5844 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -19,6 +19,7 @@ top_builddir = @top_builddir@
 SOURCES =\
 	dumpconfig.c \
 	formats.c \
+	hosttags.c \
 	lvchange.c \
 	lvconvert.c \
 	lvcreate.c \
@@ -166,7 +167,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
+		egrep -v '^ *(|#.*|devtypes|dumpconfig|formats|help|hosttags|pvdata|segtypes|version) *$$' > .commands
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/tools/commands.h b/tools/commands.h
index 938898b..08aae9a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -80,6 +80,11 @@ xx(help,
    PERMITTED_READ_ONLY,
    "help <command>" "\n")
 
+xx(hosttags,
+   "List tags defined on this host",
+   PERMITTED_READ_ONLY,
+   "hosttags\n")
+
 /*********
 xx(lvactivate,
    "Activate logical volume on given partition(s)",


