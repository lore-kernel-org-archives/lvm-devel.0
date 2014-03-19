From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:12 +0000 (UTC)
Subject: master - pv_vg_name: do not expose internal orphans to lvm2 users
Message-ID: <20140319000212.92C7260FD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=506091be70b3ebaed02c5d9c1c8fa991f4382182
Commit:        506091be70b3ebaed02c5d9c1c8fa991f4382182
Parent:        5b69bfb6f867944e7831a653f6aa4b17853fbbe5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 18 23:54:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:57:59 2014 +0100

pv_vg_name: do not expose internal orphans to lvm2 users

Check for orphan VG name and return just empty string,
Use internally pv->vg_name if the real orphan name is needed.
---
 WHATS_NEW               |    1 +
 lib/display/display.c   |    2 +-
 lib/metadata/metadata.c |    2 +-
 lib/metadata/pv.c       |    3 ++-
 lib/metadata/pv_manip.c |    2 +-
 5 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index adf446a..2492598 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Do not report internal orphan VG names when reporting pvdisplay/pvscan.
   Fix pvdisplay -c man page referencing KB instead of sectors.
   Skip redundant synchronization calls on local clvmd.
   Use correct PATH_MAX for locking dir path.
diff --git a/lib/display/display.c b/lib/display/display.c
index 66acb88..d2450dd 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -362,7 +362,7 @@ void pvdisplay_colons(const struct physical_volume *pv)
 	}
 
 	log_print("%s:%s:%" PRIu64 ":-1:%" PRIu64 ":%" PRIu64 ":-1:%" PRIu32 ":%u:%u:%u:%s",
-		  pv_dev_name(pv), pv->vg_name, pv->size,
+		  pv_dev_name(pv), pv_vg_name(pv), pv->size,
 		  /* FIXME pv->pv_number, Derive or remove? */
 		  pv->status,	/* FIXME Support old or new format here? */
 		  pv->status & ALLOCATABLE_PV,	/* FIXME remove? */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b5e2ed6..ff14e16 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3947,7 +3947,7 @@ int pv_write(struct cmd_context *cmd __attribute__((unused)),
 	if (!allow_non_orphan &&
 	    (!is_orphan_vg(pv->vg_name) || pv->pe_alloc_count)) {
 		log_error("Assertion failed: can't _pv_write non-orphan PV "
-			  "(in VG %s)", pv->vg_name);
+			  "(in VG %s)", pv_vg_name(pv));
 		return 0;
 	}
 
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 45acef4..774cedb 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -69,7 +69,8 @@ struct device *pv_dev(const struct physical_volume *pv)
 
 const char *pv_vg_name(const struct physical_volume *pv)
 {
-	return pv_field(pv, vg_name);
+	/* Avoid exposing internal orphan names to users */
+	return (!is_orphan(pv)) ? pv_field(pv, vg_name) : "";
 }
 
 const char *pv_dev_name(const struct physical_volume *pv)
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index d0c3b44..cb19be2 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -558,7 +558,7 @@ int pv_resize_single(struct cmd_context *cmd,
 	uint64_t size = 0;
 	int r = 0;
 	const char *pv_name = pv_dev_name(pv);
-	const char *vg_name = pv_vg_name(pv);
+	const char *vg_name = pv->vg_name;
 	struct volume_group *old_vg = vg;
 	int vg_needs_pv_write = 0;
 


