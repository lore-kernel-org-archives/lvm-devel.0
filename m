From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Oct 2012 12:09:41 +0000 (UTC)
Subject: master - thin: raise required version to 1.4
Message-ID: <20121011120941.84F7BA0D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=316ce655a37136375dc9ea1204f218838d77ce41
Commit:        316ce655a37136375dc9ea1204f218838d77ce41
Parent:        57460fe5a853c0824d35c02b2a77ef0afc8a5f2d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 11 14:07:35 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 11 14:09:07 2012 +0200

thin: raise required version to 1.4

Stay safe and require 1.4 (kernel 3.6) for non-power-of-2
support for thin pool chunk_size.
---
 lib/thin/thin.c                    |    4 ++--
 man/lvcreate.8.in                  |    2 +-
 test/shell/lvcreate-thin-power2.sh |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index fd0c117..2b6c71f 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -244,7 +244,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
 	    (seg->chunk_size & (seg->chunk_size - 1))) {
 		log_error("Thin pool target does not support %uKiB chunk size "
-			  "(needs kernel >= 3.5).", seg->chunk_size / 2);
+			  "(needs kernel >= 3.6).", seg->chunk_size / 2);
 		return 0;
 	}
 
@@ -559,7 +559,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
 			log_debug("Target " THIN_MODULE " does not support external origins.");
 
-		if (maj >=1 && min >= 2)
+		if (maj >=1 && min >= 4)
 			_attrs |= THIN_FEATURE_BLOCK_SIZE;
 		else
 		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 0c39278..fb54cc6 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -133,7 +133,7 @@ For thin pools the value must be between 64KiB and
 1048576KiB and the default value starts with 64 and scales
 up to fit the pool metadata size within 128MB,
 if the poolmetadata size is not specified.
-Older dm thin pool target version (<1.2) requires the value to be power of 2.
+Older dm thin pool target version (<1.4) requires the value to be power of 2.
 The newer version requires to be the multiple of 64KiB, however discard is
 not supported for non power of 2 values.
 Default unit is in kilobytes.
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index e1c793c..882b05c 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -18,7 +18,7 @@
 #
 # Main
 #
-aux have_thin 1 2 0 || skip
+aux have_thin 1 4 0 || skip
 
 aux prepare_pvs 2 64
 


