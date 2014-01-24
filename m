From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Jan 2014 11:30:41 +0000 (UTC)
Subject: master - thin: use LV_TEMPORARY for metadata initialization
Message-ID: <20140124113041.7B89B616BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=731c298e12e36e338afdbda029e6cffb2c98b3eb
Commit:        731c298e12e36e338afdbda029e6cffb2c98b3eb
Parent:        432ff4bd720596bd3e56290c29646e8ba43575fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 24 12:28:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 24 12:30:28 2014 +0100

thin: use LV_TEMPORARY for metadata initialization

This flag need to be specified when we create thin pool - to avoid
scanning device with watch rules.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    7 ++++---
 lib/metadata/pool_manip.c        |    9 ++++++++-
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 04d62e5..6818026 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Avoid exposing temporary devices when initializing thin pool volume.
   Fix test when checking target version for available thin features.
   Detect thin feature external_origin_extend and limit extend when missing.
   Rename internal pool_can_resize_metadata() to thin_pool_feature_supported().
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6e7987d..2f1f9ec 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -105,9 +105,10 @@
 #define LV_NOSCAN		UINT64_C(0x0000080000000000)	/* LV - internal use only - the LV
 									should not be scanned */
 #define LV_TEMPORARY		UINT64_C(0x0000100000000000)	/* LV - internal use only - the LV
-								        is supposed to be created and
-									removed during single LVM
-									command execution. */
+									is supposed to be created and
+									removed or reactivated with
+									this flag dropped during single
+									LVM command execution. */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 148b30c..2cb0c27 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -241,7 +241,13 @@ int create_pool(struct logical_volume *pool_lv,
 		 *
 		 * FIXME: implement lazy clearing when activation is disabled
 		 */
-		/* pool_lv is a new LV so the VG lock protects us */
+		/*
+		 * pool_lv is a new LV so the VG lock protects us
+		 * Pass in LV_TEMPORARY flag, since device is activated purely for wipe
+		 * and later it is either deactivated (in cluster)
+		 * or directly converted to invisible device via suspend/resume
+		 */
+		pool_lv->status |= LV_TEMPORARY;
 		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv) ||
 		    /* Clear 4KB of metadata device for new thin-pool. */
 		    !wipe_lv(pool_lv, (struct wipe_params) { .do_zero = 1 })) {
@@ -249,6 +255,7 @@ int create_pool(struct logical_volume *pool_lv,
 				  pool_lv->name);
 			goto bad;
 		}
+		pool_lv->status &= LV_TEMPORARY;
 	}
 
 	if (dm_snprintf(name, sizeof(name), "%s_%s", pool_lv->name,


