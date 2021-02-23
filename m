From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:16 +0000 (GMT)
Subject: main - lvconvert: change errors to internal ones
Message-ID: <20210223140416.6B8AC3938C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ecd65e6f2f5264b0ebe1177a714bc8d29e882fb
Commit:        5ecd65e6f2f5264b0ebe1177a714bc8d29e882fb
Parent:        b140bba9fe69f3bd4c89f15998b3e197fe9bf428
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 20 23:01:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:47 2021 +0100

lvconvert: change errors to internal ones

Since these errors should never happen, change them to  internal errors.
---
 tools/lvconvert.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 83bdfd04b..4dee97ee0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4693,12 +4693,12 @@ static int _lvconvert_to_thin_with_external_single(struct cmd_context *cmd,
 		}
 
 		if (!(thinpool_lv = find_lv(vg, thinpool_name))) {
-			log_error("LV %s cannot be found.", display_lvname(thinpool_lv));
+			log_error(INTERNAL_ERROR "LV %s cannot be found.", thinpool_name);
 			goto out;
 		}
 
 		if (!lv_is_thin_pool(thinpool_lv)) {
-			log_error("LV %s is not a thin pool.", display_lvname(thinpool_lv));
+			log_error(INTERNAL_ERROR "LV %s is not a thin pool.", display_lvname(thinpool_lv));
 			goto out;
 		}
 	}


