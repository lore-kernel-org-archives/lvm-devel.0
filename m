From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:46 +0000 (UTC)
Subject: master - liblvm: replace pvcreate_single with pvcreate_vol
Message-ID: <20160225151546.2C13060EE3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0cd7d2332c4f6b5f6b71e6fe38a7678074c34bcc
Commit:        0cd7d2332c4f6b5f6b71e6fe38a7678074c34bcc
Parent:        a9940bd3c928598d1f15a60503c146046e55a357
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 26 11:50:11 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

liblvm: replace pvcreate_single with pvcreate_vol

And remove the pvcreate_single wrapper.
---
 lib/metadata/metadata-exported.h |    2 --
 lib/metadata/pv_manip.c          |   21 ---------------------
 liblvm/lvm_pv.c                  |   12 ++++++++++--
 3 files changed, 10 insertions(+), 25 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0a45397..008aef2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -647,8 +647,6 @@ struct lvresize_params {
 	const char *ac_type;
 };
 
-int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-		    struct pvcreate_params *pp);
 void pvcreate_params_set_defaults(struct pvcreate_params *pp);
 
 /*
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 4a0992b..f54111c 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -864,24 +864,3 @@ out:
 
 	return ret;
 }
-
-int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-		    struct pvcreate_params *pp)
-{
-	int r = 0;
-
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return 0;
-	}
-
-	if (!(pvcreate_vol(cmd, pv_name, pp, 1)))
-		goto_out;
-
-	r = 1;
-
-out:
-	unlock_vg(cmd, VG_ORPHANS);
-
-	return r;
-}
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 9b979f3..9bc7153 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -419,6 +419,7 @@ int lvm_pv_params_set_property(pv_create_params_t params, const char *name,
 static int _pv_create(pv_create_params_t params)
 {
 	struct cmd_context *cmd = (struct cmd_context *)params->libh;
+	int rc = 0;
 
 	if (params->pv_p.size) {
 		if (params->pv_p.size % SECTOR_SIZE) {
@@ -428,9 +429,16 @@ static int _pv_create(pv_create_params_t params)
 		params->pv_p.size = params->pv_p.size >> SECTOR_SHIFT;
 	}
 
-	if (!pvcreate_single(cmd, params->pv_name, &params->pv_p))
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_errno(EINVAL, "Can't get lock for orphan PVs");
 		return -1;
-	return 0;
+	}
+
+	if (!(pvcreate_vol(cmd, params->pv_name, &params->pv_p, 1)))
+		rc = -1;
+
+	unlock_vg(cmd, VG_ORPHANS);
+	return rc;
 }
 
 int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)


