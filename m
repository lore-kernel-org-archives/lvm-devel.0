From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:47:21 -0500
Subject: master - cov: drop unneeded header file
Message-ID: <201812212047.wBLKlL7S021521@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9dfb1a11b76282ed8f3819bf63c369b179fac78d
Commit:        9dfb1a11b76282ed8f3819bf63c369b179fac78d
Parent:        a355aeb17a4fda7fab76a2c85bdc7ff03159424a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:52:49 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:45:08 2018 +0100

cov: drop unneeded header file

MAX macro no longer needed in pe_align.
---
 lib/metadata/metadata.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6a0be85..9efc355 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -34,7 +34,6 @@
 #include "lib/notify/lvmnotify.h"
 
 #include <math.h>
-#include <sys/param.h>
 
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					const struct format_type *fmt,


