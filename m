From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 05:34:54 -0400
Subject: master - man: fix cut and paste bug
Message-ID: <201805240934.w4O9YscR002247@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4be1ec3da4eaa4ae315ca7c33265828dda37c58c
Commit:        4be1ec3da4eaa4ae315ca7c33265828dda37c58c
Parent:        c35d3242a8897c054c993dc59ad6e1cfff658061
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 23 19:45:53 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 23 19:45:53 2018 +0200

man: fix cut and paste bug

Fixing missing 'META' in DMEVENTD_THIN_POOL_METADATA.
---
 man/dmeventd.8_main |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index 7e3f9a2..98b1b98 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -134,7 +134,7 @@ Variable is set by thin plugin and is available to executed program. Value prese
 actual usage of thin pool data volume. Variable is not set when error event
 is processed.
 .TP
-.B DMEVENTD_THIN_POOL_DATA
+.B DMEVENTD_THIN_POOL_METADATA
 Variable is set by thin plugin and is available to executed program. Value present
 actual usage of thin pool metadata volume. Variable is not set when error event
 is processed.


