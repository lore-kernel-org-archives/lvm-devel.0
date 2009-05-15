From: Milan Broz <mbroz@redhat.com>
Date: Fri, 15 May 2009 16:34:23 +0200
Subject: [PATCH] vgcfgbackup: do not produce corrupted metadata if PVs are missing
Message-ID: <4A0D7D6F.4020103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use PV UUID in hash for device name when exporting metadata.

Currently code uses pv_dev_name() for hash when getting internal
"pvX" name.

This produce corrupted metadata if PVs are missing, pv->dev
is NULL and all these missing devices returns one name
(using "unknown device" for all missing devices as hash key).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format_text/export.c    |   29 +++++++++++++++++++++--------
 test/t-vgcfgbackup-usage.sh |   22 ++++++++++++++++++++--
 2 files changed, 41 insertions(+), 10 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index ce6676e..b6ead68 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -378,10 +378,19 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
  * Get the pv%d name from the formatters hash
  * table.
  */
+static const char *_get_pv_name_from_uuid(struct formatter *f, char *uuid)
+{
+	return dm_hash_lookup(f->pv_names, uuid);
+}
+
 static const char *_get_pv_name(struct formatter *f, struct physical_volume *pv)
 {
-	return (pv) ? (const char *)
-	    dm_hash_lookup(f->pv_names, pv_dev_name(pv)) : "Missing";
+	char uuid[40];
+
+	if (!pv || !id_write_format(&pv->id, uuid, sizeof(uuid)))
+		return_NULL;
+
+	return _get_pv_name_from_uuid(f, uuid);
 }
 
 static int _print_pvs(struct formatter *f, struct volume_group *vg)
@@ -398,16 +407,16 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 
-		if (!(name = _get_pv_name(f, pv)))
+		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
+			return_0;
+
+		if (!(name = _get_pv_name_from_uuid(f, buffer)))
 			return_0;
 
 		outnl(f);
 		outf(f, "%s {", name);
 		_inc_indent(f);
 
-		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
-			return_0;
-
 		outf(f, "id = \"%s\"", buffer);
 
 		if (!(buf = alloca(escaped_len(pv_dev_name(pv))))) {
@@ -621,7 +630,7 @@ static int _build_pv_names(struct formatter *f, struct volume_group *vg)
 	int count = 0;
 	struct pv_list *pvl;
 	struct physical_volume *pv;
-	char buffer[32], *name;
+	char buffer[32], *uuid, *name;
 
 	if (!(f->mem = dm_pool_create("text pv_names", 512)))
 		return_0;
@@ -639,7 +648,11 @@ static int _build_pv_names(struct formatter *f, struct volume_group *vg)
 		if (!(name = dm_pool_strdup(f->mem, buffer)))
 			return_0;
 
-		if (!dm_hash_insert(f->pv_names, pv_dev_name(pv), name))
+		if (!(uuid = dm_pool_zalloc(f->mem, 40)) ||
+		   !id_write_format(&pv->id, uuid, 40))
+			return_0;
+
+		if (!dm_hash_insert(f->pv_names, uuid, name))
 			return_0;
 	}
 
diff --git a/test/t-vgcfgbackup-usage.sh b/test/t-vgcfgbackup-usage.sh
index 0242d55..6d49121 100644
--- a/test/t-vgcfgbackup-usage.sh
+++ b/test/t-vgcfgbackup-usage.sh
@@ -11,14 +11,32 @@
 
 . ./test-utils.sh
 
-aux prepare_pvs 2
+aux prepare_pvs 4
 
 # vgcfgbackup handles similar VG names (bz458941)
 vg1=${PREFIX}vg00
-vg1=${PREFIX}vg01
+vg2=${PREFIX}vg01
 vgcreate $vg1 $dev1
 vgcreate $vg2 $dev2
 vgcfgbackup -f /tmp/bak-%s >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out
+vgremove -ff $vg1
+vgremove -ff $vg2
 
+# vgcfgbackup correctly stores metadata with missing PVs
+# and vgcfgrestore able to restore them when device reappears
+pv1_uuid=$(pvs --noheadings -o pv_uuid $dev1)
+pv2_uuid=$(pvs --noheadings -o pv_uuid $dev2)
+vgcreate $vg $devs
+lvcreate -l1 -n $lv1 $vg $dev1
+lvcreate -l1 -n $lv2 $vg $dev2
+lvcreate -l1 -n $lv3 $vg $dev3
+vgchange -a n $vg
+pvcreate -ff -y $dev1
+pvcreate -ff -y $dev2
+vgcfgbackup -f "$(pwd)/backup.$$" $vg
+sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
+pvcreate -ff -y -u $pv1_uuid $dev1
+pvcreate -ff -y -u $pv2_uuid $dev2
+vgcfgrestore -f "$(pwd)/backup.$$1" $vg



