From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:18:04 +0000 (UTC)
Subject: master - cleanup: add struct pvcreate_restorable_params and move relevant items from pvcreate_params
Message-ID: <20130226141804.9C2B5A0C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6692b177777501532ba0d422dcb2a22016405519
Commit:        6692b177777501532ba0d422dcb2a22016405519
Parent:        71f49345004d385acc71a8e534c4313069cc59b6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 18 10:51:32 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 11:24:38 2013 +0100

cleanup: add struct pvcreate_restorable_params and move relevant items from pvcreate_params

Extract restorable PV creation parameters from struct pvcreate_params into
a separate struct pvcreate_restorable_params for clarity and also for better
maintainability when adding any new items later.
---
 lib/metadata/metadata-exported.h |   16 ++++++++++------
 lib/metadata/metadata.c          |   22 +++++++++++-----------
 tools/pvcreate.c                 |   20 ++++++++++----------
 tools/toollib.c                  |   10 +++++-----
 4 files changed, 36 insertions(+), 32 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b37d64c..1f77ce9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -391,6 +391,15 @@ struct lv_list {
 	struct logical_volume *lv;
 };
 
+struct pvcreate_restorable_params {
+	const char *restorefile; /* 0 if no --restorefile option */
+	struct id id; /* FIXME: redundant */
+	struct id *idp; /* 0 if no --uuid option */
+	uint64_t pe_start;
+	uint32_t extent_count;
+	uint32_t extent_size;
+};
+
 struct pvcreate_params {
 	int zero;
 	uint64_t size;
@@ -399,15 +408,10 @@ struct pvcreate_params {
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
-	struct id id; /* FIXME: redundant */
-	struct id *idp; /* 0 if no --uuid option */
-	uint64_t pe_start;
-	uint32_t extent_count;
-	uint32_t extent_size;
-	const char *restorefile; /* 0 if no --restorefile option */
 	force_t force;
 	unsigned yes;
 	unsigned metadataignore;
+	struct pvcreate_restorable_params rp;
 };
 
 struct physical_volume *pvcreate_single(struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d03b49c..025329f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1425,14 +1425,14 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 	pp->pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
 	pp->pvmetadatasize = DEFAULT_PVMETADATASIZE;
 	pp->labelsector = DEFAULT_LABELSECTOR;
-	pp->idp = 0;
-	pp->pe_start = 0;
-	pp->extent_count = 0;
-	pp->extent_size = 0;
-	pp->restorefile = 0;
 	pp->force = PROMPT;
 	pp->yes = 0;
 	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
+	pp->rp.restorefile = 0;
+	pp->rp.idp = 0;
+	pp->rp.pe_start = 0;
+	pp->rp.extent_count = 0;
+	pp->rp.extent_size = 0;
 }
 
 
@@ -1504,10 +1504,10 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 	if (!pp)
 		pp = &default_pp;
 
-	if (pp->idp) {
-		if ((dev = lvmcache_device_from_pvid(cmd, pp->idp, NULL, NULL)) &&
+	if (pp->rp.idp) {
+		if ((dev = lvmcache_device_from_pvid(cmd, pp->rp.idp, NULL, NULL)) &&
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
-			if (!id_write_format((const struct id*)&pp->idp->uuid,
+			if (!id_write_format((const struct id*)&pp->rp.idp->uuid,
 			    buffer, sizeof(buffer)))
 				goto_bad;
 			log_error("uuid %s already in use on \"%s\"", buffer,
@@ -1530,10 +1530,10 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 
 	dm_list_init(&mdas);
 
-	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
+	if (!(pv = pv_create(cmd, dev, pp->rp.idp, pp->size,
 			     pp->data_alignment, pp->data_alignment_offset,
-			     pp->pe_start ? pp->pe_start : PV_PE_START_CALC,
-			     pp->extent_count, pp->extent_size,
+			     pp->rp.pe_start ? pp->rp.pe_start : PV_PE_START_CALC,
+			     pp->rp.extent_count, pp->rp.extent_size,
 			     pp->labelsector, pp->pvmetadatacopies,
 			     pp->pvmetadatasize, pp->metadataignore))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index c75f561..d7e7e52 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -53,29 +53,29 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 
  	if (arg_count(cmd, uuidstr_ARG)) {
 		uuid = arg_str_value(cmd, uuidstr_ARG, "");
-		if (!id_read_format(&pp->id, uuid))
+		if (!id_read_format(&pp->rp.id, uuid))
 			return 0;
-		pp->idp = &pp->id;
+		pp->rp.idp = &pp->rp.id;
 		lvmcache_seed_infos_from_lvmetad(cmd); /* need to check for UUID dups */
 	}
 
 	if (arg_count(cmd, restorefile_ARG)) {
-		pp->restorefile = arg_str_value(cmd, restorefile_ARG, "");
+		pp->rp.restorefile = arg_str_value(cmd, restorefile_ARG, "");
 		/* The uuid won't already exist */
-		if (!(vg = backup_read_vg(cmd, NULL, pp->restorefile))) {
+		if (!(vg = backup_read_vg(cmd, NULL, pp->rp.restorefile))) {
 			log_error("Unable to read volume group from %s",
-				  pp->restorefile);
+				  pp->rp.restorefile);
 			return 0;
 		}
-		if (!(existing_pvl = find_pv_in_vg_by_uuid(vg, pp->idp))) {
+		if (!(existing_pvl = find_pv_in_vg_by_uuid(vg, pp->rp.idp))) {
 			release_vg(vg);
 			log_error("Can't find uuid %s in backup file %s",
-				  uuid, pp->restorefile);
+				  uuid, pp->rp.restorefile);
 			return 0;
 		}
-		pp->pe_start = pv_pe_start(existing_pvl->pv);
-		pp->extent_size = pv_pe_size(existing_pvl->pv);
-		pp->extent_count = pv_pe_count(existing_pvl->pv);
+		pp->rp.pe_start = pv_pe_start(existing_pvl->pv);
+		pp->rp.extent_size = pv_pe_size(existing_pvl->pv);
+		pp->rp.extent_count = pv_pe_count(existing_pvl->pv);
 		release_vg(vg);
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 1abe837..c3c4dbe 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1451,11 +1451,11 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (pp->data_alignment && pp->pe_start) {
-		if (pp->pe_start % pp->data_alignment)
+	if (pp->data_alignment && pp->rp.pe_start) {
+		if (pp->rp.pe_start % pp->data_alignment)
 			log_warn("WARNING: Ignoring data alignment %" PRIu64
 				 " incompatible with --restorefile value (%"
-				 PRIu64").", pp->data_alignment, pp->pe_start);
+				 PRIu64").", pp->data_alignment, pp->rp.pe_start);
 		pp->data_alignment = 0;
 	}
 
@@ -1470,10 +1470,10 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (pp->data_alignment_offset && pp->pe_start) {
+	if (pp->data_alignment_offset && pp->rp.pe_start) {
 		log_warn("WARNING: Ignoring data alignment offset %" PRIu64
 			 " incompatible with --restorefile value (%"
-			 PRIu64").", pp->data_alignment_offset, pp->pe_start);
+			 PRIu64").", pp->data_alignment_offset, pp->rp.pe_start);
 		pp->data_alignment_offset = 0;
 	}
 


