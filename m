From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:41 +0000 (UTC)
Subject: master - metadata: format_text: import historical LVs
Message-ID: <20160303131941.8E47060960@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0842d1f259c467cb02a8dd94e3a53f543ade7fb
Commit:        a0842d1f259c467cb02a8dd94e3a53f543ade7fb
Parent:        54d3d976c71d45748fef267b5c35a49467e781c5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:54:02 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:46:39 2016 +0100

metadata: format_text: import historical LVs

Import historical LV list from metadata and add it to struct
volume_group's historical_lvs list.
---
 lib/format_text/import_vsn1.c |   78 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 71181bd..3bc38b9 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -699,6 +699,77 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	return 1;
 }
 
+static int _read_historical_lvnames(struct format_instance *fid __attribute__((unused)),
+				     struct volume_group *vg, const struct dm_config_node *hlvn,
+				     const struct dm_config_node *vgn __attribute__((unused)),
+				     struct dm_hash_table *pv_hash __attribute__((unused)),
+				     struct dm_hash_table *lv_hash __attribute__((unused)),
+				     unsigned *scan_done_once __attribute__((unused)),
+				     unsigned report_missing_devices __attribute__((unused)))
+{
+	struct dm_pool *mem = vg->vgmem;
+	struct generic_logical_volume *glv;
+	struct glv_list *glvl;
+	const char *str;
+	uint64_t timestamp;
+
+	if (!(glv = dm_pool_zalloc(mem, sizeof(struct generic_logical_volume))) ||
+	    !(glv->historical = dm_pool_zalloc(mem, sizeof(struct historical_logical_volume))) ||
+	    !(glvl = dm_pool_zalloc(mem, sizeof(struct glv_list)))) {
+		log_error("Removed logical volume structure allocation failed");
+		goto bad;
+	}
+
+	glv->is_historical = 1;
+	glv->historical->vg = vg;
+	dm_list_init(&glv->historical->indirect_glvs);
+
+	if (!(glv->historical->name = dm_pool_strdup(mem, hlvn->key)))
+		goto_bad;
+
+	if (!(hlvn = hlvn->child)) {
+		log_error("Empty removed logical volume section.");
+		goto_bad;
+	}
+
+	if (!_read_id(&glv->historical->lvid.id[1], hlvn, "id")) {
+		log_error("Couldn't read uuid for removed logical volume %s in vg %s.",
+			  glv->historical->name, vg->name);
+		return 0;
+	}
+	memcpy(&glv->historical->lvid.id[0], &glv->historical->vg->id, sizeof(glv->historical->lvid.id[0]));
+
+	if (dm_config_get_str(hlvn, "name", &str)) {
+		if (!(glv->historical->name = dm_pool_strdup(mem, str)))
+			goto_bad;
+	}
+
+	if (dm_config_has_node(hlvn, "creation_time")) {
+		if (!_read_uint64(hlvn, "creation_time", &timestamp)) {
+			log_error("Invalid creation_time for removed logical volume %s.", str);
+			goto bad;
+		}
+		glv->historical->timestamp = timestamp;
+	}
+
+	if (dm_config_has_node(hlvn, "removal_time")) {
+		if (!_read_uint64(hlvn, "removal_time", &timestamp)) {
+			log_error("Invalid removal_time for removed logical volume %s.", str);
+			goto bad;
+		}
+		glv->historical->timestamp_removed = timestamp;
+	}
+
+	glvl->glv = glv;
+	dm_list_add(&vg->historical_lvs, &glvl->list);
+
+	return 1;
+bad:
+	if (glv)
+		dm_pool_free(mem, glv);
+	return 0;
+}
+
 static int _read_lvsegs(struct format_instance *fid,
 			struct volume_group *vg, const struct dm_config_node *lvn,
 			const struct dm_config_node *vgn __attribute__((unused)),
@@ -982,6 +1053,13 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
+	if (!_read_sections(fid, "historical_logical_volumes", _read_historical_lvnames, vg,
+			    vgn, pv_hash, lv_hash, 1, NULL)) {
+		log_error("Couldn't read all historical logical volumes for volume "
+			  "group %s.", vg->name);
+		goto bad;
+	}
+
 	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, vg,
 			    vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volumes for "


