From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Mar 2013 14:30:58 +0000 (UTC)
Subject: master - cleanup: remove unused 'pv_by_path' fn
Message-ID: <20130319143058.A0D561472@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea36d0501e0ede347f251f6cda20903ad13f3700
Commit:        ea36d0501e0ede347f251f6cda20903ad13f3700
Parent:        7e5e2dd4ee684137485a86c00e8ff29e7f169e14
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 19 14:17:53 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 19 14:57:36 2013 +0100

cleanup: remove unused 'pv_by_path' fn

The pv_by_path might be also dangerous to use as it does not
count with any other metadata areas but the ones found on the PV
itself. If metadata was not found on the PV referenced by the path,
it returned no PV though it might have been referenced by metadata
elsewhere (on other PVs...).
---
 lib/metadata/metadata-exported.h |    3 +--
 lib/metadata/metadata.c          |   16 ----------------
 lib/metadata/metadata.h          |    1 -
 3 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f218f47..df21759 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -522,8 +522,7 @@ int remove_lvs_in_vg(struct cmd_context *cmd,
 
 /*
  * free_pv_fid() must be called on every struct physical_volume allocated
- * by pv_create, pv_read, find_pv_by_name or pv_by_path to free it when
- * no longer required.
+ * by pv_create, pv_read, find_pv_by_name or to free it when no longer required.
  */
 void free_pv_fid(struct physical_volume *pv);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 775e40d..a913597 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4524,19 +4524,3 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
 	}
 	return dm_pool_end_object(mem);
 }
-
-/**
- * pv_by_path - Given a device path return a PV handle if it is a PV
- * @cmd - handle to the LVM command instance
- * @pv_name - device path to read for the PV
- *
- * Returns:
- *  NULL - device path does not contain a valid PV
- *  non-NULL - PV handle corresponding to device path
- *
- * FIXME: merge with find_pv_by_name ?
- */
-struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name)
-{
-	return _pv_read(cmd, cmd->mem, pv_name, NULL, 1, 0);
-}
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f7b3409..0c13a97 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -483,7 +483,6 @@ struct id pv_id(const struct physical_volume *pv);
 const struct format_type *pv_format_type(const struct physical_volume *pv);
 struct id pv_vgid(const struct physical_volume *pv);
 
-struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv, struct pvcreate_params *pp);
 


