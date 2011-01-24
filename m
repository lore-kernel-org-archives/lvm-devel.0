From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 24 Jan 2011 12:03:54 +0100
Subject: [PATCH 03/17] Add struct format_instance *fid field to struct physical_volume.
In-Reply-To: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1295867048-21558-4-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

So PV has also a format instance from now on.
Also, for starters, let's create a new PV-based format_instance in
pv_create code.

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/metadata/metadata.c |    7 +++++++
 lib/metadata/pv.h       |    1 +
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c3accaf..ed2084d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1547,6 +1547,7 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
 	if (!pv)
 		return_NULL;
 
+	pv->fid = NULL;
 	pv->pe_size = 0;
 	pv->pe_start = 0;
 	pv->pe_count = 0;
@@ -1638,6 +1639,12 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 		goto bad;
 	}
 
+	if (!(pv->fid = fmt->ops->create_instance(fmt, (const char *) &pv->id,
+						  NULL, NULL, NULL))) {
+		log_error("Couldn't create format instance for PV %s.", pv_dev_name(pv));
+		goto bad;
+	}
+
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
 
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index a02f6f8..a9efcfe 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -24,6 +24,7 @@ struct physical_volume {
 	struct id id;
 	struct device *dev;
 	const struct format_type *fmt;
+	struct format_instance *fid;
 
 	/*
 	 * vg_name and vgid are used before the parent VG struct exists.
-- 
1.7.3.4


