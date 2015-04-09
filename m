From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  9 Apr 2015 20:28:44 +0000 (UTC)
Subject: master - cache: Set correct vgid when changing PV header.
Message-ID: <20150409202844.98A3260D63@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9d48bae2f942f29746f95ec35609e36ead6cea2
Commit:        a9d48bae2f942f29746f95ec35609e36ead6cea2
Parent:        249d4a921ca300c746588c7683484aa75442771b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 9 21:13:55 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 9 21:13:55 2015 +0100

cache: Set correct vgid when changing PV header.

pv_write is called both to write orphans and to rewrite PV headers
of PVs in VGs.  It needs to select the correct VG id so that the
internal cache state gets updated correctly.

It only affected commands that involved further steps after
the pv_write and was often masked because the metadata would
be re-read off disk and correct itself.

"Incorrect metadata area header checksum" warnings appeared.

Example:
  Create vg1 containing dev1, dev2 and dev3.
  Hide dev1 and dev2 from the system.
  Fix up vg1 with vgreduce --removemissing.
  Bring back dev1 and dev2.
  In a single operation reinstate dev1 and dev2 into vg1 (vgextend).
Done as separate operations (automatically fix-up dev1 and dev2 as orphans,
then vgextend) it worked, but done all in one go the internal cache got
corrupted and warnings about checksum errors appeared.
---
 WHATS_NEW                     |    1 +
 lib/cache/lvmcache.c          |    1 +
 lib/format_text/format-text.c |    5 +++--
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6f43437..1870801 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Set correct vgid when updating cache when writing PV metadata.
   More efficient clvmd singlenode locking emulation.
   Don't skip invalidation of cached orphans if vg write lck is held (2.02.118).
   Log relevant PV tags when using cling allocation.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 27b4292..6f8c950 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1544,6 +1544,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 		.vgstatus = vgstatus,
 	};
 
+	/* N.B. vgid is not NUL-terminated when called from _text_pv_write */
 	if (vgid)
 		strncpy((char *)&vgsummary.vgid, vgid, sizeof(vgsummary.vgid));
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index bdac7f9..8e5578c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1318,7 +1318,7 @@ static int _write_single_mda(struct metadata_area *mda, void *baton)
 	return 1;
 }
 
-/* Only for orphans */
+/* Only for orphans - FIXME That's not true any more */
 static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv)
 {
 	struct format_instance *fid = pv->fid;
@@ -1332,7 +1332,8 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 
 	/* Add a new cache entry with PV info or update existing one. */
 	if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,
-				  pv->dev, pv->vg_name, NULL, 0)))
+				  pv->dev, pv->vg_name,
+				  is_orphan_vg(pv->vg_name) ? pv->vg_name : pv->vg ? &pv->vg->id : NULL, 0)))
 		return_0;
 
 	label = lvmcache_get_label(info);


