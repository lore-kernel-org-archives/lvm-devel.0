From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 20 Aug 2016 01:15:14 +0000 (UTC)
Subject: master - raid: Don't monitor raid0 or raid0_meta LVs.
Message-ID: <20160820011514.CFDB960FF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7646741ec67845f47b77eb647ef0fedc78d6b92c
Commit:        7646741ec67845f47b77eb647ef0fedc78d6b92c
Parent:        896912b14d80e49582759d0c5b14b16954b3857d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Aug 20 02:14:33 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Aug 20 02:14:33 2016 +0100

raid: Don't monitor raid0 or raid0_meta LVs.

---
 WHATS_NEW       |    2 +-
 lib/raid/raid.c |    7 ++++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5a258c1..0b23018 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.165 - 
 ===================================
-  Don't allow lvconvert --repair on raid0 devices.
+  Don't allow lvconvert --repair on raid0 devices or attempt to monitor them.
   No longer adjust incorrect number of raid stripes supplied to lvcreate.
   Move lcm and gcd to lib/misc.
   Suppress some unnecessary --stripesize parameter warnings.
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index ef5794f..3bc3c75 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -499,7 +499,12 @@ static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
 
 	segtype->ops = &_raid_ops;
 	segtype->name = rt->name;
-	segtype->flags = SEG_RAID | SEG_ONLY_EXCLUSIVE | rt->extra_flags | monitored;
+	segtype->flags = SEG_RAID | SEG_ONLY_EXCLUSIVE | rt->extra_flags;
+
+	/* Never monitor raid0 or raid0_meta LVs */
+	if (!segtype_is_any_raid0(segtype))
+		segtype->flags |= monitored;
+
 	segtype->parity_devs = rt->parity;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);


