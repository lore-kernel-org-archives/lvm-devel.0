From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 26 Oct 2017 08:05:48 -0400
Subject: master - WHATS_NEW: missed
Message-ID: <201710261205.v9QC5m0X008059@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1758614f9648d4dfba91377336c60aaf3cc5265c
Commit:        1758614f9648d4dfba91377336c60aaf3cc5265c
Parent:        44c4fe8e61e4ae43e7513130bc62f1a584879b2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 26 14:02:44 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 26 14:04:58 2017 +0200

WHATS_NEW: missed

Last patch missed to mention, we've improved/fixed generated paths
in units and init.d shell scripts when lvm2 was plainly configured
with just i.e. --prefix.

Note: some distros might have fully specified --sbindir and
--usrsbindir - thus those very not seeing problems in generated paths.
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 78a8052..55e06f6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Improve used paths for generated systemd units and init shells.
   Disallow creation of snapshot of mirror/raid subLV (was never supported).
   Fix regression in more advanced vgname extraction in lvconvert (2.02.169).
   Allow lvcreate to be used for caching of _tdata LV.


