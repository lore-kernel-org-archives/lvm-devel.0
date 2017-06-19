From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 19 Jun 2017 15:07:53 -0400
Subject: master - lvconvert: disable reshaping of RAID LVs in the cluster
Message-ID: <201706191907.v5JJ7r58031688@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb46175ce7550fd6c9f40e6d8eec337fc2693e80
Commit:        fb46175ce7550fd6c9f40e6d8eec337fc2693e80
Parent:        1c212b8a43750ea48b9e96da75c1349682c81454
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jun 19 20:01:01 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jun 19 21:06:53 2017 +0200

lvconvert: disable reshaping of RAID LVs in the cluster

Disable until we have a proper fix for reshape space allocation,
switching it to begin/end of rimages and activation in the cluster.

Related: rhbz1448116
Related: rhbz1461526
Related: rhbz1448123
---
 lib/metadata/raid_manip.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5c3f9ef..6abf482 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6319,6 +6319,12 @@ int lv_raid_convert(struct logical_volume *lv,
 	case 0:
 		break;
 	case 1:
+		/* Conversion of reshapable raids is the cluster is not supported yet. */
+		if (locking_is_clustered()) {
+			log_error("Conversion of %s not supported in the cluster.", display_lvname(lv));
+			return 0;
+		}
+
 		if (!_raid_reshape(lv, new_segtype, yes, force,
 				   data_copies, region_size,
 				   stripes, stripe_size, allocate_pvs)) {


