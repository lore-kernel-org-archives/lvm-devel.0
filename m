From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:08:59 +0000 (UTC)
Subject: master - thin: report t for thin pool and volume
Message-ID: <20130611120859.C26EF61018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7151ede767ad168b71f338c48835fcf64a9e3ce7
Commit:        7151ede767ad168b71f338c48835fcf64a9e3ce7
Parent:        272f5ae208d20dc56599e61b37e74afac05a1140
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 13:44:10 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 13:58:16 2013 +0200

thin: report t for thin pool and volume

Do not mark internal device _tdata and _tmeta as having target type 't'.
They have the target type on their own (i.e. mirror, raid).
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 57aab93..96478e6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Report lvs target type 't' only for thin pools and thin volumes.
   Fix test for active snapshot in cluster before resizing it.
   Report backtrace from dump filter error path.
   Do not use persistent filter with lvmetad.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 182eb57..e53fdf3 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -617,7 +617,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[5] = '-';
 	}
 
-	if (lv_is_thin_type(lv))
+	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		repstr[6] = 't';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';


