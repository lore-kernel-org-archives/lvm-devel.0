From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Mar 2017 23:04:56 -0400
Subject: master - Revert "lvcreate: continue to accept --thinpool with -L and -V but not -T"
Message-ID: <201703220304.v2M34u97003506@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3be2e61c9fd775c03636937001a3f5e593096c85
Commit:        3be2e61c9fd775c03636937001a3f5e593096c85
Parent:        7126fb13e7d4f9fbdf10663a5d04b52a3f5dba0c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 21 20:38:47 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 21 22:01:19 2017 -0500

Revert "lvcreate: continue to accept --thinpool with -L and -V but not -T"

This reverts commit 642d682d8ddcc3152f68b3ec8518902a0ef448ac.

Using the thinpool option with this cmd def makes it
indistinct from other cmd defs where thinpool is a
required option.
---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index a4d1f38..2fec553 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1056,7 +1056,7 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvcreate --size SizeMB --virtualsize SizeMB VG
-OO: --type thin, --type snapshot, --thin, --snapshot, --thinpool LV_new, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+OO: --type thin, --type snapshot, --thin, --snapshot, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
 IO: --mirrors 0


