From: Petr Rockai <prockai@redhat.com>
Date: Wed, 10 Sep 2008 13:49:09 +0200
Subject: [PATCH] (4/6) new vgreduce --removemissing semantics
In-Reply-To: <87y73k24i3.fsf@eriador.mornfall.net> (Petr Rockai's message of
	"Tue, 29 Jul 2008 15:40:04 +0200")
References: <87y73k24i3.fsf@eriador.mornfall.net>
Message-ID: <87r67s6x1m.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

there is one small addendum to make --removemissing --force actually work with
this patch. It circumvents the error return from _consolidate_vg when it is
used from _make_vg_consistent (which is in turn used when --force is in
effect).

Now looking at the patch again, I am not so convinced this is the correct
solution: it seems that if _make_vg_consistent worked as expected, removing any
LVs that reside on missing PVs should have been removed by the time we call
_consolidate_vg. I am still sending this patch for reference, but please bear
with me, I will come with a better one in a few minutes.

However, I am not sure why this makes the tests pass -- probably an omission in
our testsuite (or how it checks that the vgreduce worked correctly)?

Yours,
   Petr.

diff -rN -p -u old-hotspare-everything/tools/vgreduce.c new-hotspare-everything/tools/vgreduce.c
--- old-hotspare-everything/tools/vgreduce.c	2008-09-10 13:39:47.064286369 +0200
+++ new-hotspare-everything/tools/vgreduce.c	2008-09-10 13:39:47.104289777 +0200
@@ -131,12 +131,16 @@ static int _remove_lv(struct cmd_context
 	return 1;
 }
 
-static int _consolidate_vg(struct cmd_context *cmd, struct volume_group *vg)
+static int _consolidate_vg(struct cmd_context *cmd, struct volume_group *vg,
+			   int force)
 {
 	struct pv_list *pvl;
 	struct lv_list *lvl;
 	int err = 0;
 
+	if (force)
+		goto remove;
+
 	list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & PARTIAL_LV) {
 			log_warn("WARNING: Partial LV %s needs to be repaired "
@@ -153,6 +157,7 @@ static int _consolidate_vg(struct cmd_co
 		log_warn("Proceeding to remove empty missing PVs.");
 	}
 
+remove:
 	list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev && !(pvl->pv->status & MISSING_PV))
 			continue;
@@ -214,7 +219,7 @@ static int _make_vg_consistent(struct cm
 		return 0;
 	}
 
-	if (!_consolidate_vg(cmd, vg))
+	if (!_consolidate_vg(cmd, vg, 1))
 		return_0;
 
 	/* FIXME Recovery.  For now people must clean up by hand. */
@@ -549,7 +554,7 @@ int vgreduce(struct cmd_context *cmd, in
 				return ECMD_FAILED;
 			}
 		} else {
-			fixed = _consolidate_vg(cmd, vg);
+			fixed = _consolidate_vg(cmd, vg, 0);
 		}
 
 		if (!vg_write(vg) || !vg_commit(vg)) {



-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


