From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  7 Oct 2014 06:59:08 +0000 (UTC)
Subject: master - lvconvert: Allow --repair and --splitmirrors on reserved-name LVs.
Message-ID: <20141007065908.356926113C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b66f16fd63014c958d65ab37df4b72f1566176d3
Commit:        b66f16fd63014c958d65ab37df4b72f1566176d3
Parent:        86dad329be2fa20a528066776aab77f26a29790c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 7 08:55:09 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 7 08:58:24 2014 +0200

lvconvert: Allow --repair and --splitmirrors on reserved-name LVs.

---
 test/shell/lvconvert-cache.sh |   16 ++++++++++++++++
 tools/lvconvert.c             |    2 ++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index c108008..1c62309 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -99,6 +99,22 @@ lvconvert --splitmirrors 1 --name split $vg/corigin $dev1
 
 lvremove -f $vg
 
+lvcreate -n cpool_meta -m 1 --type raid1 -l 10 $vg
+lvcreate -n cpool -m 1 --type raid1 -l 10 $vg
+lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
+lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
+
+lvconvert --repair -y $vg/cpool_cmeta
+lvconvert --repair -y $vg/cpool_cdata
+
+# do not allow reserved names for *new* LVs
+not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cmeta $dev1
+not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata $dev1
+
+# but allow manipulating existing LVs with reserved names
+lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta $dev1
+lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata $dev1
+
 #######################
 # Invalid conversions #
 #######################
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8f25561..fc22823 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -160,6 +160,8 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		lp->lv_name = lp->lv_name_full;
 
 	if (!lp->merge_mirror &&
+	    !arg_count(cmd, repair_ARG) &&
+	    !arg_count(cmd, splitmirrors_ARG) &&
 	    !strstr(lp->lv_name, "_tdata") &&
 	    !strstr(lp->lv_name, "_tmeta") &&
 	    !apply_lvname_restrictions(lp->lv_name))


