From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:24 -0400
Subject: master - build: properly track source file for lmvlockctl
Message-ID: <201805121626.w4CGQOdM008310@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7616a7f46ee3de6dfc898b98ed33dbbf9d12cc95
Commit:        7616a7f46ee3de6dfc898b98ed33dbbf9d12cc95
Parent:        cbe81a0b058b6c994ff2cdf9b3f7bd7903074320
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 01:19:07 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:05:50 2018 +0200

build: properly track source file for lmvlockctl

Ensure the source file is tracked by various cleanup functions.
---
 daemons/lvmlockd/Makefile.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 8f16d06..63944cb 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -27,6 +27,8 @@ ifeq ("@BUILD_LOCKDDLM@", "yes")
   LOCK_LIBS += -ldlm_lt
 endif
 
+SOURCES2 = lvmlockctl.c
+
 TARGETS = lvmlockd lvmlockctl
 
 .PHONY: install_lvmlockd


