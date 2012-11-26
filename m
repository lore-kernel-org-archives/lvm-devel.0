From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Nov 2012 11:17:19 +0000 (UTC)
Subject: master - thin: detect discards for non-power-2
Message-ID: <20121126111719.0EFF2A0DA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=683b1f0625a39084ed32ebce06a62d5a1fb4bf23
Commit:        683b1f0625a39084ed32ebce06a62d5a1fb4bf23
Parent:        668b669d5b40cb4a2d2ed62ebacb02ebeab03b98
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 26 11:04:00 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 26 12:14:47 2012 +0100

thin: detect discards for non-power-2

Check if target supports discards for chunk sizes,
that are not power of 2 (just multiple of 64K),
and enable it in case it's supported by thin kernel target.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.h |    1 +
 lib/thin/thin.c         |    6 ++++++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2ea3f2b..068f453 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Support discards for non-power-of-2 thin pool chunks.
   Automatically restore MISSING PVs with no MDAs.
   When no '-i' argument is given for RAID10, default to 2 stripes.
   Do not allow --splitmirrors on RAID10 logical volumes.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index ba24d2a..0a0c97e 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -51,6 +51,7 @@ enum {
 	THIN_FEATURE_EXTERNAL_ORIGIN		= (1 << 1),
 	THIN_FEATURE_HELD_ROOT			= (1 << 2),
 	THIN_FEATURE_BLOCK_SIZE			= (1 << 3),
+	THIN_FEATURE_DISCARDS_NON_POWER_2	= (1 << 4),
 };
 
 void set_activation(int activation);
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 2b6c71f..693b8b6 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -565,6 +565,12 @@ static int _thin_target_present(struct cmd_context *cmd,
 		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
 			log_debug("Target " THIN_MODULE " does not support non power of 2 block sizes.");
 
+		if (maj >=1 && min >= 5)
+			_attrs |= THIN_FEATURE_DISCARDS_NON_POWER_2;
+		else
+		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
+			log_debug("Target " THIN_MODULE " does not support discards for non power of 2 block sizes.");
+
 		_checked = 1;
 	}
 


