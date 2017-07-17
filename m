From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:23 -0400
Subject: master - lvmcmdline: validate size as double
Message-ID: <201707171140.v6HBeNt6022526@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94838b4df06c4f5a47c4cb51d5949d8e7b4684e7
Commit:        94838b4df06c4f5a47c4cb51d5949d8e7b4684e7
Parent:        28e319ddc0cf3f60ee200a2c4a0bab971e1490c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 09:53:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:32:18 2017 +0200

lvmcmdline: validate size as double

Since we are reading size as (double) we can get way bigger
number then just plain int64. So to make this check actually
more valid and usable do a maxsize compare in 'double'.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 477d4ea..48ec679 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Improve --size args validation and report more detailed error message.
   Initialize debugging mutex before any debug message in clvmd.
   Log error instad of warn when noticing connection problem with lvmetad.
   Fix memory leak in lvmetad when working with duplicates.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 700593c..d3523be 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -617,7 +617,8 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 	} else
 		v *= factor;
 
-	if ((uint64_t) v >= (UINT64_MAX >> SECTOR_SHIFT)) {
+	/* Compare (double) */
+	if (v >= (double) (UINT64_MAX >> SECTOR_SHIFT)) {
 		log_error("Size is too big (>=16EiB).");
 		return 0;
 	}


