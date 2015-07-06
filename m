From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Jul 2015 20:56:31 +0000 (UTC)
Subject: master - lvmetactl: program to interact with lvmetad
Message-ID: <20150706205631.2E582602FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d16332be72ff46d90b5245d25c4aa471913f0e91
Commit:        d16332be72ff46d90b5245d25c4aa471913f0e91
Parent:        6a8cc1dcd41f12a48108744b9070405169e7853f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 21 09:42:20 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 6 15:54:22 2015 -0500

lvmetactl: program to interact with lvmetad

This is not installed; it's only a developer utility
at this point.
---
 daemons/lvmetad/Makefile.in |    6 +-
 daemons/lvmetad/lvmetactl.c |  183 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 188 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index 765128c..090bb76 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -18,7 +18,7 @@ top_builddir = @top_builddir@
 SOURCES = lvmetad-core.c
 SOURCES2 = testclient.c
 
-TARGETS = lvmetad
+TARGETS = lvmetad lvmetactl
 
 .PHONY: install_lvmetad
 
@@ -41,6 +41,10 @@ lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
 
+lvmetactl: lvmetactl.o $(top_builddir)/libdaemon/client/libdaemonclient.a \
+	$(top_builddir)/libdaemon/server/libdaemonserver.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmetactl.o $(LVMLIBS)
+
 # TODO: No idea. No idea how to test either.
 #ifneq ("$(CFLOW_CMD)", "")
 #CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/daemons/lvmetad/lvmetactl.c b/daemons/lvmetad/lvmetactl.c
new file mode 100644
index 0000000..2c1c9b9
--- /dev/null
+++ b/daemons/lvmetad/lvmetactl.c
@@ -0,0 +1,183 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#include "tool.h"
+
+#include "lvmetad-client.h"
+
+daemon_handle h;
+
+static void print_reply(daemon_reply reply)
+{
+	const char *a = daemon_reply_str(reply, "response", NULL);
+	const char *b = daemon_reply_str(reply, "status", NULL);
+	const char *c = daemon_reply_str(reply, "reason", NULL);
+
+	printf("response \"%s\" status \"%s\" reason \"%s\"\n",
+	       a ? a : "", b ? b : "", c ? c : "");
+}
+
+int main(int argc, char **argv)
+{
+	daemon_reply reply;
+	char *cmd;
+	char *uuid;
+	char *name;
+	int val;
+	int ver;
+
+	if (argc < 2) {
+		printf("lvmeta dump\n");
+		printf("lvmeta pv_list\n");
+		printf("lvmeta vg_list\n");
+		printf("lvmeta vg_lookup_name <name>\n");
+		printf("lvmeta vg_lookup_uuid <uuid>\n");
+		printf("lvmeta pv_lookup_uuid <uuid>\n");
+		printf("lvmeta set_global_invalid 0|1\n");
+		printf("lvmeta get_global_invalid\n");
+		printf("lvmeta set_vg_version <uuid> <version>\n");
+		printf("lvmeta vg_lock_type <uuid>\n");
+		return -1;
+	}
+
+	cmd = argv[1];
+
+	h = lvmetad_open(NULL);
+
+	if (!strcmp(cmd, "dump")) {
+		reply = daemon_send_simple(h, "dump",
+					   "token = %s", "skip",
+					   NULL);
+		printf("%s\n", reply.buffer.mem);
+
+	} else if (!strcmp(cmd, "pv_list")) {
+		reply = daemon_send_simple(h, "pv_list",
+					   "token = %s", "skip",
+					   NULL);
+		printf("%s\n", reply.buffer.mem);
+
+	} else if (!strcmp(cmd, "vg_list")) {
+		reply = daemon_send_simple(h, "vg_list",
+					   "token = %s", "skip",
+					   NULL);
+		printf("%s\n", reply.buffer.mem);
+
+	} else if (!strcmp(cmd, "set_global_invalid")) {
+		if (argc < 3) {
+			printf("set_global_invalid 0|1\n");
+			return -1;
+		}
+		val = atoi(argv[2]);
+
+		reply = daemon_send_simple(h, "set_global_info",
+					   "global_invalid = %d", val,
+					   "token = %s", "skip",
+					   NULL);
+		print_reply(reply);
+
+	} else if (!strcmp(cmd, "get_global_invalid")) {
+		reply = daemon_send_simple(h, "get_global_info",
+					   "token = %s", "skip",
+					   NULL);
+		printf("%s\n", reply.buffer.mem);
+
+	} else if (!strcmp(cmd, "set_vg_version")) {
+		if (argc < 4) {
+			printf("set_vg_version <uuid> <ver>\n");
+			return -1;
+		}
+		uuid = argv[2];
+		ver = atoi(argv[3]);
+
+		reply = daemon_send_simple(h, "set_vg_info",
+					   "uuid = %s", uuid,
+					   "version = %d", ver,
+					   "token = %s", "skip",
+					   NULL);
+		print_reply(reply);
+
+	} else if (!strcmp(cmd, "vg_lookup_name")) {
+		if (argc < 3) {
+			printf("vg_lookup_name <name>\n");
+			return -1;
+		}
+		name = argv[2];
+
+		reply = daemon_send_simple(h, "vg_lookup",
+					   "name = %s", name,
+					   "token = %s", "skip",
+					   NULL);
+		printf("%s\n", reply.buffer.mem);
+
+	} else if (!strcmp(cmd, "vg_lookup_uuid")) {
+		if (argc < 3) {
+			printf("vg_lookup_uuid <uuid>\n");
+			return -1;
+		}
+		uuid = argv[2];
+
+		reply = daemon_send_simple(h, "vg_lookup",
+					   "uuid = %s", uuid,
+					   "token = %s", "skip",
+					   NULL);
+		printf("%s\n", reply.buffer.mem);
+
+	} else if (!strcmp(cmd, "vg_lock_type")) {
+		struct dm_config_node *metadata;
+		const char *lock_type;
+
+		if (argc < 3) {
+			printf("vg_lock_type <uuid>\n");
+			return -1;
+		}
+		uuid = argv[2];
+
+		reply = daemon_send_simple(h, "vg_lookup",
+					   "uuid = %s", uuid,
+					   "token = %s", "skip",
+					   NULL);
+		/* printf("%s\n", reply.buffer.mem); */
+
+		metadata = dm_config_find_node(reply.cft->root, "metadata");
+		if (!metadata) {
+			printf("no metadata\n");
+			goto out;
+		}
+
+		lock_type = dm_config_find_str(metadata, "metadata/lock_type", NULL);
+		if (!lock_type) {
+			printf("no lock_type\n");
+			goto out;
+		}
+		printf("lock_type %s\n", lock_type);
+
+	} else if (!strcmp(cmd, "pv_lookup_uuid")) {
+		if (argc < 3) {
+			printf("pv_lookup_uuid <uuid>\n");
+			return -1;
+		}
+		uuid = argv[2];
+
+		reply = daemon_send_simple(h, "pv_lookup",
+					   "uuid = %s", uuid,
+					   "token = %s", "skip",
+					   NULL);
+		printf("%s\n", reply.buffer.mem);
+
+	} else {
+		printf("unknown command\n");
+		goto out_close;
+	}
+out:
+	daemon_reply_destroy(reply);
+out_close:
+	daemon_close(h);
+	return 0;
+}


