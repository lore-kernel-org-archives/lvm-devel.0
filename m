From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:13 -0500
Subject: master - raid: add free for error path
Message-ID: <201802282022.w1SKMDK5009738@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=261e6c3df69082490a685f0d0599e88139b9a927
Commit:        261e6c3df69082490a685f0d0599e88139b9a927
Parent:        9bfc8881cb712a6b164f08ca3d70ec99745e6c22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 25 16:20:30 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:05:18 2018 +0100

raid: add free for error path

Recent patch forget to release now allocated 'dso' on error path.
---
 lib/raid/raid.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 31a0ac0..269a30c 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -655,6 +655,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 	char *dso = NULL;
 	unsigned i;
 	uint64_t monitored = 0;
+	int r = 1;
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
@@ -667,11 +668,14 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 
 	for (i = 0; i < DM_ARRAY_SIZE(_raid_types); ++i)
 		if ((segtype = _init_raid_segtype(cmd, &_raid_types[i], dso, monitored)) &&
-		    !lvm_register_segtype(seglib, segtype))
+		    !lvm_register_segtype(seglib, segtype)) {
 			/* segtype is already destroyed */
-			return_0;
+			stack;
+			r = 0;
+			break;
+		}
 
 	dm_free(dso);
 
-	return 1;
+	return r;
 }


