From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 May 2017 11:45:59 -0400
Subject: master - vg_read: check for NULL dev to avoid segfault
Message-ID: <201705101545.v4AFjx0S020888@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d45531712d7c18035975980069a1683c218abec2
Commit:        d45531712d7c18035975980069a1683c218abec2
Parent:        b817cc5746ef3bd3105a73e43aaf4b2ccd134335
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 9 15:44:26 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 10 10:45:41 2017 -0500

vg_read: check for NULL dev to avoid segfault

There are certain situations (not fully understood)
where is_missing_pv() is false, but pv->dev is NULL,
so this adds a check for NULL pv->dev after is_missing_pv()
to avoid a segfault.
---
 lib/metadata/metadata.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1b500ed..972306e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4039,6 +4039,7 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 				   struct volume_group *vg,
 				   int repair, int *inconsistent_pvs)
 {
+	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_info *info;
 	uint32_t ext_version, ext_flags;
 	struct pv_list *pvl;
@@ -4052,6 +4053,14 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 		if (is_missing_pv(pvl->pv))
 			continue;
 
+		if (!pvl->pv->dev) {
+			/* is_missing_pv doesn't catch NULL dev */
+			memset(&uuid, 0, sizeof(uuid));
+			id_write_format(&pvl->pv->id, uuid, sizeof(uuid));
+			log_warn("WARNING: Not repairing PV %s with missing device.", uuid);
+			continue;
+		}
+
 		if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, pvl->pv->dev, 0))) {
 			log_error("Failed to find cached info for PV %s.", pv_dev_name(pvl->pv));
 			goto out;


