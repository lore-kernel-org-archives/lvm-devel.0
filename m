From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 13:11:17 -0000
Subject: LVM2 daemons/dmeventd/plugins/lvm2/Makefile.in ...
Message-ID: <20120223131117.27092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 13:11:11

Modified files:
	daemons/dmeventd/plugins/lvm2: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	daemons/lvmetad: lvmetad-client.h 
	lib            : Makefile.in 
	lib/activate   : activate.c 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/commands   : toolcontext.c 
	lib/device     : dev-cache.c dev-cache.h dev-io.c 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: export.c format-text.c import_vsn1.c 
	                 text_label.c 
	lib/label      : label.c label.h 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	tools          : Makefile.in args.h commands.h pvcreate.c 
	                 pvremove.c pvscan.c toollib.c tools.h 
	                 vgcfgrestore.c vgcreate.c vgrename.c vgscan.c 
	doc            : example.conf.in 
	scripts        : vgimportclone.sh 
	test/lib       : aux.sh 
	test/shell     : inconsistent-metadata.sh lvconvert-mirror.sh 
	                 lvcreate-repair.sh lvmcache-exercise.sh 
	                 pool-labels.sh vgimportclone.sh 
	test/unit      : Makefile.in 
Added files:
	lib/cache      : lvmetad.c lvmetad.h 

Log message:
	The lvmetad client-side integration. Only active when use_lvmetad = 1 is set in
	lvm.conf *and* lvmetad is running.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.241&r2=1.242
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.193&r2=1.194
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.231&r2=1.232
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.485&r2=1.486
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.266&r2=1.267
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.241&r2=1.242
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/vgimportclone.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-repair.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvmcache-exercise.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pool-labels.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgimportclone.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2011/09/24 21:00:52	1.7
+++ LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2012/02/23 13:11:07	1.8
@@ -24,7 +24,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ -ldevmapper $(PTHREAD_LIBS)
+LIBS += @LVM2CMD_LIB@ -ldevmapper $(PTHREAD_LIBS) -L$(top_builddir)/daemons/common -ldaemon
 
 install_lvm2: install_lib_shared
 
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2011/09/24 21:00:52	1.23
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2012/02/23 13:11:07	1.24
@@ -30,7 +30,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 -ldevmapper
+LIBS += -ldevmapper-event-lvm2 -ldevmapper -L$(top_builddir)/daemons/common -ldaemon
 
 install_lvm2: install_dm_plugin
 
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2011/09/24 21:00:53	1.18
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2012/02/23 13:11:08	1.19
@@ -26,7 +26,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 -ldevmapper
+LIBS += -ldevmapper-event-lvm2 -ldevmapper -L$(top_builddir)/daemons/common -ldaemon
 
 install_lvm2: install_dm_plugin
 
--- LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/23 11:40:24	1.6
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/23 13:11:08	1.7
@@ -64,11 +64,10 @@
 
 static inline daemon_handle lvmetad_open(const char *socket)
 {
-	/* TODO configurable */
 	daemon_info lvmetad_info = {
 		.path = "lvmetad",
 		.socket = socket ?: DEFAULT_RUN_DIR "/lvmetad.socket",
-		.autostart = 1
+		.autostart = 0
 	};
 
 	return daemon_open(lvmetad_info);
--- LVM2/lib/Makefile.in	2011/11/11 15:11:10	1.114
+++ LVM2/lib/Makefile.in	2012/02/23 13:11:08	1.115
@@ -16,6 +16,8 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
+INCLUDES += -I$(top_srcdir)/daemons/common -I$(top_srcdir)/daemons/lvmetad
+
 ifeq ("@LVM1@", "shared")
   SUBDIRS = format1
 endif
@@ -46,6 +48,7 @@
 
 SOURCES =\
 	activate/activate.c \
+	cache/lvmetad.c \
 	cache/lvmcache.c \
 	commands/toolcontext.c \
 	config/config.c \
--- LVM2/lib/activate/activate.c	2012/01/25 22:16:04	1.241
+++ LVM2/lib/activate/activate.c	2012/02/23 13:11:08	1.242
@@ -1883,7 +1883,7 @@
 int pv_uses_vg(struct physical_volume *pv,
 	       struct volume_group *vg)
 {
-	if (!activation())
+	if (!activation() || !pv->dev)
 		return 0;
 
 	if (!dm_is_dm_major(MAJOR(pv->dev->dev)))
/cvs/lvm2/LVM2/lib/cache/lvmetad.c,v  -->  standard output
revision 1.1
--- LVM2/lib/cache/lvmetad.c
+++ -	2012-02-23 13:11:12.722985000 +0000
@@ -0,0 +1,633 @@
+#include "lib.h"
+#include "toolcontext.h"
+#include "metadata.h"
+#include "device.h"
+#include "lvmetad.h"
+#include "lvmcache.h"
+#include "lvmetad-client.h"
+#include "format-text.h" // TODO for disk_locn, used as a DA representation
+#include "filter.h"
+
+static int _using_lvmetad = 0;
+static daemon_handle _lvmetad;
+
+void lvmetad_init(void)
+{
+	const char *socket = getenv("LVM_LVMETAD_SOCKET");
+	if (_using_lvmetad) { /* configured by the toolcontext */
+		_lvmetad = lvmetad_open(socket ?: DEFAULT_RUN_DIR "/lvmetad.socket");
+		if (_lvmetad.socket_fd < 0) {
+			log_warn("Failed to connect to lvmetad. Falling back to scanning.");
+			_using_lvmetad = 0;
+		}
+	}
+}
+
+/*
+ * Helper; evaluate the reply from lvmetad, check for errors, print diagnostics
+ * and return a summary success/failure exit code. Frees up the reply resources
+ * as well.
+ */
+static int _lvmetad_handle_reply(daemon_reply reply, const char *action, const char *object) {
+	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		log_error("Request to %s %s in lvmetad has failed. Reason: %s",
+			  action, object, reply.error ? strerror(reply.error) :
+			  daemon_reply_str(reply, "reason", "Unknown."));
+		daemon_reply_destroy(reply);
+		return 0;
+	}
+
+	daemon_reply_destroy(reply);
+	return 1;
+}
+
+static int _read_mda(struct lvmcache_info *info,
+		     struct format_type *fmt,
+		     const struct dm_config_node *cn)
+{
+	struct metadata_area_ops *ops;
+	struct metadata_area *mda = NULL;
+	dm_list_iterate_items(ops, &fmt->mda_ops) {
+		if (ops->mda_import_text && ops->mda_import_text(info, cn))
+			return 1;
+	}
+	return 0;
+}
+
+static struct lvmcache_info *_pv_populate_lvmcache(
+	struct cmd_context *cmd, struct dm_config_node *cn, dev_t fallback)
+{
+	const char *pvid_txt = dm_config_find_str(cn->child, "id", NULL),
+		   *vgid_txt = dm_config_find_str(cn->child, "vgid", NULL),
+		   *vgname = dm_config_find_str(cn->child, "vgname", NULL),
+		   *fmt_name = dm_config_find_str(cn->child, "format", NULL);
+	dev_t devt = dm_config_find_int(cn->child, "device", 0);
+	uint64_t devsize = dm_config_find_int(cn->child, "dev_size", 0),
+		 label_sector = dm_config_find_int(cn->child, "label_sector", 0);
+
+	struct format_type *fmt = fmt_name ? get_format_by_name(cmd, fmt_name) : NULL;
+
+	if (!fmt) {
+		log_warn("No format for PV %s. It is probably missing.", pvid_txt);
+		return_NULL;
+	}
+
+	struct device *device = dev_cache_get_by_devt(devt, cmd->filter);
+	struct id pvid, vgid;
+
+	if (!device && fallback)
+		device = dev_cache_get_by_devt(fallback, cmd->filter);
+
+	if (!device) {
+		log_warn("No device for PV %s.", pvid_txt);
+		return_NULL;
+	}
+
+	if (!pvid_txt || !id_read_format(&pvid, pvid_txt)) {
+		log_warn("Missing or ill-formatted PVID for PV: %s.", pvid_txt);
+		return_NULL;
+	}
+
+	if (vgid_txt)
+		id_read_format(&vgid, vgid_txt);
+	else
+		strcpy((char*)&vgid, fmt->orphan_vg_name);
+
+	if (!vgname)
+		vgname = fmt->orphan_vg_name;
+
+	struct lvmcache_info *info =
+		lvmcache_add(fmt->labeller, (const char *)&pvid, device,
+			     vgname, (const char *)&vgid, 0);
+
+	lvmcache_get_label(info)->sector = label_sector;
+	lvmcache_set_device_size(info, devsize);
+	lvmcache_del_das(info);
+	lvmcache_del_mdas(info);
+
+	int i = 0;
+	struct dm_config_node *mda = NULL;
+	do {
+		char mda_id[32];
+		sprintf(mda_id, "mda%d", i);
+		mda = dm_config_find_node(cn->child, mda_id);
+		if (mda)
+			_read_mda(info, fmt, mda);
+		++i;
+	} while (mda);
+
+	i = 0;
+	struct dm_config_node *da = NULL;
+	do {
+		char da_id[32];
+		sprintf(da_id, "da%d", i);
+		da = dm_config_find_node(cn->child, da_id);
+		if (da) {
+			uint64_t offset, size;
+			if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;
+			if (!dm_config_get_uint64(da->child, "size", &size)) return_0;
+			lvmcache_add_da(info, offset, size);
+		}
+		++i;
+	} while (da);
+
+	return info;
+}
+
+struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgname, const char *vgid)
+{
+	if (!_using_lvmetad)
+		return NULL;
+
+	struct volume_group *vg = NULL;
+	daemon_reply reply;
+	if (vgid) {
+		char uuid[64];
+		id_write_format((struct id*)vgid, uuid, 64);
+		reply = daemon_send_simple(_lvmetad, "vg_lookup", "uuid = %s", uuid, NULL);
+	} else {
+		if (!vgname)
+			log_error(INTERNAL_ERROR "VG name required (VGID not available)");
+		reply = daemon_send_simple(_lvmetad, "vg_lookup", "name = %s", vgname, NULL);
+	}
+
+	if (!strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+
+		struct dm_config_node *top = dm_config_find_node(reply.cft->root, "metadata");
+		const char *name = daemon_reply_str(reply, "name", NULL);
+
+		struct format_instance *fid;
+		struct format_instance_ctx fic;
+
+		/* fall back to lvm2 if we don't know better */
+		const char *fmt_name = dm_config_find_str(top, "metadata/format", "lvm2");
+		struct format_type *fmt = get_format_by_name(cmd, fmt_name);
+		if (!fmt) {
+			log_error(INTERNAL_ERROR
+				  "We do not know the format (%s) reported by lvmetad.",
+				  fmt_name);
+			return NULL;
+		}
+
+		fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+		fic.context.vg_ref.vg_name = name;
+		fic.context.vg_ref.vg_id = vgid;
+
+		if (!(fid = fmt->ops->create_instance(fmt, &fic)))
+			return_NULL;
+
+		struct dm_config_node *pvcn =
+			dm_config_find_node(top, "metadata/physical_volumes")->child;
+		while (pvcn) {
+			_pv_populate_lvmcache(cmd, pvcn, 0);
+			pvcn = pvcn->sib;
+		}
+
+		top->key = name;
+		vg = import_vg_from_config_tree(reply.cft, fid);
+
+		struct pv_list *pvl;
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			struct lvmcache_info *info =
+				lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0);
+			if (info) {
+				pvl->pv->label_sector = lvmcache_get_label(info)->sector;
+				pvl->pv->dev = lvmcache_device(info);
+				lvmcache_fid_add_mdas_pv(info, fid);
+			} /* else probably missing */
+		}
+
+		lvmcache_update_vg(vg, 0);
+	}
+
+	daemon_reply_destroy(reply);
+	return vg;
+}
+
+struct _fixup_baton {
+	int i;
+	int find;
+	int ignore;
+};
+
+static int _fixup_ignored(struct metadata_area *mda, void *baton) {
+	struct _fixup_baton *b = baton;
+	if (b->i == b->find)
+		mda_set_ignored(mda, b->ignore);
+	b->i ++;
+	return 1;
+}
+
+int lvmetad_vg_update(struct volume_group *vg)
+{
+	char *buf = NULL;
+	if (!vg)
+		return 0;
+	if (!_using_lvmetad)
+		return 1; /* fake it */
+
+	/* TODO. This is not entirely correct, since export_vg_to_buffer
+	 * adds trailing nodes to the buffer. We may need to use
+	 * export_vg_to_config_tree and format the buffer ourselves. It
+	 * does, however, work for now, since the garbage is well
+	 * formatted and has no conflicting keys with the rest of the
+	 * request.  */
+	if (!export_vg_to_buffer(vg, &buf)) {
+		log_error("Could not format VG metadata.");
+		return_0;
+	}
+
+	daemon_reply reply;
+
+	reply = daemon_send_simple(_lvmetad, "vg_update", "vgname = %s", vg->name,
+				             "metadata = %b", strchr(buf, '{'),
+				   NULL);
+
+	if (!_lvmetad_handle_reply(reply, "update VG", vg->name))
+		return 0;
+
+	struct dm_hash_node *n = (vg->fid && vg->fid->metadata_areas_index) ?
+		dm_hash_get_first(vg->fid->metadata_areas_index) : NULL;
+	while (n) {
+		struct metadata_area *mda = dm_hash_get_data(vg->fid->metadata_areas_index, n);
+		char mda_id[128], *num;
+		strcpy(mda_id, dm_hash_get_key(vg->fid->metadata_areas_index, n));
+		if ((num = strchr(mda_id, '_'))) {
+			*num = 0;
+			++num;
+			struct lvmcache_info *info =
+				lvmcache_info_from_pvid(mda_id, 0);
+			struct _fixup_baton baton = { .i = 0, .find = atoi(num),
+						      .ignore = mda_is_ignored(mda) };
+			if (info)
+				lvmcache_foreach_mda(info, _fixup_ignored, &baton);
+		}
+		n = dm_hash_get_next(vg->fid->metadata_areas_index, n);
+	}
+
+	struct pv_list *pvl;
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		/* NB. the PV fmt pointer is sometimes wrong during vgconvert */
+		if (pvl->pv->dev && !lvmetad_pv_found(pvl->pv->id, pvl->pv->dev,
+						      vg->fid ? vg->fid->fmt : pvl->pv->fmt,
+						      pvl->pv->label_sector, NULL))
+			return 0;
+	}
+
+	return 1;
+}
+
+int lvmetad_vg_remove(struct volume_group *vg)
+{
+	if (!_using_lvmetad)
+		return 1; /* just fake it */
+	char uuid[64];
+	id_write_format(&vg->id, uuid, 64);
+	daemon_reply reply =
+		daemon_send_simple(_lvmetad, "vg_remove", "uuid = %s", uuid, NULL);
+
+	return _lvmetad_handle_reply(reply, "remove VG", vg->name);
+}
+
+int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid)
+{
+	if (!_using_lvmetad)
+		return_0;
+
+	int result = 1;
+	char uuid[64];
+	id_write_format(&pvid, uuid, 64);
+
+	daemon_reply reply =
+		daemon_send_simple(_lvmetad, "pv_lookup", "uuid = %s", uuid, NULL);
+
+	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		_lvmetad_handle_reply(reply, "lookup PVs", "");
+		return_0;
+	}
+
+	struct dm_config_node *cn = dm_config_find_node(reply.cft->root, "physical_volume");
+	if (!_pv_populate_lvmcache(cmd, cn, 0))
+		result = 0;
+
+	daemon_reply_destroy(reply);
+	return result;
+}
+
+int lvmetad_pv_lookup_by_devt(struct cmd_context *cmd, dev_t device)
+{
+	if (!_using_lvmetad)
+		return_0;
+
+	int result = 1;
+
+	daemon_reply reply =
+		daemon_send_simple(_lvmetad, "pv_lookup", "device = %d", device, NULL);
+
+	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		_lvmetad_handle_reply(reply, "lookup PVs", "");
+		return_0;
+	}
+
+	struct dm_config_node *cn = dm_config_find_node(reply.cft->root, "physical_volume");
+	if (!_pv_populate_lvmcache(cmd, cn, device))
+		result = 0;
+
+	daemon_reply_destroy(reply);
+	return result;
+}
+
+int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
+{
+	if (!_using_lvmetad)
+		return_0;
+
+	daemon_reply reply =
+		daemon_send_simple(_lvmetad, "pv_list", NULL);
+
+	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		_lvmetad_handle_reply(reply, "list PVs", "");
+		return_0;
+	}
+
+	struct dm_config_node *cn = dm_config_find_node(reply.cft->root, "physical_volumes")->child;
+	while (cn) {
+		_pv_populate_lvmcache(cmd, cn, 0);
+		cn = cn->sib;
+	}
+
+	daemon_reply_destroy(reply);
+	return 1;
+}
+
+int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
+{
+	if (!_using_lvmetad)
+		return_0;
+
+	daemon_reply reply =
+		daemon_send_simple(_lvmetad, "vg_list", NULL);
+
+	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		_lvmetad_handle_reply(reply, "list VGs", "");
+		return_0;
+	}
+
+	struct dm_config_node *cn = dm_config_find_node(reply.cft->root, "volume_groups")->child;
+	while (cn) {
+		struct id vgid;
+		const char *vgid_txt = cn->key,
+			   *name = dm_config_find_str(cn->child, "name", NULL);
+		id_read_format(&vgid, vgid_txt);
+
+		cn = cn->sib;
+
+		/* the call to lvmetad_vg_lookup will poke the VG into lvmcache */
+		struct volume_group *tmp = lvmetad_vg_lookup(cmd, NULL, (const char*)&vgid);
+		release_vg(tmp);
+	}
+
+	daemon_reply_destroy(reply);
+	return 1;
+}
+
+struct _print_mda_baton {
+	int i;
+	char *buffer;
+};
+
+static int _print_mda(struct metadata_area *mda, void *baton)
+{
+	int result = 0;
+	struct _print_mda_baton *b = baton;
+
+	if (!mda->ops->mda_export_text) /* do nothing */
+		return 1;
+
+	char *buf = b->buffer;
+	char *mda_txt = mda->ops->mda_export_text(mda);
+	if (!dm_asprintf(&b->buffer, "%s mda%i { %s }", b->buffer ?: "", b->i, mda_txt))
+		goto_out;
+	b->i ++;
+	result = 1;
+out:
+	dm_free(mda_txt);
+	dm_free(buf);
+	return result;
+}
+
+static int _print_da(struct disk_locn *da, void *baton)
+{
+	if (!da)
+		return 1;
+
+	struct _print_mda_baton *b = baton;
+
+	char *buf = b->buffer;
+	if (!dm_asprintf(&b->buffer, "%s da%i { offset = %lld size = %lld }",
+			 b->buffer ?: "", b->i, da->offset, da->size))
+	{
+		dm_free(buf);
+		return_0;
+	}
+	b->i ++;
+	dm_free(buf);
+	return 1;
+}
+
+static const char *_print_mdas(struct lvmcache_info *info)
+{
+	struct _print_mda_baton baton = { .i = 0, .buffer = NULL };
+	if (!lvmcache_foreach_mda(info, &_print_mda, &baton))
+		return NULL;
+	baton.i = 0;
+	if (!lvmcache_foreach_da(info, &_print_da, &baton))
+		return NULL;
+	return baton.buffer;
+}
+
+int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_type *fmt,
+		     uint64_t label_sector, struct volume_group *vg)
+{
+	if (!_using_lvmetad)
+		return 1;
+
+	char uuid[64];
+
+	id_write_format(&pvid, uuid, 64);
+
+	/* FIXME A more direct route would be much preferable. */
+	struct lvmcache_info *info = lvmcache_info_from_pvid((const char *)&pvid, 0);
+	const char *mdas = NULL;
+	if (info)
+		mdas = _print_mdas(info);
+
+	char *pvmeta;
+	if (!dm_asprintf(&pvmeta,
+			 "{ device = %lld\n"
+			 "  dev_size = %lld\n"
+			 "  format = \"%s\"\n"
+			 "  label_sector = %lld\n"
+			 "  id = \"%s\"\n"
+			 "  %s"
+			 "}", device->dev, info ? lvmcache_device_size(info) : 0,
+			 fmt->name, label_sector, uuid, mdas ?: ""))
+		return_0;
+
+	daemon_reply reply;
+
+	if (vg) {
+		char *buf = NULL;
+		/*
+		 * TODO. This is not entirely correct, since export_vg_to_buffer
+		 * adds trailing garbage to the buffer. We may need to use
+		 * export_vg_to_config_tree and format the buffer ourselves. It
+		 * does, however, work for now, since the garbage is well
+		 * formatted and has no conflicting keys with the rest of the
+		 * request.
+		 */
+		export_vg_to_buffer(vg, &buf);
+		reply = daemon_send_simple(_lvmetad,
+					   "pv_found",
+					   "pvmeta = %b", pvmeta,
+					   "vgname = %s", vg->name,
+					   "metadata = %b", strchr(buf, '{'),
+					   NULL);
+	} else {
+		/* There are no MDAs on this PV. */
+		reply = daemon_send_simple(_lvmetad,
+					   "pv_found",
+					   "pvmeta = %b", pvmeta,
+					   NULL);
+	}
+
+	dm_free(pvmeta);
+	return _lvmetad_handle_reply(reply, "update PV", uuid);
+}
+
+int lvmetad_pv_gone(dev_t device)
+{
+	daemon_reply reply =
+		daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
+
+	return _lvmetad_handle_reply(reply, "drop PV", "");
+}
+
+int lvmetad_active()
+{
+	return _using_lvmetad;
+}
+
+void lvmetad_set_active(int active)
+{
+	_using_lvmetad = active;
+}
+
+/*
+ * The following code implements pvscan --lvmetad.
+ */
+
+struct _pvscan_lvmetad_baton {
+	struct volume_group *vg;
+	struct format_instance *fid;
+};
+
+static int _pvscan_lvmetad_single(struct metadata_area *mda, void *baton)
+{
+	struct _pvscan_lvmetad_baton *b = baton;
+	struct volume_group *this = mda->ops->vg_read(b->fid, "", mda);
+	if ((this && !b->vg) || this->seqno > b->vg->seqno)
+		b->vg = this;
+	else release_vg(this);
+	return 1;
+}
+
+static dev_t _parse_devt(const char *str) { /* Oh. */
+	char *where = (char *) str;
+	int major = strtol(str, &where, 10);
+	if (where == str)
+		return -1;
+	if (*where != ':')
+		return -1;
+	++where;
+	str = where;
+	int minor = strtol(str, &where, 10);
+	if (where == str)
+		return -1;
+	if (*where)
+		return -1;
+
+	return MKDEV(major, minor);
+}
+
+int pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
+{
+	if (argc != 1) {
+		log_error("Exactly one device parameter required.");
+		return 0;
+	}
+
+	if (!lvmetad_active()) {
+		log_error("Cannot proceed since lvmetad is not active.");
+		return 0;
+	}
+
+	struct device *dev = dev_cache_get(argv[0], NULL);
+	if (!dev && _parse_devt(argv[0]) != -1)
+		dev = dev_cache_get_by_devt(_parse_devt(argv[0]), NULL);
+
+	if (!dev) {
+		if (_parse_devt(argv[0]) == -1) {
+			log_error("For devices that do not exist, we need a MAJOR:MINOR pair.");
+			return 0;
+		}
+
+		if (!lvmetad_pv_gone(_parse_devt(argv[0])))
+			goto fatal;
+
+		log_info("Device %s not found and was wiped from lvmetad.", argv[0]);
+		return 1;
+	}
+
+	struct label *label;
+	if (!label_read(dev, &label, 0)) {
+		log_warn("No PV label found on %s.", dev_name(dev));
+		if (!lvmetad_pv_gone(dev->dev))
+			goto fatal;
+		return 1;
+	}
+
+	struct lvmcache_info *info = (struct lvmcache_info *) label->info;
+	struct physical_volume pv;
+	memset(&pv, 0, sizeof(pv));
+
+	struct _pvscan_lvmetad_baton baton;
+	baton.vg = NULL;
+
+	/* Create a dummy instance. */
+	struct format_instance_ctx fic = { .type = 0 };
+	baton.fid =
+		lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
+	struct metadata_area *mda;
+
+	lvmcache_foreach_mda(info, _pvscan_lvmetad_single, &baton);
+
+	/*
+	 * NB. If this command failed and we are relying on lvmetad to have an
+	 * *exact* image of the system, the lvmetad instance that went out of
+	 * sync needs to be killed.
+	 */
+	if (!lvmetad_pv_found(*(struct id *)dev->pvid, dev, lvmcache_fmt(info),
+			      label->sector, baton.vg))
+		goto fatal;
+
+	release_vg(baton.vg);
+	return 1;
+fatal:
+	release_vg(baton.vg);
+	/* FIXME kill lvmetad automatically if we can */
+	log_error("Update of lvmetad failed. This is a serious problem.\n  "
+		  "It is strongly recommended that you restart lvmetad immediately.");
+	return 0;
+}
+
/cvs/lvm2/LVM2/lib/cache/lvmetad.h,v  -->  standard output
revision 1.1
--- LVM2/lib/cache/lvmetad.h
+++ -	2012-02-23 13:11:12.832074000 +0000
@@ -0,0 +1,99 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_METAD_H
+#define _LVM_METAD_H
+
+struct volume_group;
+struct cmd_context;
+struct dm_config_tree;
+
+/*
+ * Initialise the communication with lvmetad. Normally called by
+ * lvmcache_init. Sets up a global handle for our process.
+ */
+void lvmetad_init(void);
+
+/*
+ * Override the use of lvmetad for retrieving scan results and metadata.
+ */
+void lvmetad_set_active(int);
+
+/*
+ * Check whether lvmetad is active (where active means both that it is running
+ * and that we have a working connection with it).
+ */
+int lvmetad_active(void);
+
+/*
+ * Send a new version of VG metadata to lvmetad. This is normally called after
+ * vg_write but before vg_commit. After vg_commit, lvmetad_vg_commit is called
+ * to seal the transaction. The result of lvmetad_vg_update is that the new
+ * metadata is stored tentatively in lvmetad, but it is not used until
+ * lvmetad_vg_commit. The request is validated immediately and lvmetad_vg_commit
+ * only constitutes a pointer update.
+ */
+int lvmetad_vg_update(struct volume_group *vg);
+
+/*
+ * Inform lvmetad that a VG has been removed. This is not entirely safe, but is
+ * only needed during vgremove, which does not wipe PV labels and therefore
+ * cannot mark the PVs as gone.
+ */
+int lvmetad_vg_remove(struct volume_group *vg);
+
+/*
+ * Notify lvmetad that a PV has been found. It is not an error if the PV is
+ * already marked as present in lvmetad. If a non-NULL vg pointer is supplied,
+ * it is taken to represent the metadata read from the MDA(s) present on that
+ * PV. It *is* an error if: the VG is already known to lvmetad, the sequence
+ * number on the cached and on the discovered PV match but the metadata content
+ * does not.
+ */
+int lvmetad_pv_found(struct id pvid, struct device *device,
+		     const struct format_type *fmt, uint64_t label_sector,
+		     struct volume_group *vg);
+
+/*
+ * Inform the daemon that the device no longer exists. We do not support
+ * multiple device names, so this needs a unique and stable name, the same as
+ * provided to lvmetad_pv_found.
+ */
+int lvmetad_pv_gone(dev_t device);
+
+/*
+ * Request a list of all PVs available to lvmetad. If requested, this will also
+ * read labels off all the PVs to populate lvmcache.
+ */
+int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd);
+
+int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid);
+int lvmetad_pv_lookup_by_devt(struct cmd_context *cmd, dev_t dev);
+
+/*
+ * Request a list of all VGs available to lvmetad and use it to fill in
+ * lvmcache..
+ */
+int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd);
+
+struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgname, const char *vgid);
+
+/*
+ * Scan a single device and update lvmetad with the result(s). If the device
+ * node does not exist, it must be supplied in a major:minor format.
+ */
+int pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv);
+
+#endif
+
--- LVM2/lib/cache/lvmcache.c	2012/02/13 14:26:15	1.126
+++ LVM2/lib/cache/lvmcache.c	2012/02/23 13:11:08	1.127
@@ -28,6 +28,8 @@
 #include "format1.h"
 #include "config.h"
 
+#include "lvmetad.h"
+
 #define CACHE_INVALID	0x00000001
 #define CACHE_LOCKED	0x00000002
 
@@ -107,9 +109,20 @@
 		_vg_global_lock_held = 0;
 	}
 
+	lvmetad_init();
+
 	return 1;
 }
 
+void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
+{
+	if (lvmetad_active() && !_has_scanned) {
+		lvmetad_pv_list_to_lvmcache(cmd);
+		_has_scanned = 1;
+	}
+};
+
+
 /* Volume Group metadata cache functions */
 static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 {
@@ -429,7 +442,9 @@
 	return vginfo;
 }
 
-const struct format_type *lvmcache_fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels)
+const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
+						   const char *vgname, const char *vgid,
+						   unsigned revalidate_labels)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -439,8 +454,19 @@
 	struct device_list *devl;
 	char vgid_found[ID_LEN + 1] __attribute__((aligned(8)));
 
-	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+		if (!lvmetad_active())
+			return NULL; /* too bad */
+		/* If we don't have the info but we have lvmetad, we can ask
+		 * there before failing. */
+		struct volume_group *vg = lvmetad_vg_lookup(cmd, vgname, vgid);
+		if (vg) {
+			const struct format_type *fmt = vg->fid->fmt;
+			release_vg(vg);
+			return fmt;
+		}
 		return NULL;
+	}
 
 	/*
 	 * If this function is called repeatedly, only the first one needs to revalidate.
@@ -581,6 +607,13 @@
 	return info;
 }
 
+const char *lvmcache_vgname_from_info(struct lvmcache_info *info)
+{
+	if (info->vginfo)
+		return info->vginfo->vgname;
+	return NULL;
+}
+
 char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 {
 	struct lvmcache_info *info;
@@ -626,6 +659,9 @@
 
 	int r = 0;
 
+	if (lvmetad_active())
+		return 1;
+
 	/* Avoid recursion when a PVID can't be found! */
 	if (_scanning_in_progress)
 		return 0;
@@ -678,13 +714,28 @@
 	return r;
 }
 
-struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
+struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname,
+				     const char *vgid, unsigned precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg = NULL;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 
+	/*
+	 * We currently do not store precommitted metadata in lvmetad at
+	 * all. This means that any request for precommitted metadata is served
+	 * using the classic scanning mechanics, and read from disk or from
+	 * lvmcache.
+	 */
+	if (lvmetad_active() && !precommitted) {
+		/* Still serve the locally cached VG if available */
+		if (vgid && (vginfo = lvmcache_vginfo_from_vgid(vgid)) &&
+		    vginfo->vgmetadata && (vg = vginfo->cached_vg))
+			goto out;
+		return lvmetad_vg_lookup(cmd, vgname, vgid);
+	}
+
 	if (!vgid || !(vginfo = lvmcache_vginfo_from_vgid(vgid)) || !vginfo->vgmetadata)
 		return NULL;
 
@@ -781,6 +832,7 @@
 	struct dm_list *vgids;
 	struct lvmcache_vginfo *vginfo;
 
+	// TODO plug into lvmetad here automagically?
 	lvmcache_label_scan(cmd, 0);
 
 	if (!(vgids = str_list_create(cmd->mem))) {
@@ -862,6 +914,12 @@
 	struct label *label;
 
 	if ((info = lvmcache_info_from_pvid((const char *) pvid, 0))) {
+		if (lvmetad_active()) {
+			if (info->label && label_sector)
+				*label_sector = info->label->sector;
+			return info->dev;
+		}
+
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid)) {
@@ -1333,6 +1391,10 @@
 		vgid = vgname;
 	}
 
+	/* When using lvmetad, the PV could not have become orphaned. */
+	if (lvmetad_active() && is_orphan_vg(vgname) && info->vginfo)
+		return 1;
+
 	/* If PV without mdas is already in a real VG, don't make it orphan */
 	if (is_orphan_vg(vgname) && info->vginfo &&
 	    mdas_empty_or_ignored(&info->mdas) &&
@@ -1408,6 +1470,9 @@
 		info->label = label;
 		dm_list_init(&info->list);
 		info->dev = dev;
+
+		lvmcache_del_mdas(info);
+		lvmcache_del_das(info);
 	} else {
 		if (existing->dev != dev) {
 			/* Is the existing entry a duplicate pvid e.g. md ? */
@@ -1711,7 +1776,7 @@
 	} else
 		dm_list_init(&info->das);
 
-	if (!add_da(NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
+	if (!add_da(NULL, &info->das, pv->pe_start << SECTOR_SHIFT, 0 /*pv->size << SECTOR_SHIFT*/))
 		return_0;
 
 	return 1;
@@ -1749,12 +1814,12 @@
 }
 
 int lvmcache_foreach_da(struct lvmcache_info *info,
-			int (*fun)(struct data_area_list *, void *),
+			int (*fun)(struct disk_locn *, void *),
 			void *baton)
 {
 	struct data_area_list *da;
 	dm_list_iterate_items(da, &info->das) {
-		if (!fun(da, baton))
+		if (!fun(&da->disk_locn, baton))
 			return_0;
 	}
 
@@ -1793,6 +1858,10 @@
 
 int lvmcache_vgid_is_cached(const char *vgid) {
 	struct lvmcache_vginfo *vginfo;
+
+	if (lvmetad_active())
+		return 1;
+
 	vginfo = lvmcache_vginfo_from_vgid(vgid);
 
 	if (!vginfo || !vginfo->vgname)
--- LVM2/lib/cache/lvmcache.h	2012/02/10 01:28:27	1.42
+++ LVM2/lib/cache/lvmcache.h	2012/02/23 13:11:08	1.43
@@ -34,11 +34,13 @@
 struct dm_config_tree;
 struct format_instance;
 struct metadata_area;
-struct data_area_list;
+struct disk_locn;
 
 struct lvmcache_vginfo;
 
 int lvmcache_init(void);
+void lvmcache_allow_reads_with_lvmetad();
+
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans);
 
 /* Set full_scan to 1 to reread every filtered device label or
@@ -64,7 +66,7 @@
 int lvmcache_verify_lock_order(const char *vgname);
 
 /* Queries */
-const struct format_type *lvmcache_fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels);
+const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd, const char *vgname, const char *vgid, unsigned revalidate_labels);
 
 /* Decrement and test if there are still vg holders in vginfo. */
 int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo);
@@ -79,9 +81,12 @@
 const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 			      const char *dev_name);
 char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
+const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 int lvmcache_vgs_locked(void);
 int lvmcache_vgname_is_locked(const char *vgname);
 
+void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd);
+
 /* Returns list of struct str_lists containing pool-allocated copy of vgnames */
 /* If include_internal is not set, return only proper vg names. */
 struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
@@ -97,7 +102,8 @@
 				const char *vgid);
 
 /* Returns cached volume group metadata. */
-struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
+struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname,
+				     const char *vgid, unsigned precommitted);
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
@@ -127,7 +133,7 @@
 			 void *baton);
 
 int lvmcache_foreach_da(struct lvmcache_info *info,
-			int (*fun)(struct data_area_list *, void *),
+			int (*fun)(struct disk_locn *, void *),
 			void *baton);
 
 int lvmcache_foreach_pv(struct lvmcache_vginfo *vg,
--- LVM2/lib/commands/toolcontext.c	2012/02/08 13:44:49	1.150
+++ LVM2/lib/commands/toolcontext.c	2012/02/23 13:11:09	1.151
@@ -34,6 +34,7 @@
 #include "str_list.h"
 #include "segtype.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 #include "dev-cache.h"
 #include "archiver.h"
 
@@ -389,6 +390,8 @@
 		(find_config_tree_int(cmd, "global/detect_internal_vg_cache_corruption()",
 				      DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION));
 
+	lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));
+
 	return 1;
 }
 
--- LVM2/lib/device/dev-cache.c	2012/02/08 11:05:04	1.71
+++ LVM2/lib/device/dev-cache.c	2012/02/23 13:11:09	1.72
@@ -906,6 +906,39 @@
 		      f->passes_filter(f, d))) ? d : NULL;
 }
 
+static struct device *_dev_cache_seek_devt(dev_t dev)
+{
+	struct device *d = NULL;
+	struct dm_hash_node *n = dm_hash_get_first(_cache.names);
+	while (n) {
+		d = dm_hash_get_data(_cache.names, n);
+		if (d->dev == dev)
+			return d;
+		n = dm_hash_get_next(_cache.names, n);
+	}
+	return NULL;
+}
+
+/*
+ * TODO This is very inefficient. We probably want a hash table indexed by
+ * major:minor for keys to speed up these lookups.
+ */
+struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
+{
+	struct device *d = _dev_cache_seek_devt(dev);
+
+	if (d && (d->flags & DEV_REGULAR))
+		return d;
+
+	if (!d) {
+		_full_scan(0);
+		d = _dev_cache_seek_devt(dev);
+	}
+
+	return (d && (!f || (d->flags & DEV_REGULAR) ||
+		      f->passes_filter(f, d))) ? d : NULL;
+}
+
 struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 {
 	struct dev_iter *di = dm_malloc(sizeof(*di));
--- LVM2/lib/device/dev-cache.h	2011/04/22 12:05:33	1.14
+++ LVM2/lib/device/dev-cache.h	2012/02/23 13:11:09	1.15
@@ -44,6 +44,9 @@
 int dev_cache_add_loopfile(const char *path);
 struct device *dev_cache_get(const char *name, struct dev_filter *f);
 
+// TODO
+struct device *dev_cache_get_by_devt(dev_t device, struct dev_filter *f);
+
 void dev_set_preferred_name(struct str_list *sl, struct device *dev);
 
 /*
--- LVM2/lib/device/dev-io.c	2012/02/10 01:28:27	1.81
+++ LVM2/lib/device/dev-io.c	2012/02/23 13:11:09	1.82
@@ -664,6 +664,8 @@
 	where.start = offset;
 	where.size = len;
 
+	// fprintf(stderr, "READ: %s, %lld, %d\n", dev_name(dev), offset, len);
+
 	ret = _aligned_io(&where, buffer, 0);
 	if (!ret)
 		_dev_inc_error_count(dev);
--- LVM2/lib/format1/format1.c	2012/02/15 01:44:58	1.147
+++ LVM2/lib/format1/format1.c	2012/02/23 13:11:09	1.148
@@ -415,6 +415,7 @@
 
 	lvmcache_update_pv(info, pv, fmt);
 	lvmcache_del_mdas(info);
+	lvmcache_del_das(info);
 
 	dm_list_init(&pvs);
 
@@ -590,6 +591,8 @@
 			FMT_RESTRICTED_READAHEAD;
 	fmt->private = NULL;
 
+	dm_list_init(&fmt->mda_ops);
+
 	if (!(fmt->labeller = lvm1_labeller_create(fmt))) {
 		log_error("Couldn't create lvm1 label handler.");
 		dm_free(fmt);
--- LVM2/lib/format_pool/format_pool.c	2012/02/15 13:46:54	1.52
+++ LVM2/lib/format_pool/format_pool.c	2012/02/23 13:11:09	1.53
@@ -301,6 +301,8 @@
 	fmt->features = 0;
 	fmt->private = NULL;
 
+	dm_list_init(&fmt->mda_ops);
+
 	if (!(fmt->labeller = pool_labeller_create(fmt))) {
 		log_error("Couldn't create pool label handler.");
 		dm_free(fmt);
--- LVM2/lib/format_text/export.c	2012/01/25 22:35:36	1.86
+++ LVM2/lib/format_text/export.c	2012/02/23 13:11:09	1.87
@@ -395,6 +395,9 @@
 
 	outf(f, "seqno = %u", vg->seqno);
 
+	if (vg->fid && vg->fid->fmt)
+		outf(f, "format = \"%s\" # informational", vg->fid->fmt->name);
+
 	if (!_print_flag_config(f, vg->status, VG_FLAGS))
 		return_0;
 
--- LVM2/lib/format_text/format-text.c	2012/02/13 11:09:25	1.193
+++ LVM2/lib/format_text/format-text.c	2012/02/23 13:11:09	1.194
@@ -29,6 +29,7 @@
 #include "label.h"
 #include "memlock.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 
 #include <unistd.h>
 #include <sys/file.h>
@@ -738,6 +739,7 @@
 			  dev_name(mdac->area.dev), mdac->area.start);
 
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
+
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
@@ -1430,16 +1432,25 @@
 static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 		    struct physical_volume *pv, int scan_label_only)
 {
-	struct label *label;
+	struct lvmcache_info *info;
 	struct device *dev;
 
 	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
 		return_0;
 
-	if (!(label_read(dev, &label, UINT64_C(0))))
-		return_0;
+	if (lvmetad_active()) {
+		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		if (!info && !lvmetad_pv_lookup_by_devt(fmt->cmd, dev->dev))
+			return 0;
+		info = lvmcache_info_from_pvid(dev->pvid, 0);
+	} else {
+		struct label *label;
+		if (!(label_read(dev, &label, UINT64_C(0))))
+			return_0;
+		info = label->info;
+	}
 
-	if (!lvmcache_populate_pv_fields(label->info, pv, scan_label_only))
+	if (!lvmcache_populate_pv_fields(info, pv, scan_label_only))
 		return 0;
 
 	return 1;
@@ -1568,6 +1579,9 @@
 	.vg_commit = _vg_commit_file_backup
 };
 
+static char *_mda_export_text_raw(struct metadata_area *mda);
+static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_config_node *cn);
+
 static struct metadata_area_ops _metadata_text_raw_ops = {
 	.vg_read = _vg_read_raw,
 	.vg_read_precommit = _vg_read_precommit_raw,
@@ -1584,9 +1598,42 @@
 	.mda_in_vg = _mda_in_vg_raw,
 	.pv_analyze_mda = _pv_analyze_mda_raw,
 	.mda_locns_match = _mda_locns_match_raw,
-	.mda_get_device = _mda_get_device_raw
+	.mda_get_device = _mda_get_device_raw,
+	.mda_export_text = _mda_export_text_raw,
+	.mda_import_text = _mda_import_text_raw
 };
 
+static char *_mda_export_text_raw(struct metadata_area *mda)
+{
+	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
+	char *result;
+	dm_asprintf(&result,
+		    "ignore = %d "
+		    "start = %" PRIu64" "
+		    "size = %" PRIu64 " "
+		    "free_sectors = %" PRIu64,
+		    mda_is_ignored(mda), mdc->area.start, mdc->area.size, mdc->free_sectors);
+	return result;
+}
+
+static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_config_node *cn)
+{
+	if (!cn->child)
+		return 0;
+	cn = cn->child;
+
+	struct device *device = lvmcache_device(info);
+	uint64_t offset = dm_config_find_int(cn, "start", 0);
+	uint64_t size = dm_config_find_int(cn, "size", 0);
+	int ignore = dm_config_find_int(cn, "ignore", 0);
+
+	if (!device || !size)
+		return 0;
+
+	lvmcache_add_mda(info, device, offset, size, ignore);
+	return 1;
+}
+
 static int _text_pv_setup(const struct format_type *fmt,
 			  struct physical_volume *pv,
 			  struct volume_group *vg)
@@ -1619,7 +1666,9 @@
 	 * reread PV mda information from the cache and add it to vg->fid.
 	 */
 	else {
-		if (!(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
+		if (!pv->dev ||
+		    !pv->dev->pvid ||
+		    !(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
 			log_error("PV %s missing from cache", pv_dev_name(pv));
 			return 0;
 		}
@@ -2292,6 +2341,9 @@
 	mda_lists->raw_ops = &_metadata_text_raw_ops;
 	fmt->private = (void *) mda_lists;
 
+	dm_list_init(&fmt->mda_ops);
+	dm_list_add(&fmt->mda_ops, &_metadata_text_raw_ops.list);
+
 	if (!(fmt->labeller = text_labeller_create(fmt))) {
 		log_error("Couldn't create text label handler.");
 		goto bad;
--- LVM2/lib/format_text/import_vsn1.c	2012/02/10 01:28:28	1.100
+++ LVM2/lib/format_text/import_vsn1.c	2012/02/23 13:11:09	1.101
@@ -19,6 +19,7 @@
 #include "display.h"
 #include "toolcontext.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 #include "lv_alloc.h"
 #include "pv_alloc.h"
 #include "segtype.h"
@@ -59,6 +60,10 @@
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 
+	// TODO if this is pvscan --lvmetad, we want this check back.
+	if (lvmetad_active())
+		return 1;
+
 	/*
 	 * Check the contents field.
 	 */
@@ -212,7 +217,8 @@
 		return 0;
 	}
 
-	if (!pv->dev)
+	/* TODO is the !lvmetad_active() too coarse here? */
+	if (!pv->dev && !lvmetad_active())
 		pv->status |= MISSING_PV;
 
 	/* Late addition */
--- LVM2/lib/format_text/text_label.c	2012/02/10 01:28:28	1.41
+++ LVM2/lib/format_text/text_label.c	2012/02/23 13:11:09	1.42
@@ -19,6 +19,7 @@
 #include "label.h"
 #include "xlate.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -40,11 +41,11 @@
 	struct device *dev;
 };
 
-static int _da_setup(struct data_area_list *da, void *baton)
+static int _da_setup(struct disk_locn *da, void *baton)
 {
 	struct _da_setup_baton *p = baton;
-	p->pvh_dlocn_xl->offset = xlate64(da->disk_locn.offset);
-	p->pvh_dlocn_xl->size = xlate64(da->disk_locn.size);
+	p->pvh_dlocn_xl->offset = xlate64(da->offset);
+	p->pvh_dlocn_xl->size = xlate64(da->size);
 	p->pvh_dlocn_xl++;
 	return 1;
 }
@@ -275,7 +276,7 @@
 	const struct format_type *fmt = p->label->labeller->private; // Oh dear.
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
-	const char *vgname;
+	const char *vgname = NULL;
 	struct id vgid;
 	uint64_t vgstatus;
 	char *creation_host;
@@ -337,7 +338,6 @@
 				  FMT_TEXT_ORPHAN_VG_NAME, 0)))
 		return_0;
 
-	/* this one is leaked forever */
 	*label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, xlate64(pvhdr->device_size_xl));
--- LVM2/lib/label/label.c	2012/02/10 01:28:28	1.56
+++ LVM2/lib/label/label.c	2012/02/23 13:11:09	1.57
@@ -18,6 +18,7 @@
 #include "crc.h"
 #include "xlate.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 #include "metadata.h"
 
 #include <sys/stat.h>
@@ -263,7 +264,7 @@
 
 	if ((info = lvmcache_info_from_pvid(dev->pvid, 1))) {
 		log_debug("Using cached label for %s", dev_name(dev));
-		*result = lvmcache_get_label(info); /* leaked */
+		*result = lvmcache_get_label(info);
 		return 1;
 	}
 
--- LVM2/lib/label/label.h	2007/08/20 20:55:26	1.20
+++ LVM2/lib/label/label.h	2012/02/23 13:11:09	1.21
@@ -26,6 +26,8 @@
 
 struct labeller;
 
+void allow_reads_with_lvmetad(void);
+
 /* On disk - 32 bytes */
 struct label_header {
 	int8_t id[8];		/* LABELONE */
--- LVM2/lib/metadata/metadata-exported.h	2012/02/15 15:18:43	1.231
+++ LVM2/lib/metadata/metadata-exported.h	2012/02/23 13:11:09	1.232
@@ -174,6 +174,7 @@
 	struct dm_list list;
 	struct cmd_context *cmd;
 	struct format_handler *ops;
+	struct dm_list mda_ops; /* List of permissible mda ops. */
 	struct labeller *labeller;
 	const char *name;
 	const char *alias;
--- LVM2/lib/metadata/metadata.c	2012/02/23 00:11:01	1.485
+++ LVM2/lib/metadata/metadata.c	2012/02/23 13:11:10	1.486
@@ -20,6 +20,7 @@
 #include "lvm-string.h"
 #include "lvm-file.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 #include "memlock.h"
 #include "str_list.h"
 #include "pv_alloc.h"
@@ -257,7 +258,7 @@
 			stack;
 			uuid[0] = '\0';
 		}
-		log_error("Physical volume '%s (%s)' listed more than once.",
+		log_error("Physical volume '%s (%s)' already in the VG.",
 			  pv_name, uuid);
 		return 0;
 	}
@@ -615,6 +616,10 @@
 		}
 	}
 
+	/* FIXME Handle partial failures from above. */
+	if (!lvmetad_vg_remove(vg))
+		stack;
+
 	if (!backup_remove(vg->cmd, vg->name))
 		stack;
 
@@ -2678,6 +2683,7 @@
 		/* Update cache first time we succeed */
 		if (!failed && !cache_updated) {
 			lvmcache_update_vg(vg, 0);
+			// lvmetad_vg_commit(vg);
 			cache_updated = 1;
 		}
 	}
@@ -2695,6 +2701,9 @@
 		return cache_updated;
 	}
 
+	if (!lvmetad_vg_update(vg))
+		return 0;
+
 	cache_updated = _vg_commit_mdas(vg);
 
 	if (cache_updated) {
@@ -2750,6 +2759,7 @@
 			    b->vg->fid, b->warnings, 0))) {
 		return 1;
 	}
+
 	if (!(pvl = dm_pool_zalloc(b->vg->vgmem, sizeof(*pvl)))) {
 		log_error("pv_list allocation failed");
 		free_pv_fid(pv);
@@ -2771,11 +2781,12 @@
 	struct _vg_read_orphan_baton baton;
 
 	lvmcache_label_scan(cmd, 0);
+	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
 
-	if (!(fmt = lvmcache_fmt_from_vgname(orphan_vgname, NULL, 0)))
+	if (!(fmt = lvmcache_fmt_from_vgname(cmd, orphan_vgname, NULL, 0)))
 		return_NULL;
 
 	vg = fmt->orphan_vg;
@@ -2915,6 +2926,7 @@
 	struct pv_list *pvl, *pvl2;
 	struct dm_list all_pvs;
 	char uuid[64] __attribute__((aligned(8)));
+	int seqno = 0;
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
@@ -2926,31 +2938,39 @@
 		return _vg_read_orphans(cmd, warnings, vgname);
 	}
 
+	if (lvmetad_active() && !use_precommitted) {
+		*consistent = 1;
+		return lvmcache_get_vg(cmd, vgname, vgid, precommitted);
+	}
+
 	/*
 	 * If cached metadata was inconsistent and *consistent is set
 	 * then repair it now.  Otherwise just return it.
 	 * Also return if use_precommitted is set due to the FIXME in
 	 * the missing PV logic below.
 	 */
-	if ((correct_vg = lvmcache_get_vg(vgid, precommitted)) &&
+	if ((correct_vg = lvmcache_get_vg(cmd, vgname, vgid, precommitted)) &&
 	    (use_precommitted || !*consistent)) {
 		*consistent = 1;
 		return correct_vg;
 	} else {
+		if (correct_vg && correct_vg->seqno > seqno)
+			seqno = correct_vg->seqno;
 		release_vg(correct_vg);
 		correct_vg = NULL;
 	}
 
+
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
-	if (!(fmt = lvmcache_fmt_from_vgname(vgname, vgid, 1))) {
+	if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 1))) {
 		lvmcache_label_scan(cmd, 0);
-		if (!(fmt = lvmcache_fmt_from_vgname(vgname, vgid, 1))) {
+		if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 1))) {
 			/* Independent MDAs aren't supported under low memory */
 			if (!cmd->independent_metadata_areas && critical_section())
 				return_NULL;
 			lvmcache_label_scan(cmd, 2);
-			if (!(fmt = lvmcache_fmt_from_vgname(vgname, vgid, 0)))
+			if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0)))
 				return_NULL;
 		}
 	}
@@ -3026,6 +3046,12 @@
 	/* Ensure every PV in the VG was in the cache */
 	if (correct_vg) {
 		/*
+		 * Update the seqno from the cache, for the benefit of
+		 * retro-style metadata formats like LVM1.
+		 */
+		// correct_vg->seqno = seqno > correct_vg->seqno ? seqno : correct_vg->seqno;
+
+		/*
 		 * If the VG has PVs without mdas, or ignored mdas, they may
 		 * still be orphans in the cache: update the cache state here,
 		 * and update the metadata lists in the vg.
@@ -3136,7 +3162,7 @@
 		if (!cmd->independent_metadata_areas && critical_section())
 			return_NULL;
 		lvmcache_label_scan(cmd, 2);
-		if (!(fmt = lvmcache_fmt_from_vgname(vgname, vgid, 0)))
+		if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0)))
 			return_NULL;
 
 		if (precommitted && !(fmt->features & FMT_PRECOMMIT))
@@ -3582,14 +3608,22 @@
 	if (!(dev = dev_cache_get(pv_name, cmd->filter)))
 		return_NULL;
 
-	if (!(label_read(dev, &label, UINT64_C(0)))) {
-		if (warnings)
-			log_error("No physical volume label read from %s",
-				  pv_name);
-		return NULL;
+	if (lvmetad_active()) {
+		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		if (!info && !lvmetad_pv_lookup_by_devt(cmd, dev->dev))
+			return NULL;
+		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		label = lvmcache_get_label(info);
+	} else {
+		if (!(label_read(dev, &label, UINT64_C(0)))) {
+			if (warnings)
+				log_error("No physical volume label read from %s",
+					  pv_name);
+			return NULL;
+		}
+		info = (struct lvmcache_info *) label->info;
 	}
 
-	info = (struct lvmcache_info *) label->info;
 	fmt = lvmcache_fmt(info);
 
 	pv = _alloc_pv(pvmem, dev);
@@ -3748,6 +3782,9 @@
 	if (!pv->fmt->ops->pv_write(pv->fmt, pv))
 		return_0;
 
+	if (!lvmetad_pv_found(pv->id, pv->dev, pv->fmt, pv->label_sector, NULL))
+		return_0;
+
 	return 1;
 }
 
@@ -4120,9 +4157,9 @@
 
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
-	if (!lvmcache_fmt_from_vgname(vgname, NULL, 1)) {
+	if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 1)) {
 		lvmcache_label_scan(cmd, 0);
-		if (!lvmcache_fmt_from_vgname(vgname, NULL, 1)) {
+		if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 1)) {
 			/* Independent MDAs aren't supported under low memory */
 			if (!cmd->independent_metadata_areas && critical_section()) {
 				/*
@@ -4133,7 +4170,7 @@
 				return FAILED_LOCKING;
 			}
 			lvmcache_label_scan(cmd, 2);
-			if (!lvmcache_fmt_from_vgname(vgname, NULL, 0)) {
+			if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 0)) {
 				/* vgname not found after scanning */
 				return SUCCESS;
 			}
@@ -4228,8 +4265,9 @@
 		 const char *key, size_t key_len, const unsigned sub_key)
 {
 	static char full_key[PATH_MAX];
+
 	dm_list_add(mda_is_ignored(mda) ? &fid->metadata_areas_ignored :
-					  &fid->metadata_areas_in_use, &mda->list);
+		                          &fid->metadata_areas_in_use, &mda->list);
 
 	/* Return if the mda is not supposed to be indexed. */
 	if (!key)
@@ -4238,7 +4276,7 @@
 	/* Add metadata area to index. */
 	if (!_convert_key_to_string(key, key_len, sub_key,
 				    full_key, sizeof(full_key)))
-	return_0;
+		return_0;
 
 	dm_hash_insert(fid->metadata_areas_index,
 		       full_key, mda);
--- LVM2/lib/metadata/metadata.h	2012/02/08 13:05:39	1.266
+++ LVM2/lib/metadata/metadata.h	2012/02/23 13:11:10	1.267
@@ -70,9 +70,11 @@
 struct dm_config_tree;
 struct metadata_area;
 struct alloc_handle;
+struct lvmcache_info;
 
 /* Per-format per-metadata area operations */
 struct metadata_area_ops {
+	struct dm_list list;
 	struct volume_group *(*vg_read) (struct format_instance * fi,
 					 const char *vg_name,
 					 struct metadata_area * mda);
@@ -145,6 +147,8 @@
 				    struct metadata_area *mda2);
 
 	struct device *(*mda_get_device)(struct metadata_area *mda);
+	char *(*mda_export_text)(struct metadata_area *mda);
+	int (*mda_import_text)(struct lvmcache_info *info, const struct dm_config_node *cn);
 };
 
 #define MDA_IGNORED      0x00000001
--- LVM2/tools/Makefile.in	2011/11/14 21:30:36	1.124
+++ LVM2/tools/Makefile.in	2012/02/23 13:11:10	1.125
@@ -16,6 +16,8 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
+INCLUDES += -I$(top_srcdir)/daemons/common -I$(top_srcdir)/daemons/lvmetad
+
 SOURCES =\
 	dumpconfig.c \
 	formats.c \
--- LVM2/tools/args.h	2011/11/30 02:02:12	1.86
+++ LVM2/tools/args.h	2012/02/23 13:11:10	1.87
@@ -61,6 +61,7 @@
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
+arg(lvmetad_ARG, '\0', "lvmetad", NULL, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
--- LVM2/tools/commands.h	2011/11/30 02:02:12	1.167
+++ LVM2/tools/commands.h	2012/02/23 13:11:10	1.168
@@ -670,11 +670,12 @@
    "\t[-P|--partial] " "\n"
    "\t[-s|--short] " "\n"
    "\t[-u|--uuid] " "\n"
+   "\t[--lvmetad DEVICE] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
    exported_ARG, ignorelockingfailure_ARG, novolumegroup_ARG, partial_ARG,
-   short_ARG, uuid_ARG)
+   short_ARG, uuid_ARG, lvmetad_ARG)
 
 xx(segtypes,
    "List available segment types",
--- LVM2/tools/pvcreate.c	2012/02/13 11:04:00	1.98
+++ LVM2/tools/pvcreate.c	2012/02/23 13:11:10	1.99
@@ -56,6 +56,7 @@
 		if (!id_read_format(&pp->id, uuid))
 			return 0;
 		pp->idp = &pp->id;
+		lvmcache_seed_infos_from_lvmetad(cmd); /* need to check for UUID dups */
 	}
 
 	if (arg_count(cmd, restorefile_ARG)) {
--- LVM2/tools/pvremove.c	2011/08/30 14:55:19	1.36
+++ LVM2/tools/pvremove.c	2012/02/23 13:11:10	1.37
@@ -128,6 +128,8 @@
 		goto error;
 	}
 
+	lvmetad_pv_gone(dev->dev);
+
 	log_print("Labels on physical volume \"%s\" successfully wiped",
 		  pv_name);
 
--- LVM2/tools/pvscan.c	2011/03/11 14:56:56	1.53
+++ LVM2/tools/pvscan.c	2012/02/23 13:11:10	1.54
@@ -15,6 +15,9 @@
 
 #include "tools.h"
 
+#include "lvmetad.h"
+#include "lvmcache.h"
+
 int pv_max_name_len = 0;
 int vg_max_name_len = 0;
 
@@ -96,8 +99,7 @@
 					   pv_pe_size(pv)));
 }
 
-int pvscan(struct cmd_context *cmd, int argc __attribute__((unused)),
-	   char **argv __attribute__((unused)))
+int pvscan(struct cmd_context *cmd, int argc, char **argv)
 {
 	int new_pvs_found = 0;
 	int pvs_found = 0;
@@ -113,6 +115,12 @@
 	pv_max_name_len = 0;
 	vg_max_name_len = 0;
 
+	if (arg_count(cmd, lvmetad_ARG)) {
+		if (!pvscan_lvmetad(cmd, argc, argv))
+			return ECMD_FAILED;
+		return ECMD_PROCESSED;
+	}
+
 	if (arg_count(cmd, novolumegroup_ARG) && arg_count(cmd, exported_ARG)) {
 		log_error("Options -e and -n are incompatible");
 		return EINVALID_CMD_LINE;
@@ -184,8 +192,8 @@
 	vg_max_name_len += 2;
 
 	dm_list_iterate_items(pvl, pvslist) {
-	    _pvscan_display_single(cmd, pvl->pv, NULL);
-	    free_pv_fid(pvl->pv);
+		_pvscan_display_single(cmd, pvl->pv, NULL);
+		free_pv_fid(pvl->pv);
 	}
 
 	if (!pvs_found) {
--- LVM2/tools/toollib.c	2012/02/15 15:18:44	1.241
+++ LVM2/tools/toollib.c	2012/02/23 13:11:10	1.242
@@ -305,6 +305,7 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
+		lvmetad_vg_list_to_lvmcache(cmd);
 		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
@@ -581,6 +582,7 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all volume groups");
+		lvmetad_vg_list_to_lvmcache(cmd);
 		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 			log_error("No volume groups found");
 			return ret_max;
@@ -837,6 +839,7 @@
 		} else {
 			log_verbose("Scanning for physical volume names");
 
+			lvmcache_seed_infos_from_lvmetad(cmd);
 			if (!(pvslist = get_pvs(cmd)))
 				goto bad;
 
--- LVM2/tools/tools.h	2012/01/05 15:38:19	1.78
+++ LVM2/tools/tools.h	2012/02/23 13:11:10	1.79
@@ -28,6 +28,7 @@
 #include "activate.h"
 #include "archiver.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 #include "config.h"
 #include "defaults.h"
 #include "dev-cache.h"
--- LVM2/tools/vgcfgrestore.c	2011/02/18 14:47:31	1.25
+++ LVM2/tools/vgcfgrestore.c	2012/02/23 13:11:10	1.26
@@ -45,6 +45,8 @@
 		return ECMD_PROCESSED;
 	}
 
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 		log_error("Unable to lock volume group %s", vg_name);
 		return ECMD_FAILED;
--- LVM2/tools/vgcreate.c	2011/08/10 20:25:31	1.84
+++ LVM2/tools/vgcreate.c	2012/02/23 13:11:10	1.85
@@ -49,6 +49,8 @@
 	if (vgcreate_params_validate(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
 	/* Create the new VG */
 	vg = vg_create(cmd, vp_new.vg_name);
 	if (vg_read_error(vg)) {
--- LVM2/tools/vgrename.c	2012/02/10 01:28:29	1.77
+++ LVM2/tools/vgrename.c	2012/02/23 13:11:10	1.78
@@ -79,6 +79,8 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
+	lvmetad_vg_list_to_lvmcache(cmd); /* populate lvmcache */
+
 	/* Avoid duplicates */
 	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 		log_error("No complete volume groups found");
--- LVM2/tools/vgscan.c	2010/07/09 15:34:48	1.38
+++ LVM2/tools/vgscan.c	2012/02/23 13:11:10	1.39
@@ -24,13 +24,14 @@
 		  vg->fid->fmt->name);
 
 	check_current_backup(vg);
+	lvmetad_vg_update(vg); /* keep lvmetad up to date */
 
 	return ECMD_PROCESSED;
 }
 
 int vgscan(struct cmd_context *cmd, int argc, char **argv)
 {
-	int maxret, ret;
+	int maxret, ret, lvmetad;
 
 	if (argc) {
 		log_error("Too many parameters on command line");
@@ -44,6 +45,8 @@
 
 	persistent_filter_wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1);
+	lvmetad = lvmetad_active();
+	lvmetad_set_active(0); /* do not rely on lvmetad info */
 
 	log_print("Reading all physical volumes.  This may take a while...");
 
@@ -56,6 +59,7 @@
 			maxret = ret;
 	}
 
+	lvmetad_set_active(lvmetad); /* restore */
 	unlock_vg(cmd, VG_GLOBAL);
 	return maxret;
 }
--- LVM2/doc/example.conf.in	2012/01/26 14:02:44	1.43
+++ LVM2/doc/example.conf.in	2012/02/23 13:11:10	1.44
@@ -453,6 +453,16 @@
     # Set to 1 to reinstate the previous format.
     #
     # lvdisplay_shows_full_device_path = 0
+
+    # Whether to use (trust) a running instance of lvmetad. If this is set to
+    # 0, all commands fall back to the usual scanning mechanisms. When set to 1
+    # *and* when lvmetad is running (it is not auto-started), the volume group
+    # metadata and PV state flags are obtained from the lvmetad instance and no
+    # scanning is done by the individual commands. In a setup with lvmetad,
+    # lvmetad udev rules *must* be set up for LVM to work correctly. Without
+    # proper udev rules, all changes in block device configuration will be
+    # *ignored* until a manual 'vgscan' is performed.
+    use_lvmetad = 0
 }
 
 activation {
--- LVM2/scripts/vgimportclone.sh	2011/09/07 08:31:17	1.4
+++ LVM2/scripts/vgimportclone.sh	2012/02/23 13:11:10	1.5
@@ -249,6 +249,7 @@
     '/^[ \t]*filter[ \t]*=/{print ENVIRON["FILTER"];next} \
      /^[ \t]*scan[ \t]*=/{print "scan = [ \"" DEV "\" ]";next} \
      /^[ \t]*cache[ \t]*=/{print "cache = \"" CACHE "\"";next} \
+     /^[ \t]*use_lvmetad[ \t]*=/{print "use_lvmetad = 0";next} \
      /^[ \t]*cache_dir[ \t]*=/{print "cache_dir = \"" CACHE_DIR "\"";next} \
      {print $0}' > ${LVMCONF}
 
--- LVM2/test/lib/aux.sh	2012/02/15 14:24:32	1.37
+++ LVM2/test/lib/aux.sh	2012/02/23 13:11:10	1.38
@@ -70,6 +70,7 @@
 	}
 
 	lvmconf "global/use_lvmetad = 1"
+	lvmconf "devices/md_component_detection = 0"
 
 	lvmetad -f "$@" -s $TESTDIR/lvmetad.socket &
 	echo "$!" > LOCAL_LVMETAD
@@ -323,8 +324,11 @@
 
 	init_udev_transaction
 	for dev in "$@"; do
-        	dmsetup remove -f $dev || true
-		pvscan --lvmetad $dev || true
+	    maj=$(($(stat --printf=0x%t $dev)))
+	    min=$(($(stat --printf=0x%T $dev)))
+	    echo "disabling device $dev ($maj:$min)"
+            dmsetup remove -f $dev || true
+	    pvscan --lvmetad $maj:$min || true
 	done
 	finish_udev_transaction
 
--- LVM2/test/shell/inconsistent-metadata.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/inconsistent-metadata.sh	2012/02/23 13:11:10	1.2
@@ -40,29 +40,32 @@
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
-# vgdisplay fixes
-init
-vgdisplay 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg" cmd.out
-vgdisplay 2>&1 | tee cmd.out
-not grep "Inconsistent metadata found for VG $vg" cmd.out
-check
+# only vgscan would have noticed metadata inconsistencies when lvmetad is active
+if !test -e LOCAL_LVMETAD; then
+	# vgdisplay fixes
+	init
+	vgdisplay 2>&1 | tee cmd.out
+	grep "Inconsistent metadata found for VG $vg" cmd.out
+	vgdisplay 2>&1 | tee cmd.out
+	not grep "Inconsistent metadata found for VG $vg" cmd.out
+	check
 
-# lvs fixes up
-init
-lvs 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg" cmd.out
-vgdisplay 2>&1 | tee cmd.out
-not grep "Inconsistent metadata found for VG $vg" cmd.out
-check
+	# lvs fixes up
+	init
+	lvs 2>&1 | tee cmd.out
+	grep "Inconsistent metadata found for VG $vg" cmd.out
+	vgdisplay 2>&1 | tee cmd.out
+	not grep "Inconsistent metadata found for VG $vg" cmd.out
+	check
 
-# vgs fixes up as well
-init
-vgs 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg" cmd.out
-vgs 2>&1 | tee cmd.out
-not grep "Inconsistent metadata found for VG $vg" cmd.out
-check
+	# vgs fixes up as well
+	init
+	vgs 2>&1 | tee cmd.out
+	grep "Inconsistent metadata found for VG $vg" cmd.out
+	vgs 2>&1 | tee cmd.out
+	not grep "Inconsistent metadata found for VG $vg" cmd.out
+	check
+fi
 
 echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
 vgremove -f $vg
--- LVM2/test/shell/lvconvert-mirror.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-mirror.sh	2012/02/23 13:11:10	1.2
@@ -79,6 +79,7 @@
 lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 $dev1 $dev2 $dev4 $dev3:0 # If the above "should" failed...
 
+sleep 1
 lvconvert -m-1 $vg/$lv1 $dev1
 check mirror_images_on $lv1 $dev2 $dev4
 lvconvert -m-1 $vg/$lv1 $dev2
--- LVM2/test/shell/lvcreate-repair.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvcreate-repair.sh	2012/02/23 13:11:10	1.2
@@ -14,31 +14,32 @@
 aux prepare_vg 3
 
 # fail multiple devices
-for i in pv1 pv2 pv3 ; do
-	for j in pv2 pv3 ; do
+for i in $dev1 $dev2 $dev3 ; do
+	for j in $dev2 $dev3 ; do
 
 		if test $i = $j ; then continue ; fi
 
 		vgremove -ff $vg
 		vgcreate $vg $dev1 $dev2 $dev3
+		# exit 1
 
 		lvcreate -l1 -n $lv1 $vg $dev1
 
-		aux lvmconf "devices/filter = [ \"r/.*$i$/\", \"r/.*$j$/\", \"a/dev\/mapper\/.*pv[0-9_]*$/\", \"r/.*/\" ]"
+		aux disable_dev $i $j
 
 		vgreduce --removemissing --force $vg
 
 		# check if reduced device was removed
-		test $i = pv1 && dmsetup table | not egrep "$vg-$lv1: *[^ ]+" >/dev/null
+		test $i = $dev1 && dmsetup table | not egrep "$vg-$lv1: *[^ ]+" >/dev/null
 
 		lvcreate -l1 -n $lv2 $vg
 
-		test $i != pv1 && check lv_exists $vg $lv1
+		test $i != $dev1 && check lv_exists $vg $lv1
 		check lv_exists $vg $lv2
 
-		aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]'
+		aux enable_dev $i $j
 
-		test $i != pv1 && check lv_exists $vg $lv1
+		test $i != $dev1 && check lv_exists $vg $lv1
 		check lv_exists $vg $lv2
 	done
 done
@@ -84,6 +85,7 @@
 
 # dirty game
 dd if=/dev/zero of="$dev3" bs=256K count=1
+pvscan --lvmetad $dev3 || true # udev be watching you
 
 vgreduce --removemissing --force $vg
 
--- LVM2/test/shell/lvmcache-exercise.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvmcache-exercise.sh	2012/02/23 13:11:10	1.2
@@ -19,5 +19,5 @@
 pvscan
 vgcreate $vg1 $dev2
 aux enable_dev $dev1
-pvs
+valgrind --trace-children=yes pvs
 pvs
--- LVM2/test/shell/pool-labels.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pool-labels.sh	2012/02/23 13:11:10	1.2
@@ -18,6 +18,7 @@
   # printf comes from coreutils, and is probably not posix either
   env printf "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of=$2 bs=5 seek=1 conv=notrunc
   env printf "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
+  pvscan --lvmetad "$2" || true
 }
 
 env printf "" || exit 200 # skip if printf is not available
--- LVM2/test/shell/vgimportclone.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/vgimportclone.sh	2012/02/23 13:11:10	1.2
@@ -17,6 +17,7 @@
 
 # Clone the LUN
 dd if=$dev1 of=$dev2 bs=256K count=1
+pvscan --lvmetad $dev2 || true
 
 # Verify pvs works on each device to give us vgname
 check pv_field $dev1 vg_name $vg1
@@ -25,6 +26,13 @@
 # Import the cloned PV to a new VG
 vgimportclone --basevgname $vg2 $dev2
 
+# We need to re-scan *both* $dev1 and $dev2 since a PV, as far as lvmetad is
+# concerned, can only live on a single device. With the last pvscan, we told it
+# that PV from $dev1 now lives on $dev2, but in fact this is not true anymore,
+# since we wrote a different PV over $dev2.
+pvscan --lvmetad $dev2 || true
+pvscan --lvmetad $dev1 || true
+
 # Verify we can activate / deactivate the LV from both VGs
 lvchange -ay $vg1/$lv1 $vg2/$lv1
 vgchange -an $vg1 $vg2
--- LVM2/test/unit/Makefile.in	2012/01/27 10:55:02	1.7
+++ LVM2/test/unit/Makefile.in	2012/02/23 13:11:11	1.8
@@ -25,7 +25,7 @@
 LDLIBS += -ldevmapper @CUNIT_LIBS@
 CFLAGS += @CUNIT_CFLAGS@
 
-all: unit
+check: unit
 
 unit: $(TARGETS)
 	@echo Running unit tests


