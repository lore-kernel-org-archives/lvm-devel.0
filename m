From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jan 2014 13:23:46 +0000 (UTC)
Subject: master - thin: fix feature compare function
Message-ID: <20140123132346.A31696062C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8b20fb8e8e54561321b030fae7249ac2c2ac950
Commit:        f8b20fb8e8e54561321b030fae7249ac2c2ac950
Parent:        902b343e0ed071e684dfe89086c740db2e20c663
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 23 13:47:23 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 14:22:31 2014 +0100

thin: fix feature compare function

Comparing for available feature missed the code path, when
maj is already bigger.

The bug would be only hit in the case, thin pool target would have
increased major version.
---
 WHATS_NEW       |    1 +
 lib/thin/thin.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c385951..04d62e5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix test when checking target version for available thin features.
   Detect thin feature external_origin_extend and limit extend when missing.
   Rename internal pool_can_resize_metadata() to thin_pool_feature_supported().
   Issue error if libbblkid detects signature and fails to return offset/length.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index cf74964..0b8eaf8 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -651,7 +651,8 @@ static int _thin_target_present(struct cmd_context *cmd,
 		}
 
 		for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
-			if (maj >= _features[i].maj && min >= _features[i].min)
+			if ((maj > _features[i].maj) ||
+			    (maj == _features[i].maj && min >= _features[i].min))
 				_attrs |= _features[i].thin_feature;
 			else
 				log_very_verbose("Target %s does not support %s.",


