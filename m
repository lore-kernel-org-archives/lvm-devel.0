From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 22 Nov 2012 00:49:49 +0000 (UTC)
Subject: master - RAID: If no stripes argument is given for RAID10 create, default to 2
Message-ID: <20121122004949.89587A0C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3e9a09abefde12be2031235275f11d4a53dea11
Commit:        b3e9a09abefde12be2031235275f11d4a53dea11
Parent:        fb0cee9a66db6141ed331c8058d2c5c2c3a30cc1
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Nov 21 18:46:52 2012 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Nov 21 18:46:52 2012 -0600

RAID:  If no stripes argument is given for RAID10 create, default to 2

Similar to the way the 'mirror', 'raid1' and 'raid10' segment types set
the number of mirrors to 2 ('-m 1') if the argument is not specified,
here we set the number of stripes to 2 if not given on the command line
when creating a RAID10 LV.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |   13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a0504fc..0904940 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  When no '-i' argument is given for RAID10, default to 2 stripes.
   Do not allow --splitmirrors on RAID10 logical volumes.
   Skip mlocking [vectors] on arm architecture.
   Support allocation of pool metadata with lvconvert command.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 801ff64..0d76bbe 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -493,13 +493,24 @@ static int _read_raid_params(struct lvcreate_params *lp,
 	 *   lp->stripes
 	 *   lp->stripe_size
 	 *
-	 * For RAID 4/5/6, these values must be set.
+	 * For RAID 4/5/6/10, these values must be set.
 	 */
 	if (!segtype_is_mirrored(lp->segtype) &&
 	    (lp->stripes <= lp->segtype->parity_devs)) {
 		log_error("Number of stripes must be at least %d for %s",
 			  lp->segtype->parity_devs + 1, lp->segtype->name);
 		return 0;
+	} else if (!strcmp(lp->segtype->name, "raid10") && (lp->stripes < 2)) {
+		if (arg_count(cmd, stripes_ARG)) {
+			/* User supplied the bad argument */
+			log_error("Segment type 'raid10' requires 2 or more stripes.");
+			return 0;
+		}
+		/* No stripe argument was given - default to 2 */
+		lp->stripes = 2;
+		lp->stripe_size = find_config_tree_int(cmd,
+						       "metadata/stripesize",
+						       DEFAULT_STRIPESIZE) * 2;
 	}
 
 	/*


