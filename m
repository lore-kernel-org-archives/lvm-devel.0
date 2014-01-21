From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 21 Jan 2014 12:54:16 +0000 (UTC)
Subject: master - thin: online metadata resize requires 1.10
Message-ID: <20140121125416.522A160DB2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22d9daff12b73e72f520ea70f416e1d3057ae740
Commit:        22d9daff12b73e72f520ea70f416e1d3057ae740
Parent:        899a079c8f36decd2fda42412091df57ab8f72cb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 21 13:48:57 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 21 13:50:17 2014 +0100

thin: online metadata resize requires 1.10

Version 1.10 starts to look promissing, let's enable
online resize when this thin-pool kernel target is present.
---
 WHATS_NEW       |    1 +
 lib/thin/thin.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 982f44d..a5e58b5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Online thin pool metadata resize requires 1.10 kernel thin pool target.
 
 Version 2.02.105 - 20th January 2014
 ====================================
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index ff263d9..6011d77 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -618,7 +618,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		{ 1, 1, THIN_FEATURE_EXTERNAL_ORIGIN, "external_origin" },
 		{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
 		{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
-		{ 9, 9, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
+		{ 1, 10, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
 	};
 
 	static const char _lvmconf[] = "global/thin_disabled_features";


