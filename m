From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:42:22 +0000 (UTC)
Subject: master - memory: disable check with valgrind pool build
Message-ID: <20150212144222.502F660DBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9809038b9d3beddd90cb80311c61fd67856e0728
Commit:        9809038b9d3beddd90cb80311c61fd67856e0728
Parent:        425c04e4dc54f1c8aee261217b5b0fc00df643ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 12 15:30:43 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 12 15:40:53 2015 +0100

memory: disable check with valgrind pool build

When lvm2 is build with valgrind pool detection - always disable
memcheck, since pool memory allocation are unconditionaly passed
into valgrind library.
---
 lib/mm/memlock.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 2327d4c..534aab3 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -262,8 +262,10 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 	/*
 	 * Valgrind is continually eating memory while executing code
 	 * so we need to deactivate check of locked memory size
-         */
+	 */
+#ifndef VALGRIND_POOL
 	if (RUNNING_ON_VALGRIND)
+#endif
 		sz -= sz; /* = 0, but avoids getting warning about dead assigment */
 
 #endif


