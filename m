From: David Teigland <teigland@sourceware.org>
Date: Wed,  6 Apr 2022 17:27:20 +0000 (GMT)
Subject: main - vgimportdevices: fix incorrect deviceidtype usage
Message-ID: <20220406172720.C1B5C3858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=151ce8b27672134438d0bc457f49123db96a176c
Commit:        151ce8b27672134438d0bc457f49123db96a176c
Parent:        f840dbb3205754db1a339aba8e0f68fa40138ba1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 6 12:20:26 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 6 12:20:26 2022 -0500

vgimportdevices: fix incorrect deviceidtype usage

When a VG has PVs with different device id types,
it would try to use the idtype of the previous PV
in the loop.  This would produce an unncessary warning,
or could lead to using the devname idtype when a better
idtype is available.
---
 tools/vgimportdevices.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index 2580613c4..ea205d941 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -57,8 +57,7 @@ static int _vgimportdevices_single(struct cmd_context *cmd,
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 
-		if (!idtypestr && pv->device_id_type)
-			idtypestr = pv->device_id_type;
+		idtypestr = pv->device_id_type;
 
 		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
 		device_id_add(cmd, pv->dev, pvid, idtypestr, NULL);

