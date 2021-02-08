From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:54:21 +0000 (GMT)
Subject: main - typo: fixes
Message-ID: <20210208225421.7318C385480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef2e0d3d680829ad4f4253787cd7a0db0c4597d6
Commit:        ef2e0d3d680829ad4f4253787cd7a0db0c4597d6
Parent:        d280999b62c61b9769eb5c3a01a19fa54461259d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 8 23:51:56 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:53:41 2021 +0100

typo: fixes

forgotten merge from last batch.
---
 lib/snapshot/snapshot.c     | 2 +-
 lib/writecache/writecache.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index b832f890d..8446a6914 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -154,7 +154,7 @@ static int _snap_target_present(struct cmd_context *cmd,
 
 		if (!(_snap_present = (target_present_version(cmd, TARGET_NAME_SNAPSHOT, 1,
 							      &maj, &min, &patchlevel) &&
-				       target_present(cmd, TARGET_NAME_SNAPSHOT_ORIGIN, 0)))
+				       target_present(cmd, TARGET_NAME_SNAPSHOT_ORIGIN, 0))))
 			return 0;
 
 		if ((maj > 1 ||
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index d114d698c..aa2113271 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -238,7 +238,7 @@ static int _target_present(struct cmd_context *cmd,
 
 	if (!_writecache_checked) {
 		_writecache_checked = 1;
-		if (!(_writecache_present = target_present_version(cmd, TARGET_NAME_WRITECACHE, 1.
+		if (!(_writecache_present = target_present_version(cmd, TARGET_NAME_WRITECACHE, 1,
 								   &maj, &min, &patchlevel)))
 			return 0;
 


