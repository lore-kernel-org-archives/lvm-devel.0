From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:40 +0000 (UTC)
Subject: master - liblvm2cmd: ensure standard descriptors are ready
Message-ID: <20121003131440.9AA5C2319@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=739092e64ac2776a0b0b0796349041b659d816b0
Commit:        739092e64ac2776a0b0b0796349041b659d816b0
Parent:        1f30e048bd8b387e25baad4f82223b63dc516cf5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 7 11:13:41 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:02:26 2012 +0200

liblvm2cmd: ensure standard descriptors are ready

Check if FDs 0,1,2 are available, and in case they are missing,
use /dev/null for them.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |   39 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5f82424..45ce574 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Ensure descriptors 0,1,2 are always available.
   Use /proc/self/fd for closing openned descriptors.
   Add missing pkg init with --enable-testing in configure.in (2.02.71).
   Fix inability to create, extend or convert to a large (> 1TiB) RAID LV.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e015a12..bccf7a6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -26,6 +26,7 @@
 #include <time.h>
 #include <sys/resource.h>
 #include <dirent.h>
+#include <paths.h>
 
 #ifdef HAVE_GETOPTLONG
 #  include <getopt.h>
@@ -1186,6 +1187,39 @@ int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
+/* Make sure we have always valid filedescriptors 0,1,2 */
+static int _check_standard_fds(void)
+{
+	int err = is_valid_fd(STDERR_FILENO);
+
+	if (!is_valid_fd(STDIN_FILENO) &&
+	    !(stdin = fopen(_PATH_DEVNULL, "r"))) {
+		if (err)
+			perror("stdin stream open");
+		else
+			printf("stdin stream open: %s\n",
+			       strerror(errno));
+		return 0;
+	}
+
+	if (!is_valid_fd(STDOUT_FILENO) &&
+	    !(stdout = fopen(_PATH_DEVNULL, "w"))) {
+		if (err)
+			perror("stdout stream open");
+		/* else no stdout */
+		return 0;
+	}
+
+	if (!is_valid_fd(STDERR_FILENO) &&
+	    !(stderr = fopen(_PATH_DEVNULL, "w"))) {
+		printf("stderr stream open: %s\n",
+		       strerror(errno));
+		return 0;
+	}
+
+	return 1;
+}
+
 static const char *_get_cmdline(pid_t pid)
 {
 	static char _proc_cmdline[32];
@@ -1450,6 +1484,9 @@ int lvm2_main(int argc, char **argv)
 	    strcmp(base, "initrd-lvm"))
 		alias = 1;
 
+	if (!_check_standard_fds())
+		return -1;
+
 	if (!_close_stray_fds(base))
 		return -1;
 


