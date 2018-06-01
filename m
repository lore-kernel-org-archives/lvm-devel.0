From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 12:21:22 -0400
Subject: master - build: Link with -lrt
Message-ID: <201806011621.w51GLM2L018928@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4497ee9e849d2d6c74412de21c6c3823d4de5f1
Commit:        c4497ee9e849d2d6c74412de21c6c3823d4de5f1
Parent:        15a8142f6df6d7ce26ca71f2434d6cd44ef2265c
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 1 17:20:48 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 1 17:20:48 2018 +0100

build: Link with -lrt

Needed for older version of glibc
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index c2d81c0..ad927b0 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -58,7 +58,7 @@ PYTHON3 = @PYTHON3@
 PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
 LIBS = @LIBS@
-LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS)
 # Extra libraries always linked with static binaries
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@


