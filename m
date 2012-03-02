From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2012 21:24:38 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120302212438.17070.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-02 21:24:38

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	missing reply frees

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/lib/cache/lvmetad.c	2012/03/02 20:46:37	1.15
+++ LVM2/lib/cache/lvmetad.c	2012/03/02 21:24:37	1.16
@@ -208,7 +208,7 @@
 			log_error(INTERNAL_ERROR
 				  "We do not know the format (%s) reported by lvmetad.",
 				  fmt_name);
-			return NULL;
+			goto out;
 		}
 
 		fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
@@ -216,7 +216,7 @@
 		fic.context.vg_ref.vg_id = vgid;
 
 		if (!(fid = fmt->ops->create_instance(fmt, &fic)))
-			return_NULL;
+			goto_out;
 
 		if ((pvcn = dm_config_find_node(top, "metadata/physical_volumes")))
 			for (pvcn = pvcn->child; pvcn; pvcn = pvcn->sib)
@@ -224,21 +224,25 @@
 
 		top->key = name;
 		if (!(vg = import_vg_from_config_tree(reply.cft, fid)))
-			return_NULL;
+			goto_out;
 
 		dm_list_iterate_items(pvl, &vg->pvs) {
 			if ((info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0))) {
 				pvl->pv->label_sector = lvmcache_get_label(info)->sector;
 				pvl->pv->dev = lvmcache_device(info);
-				if (!lvmcache_fid_add_mdas_pv(info, fid))
-                                        return_NULL; /* FIXME error path */
+				if (!lvmcache_fid_add_mdas_pv(info, fid)) {
+					vg = NULL;
+					goto_out;	/* FIXME error path */
+				}
 			} /* else probably missing */
 		}
 
 		lvmcache_update_vg(vg, 0);
 	}
 
+out:
 	daemon_reply_destroy(reply);
+
 	return vg;
 }
 
@@ -285,8 +289,7 @@
 	}
 
 	reply = daemon_send_simple(_lvmetad, "vg_update", "vgname = %s", vg->name,
-				             "metadata = %b", strchr(buf, '{'),
-				   NULL);
+				   "metadata = %b", strchr(buf, '{'), NULL);
 	dm_free(buf);
 
 	if (!_lvmetad_handle_reply(reply, "update VG", vg->name, NULL)) {
@@ -294,6 +297,8 @@
 		return 0;
 	}
 
+	daemon_reply_destroy(reply);
+
 	n = (vg->fid && vg->fid->metadata_areas_index) ?
 		dm_hash_get_first(vg->fid->metadata_areas_index) : NULL;
 	while (n) {


