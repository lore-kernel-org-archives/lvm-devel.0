From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:40 -0500
Subject: master - makefiles: allow to set LIBS in Makefiles
Message-ID: <201812171008.wBHA8ekC024838@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5366b1d8d9edf8a21de4e256ff89774c6b87f16
Commit:        b5366b1d8d9edf8a21de4e256ff89774c6b87f16
Parent:        143c8dcd7f20f6ac07eeb859c5fa8d7fad9a5a44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 16 15:55:19 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:55:19 2018 +0100

makefiles: allow to set LIBS in Makefiles

Avoid doing hard set of LIBS var,
so if the LIBS is set before 'include make.tmpl' it's not lost.
This gives better control over order of linked libraries.
---
 make.tmpl.in |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 56d7cd6..d7b6568 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -61,8 +61,7 @@ PYTHON2 = @PYTHON2@
 PYTHON3 = @PYTHON3@
 PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
-LIBS = @LIBS@
-LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS) -lm
+LIBS += @LIBS@ $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS) $(M_LIBS)
 # Extra libraries always linked with static binaries
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@


