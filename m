From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:05:05 -0400
Subject: master - debug: missing trace
Message-ID: <201910171105.x9HB55ii023620@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9969361b51d0b69fa04a6a7cd87ca74208b2437a
Commit:        9969361b51d0b69fa04a6a7cd87ca74208b2437a
Parent:        a255385e3a5e3668eb0a4772cd867a3a7394285b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 12:40:13 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:50 2019 +0200

debug: missing trace

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e6524f3..b3a749d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6360,7 +6360,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	if (!archive(vg))
-		return 0;
+		return_0;
 
 	/* Special case removing a striped raid LV with allocated reshape space */
 	if (seg && seg->reshape_len) {


