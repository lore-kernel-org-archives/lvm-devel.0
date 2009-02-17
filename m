From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 16 Feb 2009 21:55:15 -0500
Subject: [PATCH 1/3] Add lvm_vg_name() and lvm_vg_uuid().
In-Reply-To: <1234839317-20159-1-git-send-email-dwysocha@redhat.com>
References: <20090216190806.GA26197@agk.fab.redhat.com>
	<1234839317-20159-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1234839317-20159-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |   19 +++++++++++++++++++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a1c45ce..d279b31 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -621,6 +621,8 @@ uint32_t pv_pe_size(const pv_t *pv);
 uint64_t pv_pe_start(const pv_t *pv);
 uint32_t pv_pe_count(const pv_t *pv);
 uint32_t pv_pe_alloc_count(const pv_t *pv);
+const char *lvm_vg_name(const vg_t *vg);
+const char *lvm_vg_uuid(vg_t *vg);
 
 int vg_missing_pv_count(const vg_t *vg);
 uint32_t vg_status(const vg_t *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a2b5f2f..e699ae9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2673,6 +2673,25 @@ vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 	return vg_read(cmd, vg_name, vgid, flags | READ_FOR_UPDATE);
 }
 
+const char *lvm_vg_name(const vg_t *vg)
+{
+	return vg->name;
+}
+
+/* FIXME: signedness + null termination problem - export proper uuid type */
+const char *lvm_vg_uuid(vg_t *vg)
+{
+	char *value;
+
+	/* FIXME: leak - this is really bad */
+	if (!(value = dm_pool_zalloc(vg->cmd->mem, sizeof(vg->id.uuid)+1)))
+		return NULL;
+	strncpy(value, vg->id.uuid, sizeof(vg->id.uuid));
+	value[sizeof(vg->id.uuid)] = '\0';
+
+	return value;
+}
+
 /*
  * Test the validity of a VG handle returned by vg_read() or vg_read_for_update().
  *
-- 
1.6.0.6


