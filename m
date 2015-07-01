From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  1 Jul 2015 22:11:52 +0000 (UTC)
Subject: master - display: missed to count with 0
Message-ID: <20150701221152.363C660571@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f63fff9c4a4e82925227e94d1fa4ba4500ebc2b
Commit:        7f63fff9c4a4e82925227e94d1fa4ba4500ebc2b
Parent:        21c0b1134f7812300aea1e24da11ac1d93bac7b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 2 00:04:38 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 2 00:10:38 2015 +0200

display: missed to count with 0

dm_snprintf() returns upon success the number of characters printed
(excluding the null byte used to end output to strings).

So add extra byte to preserve \0.
This fixes regression when displaying more then a single lv name.
---
 WHATS_NEW             |    1 +
 lib/display/display.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6c539e6..1b5b097 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.124 -
 =================================
+  Fix regression when printing more lv names via display_lvname (2.02.122).
   Add missing error logging to unlock_vg and sync_local_dev_names callers.
 
 Version 2.02.123 - 30th June 2015
diff --git a/lib/display/display.c b/lib/display/display.c
index 059bc8f..98433e7 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -109,7 +109,7 @@ const char *display_lvname(const struct logical_volume *lv)
 		return NULL;
 	}
 
-	lv->vg->cmd->display_lvname_idx += r;
+	lv->vg->cmd->display_lvname_idx += r + 1;
 
 	return name;
 }


