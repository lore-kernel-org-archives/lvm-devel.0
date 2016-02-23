From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:26 +0000 (UTC)
Subject: master - coverity: ensure non-null pointers are used
Message-ID: <20160223204126.341616055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68955a81024d43138ee29b682d08233baf5ee876
Commit:        68955a81024d43138ee29b682d08233baf5ee876
Parent:        9b92cb27609ed239814d1e0d36f77d41464b23bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 20:16:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:16 2016 +0100

coverity: ensure non-null pointers are used

Here is too complex for Coverity to guess
those pointers cannot be NULL, but it's
very easy to add little checks here.
---
 lib/activate/dev_manager.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a1c9a23..7ad8982 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -352,7 +352,8 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 	do {
 		next = dm_get_next_target(dmt, next, &s, &l,
 					  &target_type, &params);
-		if ((s == start) && (l == length)) {
+		if ((s == start) && (l == length) &&
+		    target_type && params) {
 			if (strcmp(target_type, "mirror"))
 				goto_out;
 


