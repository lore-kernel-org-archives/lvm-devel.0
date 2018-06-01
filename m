From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 11:55:17 -0400
Subject: master - build: make sure selinux, udev and blkid libraries are linked.
Message-ID: <201806011555.w51FtHYh011325@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15a8142f6df6d7ce26ca71f2434d6cd44ef2265c
Commit:        15a8142f6df6d7ce26ca71f2434d6cd44ef2265c
Parent:        dbba1e9b93bac348c0df556b160676234cc8a8c4
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 1 16:53:20 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 1 16:53:20 2018 +0100

build: make sure selinux, udev and blkid libraries are linked.

Fixes breakage from the recent libdm split.  Though these didn't
ever appear to be linked (could they have piggy backed from libdevmapper.so
being linked to them?).
---
 make.tmpl.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 10075d4..c2d81c0 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -58,6 +58,7 @@ PYTHON3 = @PYTHON3@
 PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
 LIBS = @LIBS@
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 # Extra libraries always linked with static binaries
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@


