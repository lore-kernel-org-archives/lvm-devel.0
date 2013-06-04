From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:27 +0000 (UTC)
Subject: dev-mornfall-activate - snapshot: fix resize of 100% full cow
Message-ID: <20130604192727.9ADFF60DCA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56779c32c500426db33d0e6032160ef4f5e0bbcc
Commit:        56779c32c500426db33d0e6032160ef4f5e0bbcc
Parent:        99f04835802ee675242a4896697eb784717ee998
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 21:17:15 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:26:20 2013 +0200

snapshot: fix resize of 100% full cow

When the COW area is using all the available space (100%) it can be still
a valid snapshot which may need a resize. So support it.
---
 WHATS_NEW        |    1 +
 tools/lvresize.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 86357fd..1888c62 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix lvresize --use-policies of VALID but 100% full snapshot.
   Do not accept size parameters bigger then 16EiB.
   Fix release of PV's fid in free_pv_fid().
   Skip monitoring of snapshots that are already bigger then origin.
diff --git a/tools/lvresize.c b/tools/lvresize.c
index b679bf9..b1008ec 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -321,7 +321,7 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 	} else {
 		if (!lv_snapshot_percent(lv, &percent))
 			return_0;
-		if (!(PERCENT_0 < percent && percent < PERCENT_100) || percent <= policy_threshold)
+		if (!(PERCENT_0 < percent && percent <= PERCENT_100) || percent <= policy_threshold)
 			return 1; /* nothing to do */
 	}
 


