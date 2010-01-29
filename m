From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 29 Jan 2010 16:37:57 -0500
Subject: [PATCH 07/12] Add vg field to struct physical_volume and find_vg_by_pv().
In-Reply-To: <1264801082-28132-7-git-send-email-dwysocha@redhat.com>
References: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-2-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-3-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-4-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-5-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-6-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1264801082-28132-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Until now, the physical_volume struct contained only the vgname and
vgid.  However, this provides some difficulty when designing a proper
API around pv handles and their properties.  In particular, this
patch is required if we want to enable/disable mdas for a particular
PV with a nice PV-based interface.

For tools and operations such as pvchange, a clean API might look
something like this:

pv = pv_open(pvname, mode);
value = pv_get_property(pv, propertyname);
pv_set_property(pv, propertyname, newvalue);

The problem is today we have no way of really "opening" a PV for
reading or writing, other than starting with a VG.  This seems
unduly restrictive to an application, since at times they may
be starting with a device (pv) name and they may not know the
vgname, nor do they really care if they are changing a device/pv
property.

The possible pv_open() API above would implicitly call vg_read(),
which would obtain the proper vg lock, and then return the pv handle.
But then we'd have the problem of what happens to the vg handle
obtained in the vg_read() call - do we leak it or store it somewhere?
Thus, we introduce this small but important addition to struct
physical_volume.  Future patches will make use of this API to rework
related areas of the code as well as enhance liblvm.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/import_vsn1.c    |    1 +
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |    5 +++++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index fd045cc..75a61e5 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -268,6 +268,7 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 
 	vg->pv_count++;
 	dm_list_add(&vg->pvs, &pvl->list);
+	pv->vg = vg;
 
 	return 1;
 }
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8342dc0..f570dd9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -182,6 +182,7 @@ struct physical_volume {
 	const struct format_type *fmt;
 	const char *vg_name;
 	struct id vgid;
+	struct volume_group *vg;
 
 	uint64_t status;
 	uint64_t size;
@@ -592,6 +593,7 @@ struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			      const char *pv_name);
 struct physical_volume *find_pv_in_vg_by_uuid(const struct volume_group *vg,
 			    const struct id *id);
+struct volume_group *find_vg_by_pv(const struct physical_volume *pv);
 
 /* Find an LV within a given VG */
 struct lv_list *find_lv_in_vg(const struct volume_group *vg,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a6f0a96..b0d0bf3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1573,6 +1573,11 @@ static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
 	return NULL;
 }
 
+struct volume_group *find_vg_by_pv(const struct physical_volume *pv)
+{
+	return pv->vg;
+}
+
 struct pv_list *find_pv_in_pv_list(const struct dm_list *pl,
 				   const struct physical_volume *pv)
 {
-- 
1.6.0.6


