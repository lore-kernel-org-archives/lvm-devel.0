From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:56:27 +0000 (UTC)
Subject: master - lvmanip: fix last commit and drop else
Message-ID: <20160114105627.CF47860C79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88400b599efa2a06fcc29c1c69ef450aa0c98524
Commit:        88400b599efa2a06fcc29c1c69ef450aa0c98524
Parent:        278c5509ee88b6384e0ccdb8b8da994b020ffe75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 14 11:54:37 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:55:47 2016 +0100

lvmanip: fix last commit and drop else

In last commit when removing if() branch
this 'else' now has to be dropped.
---
 lib/metadata/lv_manip.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ca9e0a1..7ba52f9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3136,7 +3136,8 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	/* FIXME Caller should ensure this */
 	if (mirrors && !stripes)
 		stripes = 1;
-	else if (mirrors > 1)
+
+	if (mirrors > 1)
 		area_count = mirrors * stripes;
 	else
 		area_count = stripes;


