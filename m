From: David Robinson <zxvdr.au@gmail.com>
Date: Thu, 24 May 2007 18:58:30 +1000
Subject: pvdisplay --maps
Message-ID: <465553B6.8080803@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch below adds the -m/--maps option to pvdisplay. Addresses BZ 149814.

         -m, --maps
               Display the mapping of physical extents to logical 
volumes and logical extents.

Cheers,
Dave

diff -urp LVM2.orig/lib/display/display.c LVM2/lib/display/display.c
--- LVM2.orig/lib/display/display.c	2006-12-01 09:11:40.000000000 +1000
+++ LVM2/lib/display/display.c	2007-05-24 18:45:13.000000000 +1000
@@ -258,6 +258,32 @@ void pvdisplay_colons(struct physical_vo
  	return;
  }

+void pvdisplay_segments(struct physical_volume *pv)
+{
+        struct pv_segment *seg;
+
+        log_print("--- Segments ---");
+
+	list_iterate_items(seg, &pv->segments) {
+ 		if (seg->len == pv->pe_count) continue;
+			log_print("Physical extent %u to %u:",
+			          seg->pe, seg->pe + seg->len - 1);
+
+		if (seg->lvseg) {
+			log_print("  LV Name\t\t%s%s/%s",
+			          seg->lvseg->lv->vg->cmd->dev_dir,
+			          seg->lvseg->lv->vg->name,
+			          seg->lvseg->lv->name);
+			log_print("  Logical extents\t%d to %d",
+			          seg->lvseg->le, seg->lvseg->le +
+			          seg->lvseg->len - 1);
+		}
+        }
+
+        log_print(" ");
+	return;
+}
+
  /* FIXME Include label fields */
  void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
  		    void *handle __attribute((unused)))
diff -urp LVM2.orig/lib/display/display.h LVM2/lib/display/display.h
--- LVM2.orig/lib/display/display.h	2006-05-10 07:23:50.000000000 +1000
+++ LVM2/lib/display/display.h	2007-05-24 18:45:13.000000000 +1000
@@ -31,6 +31,7 @@ char *display_uuid(char *uuidstr);
  void display_stripe(const struct lv_segment *seg, uint32_t s, const 
char *pre);

  void pvdisplay_colons(struct physical_volume *pv);
+void pvdisplay_segments(struct physical_volume *pv);
  void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
  		    void *handle);
  int pvdisplay_short(struct cmd_context *cmd, struct volume_group *vg,
diff -urp LVM2.orig/tools/pvdisplay.c LVM2/tools/pvdisplay.c
--- LVM2.orig/tools/pvdisplay.c	2006-10-17 02:29:40.000000000 +1000
+++ LVM2/tools/pvdisplay.c	2007-05-24 18:45:13.000000000 +1000
@@ -71,8 +71,8 @@ static int _pvdisplay_single(struct cmd_

  	pvdisplay_full(cmd, pv, handle);

-	if (!arg_count(cmd, maps_ARG))
-		goto out;
+	if (arg_count(cmd, maps_ARG))
+		pvdisplay_segments(pv);

  out:
          if (pv->vg_name)


