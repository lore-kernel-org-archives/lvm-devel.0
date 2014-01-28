From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 28 Jan 2014 12:25:25 +0000 (UTC)
Subject: master - thin: more validation of thin name
Message-ID: <20140128122525.EDE4A60E05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9d9852c55cbc2c509c293691287fa5443868926
Commit:        e9d9852c55cbc2c509c293691287fa5443868926
Parent:        bc5f40ee1c7c409c17f85a55f6a8b2606067e76e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 28 13:21:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 28 13:21:39 2014 +0100

thin: more validation of thin name

Avoid starting conversion of the LV to the thin pool and thin volume
at the same time.  Since this is mostly a user mistake, do not try
to just convert to one of those type, since we cannot assume if the
user wanted LV to become thin volume or thin pool.

Before the fix tool reported pretty strange internal error:
Internal error: Referenced LV lvol1_tdata not listed in VG mvg.

Fixed output:
lvconvert --thinpool lvol0 -T mvg/lvol0
Can't use same LV mvg/lvol0 for thin pool and thin volume.
---
 WHATS_NEW                             |    1 +
 test/shell/lvconvert-thin-external.sh |    4 ++++
 tools/lvconvert.c                     |    6 ++++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ca56623..3a4c7ec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Avoid trying to convert single to thin pool and volume at the same time.
   Add support for partitions on ZFS zvol.
   Fix unwanted drop of hold flocks on forked children.
   Respect LVM_LVMETAD_PIDFILE env var for lvm command.
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index d9d4d19..53758fc 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -56,6 +56,10 @@ lvremove -f $vg/pool1
 # create plain LV (will be used for external origin)
 lvcreate -L8M -n $lv1 $vg
 
+# Can't convert same LV to the thin pool and thin volume
+not lvconvert --thinpool $vg/$lv1 -T $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+
 mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
 mkdir mnt
 mount $DM_DEV_DIR/$vg/$lv1 mnt
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 87eb643..ffbf768 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2582,6 +2582,12 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	}
 
 	if (lp->thin) {
+		if (strcmp(pool_lv->name, lp->pool_data_lv_name) == 0) {
+			log_error("Can't use same LV %s/%s for thin pool and thin volume.",
+				  pool_lv->vg->name, pool_lv->name);
+			return 0;
+		}
+
 		external_lv = pool_lv;
 		if (!(pool_lv = find_lv(external_lv->vg, lp->pool_data_lv_name))) {
 			log_error("Can't find pool LV %s/%s.",


