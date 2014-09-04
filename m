From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  4 Sep 2014 08:53:21 +0000 (UTC)
Subject: master - so: make sure shared libs are built with RELRO option
Message-ID: <20140904085321.5F8BF6111C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c774d9a3f35c312d5b24c4ba13da707ccd975194
Commit:        c774d9a3f35c312d5b24c4ba13da707ccd975194
Parent:        b25e0086b6738ad1e25480571af58807c12df57c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 4 10:52:41 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 4 10:52:41 2014 +0200

so: make sure shared libs are built with RELRO option

In addition to using RELRO for daemons, use this option for shared
libraries. See also commit a65ab773b4ddb06e87d678d3b2f4d0ca3e5b9fd0.
---
 WHATS_NEW    |    1 +
 make.tmpl.in |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 70df450..bf929f6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Make sure shared libraries are built with RELRO option.
 
 Version 2.02.111 - 1st September 2014
 =====================================
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


