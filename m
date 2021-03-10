From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:30 +0000 (GMT)
Subject: main - lvremove: support faster removal of thin-pools
Message-ID: <20210310231930.879C03857C62@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4543aca15743eafdc03b4ad92084ef7343f904d
Commit:        f4543aca15743eafdc03b4ad92084ef7343f904d
Parent:        dac827470195f46393522b20ef5678136f72126b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 23:19:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

lvremove: support faster removal of thin-pools

When lvremove/vgremove removes thin volumes with its thin-pool as well,
try to skip any updates of such thin-pool, so when everything properly
deactivates, there is no message send to this thin-pool and whole
thin-pool is removed with a single commit.
---
 lib/metadata/lv.h       | 1 +
 lib/metadata/lv_manip.c | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 28bd4b869..304ee2f7d 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -57,6 +57,7 @@ struct logical_volume {
 
 	uint64_t timestamp;
 	unsigned new_lock_args:1;
+	unsigned to_remove:1; /* set when LV is known to be removed */
 	const char *hostname;
 	const char *lock_args;
 };
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 74a34c9cd..4114e7d5c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6589,6 +6589,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return 0;
 		}
 		lock_lv = pool_lv;
+		if (pool_lv->to_remove)
+			/* Thin pool is to be removed so skip updating it when possible */
+			pool_lv = NULL;
 	}
 
 	if (lv_is_locked(lv)) {
@@ -6823,6 +6826,11 @@ static int _lv_remove_segs_using_this_lv(struct cmd_context *cmd, struct logical
 			log_error("Logical volume \"%s\" not removed.", lv->name);
 			return 0;
 		}
+
+	/* Make aware users of this LV, it's going to be removed, so they
+	 * can skip any updates of itself */
+	lv->to_remove = 1;
+
 	/*
 	 * Not using _safe iterator here - since we may delete whole subtree
 	 * (similar as process_each_lv_in_vg())


