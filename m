From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:22 -0400
Subject: stable-2.02 - cov: avoid recursive self-inclusion
Message-ID: <201907052326.x65NQMZ2009730@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=721a172edf1a997b2c849f046b1ac88d6318f6d7
Commit:        721a172edf1a997b2c849f046b1ac88d6318f6d7
Parent:        23478d9d2161d1233d0dde1ca40c81d47292bd87
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 28 13:35:40 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

cov: avoid recursive self-inclusion

Include: toolcontext.h -> dev-type.h -> label.h -> toolcontext.h
Replace with struct predeclaration.
---
 lib/label/label.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.h b/lib/label/label.h
index ae6a4f5..42c9946 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -19,7 +19,6 @@
 #include "uuid.h"
 #include "device.h"
 #include "bcache.h"
-#include "toolcontext.h"
 
 #define LABEL_ID "LABELONE"
 #define LABEL_SIZE SECTOR_SIZE	/* Think very carefully before changing this */
@@ -27,6 +26,9 @@
 #define LABEL_SCAN_SIZE (LABEL_SCAN_SECTORS << SECTOR_SHIFT)
 
 struct labeller;
+struct dev_filter;
+struct cmd_context;
+struct logical_volume;
 
 void allow_reads_with_lvmetad(void);
 


