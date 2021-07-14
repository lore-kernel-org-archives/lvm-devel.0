From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 14 Jul 2021 10:56:44 +0000 (GMT)
Subject: main - thin: fix component detection of external origin
Message-ID: <20210714105644.A17F3385E44A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d38fdb25e4debc035f1e4585432c2627460d5e50
Commit:        d38fdb25e4debc035f1e4585432c2627460d5e50
Parent:        e33c2e032cab40cf8607afa1cb92176400d1cabd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 14 12:53:47 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 14 12:56:08 2021 +0200

thin: fix component detection of external origin

When check active componet of thinLV with external origin,
we need to check if the external origin isn't already active.
For this however we need to use layered check for -real device.
---
 WHATS_NEW                          |  1 +
 lib/activate/activate.c            |  5 ++++-
 test/shell/lvconvert-cache-thin.sh | 22 ++++++++++++++++++++++
 3 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 810411914..b06071c42 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.13 - 
 ===============================
+  Fix detection of active components of external origin volume.
   Add vdoimport tool to support conversion of VDO volumes.
   Support configurable allocation/vdo_pool_header_size.
   Fix handling of lvconvert --type vdo-pool --virtualsize.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6bda7385b..94fc9441d 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2740,7 +2740,10 @@ static int _component_cb(struct logical_volume *lv, void *data)
 	    (lv_is_thin_pool(lv) && pool_is_active(lv)))
 		return -1;
 
-	if (lv_is_active(lv)) {
+	/* External origin is activated through thinLV and uses -real suffix.
+	 * Note: for old clustered logic we would need to check for all thins */
+	if ((lv_is_external_origin(lv) && lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0)) ||
+	    lv_is_active(lv)) {
 		if (!lv_is_component(lv) || lv_is_visible(lv))
 			return -1;	/* skip whole subtree */
 
diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
index 7dda6e6ff..9254239ee 100644
--- a/test/shell/lvconvert-cache-thin.sh
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -67,4 +67,26 @@ fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv
 # Thin-pool CAN use cached data LV
 lvconvert --yes --thinpool $vg/$lv
 
+lvremove -f $vg
+
+# Check we can active snapshot of cached external origin (BZ: 1967744)
+lvcreate -T -L10M $vg/pool "$dev1"
+
+lvcreate -L10M -n origin $vg "$dev1"
+lvcreate -H -L4M -n CPOOL $vg/origin "$dev2"
+
+# Use cached origin as external origin
+lvconvert -y -T --thinpool $vg/pool --originname extorig origin
+
+# Check we can easily create snapshot of such LV
+lvcreate -y -kn -n snap -s $vg/origin
+
+# Deactivate everything and do a component activation of _cmeta volume
+lvchange -an $vg
+lvchange -ay -y $vg/CPOOL_cpool_cmeta
+
+# Now this must fail since component volume is active
+not lvcreate -y -kn -n snap2 -s $vg/origin |& tee err
+grep "cmeta is active" err
+
 vgremove -f $vg


