From: David Teigland <teigland@sourceware.org>
Date: Tue, 17 Oct 2017 14:48:47 -0400
Subject: master - lvmlockd: check error for sanlock access to lvmlock LV
Message-ID: <201710171848.v9HImlU5005705@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b319f39d6692a6770493d5f751ebbb9062164fc
Commit:        1b319f39d6692a6770493d5f751ebbb9062164fc
Parent:        146745ad88abc0512650b5b40d00ca587784ca36
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 17 13:45:53 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 17 13:45:53 2017 -0500

lvmlockd: check error for sanlock access to lvmlock LV

When the sanlock daemon does not have permission to access
the lvmlock LV, make the error messages more helpful.
---
 daemons/lvmlockd/lvmlockd-client.h  |    1 +
 daemons/lvmlockd/lvmlockd-sanlock.c |   19 +++++++++++++------
 lib/locking/lvmlockd.c              |    4 ++++
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index 67fcbe3..1d42338 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -48,5 +48,6 @@ static inline void lvmlockd_close(daemon_handle h)
 #define EVGKILLED 217 /* sanlock lost access to leases and VG is killed. */
 #define ELOCKIO   218 /* sanlock io errors during lock op, may be transient. */
 #define EREMOVED  219
+#define EDEVOPEN  220 /* sanlock failed to open lvmlock LV */
 
 #endif	/* _LVM_LVMLOCKD_CLIENT_H */
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index a10d02f..0e81915 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -356,12 +356,19 @@ int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_ar
 	log_debug("sanlock daemon version %08x proto %08x",
 		  daemon_version, daemon_proto);
 
-	align_size = sanlock_align(&disk);
-	if (align_size <= 0) {
-		log_error("S %s init_vg_san bad disk align size %d %s",
-			  ls_name, align_size, disk.path);
-		return -EARGS;
-	}
+	rv = sanlock_align(&disk);
+	if (rv <= 0) {
+		if (rv == -EACCES) {
+			log_error("S %s init_vg_san sanlock error -EACCES: no permission to access %s",
+				  ls_name, disk.path);
+			return -EDEVOPEN;
+		} else {
+			log_error("S %s init_vg_san sanlock error %d trying to get align size of %s",
+				  ls_name, rv, disk.path);
+			return -EARGS;
+		}
+	} else
+		align_size = rv;
 
 	strncpy(ss.name, ls_name, SANLK_NAME_LEN);
 	memcpy(ss.host_id_disk.path, disk.path, SANLK_PATH_LEN);
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 0f2b160..cf2c3d5 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -667,6 +667,10 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	case -EARGS:
 		log_error("VG %s init failed: invalid parameters for sanlock", vg->name);
 		break;
+	case -EDEVOPEN:
+		log_error("VG %s init failed: sanlock cannot open device /dev/mapper/%s-%s", vg->name, vg->name, LOCKD_SANLOCK_LV_NAME);
+		log_error("Check that sanlock has permission to access disks.");
+		break;
 	case -EMANAGER:
 		log_error("VG %s init failed: lock manager sanlock is not running", vg->name);
 		break;


