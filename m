From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Mar 2014 13:12:02 +0000 (UTC)
Subject: master - cleanup: easier casting
Message-ID: <20140326131202.AAE1160FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a93eba68e518fff7f0c16406b5a9e802d732e1d
Commit:        2a93eba68e518fff7f0c16406b5a9e802d732e1d
Parent:        0499e87ace39997c64b33d27a65011b1b3c6cecc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 26 14:02:31 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 14:11:37 2014 +0100

cleanup: easier casting

Use 32bit for extent calcs.
Drop uneeded implicit case.
---
 lib/display/display.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index d2450dd..1846f90 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -828,14 +828,14 @@ void vgdisplay_full(const struct volume_group *vg)
 			       (uint64_t) vg->extent_count * vg->extent_size));
 
 	log_print("PE Size               %s",
-		  display_size(vg->cmd, (uint64_t) vg->extent_size));
+		  display_size(vg->cmd, vg->extent_size));
 
 	log_print("Total PE              %u", vg->extent_count);
 
 	log_print("Alloc PE / Size       %u / %s",
 		  vg->extent_count - vg->free_count,
 		  display_size(vg->cmd,
-			       ((uint64_t) vg->extent_count - vg->free_count) *
+			       (uint64_t) (vg->extent_count - vg->free_count) *
 			       vg->extent_size));
 
 	log_print("Free  PE / Size       %u / %s", vg->free_count,


