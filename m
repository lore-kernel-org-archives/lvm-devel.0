From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  6 Oct 2014 06:14:18 +0000 (UTC)
Subject: master - lvconvert: Forward --splitmirror to a cache origin when applicable.
Message-ID: <20141006061418.528376029C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2f901f04f76cca110475395272e70c83bea816d
Commit:        d2f901f04f76cca110475395272e70c83bea816d
Parent:        91615603cdc7974047103c4c6f6af7e56f97437b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 6 08:11:06 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 6 08:11:06 2014 +0200

lvconvert: Forward --splitmirror to a cache origin when applicable.

---
 test/shell/lvconvert-cache.sh |   14 ++++++++++++++
 tools/lvconvert.c             |   10 ++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 6c2acd9..5979912 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -81,4 +81,18 @@ lvs -a $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
 dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
 lvremove -ff $vg
 
+lvcreate -n corigin -l 10 $vg
+lvcreate -n pool -l 10 $vg
+lvs -a -o +devices
+echo n | not lvconvert --type cache --cachepool $vg/pool $vg/corigin
+lvconvert -y --type cache --cachepool $vg/pool $vg/corigin
+
+lvremove -ff $vg
+
+# TODO: creating a cache on top of active RAID appears to be broken
+lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
+lvcreate -n cpool --type cache $vg/corigin -l 10
+lvchange --refresh $vg # fix up DM tables
+lvconvert --splitmirrors 1 --name split $vg/corigin $dev1
+
 vgremove -f $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 09257e3..0d800ec 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3064,6 +3064,7 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle)
 {
+	struct logical_volume *origin = NULL;
 	struct lvconvert_params *lp = handle;
 	struct dm_list *failed_pvs;
 
@@ -3102,6 +3103,15 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	/* forward splitmirror operations to the cache origin, which may be raid
+	 * or old-style mirror */
+	if (arg_count(cmd, splitmirrors_ARG) && lv_is_cache_type(lv)
+	    && (origin = seg_lv(first_seg(lv), 0)) && lv_is_cache_origin(origin)) {
+		log_warn("WARNING: Selected operation does not work with cache-type LVs.");
+		log_warn("Proceeding using the cache origin LV %s instead", origin->name);
+		lv = origin;
+	}
+
 	if (!lp->segtype) {
 		/* segtype not explicitly set in _read_params */
 		lp->segtype = first_seg(lv)->segtype;


