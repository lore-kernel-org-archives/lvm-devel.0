From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 29 Jan 2014 13:59:47 +0000 (UTC)
Subject: master - thin:drop stack trace when pool is above threshold
Message-ID: <20140129135947.DEAB160F65@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8074d8056acd419fd38d53b32db5373df76d825f
Commit:        8074d8056acd419fd38d53b32db5373df76d825f
Parent:        5a1e1d0d398ad5ca32092047738ce6f7624837e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 14:26:06 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 29 14:26:06 2014 +0100

thin:drop stack trace when pool is above threshold

Since this path is expected, do not log_debug stacktrace.
---
 lib/metadata/thin_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b26723b..1abc2f1 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -240,14 +240,14 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 		return_0;
 
 	if (percent >= threshold)
-		return_0;
+		return 0;
 
 	/* Metadata */
 	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent))
 		return_0;
 
 	if (percent >= threshold)
-		return_0;
+		return 0;
 
 	return 1;
 }


