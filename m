From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:48 +0000 (UTC)
Subject: master - metadata: format_text: interconnect historical LVs among each other and also with live LVs
Message-ID: <20160303131948.A257160091@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=673bc0636cf1a73321656b2129a6db1681fbd8f4
Commit:        673bc0636cf1a73321656b2129a6db1681fbd8f4
Parent:        a61bc70f62a1648632985fa7ac81b89773da6d78
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:22:28 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:13 2016 +0100

metadata: format_text: interconnect historical LVs among each other and also with live LVs

Interconnect historical LVs in an ancestry chain and also connect the first/last
one with its live ancestor/descendant if it exists.
---
 lib/format_text/import_vsn1.c |  119 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 119 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 3bc38b9..163ea38 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -770,6 +770,118 @@ bad:
 	return 0;
 }
 
+static int _read_historical_lvnames_interconnections(struct format_instance *fid __attribute__((unused)),
+						 struct volume_group *vg, const struct dm_config_node *hlvn,
+						 const struct dm_config_node *vgn __attribute__((unused)),
+						 struct dm_hash_table *pv_hash __attribute__((unused)),
+						 struct dm_hash_table *lv_hash __attribute__((unused)),
+						 unsigned *scan_done_once __attribute__((unused)),
+						 unsigned report_missing_devices __attribute__((unused)))
+{
+	struct dm_pool *mem = vg->vgmem;
+	const char *historical_lv_name, *origin_name = NULL;
+	struct generic_logical_volume *glv, *origin_glv, *descendant_glv;
+	struct logical_volume *tmp_lv;
+	struct glv_list *glvl = NULL;
+	const struct dm_config_value *descendants = NULL;
+
+	historical_lv_name = hlvn->key;
+	hlvn = hlvn->child;
+
+	if (!(glv = find_historical_glv(vg, historical_lv_name, NULL))) {
+		log_error("Unknown historical logical volume %s/%s%s",
+			  vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
+		goto bad;
+	}
+
+	if (dm_config_has_node(hlvn, "origin")) {
+		if (!dm_config_get_str(hlvn, "origin", &origin_name)) {
+			log_error("Couldn't read origin for historical logical "
+				  "volume %s/%s%s", vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
+			goto bad;
+		}
+	}
+
+	if (dm_config_has_node(hlvn, "descendants")) {
+		if (!dm_config_get_list(hlvn, "descendants", &descendants)) {
+			log_error("Couldn't get descendants list for historical logical "
+				  "volume %s/%s%s", vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
+			goto bad;
+		}
+		if (descendants->type == DM_CFG_EMPTY_ARRAY) {
+			log_error("Found empty descendants list for historical logical "
+				  "volume %s/%s%s", vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
+			goto bad;
+		}
+	}
+
+	if (!origin_name && !descendants)
+		/* no interconnections */
+		return 1;
+
+	if (origin_name) {
+		if (!(glvl = dm_pool_zalloc(mem, sizeof(struct glv_list)))) {
+			log_error("Failed to allocate list item for historical logical "
+				  "volume %s/%s%s", vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
+			goto bad;
+		}
+		glvl->glv = glv;
+
+		if (!strncmp(origin_name, HISTORICAL_LV_PREFIX, strlen(HISTORICAL_LV_PREFIX))) {
+			if (!(origin_glv = find_historical_glv(vg, origin_name + strlen(HISTORICAL_LV_PREFIX), NULL))) {
+				log_error("Unknown origin %s for historical logical volume %s/%s%s",
+					  origin_name, vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
+				goto bad;
+			}
+		} else {
+			if (!(tmp_lv = find_lv(vg, origin_name))) {
+				log_error("Unknown origin %s for historical logical volume %s/%s%s",
+					  origin_name, vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
+				goto bad;
+			}
+
+			if (!(origin_glv = get_or_create_glv(mem, tmp_lv, NULL)))
+				goto bad;
+		}
+
+		glv->historical->indirect_origin = origin_glv;
+		if (origin_glv->is_historical)
+			dm_list_add(&origin_glv->historical->indirect_glvs, &glvl->list);
+		else
+			dm_list_add(&origin_glv->live->indirect_glvs, &glvl->list);
+	}
+
+	if (descendants) {
+		do {
+			if (descendants->type != DM_CFG_STRING) {
+				log_error("Descendant value for historical logical volume %s/%s%s "
+					  "is not a string.", vg->name, HISTORICAL_LV_PREFIX, historical_lv_name);
+				goto bad;
+			}
+
+			if (!(tmp_lv = find_lv(vg, descendants->v.str))) {
+				log_error("Failed to find descendant %s for historical LV %s.",
+					  descendants->v.str, historical_lv_name);
+				goto bad;
+			}
+
+			if (!(descendant_glv = get_or_create_glv(mem, tmp_lv, NULL)))
+				goto bad;
+
+			if (!add_glv_to_indirect_glvs(mem, glv, descendant_glv))
+				goto bad;
+
+			descendants = descendants->next;
+		} while (descendants);
+	}
+
+	return 1;
+bad:
+	if (glvl)
+		dm_pool_free(mem, glvl);
+	return 0;
+}
+
 static int _read_lvsegs(struct format_instance *fid,
 			struct volume_group *vg, const struct dm_config_node *lvn,
 			const struct dm_config_node *vgn __attribute__((unused)),
@@ -1067,6 +1179,13 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
+	if (!_read_sections(fid, "historical_logical_volumes", _read_historical_lvnames_interconnections,
+			    vg, vgn, pv_hash, lv_hash, 1, NULL)) {
+		log_error("Couldn't read all removed logical volume interconnections "
+			  "for volume group %s.", vg->name);
+		goto bad;
+	}
+
 	if (!fixup_imported_mirrors(vg)) {
 		log_error("Failed to fixup mirror pointers after import for "
 			  "volume group %s.", vg->name);


