From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Dec 2012 15:04:43 +0000 (UTC)
Subject: master - lvconvert: allow lvconvert --stripes/stripesize only with -mirrors/--repair/--thinpool
Message-ID: <20121211150443.1CF7DA0D8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cad22be3942809bac979d42195ea5a861a91a71f
Commit:        cad22be3942809bac979d42195ea5a861a91a71f
Parent:        b38ba2708346b52a48be5596b22b3ad4f1304af1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 11 15:50:25 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 11 15:50:25 2012 +0100

lvconvert: allow lvconvert --stripes/stripesize only with -mirrors/--repair/--thinpool

Also, update lvconvert man page to reflect this and make clear that
the --stripes/stripesize is applied to newly allocated space only.
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |    7 ++++++-
 tools/lvconvert.c  |    8 ++++++++
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a9aa152..dbd59bf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Allow lvconvert --stripes/stripesize only with --mirrors/--repair/--thinpool.
   Fix memleak in device_is_usable mirror testing function.
   Do not ignore -f in lvconvert --repair -y -f for mirror and raid volumes.
   Disallow pvmove on RAID LVs until they are addressed properly
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 4fe9bdd..578047b 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -61,6 +61,10 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .sp
 .B lvconvert \-\-repair
 .RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-stripes
+.I Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .IR LogicalVolume [ Path ]
@@ -274,7 +278,8 @@ This option is only available to RAID segment types
 .BR \-\-stripes " " \fIStripes
 Gives the number of stripes.
 This is equal to the number of physical volumes to scatter
-the logical volume.
+the logical volume. This does not apply to existing allocated
+space, only newly allocated space can be striped.
 .TP
 .BR \-I ", " \-\-stripesize " " \fIStripeSize
 Gives the number of kilobytes for the granularity of the stripes.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2d51069..9c947d7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -167,6 +167,14 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		return 0;
 	}
 
+	if ((arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) &&
+	    !(arg_count(cmd, mirrors_ARG) || arg_count(cmd, repair_ARG) ||
+	      arg_count(cmd, thinpool_ARG))) {
+		log_error("--stripes or --stripesize argument is only valid "
+			  "with --mirrors, --repair or --thinpool");
+		return 0;
+	}
+
 	if (!arg_count(cmd, background_ARG))
 		lp->wait_completion = 1;
 


