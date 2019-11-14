From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:54 -0500
Subject: master - hints: check for _touch_hints
Message-ID: <36967.119111412075000143@us-mta-199.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61a483a654d87fc514dd4e7570467797247b6031
Commit:        61a483a654d87fc514dd4e7570467797247b6031
Parent:        c38be0653111e3d63efbbf2f8914c83f15a73e70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 18:01:05 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

hints: check for _touch_hints

Exit when !_touch_hints().
---
 lib/label/hints.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 8739f33..c6039d5 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1261,8 +1261,9 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	 */
 	if (_newhints_exists()) {
 		log_debug("get_hints: newhints file");
-		if (!_hints_exists())
-			_touch_hints();
+		if (!_hints_exists() && !_touch_hints())
+			return 0;
+
 		if (!_lock_hints(cmd, LOCK_EX, NONBLOCK))
 			return 0;
 		/* create new hints after scan */



