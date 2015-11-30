From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 30 Nov 2015 18:00:44 +0000 (UTC)
Subject: master - lvmcache: new function to check if VG is foreign
Message-ID: <20151130180044.04537602B1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb22f7c8f7351a38fc4447f56ff588f497037c23
Commit:        eb22f7c8f7351a38fc4447f56ff588f497037c23
Parent:        05ac8367980afb0b660fc312b228337e256a38e8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 11:54:56 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 30 11:54:56 2015 -0600

lvmcache: new function to check if VG is foreign

When not using lvmetad, this uses the system_id field in
the cached vginfo structs that are populated during a scan.

When using lvmetad, this requests the VG from lvmetad, and
checks the system_id field in the returned metadata.
---
 lib/cache/lvmcache.c |   14 ++++++++++++++
 lib/cache/lvmcache.h |    1 +
 lib/cache/lvmetad.c  |   26 ++++++++++++++++++++++++++
 lib/cache/lvmetad.h  |    3 +++
 4 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6c86a40..985ff43 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2402,3 +2402,17 @@ void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
 	}
 }
 
+int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid)
+{
+	struct lvmcache_vginfo *vginfo;
+	int ret = 0;
+
+	if (lvmetad_active())
+		return lvmetad_vg_is_foreign(cmd, vgname, vgid);
+
+	if ((vginfo = lvmcache_vginfo_from_vgid(vgid)))
+		ret = !is_system_id_allowed(cmd, vginfo->system_id);
+
+	return ret;
+}
+
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index ed1b916..b968a12 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -194,5 +194,6 @@ int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd);
 void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
 			unsigned *pv_max_name_len, unsigned *vg_max_name_len);
 
+int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
 #endif
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 78844c4..6d9a2f7 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1808,3 +1808,29 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 		_update_changed_pvs_in_udev(cmd, &pvc_before, &pvc_after);
 	}
 }
+
+int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid)
+{
+	daemon_reply reply;
+	struct dm_config_node *top;
+	const char *system_id = NULL;
+	char uuid[64];
+	int ret;
+
+	if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
+		return_0;
+
+	reply = _lvmetad_send("vg_lookup",
+			      "uuid = %s", uuid,
+			      "name = %s", vgname,
+			       NULL);
+
+	if ((top = dm_config_find_node(reply.cft->root, "metadata")))
+		system_id = dm_config_find_str(top, "metadata/system_id", NULL);
+
+	ret = !is_system_id_allowed(cmd, system_id);
+
+	daemon_reply_destroy(reply);
+	return ret;
+}
+
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index af0d562..2c0b134 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -169,6 +169,8 @@ int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handl
 int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg);
 void lvmetad_validate_global_cache(struct cmd_context *cmd, int force);
 
+int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
+
 #  else		/* LVMETAD_SUPPORT */
 
 #    define lvmetad_init(cmd)	do { } while (0)
@@ -197,6 +199,7 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force);
 #    define lvmetad_pvscan_foreign_vgs(cmd, handler)	(0)
 #    define lvmetad_vg_clear_outdated_pvs(vg)           (1)
 #    define lvmetad_validate_global_cache(cmd, force)	do { } while (0)
+#    define lvmetad_vg_is_foreign(cmd, vgname, vgid) (0)
 
 #  endif	/* LVMETAD_SUPPORT */
 


