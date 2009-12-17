From: Petr Rockai <prockai@redhat.com>
Date: Thu, 17 Dec 2009 12:03:31 +0100
Subject: [PATCH] Also clean up MISSING devices in --removemissing --force
Message-ID: <87iqc5g8vw.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a simple patch that makes --removemissing --force treat
MISSING_PV devices the same way as --removemissing (without --force)
does. This should fix the last bit of RHBZ 537954.

Yours,
   Petr.

===================================================================
RCS file: /cvs/lvm2/LVM2/tools/vgreduce.c,v
retrieving revision 1.98
diff -u -p -r1.98 vgreduce.c
--- tools/vgreduce.c	14 Sep 2009 22:47:50 -0000	1.98
+++ tools/vgreduce.c	17 Dec 2009 10:57:07 -0000
@@ -224,7 +224,7 @@ static int _make_vg_consistent(struct cm
 	 */
 	dm_list_iterate_safe(pvh, pvht, &vg->pvs) {
 		pvl = dm_list_item(pvh, struct pv_list);
-		if (pvl->pv->dev)
+		if (pvl->pv->dev && !(pvl->pv->status & MISSING_PV))
 			continue;
 		if (!_remove_pv(vg, pvl, 0))
 			return_0;


