From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:09:06 +0000 (UTC)
Subject: master - thin: detect online metadata resize support
Message-ID: <20130611120906.0D4BF61018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55a3859632c861e8a3bd07a7c848fdb1901e0a05
Commit:        55a3859632c861e8a3bd07a7c848fdb1901e0a05
Parent:        01ef97fcbbfe0ed49b3dc61765d166efe8647e8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 12:31:01 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:03:28 2013 +0200

thin: detect online metadata resize support

---
 WHATS_NEW               |    1 +
 lib/activate/activate.h |    1 +
 lib/thin/thin.c         |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f9f51dc..f85730c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add detection for thin pool metadata resize kernel support.
   Report lvs volume type 'e' with higher priority.
   Report lvs volume type 'o' also for external origin volumes.
   Report lvs target type 't' only for thin pools and thin volumes.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 1cbb67f..80733fe 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -51,6 +51,7 @@ enum {
 	THIN_FEATURE_HELD_ROOT			= (1 << 2),
 	THIN_FEATURE_BLOCK_SIZE			= (1 << 3),
 	THIN_FEATURE_DISCARDS_NON_POWER_2	= (1 << 4),
+	THIN_FEATURE_METADATA_RESIZE		= (1 << 5),
 };
 
 void set_activation(int activation);
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 4bfae33..d1ffd27 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -562,6 +562,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		{ 1, 1, THIN_FEATURE_EXTERNAL_ORIGIN, "external_origin" },
 		{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
 		{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
+		{ 1, 8, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
 	};
 
 	static const char _lvmconf[] = "global/thin_disabled_features";


