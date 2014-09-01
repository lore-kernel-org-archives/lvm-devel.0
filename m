From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  1 Sep 2014 10:55:05 +0000 (UTC)
Subject: master - so: make sure shared libs are built with RELRO option
Message-ID: <20140901105505.9396861112@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c34e3263a6032f7a12975662964c8b8d3084257
Commit:        5c34e3263a6032f7a12975662964c8b8d3084257
Parent:        fa1a0d170ad7193e9d0c6fe828a5c5df24806a54
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 1 12:50:14 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 1 12:54:29 2014 +0200

so: make sure shared libs are built with RELRO option

In addition to using RELRO for daemons, use this option for shared
libraries. See also commit a65ab773b4ddb06e87d678d3b2f4d0ca3e5b9fd0.
---
 WHATS_NEW    |    1 +
 make.tmpl.in |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6758389..9a786b4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.111 - 
 ===================================
+  Make sure shared libraries are built with RELRO option.
   Pass properly sized char buffers for sscanf when initializing clvmd.
   Reinstate nosync logic when extending mirror. (2.02.110)
   Fix total area extent calculation when allocating cache pool. (2.02.110)
diff --git a/make.tmpl.in b/make.tmpl.in
index 5e597df..455e9c2 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -160,6 +160,7 @@ ifeq ("@HAVE_PIE@", "yes")
 ifeq ("@HAVE_FULL_RELRO@", "yes")
   EXTRA_EXEC_CFLAGS += -fPIE -DPIE
   EXTRA_EXEC_LDFLAGS += -Wl,-z,relro,-z,now -pie
+  CLDFLAGS += -Wl,-z,relro
 endif
 endif
 endif


