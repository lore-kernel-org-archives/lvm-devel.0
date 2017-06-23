From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 12:49:11 -0400
Subject: master - raid: switch message to verbose
Message-ID: <201706231649.v5NGnBIx019864@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63ecbcd1b701b15e43e141f6ab2001dff7622e88
Commit:        63ecbcd1b701b15e43e141f6ab2001dff7622e88
Parent:        6d30350dd1bed68826ebe103f3e58c46d251caf6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 11:14:31 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:44:01 2017 +0200

raid: switch message to verbose

As this is not 'error' resulting query, decrease reported level.
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index be431f1..6bd0fb2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -49,7 +49,7 @@ static int _reshape_is_supported(struct cmd_context *cmd, const struct segment_t
 	if (!segtype->ops->target_present ||
             !segtype->ops->target_present(cmd, NULL, &attrs) ||
             !(attrs & RAID_FEATURE_RESHAPE)) {
-		log_error("RAID module does not support reshape.");
+		log_debug("RAID module does not support reshape.");
 		return 0;
 	}
 


