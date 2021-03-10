From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:45 +0000 (GMT)
Subject: main - cov: ensure buffer is initialized
Message-ID: <20210310003645.AC672385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7912635a0698b73120adf499f335145506a8b9e
Commit:        f7912635a0698b73120adf499f335145506a8b9e
Parent:        8a0367524182f55e7e982f0b5700d90f2a9519e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 16:12:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:35:02 2021 +0100

cov: ensure buffer is initialized

---
 lib/config/config.c      | 2 ++
 libdm/dm-tools/dmsetup.c | 1 +
 2 files changed, 3 insertions(+)

diff --git a/lib/config/config.c b/lib/config/config.c
index 409555096..485063a3d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1141,6 +1141,8 @@ int config_def_check(struct cft_check_handle *handle)
 	 * sections and settings with full path as a key.
 	 * If section name is variable, use '#' as a substitute.
 	 */
+	*vp = 0;
+	*rp = 0;
 	if (!handle->cmd->cft_def_hash) {
 		if (!(handle->cmd->cft_def_hash = dm_hash_create(60))) {
 			log_error("Failed to create configuration definition hash.");
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 46fa81069..a3d1248bc 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -5158,6 +5158,7 @@ static int _stats_group_segments(struct dm_stats *dms, uint64_t *region_ids,
 		return 0;
 	}
 
+	*regions = 0;
 	for (i = 0; i < count; i++) {
 		/*
 		 * We don't expect large numbers of segments (compared to e.g.


