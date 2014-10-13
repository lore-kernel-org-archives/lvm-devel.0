From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 13 Oct 2014 14:24:10 +0000 (UTC)
Subject: master - lvchange: Allow appropriate actions on cache (in addition to thin) pools.
Message-ID: <20141013142410.4D60F60F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22a6b0e40b302b333f9bd995c0b81b0146e8232a
Commit:        22a6b0e40b302b333f9bd995c0b81b0146e8232a
Parent:        b59335fb398062d6537e8d4e815dcbf339343967
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 13 16:21:41 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 13 16:21:41 2014 +0200

lvchange: Allow appropriate actions on cache (in addition to thin) pools.

---
 test/shell/lvconvert-cache-raid.sh |    4 +++-
 tools/lvchange.c                   |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 0678846..3ac2d0b 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -49,6 +49,9 @@ lvcreate -n cpool -m 1 --type raid1 -l 10 $vg
 lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
 lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
 
+lvchange --syncaction repair $vg/cpool_cmeta
+lvchange --syncaction repair $vg/cpool_cdata
+
 lvconvert --repair -y $vg/cpool_cmeta
 lvconvert --repair -y $vg/cpool_cdata
 
@@ -60,5 +63,4 @@ not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata "$dev1"
 lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
 lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
 
-
 vgremove -f $vg
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3a0e848..114065c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -857,7 +857,8 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
 		lv = origin;
 
-	if ((lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv)) &&
+	if ((lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv) ||
+	     lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) &&
 	    !arg_count(cmd, activate_ARG) &&
 	    !arg_count(cmd, permission_ARG) &&
 	    !arg_count(cmd, setactivationskip_ARG))


