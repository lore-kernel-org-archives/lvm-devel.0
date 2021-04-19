From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:48 +0000 (GMT)
Subject: main - man: use editline reference
Message-ID: <20210419130048.341A03969019@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dc934b13b9e47e59f0a176c9f4d9ceaa8a11ca32
Commit:        dc934b13b9e47e59f0a176c9f4d9ceaa8a11ca32
Parent:        54f98c94b45629dccc5588a54fa7fa448ea40d0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 16 14:40:42 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:37:07 2021 +0200

man: use editline reference

When compiled with editline, refer this in man page as well
instead of readline.
---
 man/Makefile.in | 10 ++++++++++
 man/lvm.8_main  | 12 ++++++------
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 7ad533980..31a4052e2 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -132,6 +132,15 @@ SEE_ALSO=$(srcdir)/see_also.end
 	    fi \
 	) > $@
 
+#
+# When EDITLINE_LIBS is defined, we are compiling with libedit
+#
+ifneq ("$(EDITLINE_LIBS)", "")
+DEFAULT_LIBLINE=editline
+else
+DEFAULT_LIBLINE=readline
+endif
+
 define SUBSTVARS
 $(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+" \
@@ -144,6 +153,7 @@ $(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_RUN_DIR#+$(DEFAULT_RUN_DIR)+" \
 	-e "s+#DEFAULT_PID_DIR#+$(DEFAULT_PID_DIR)+" \
 	-e "s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+" \
+	-e "s+#DEFAULT_LIBLINE#+$(DEFAULT_LIBLINE)+" \
 	-e "s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+" $< > $@
 endef
 
diff --git a/man/lvm.8_main b/man/lvm.8_main
index 44961f7cf..08af2ee33 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -24,11 +24,11 @@ kernel.
 The lvm command, and other commands listed below, are the command-line
 tools for LVM.  A separate manual page describes each command in detail.
 .P
-If \fBlvm\fP is invoked with no arguments it presents a readline prompt
-(assuming it was compiled with readline support).
+If \fBlvm\fP is invoked with no arguments it presents a #DEFAULT_LIBLINE# prompt
+(assuming it was compiled with #DEFAULT_LIBLINE# support).
 LVM commands may be entered interactively at this prompt with
-readline facilities including history and command name and option
-completion.  Refer to \fBreadline\fP(3) for details.
+#DEFAULT_LIBLINE# facilities including history and command name and option
+completion.  Refer to \fB#DEFAULT_LIBLINE#\fP(3) for details.
 .P
 If \fBlvm\fP is invoked with argv[0] set to the name of a specific
 LVM command (for example by using a hard or soft link) it acts as
@@ -409,7 +409,7 @@ Message text may also change.
 .
 .TP
 .B HOME
-Directory containing \fI.lvm_history\fP if the internal readline
+Directory containing \fI.lvm_history\fP if the internal #DEFAULT_LIBLINE#
 shell is invoked.
 .TP
 .B LVM_OUT_FD
@@ -561,4 +561,4 @@ Prepends source file name and code line number with libdm debugging.
 .P
 .BR dmsetup (8),
 .BR dmstats (8),
-.BR readline (3)
+.BR #DEFAULT_LIBLINE# (3)


