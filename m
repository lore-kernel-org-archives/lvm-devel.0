From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:29:54 -0400
Subject: master - debug: fix error path
Message-ID: <201706262229.v5QMTslc010329@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a567ec65a9d22e49208d42a08a4d7531219166d8
Commit:        a567ec65a9d22e49208d42a08a4d7531219166d8
Parent:        d444accdbfdda0712d4a83ac178378580d3f7714
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:32:04 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:36 2017 +0200

debug: fix error path

Coverity:
log_error may have dereference NULL pointer - use directly
segtype string name.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5e255d3..cfdf5de 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2724,7 +2724,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	if (!pool_segtype ||
 	    !pool_segtype->ops->target_present(cmd, NULL, &target_attr)) {
 		log_error("%s: Required device-mapper target(s) not detected in your kernel.",
-			  pool_segtype->name);
+			  str_seg_type);
 		return 0;
 	}
 


