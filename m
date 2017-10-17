From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 17 Oct 2017 18:04:34 -0400
Subject: master - libdm: fix typo in libdevmapper.pc
Message-ID: <201710172204.v9HM4YZm002157@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=327d9d59be6f7179b2e0a756deaa0f9a196e0651
Commit:        327d9d59be6f7179b2e0a756deaa0f9a196e0651
Parent:        1b319f39d6692a6770493d5f751ebbb9062164fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 18 00:03:08 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 18 00:04:06 2017 +0200

libdm: fix typo in libdevmapper.pc

Fixing name for RT libraries and using RT_LIBS.
---
 WHATS_NEW_DM             |    1 +
 libdm/libdevmapper.pc.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a5d24dd..b0dd01b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.145 - 
 ===================================
+  Fix RT_LIBS reference in generated libdevmapper.pc for pkg-config
 
 Version 1.02.144 - 6th October 2017
 ===================================
diff --git a/libdm/libdevmapper.pc.in b/libdm/libdevmapper.pc.in
index f29f920..a325aeb 100644
--- a/libdm/libdevmapper.pc.in
+++ b/libdm/libdevmapper.pc.in
@@ -9,4 +9,4 @@ Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
 Requires.private: @SELINUX_PC@ @UDEV_PC@
-Libs.private: -lm @RT_LIB@
+Libs.private: -lm @RT_LIBS@


