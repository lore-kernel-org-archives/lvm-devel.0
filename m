From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 13 Apr 2016 19:08:50 +0000 (UTC)
Subject: master - lvmetad: add FIXME to comment
Message-ID: <20160413190850.BD0CF61B99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=579bd9200950a438af9d842f5d0cbaf049bd87c9
Commit:        579bd9200950a438af9d842f5d0cbaf049bd87c9
Parent:        56c68b3476f52a07c877496a07ebef619724e224
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 13 14:08:29 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 13 14:08:29 2016 -0500

lvmetad: add FIXME to comment

---
 lib/cache/lvmetad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8cc804a..7ca5d4a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -296,9 +296,9 @@ retry:
 	 * If lvmetad is still being updated after the timeout period,
 	 * then disable this command's use of lvmetad.
 	 *
-	 * (lvmetad could return the number of objects in its cache along with
+	 * FIXME: lvmetad could return the number of objects in its cache along with
 	 * the update message so that callers could detect when a rescan has
-	 * stalled while updating lvmetad.)
+	 * stalled while updating lvmetad.
 	 */
 	if (!strcmp(daemon_token, "update in progress")) {
 		if (!(now = _monotonic_seconds()))


