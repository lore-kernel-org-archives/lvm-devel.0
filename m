From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 30 Jul 2012 09:19:59 +0000 (UTC)
Subject: master - lvmetad: Implement --test (fixes #832033).
Message-ID: <20120730091959.5F2DB5763@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6997943f2221729449469d1a7963055991c2361d
Commit:        6997943f2221729449469d1a7963055991c2361d
Parent:        4dbf872a9fc0aac34f73fd8214cc75846554e501
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Mon Jul 30 10:44:11 2012 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Mon Jul 30 11:19:02 2012 +0200

lvmetad: Implement --test (fixes #832033).

---
 WHATS_NEW           |    1 +
 lib/cache/lvmetad.c |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a09e076..cb3ed90 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Respect --test also when using lvmetad.
   No longer capitalise first LV attribute char for invalid snapshots.
   Allow vgextend to add PVs to a VG that is missing PVs.
   Recognise Micron PCIe SSDs in filter and move array out to device-types.h.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 6ef30db..3384ec4 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -275,7 +275,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 	if (!vg)
 		return 0;
 
-	if (!_using_lvmetad)
+	if (!_using_lvmetad || test_mode())
 		return 1; /* fake it */
 
 	/* TODO. This is not entirely correct, since export_vg_to_buffer
@@ -335,7 +335,7 @@ int lvmetad_vg_remove(struct volume_group *vg)
 	daemon_reply reply;
 	int result;
 
-	if (!_using_lvmetad)
+	if (!_using_lvmetad || test_mode())
 		return 1; /* just fake it */
 
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
@@ -547,7 +547,7 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	const char *status;
 	int result;
 
-	if (!_using_lvmetad)
+	if (!_using_lvmetad || test_mode())
 		return 1;
 
 	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
@@ -629,7 +629,7 @@ int lvmetad_pv_gone(dev_t device, const char *pv_name, activation_handler handle
 	int result;
 	int found;
 
-	if (!_using_lvmetad)
+	if (!_using_lvmetad || test_mode())
 		return 1;
 
 	/*


