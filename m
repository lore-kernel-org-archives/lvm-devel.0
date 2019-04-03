From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 3 Apr 2019 07:29:49 -0400
Subject: master - filter: fix mpath test
Message-ID: <201904031129.x33BTnOb027534@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bca0a4df9a5c6287bee682b40f4feae6f450729d
Commit:        bca0a4df9a5c6287bee682b40f4feae6f450729d
Parent:        2f471f0184aaac7499a33b32efb708aa8153a2af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 3 13:06:00 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 3 13:27:17 2019 +0200

filter: fix mpath test

Fix bug which leaked into commit
dc6dea40331687b8740cc48833f4c7c42a2db1a1,
where the testing code got mistakenly commited.
---
 lib/filters/filter-mpath.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 466d9c9..53a767c 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -243,7 +243,7 @@ static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
 	if (look > 0) {
 		log_debug_devs("%s(%u:%u): already checked as %sbeing mpath.",
 			       parent_name, major, minor, (look > 1) ? "" : "not ");
-		return (look > 1) ? 0 : 1;
+		return (look > 1) ? 1 : 0;
 	}
 
 	if (lvm_dm_prefix_check(major, minor, MPATH_PREFIX)) {


