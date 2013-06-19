From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 19 Jun 2013 22:54:27 +0000 (UTC)
Subject: master - RAID/MIRROR: Honor mirror_segtype_default when upconverting linear LVs
Message-ID: <20130619225427.36BDC60F3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6d13308ec0baca9a5bd48f80d02e5c71a54287f
Commit:        a6d13308ec0baca9a5bd48f80d02e5c71a54287f
Parent:        4d2aa6a7aa6f8208bc27b7f0579e7d85562af2d0
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 19 17:50:10 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 19 17:50:10 2013 -0500

RAID/MIRROR: Honor mirror_segtype_default when upconverting linear LVs

If the user would upconvert a linear LV to a mirror without specifying
the segment type ("--type mirror" vs "--type raid1"), the "mirror"
segment type would be chosen without consulting the 'default_mirror_segtype'
setting in lvm.conf.  This is now used as the basis for determining
which should be used if left unspecified.
---
 WHATS_NEW                      |    2 ++
 test/shell/lvconvert-mirror.sh |   12 ++++++++++--
 test/shell/lvconvert-raid.sh   |   18 ++++++++++++++++++
 tools/lvconvert.c              |    2 +-
 4 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 19bcf82..d527854 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.99 - 
 ===================================
+  Use mirror_segtype_default if type not specified for linear->mirror upconvert.
+  Make upconvert from linear use mirror_segtype_default to determine segtype.
   Fix use of too big chunks of memory when communication with lvmetad.
   Fix vgcfgrestore crash when specified incorrect vg name.
   Refine lvm.conf and man page documentation for autoactivation feature.
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 420241a..e3c01fa 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -16,9 +16,17 @@ aux prepare_pvs 5 10
 DEVRANGE="0-32"
 vgcreate -s 32k $vg $(cat DEVICES)
 
-# convert from linear to 2-way mirror
+# convert from linear to 2-way mirror ("mirror" default type)
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
-lvconvert -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1"
+lvconvert -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1" \
+	--config 'global { mirror_segtype_default = "mirror" }'
+check mirror $vg $lv1 "$dev3"
+lvremove -ff $vg
+
+# convert from linear to 2-way mirror (override "raid1" default type)
+lvcreate -aey -l2 -n $lv1 $vg "$dev1"
+lvconvert --type mirror -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1" \
+	--config 'global { mirror_segtype_default = "raid1" }'
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 61345da..8693cf3 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -136,6 +136,24 @@ lvconvert --merge $vg/${lv1}_rimage_2
 lvremove -ff $vg
 
 ###########################################
+# Linear to RAID1 conversion ("raid1" default segtype)
+###########################################
+lvcreate -l 2 -n $lv1 $vg
+lvconvert -m 1 $vg/$lv1 \
+	--config 'global { mirror_segtype_default = "raid1" }'
+lvs --noheadings -o attr $vg/$lv1 | grep '^r*'
+lvremove -ff $vg
+
+###########################################
+# Linear to RAID1 conversion (override "mirror" default segtype)
+###########################################
+lvcreate -l 2 -n $lv1 $vg
+lvconvert --type raid1 -m 1 $vg/$lv1 \
+	--config 'global { mirror_segtype_default = "mirror" }'
+lvs --noheadings -o attr $vg/$lv1 | grep '^r*'
+lvremove -ff $vg
+
+###########################################
 # Mirror to RAID1 conversion
 ###########################################
 for i in 1 2 3 ; do
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 46f996a..be6b55f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -490,7 +490,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 
-		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "mirror"));
+		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG)));
 		if (!lp->segtype)
 			return_0;
 	}


