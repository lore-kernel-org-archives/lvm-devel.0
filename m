From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 15 Mar 2017 21:10:45 -0400
Subject: master - lvmchange: Move to a built-in command.
Message-ID: <201703160110.v2G1AjoB025809@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4f8651984531371f73c7bed0271c7dde8afb6c19
Commit:        4f8651984531371f73c7bed0271c7dde8afb6c19
Parent:        9729fc4f8c62ade44f2adb3dadf7904a19b3709f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 01:09:29 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 01:09:29 2017 +0000

lvmchange: Move to a built-in command.

Has been obsolete since LVM1 and it's clear we'll never implement this.
---
 WHATS_NEW         |    1 +
 tools/Makefile.in |    3 +--
 tools/lvmchange.c |   23 -----------------------
 tools/stub.h      |    8 ++++++++
 4 files changed, 10 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ba17a10..25efd49 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Remove obsolete lvmchange binary - convert to built-in command.
   Lvdisplay [-m] shows more informations for cached volumes.
   Add option for lvcreate/lvconvert --cachemetadataformat auto|1|2.
   Support cache segment with configurable metadata format.
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 9e1ccba..6312c9e 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -26,7 +26,6 @@ SOURCES =\
 	lvcreate.c \
 	lvdisplay.c \
 	lvextend.c \
-	lvmchange.c \
 	lvmcmdline.c \
 	lvmdiskscan.c \
 	lvreduce.c \
@@ -173,7 +172,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		$(EGREP) -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lastlog|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
+		$(EGREP) -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lastlog|lvmchange|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
 command-count.h: $(srcdir)/command-lines.in Makefile
 	set -o pipefail && \
diff --git a/tools/lvmchange.c b/tools/lvmchange.c
deleted file mode 100644
index 91bce95..0000000
--- a/tools/lvmchange.c
+++ /dev/null
@@ -1,23 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "tools.h"
-
-int lvmchange(struct cmd_context *cmd __attribute__((unused)),
-	      int argc __attribute__((unused)), char **argv __attribute__((unused)))
-{
-	log_error("With LVM2 and the device mapper, this program is obsolete.");
-	return ECMD_FAILED;
-}
diff --git a/tools/stub.h b/tools/stub.h
index 5b2d137..f941067 100644
--- a/tools/stub.h
+++ b/tools/stub.h
@@ -41,3 +41,11 @@ int pvdata(struct cmd_context *cmd __attribute__((unused)),
 	return ECMD_FAILED;
 }
 
+int lvmchange(struct cmd_context *cmd __attribute__((unused)),
+	      int argc __attribute__((unused)),
+	      char **argv __attribute__((unused)))
+{
+	log_error("There's no 'lvmchange' command in LVM2.");
+	log_error("Use 'dmsetup' commands to reset the kernel device-mapper driver.");
+	return ECMD_FAILED;
+}


