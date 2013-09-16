From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 16 Sep 2013 18:57:46 +0000 (UTC)
Subject: master - Makefiles: Fix CC variable override.
Message-ID: <20130916185746.91F8A60DD9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36c5bb40a27c7faac2a167df8c5cbd7c98c5168d
Commit:        36c5bb40a27c7faac2a167df8c5cbd7c98c5168d
Parent:        97ba18f4cbedbdf7933d30d719cf997bb06e7214
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 16 19:57:14 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 16 19:57:14 2013 +0100

Makefiles: Fix CC variable override.

The CC override in commit f42b2d4bbf16345e5b5457f4298e751d5c134776
caused the built-in value to be used instead of the configured value
when it wasn't being overridden.

The behaviour is explained here:
	http://stackoverflow.com/questions/18007326/how-to-change-default-values-of-variables-like-cc-in-makefile
---
 WHATS_NEW    |    1 +
 make.tmpl.in |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d51f08c..45e0050 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Fix CC Makefile override which had reverted to using built-in value. (2.02.75)
   Recognise bcache block devices in filter (experimental).
   Run lvm2-activation-net after lvm2-activation service to prevent parallel run.
   Add man page entries for lvmdump's -u and -l options.
diff --git a/make.tmpl.in b/make.tmpl.in
index 6992255..3218758 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -17,7 +17,18 @@ SHELL = /bin/sh
 
 @SET_MAKE@
 
+# Allow environment to override any built-in default value for CC.
+# If there is a built-in default, CC is NOT set to @CC@ here.
 CC ?= @CC@
+
+# If $(CC) holds the usual built-in default value of 'cc' then replace it with
+# the configured value.
+# (To avoid this and force the use of 'cc' from the environment, supply its
+# full path.)
+ifeq ($(CC), cc)
+  CC = @CC@
+endif
+
 RANLIB = @RANLIB@
 INSTALL = @INSTALL@
 MKDIR_P = @MKDIR_P@


