From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Sep 2014 16:18:48 +0000 (UTC)
Subject: master - makefiles: fix linking of PIE code
Message-ID: <20140918161848.5963361150@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b72e9d3a933fd72eb4c08f13f5a3d3a7259a7741
Commit:        b72e9d3a933fd72eb4c08f13f5a3d3a7259a7741
Parent:        d450c7fb102652985a7271f3ea76ed72235060e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 18 18:14:21 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 18 18:14:21 2014 +0200

makefiles: fix linking of PIE code

PIE documentation:
:
https://gcc.gnu.org/onlinedocs/gcc/Code-Gen-Options.html
http://lfs.osuosl.org/hlfs/view/unstable/glibc/chapter02/pie.html

suggest to suply -fPIE (or -fpie) with -pie
during executable compilation.

When -fPIC and -fPIE are used together - -fPIE wins

Drop usage of -DPIE - we are not using this flag anywhere

TODO: cleanup linking flags
---
 make.tmpl.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 7a178ad..7efe46b 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -158,8 +158,8 @@ endif
 ifneq ("@STATIC_LINK@", "yes")
 ifeq ("@HAVE_PIE@", "yes")
 ifeq ("@HAVE_FULL_RELRO@", "yes")
-  EXTRA_EXEC_CFLAGS += -fPIE -DPIE
-  EXTRA_EXEC_LDFLAGS += -Wl,-z,relro,-z,now -pie
+  EXTRA_EXEC_CFLAGS += -fPIE
+  EXTRA_EXEC_LDFLAGS += -Wl,-z,relro,-z,now -pie -fPIE
   CLDFLAGS += -Wl,-z,relro
 endif
 endif


