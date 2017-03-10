From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 10 Mar 2017 12:57:25 -0500
Subject: master - lvcreate: fix "striped" limit
Message-ID: <201703101757.v2AHvPOx011041@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2fcbe34fe85fa57e1e2835dfba95fa21387377b6
Commit:        2fcbe34fe85fa57e1e2835dfba95fa21387377b6
Parent:        43388f12208be07191b80a5ed328a87790ecd64a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 10 18:57:06 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 10 18:57:06 2017 +0100

lvcreate: fix "striped" limit

Fix regression limiting number of stripes to 8.
Raise back to 128 as before.

Resolves: rhbz1389546
---
 tools/lvcreate.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index cd31c99..ed56757 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -558,8 +558,10 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 			else if (seg_is_any_raid6(lp))
 				max_images -= 2;
 		}
-	} else
+	} else if (seg_is_mirrored(lp))
 		max_images = DEFAULT_MIRROR_MAX_IMAGES;
+	else
+		max_images = MAX_STRIPES;
 
 	/* Common mirror and raid params */
 	if (arg_is_set(cmd, mirrors_ARG)) {


