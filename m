From: David Teigland <teigland@sourceware.org>
Date: Tue, 28 Sep 2021 20:24:08 +0000 (GMT)
Subject: main - handle bad metadata text in vg_read path
Message-ID: <20210928202408.8DF523858406@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=939b4bc58719605aa7d348d2b4e0fcf41aad0b17
Commit:        939b4bc58719605aa7d348d2b4e0fcf41aad0b17
Parent:        e3b4c365a4d9fc3f88dcfaca6dff89b924fc4851
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 28 14:58:03 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 28 15:17:43 2021 -0500

handle bad metadata text in vg_read path

Corrupt metadata text (with good mda header) was being handled
in the label_scan phase, but not in the vg_read phase.  This
was sufficient because metadata areas would always be read and
checksummed during label_scan (metadata parsing was skipped
previously as an optimization.)

This changed with the optimization in
commit 61a6f9905e87e650f0bddae83fec6923bb100a57
"metadata: optimize reading metadata copies in scan"

Now, some metadata areas will not be read and checksummed
at all during the label_scan phase, only during the vg_read
phase.  This means that bad metadata text may first be detected
in the vg_read phase.  So, add equivalent bad metadata handling
to the vg_read path to match the label_scan path.
---
 lib/cache/lvmcache.c            | 14 ++++++++++++++
 lib/cache/lvmcache.h            |  2 ++
 lib/format_text/format-text.c   | 18 ++++++++++++++++++
 lib/format_text/import.c        |  5 ++---
 lib/metadata/metadata.c         |  2 +-
 test/shell/metadata-bad-text.sh | 23 ++++++++++++-----------
 6 files changed, 49 insertions(+), 15 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 655f34bd8..7a7634074 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -237,6 +237,20 @@ void lvmcache_save_bad_mda(struct lvmcache_info *info, struct metadata_area *mda
 	dm_list_add(&info->bad_mdas, &mda->list);
 }
 
+void lvmcache_del_save_bad_mda(struct lvmcache_info *info, int mda_num, int bad_mda_flag)
+{
+	struct metadata_area *mda, *mda_safe;
+
+	dm_list_iterate_items_safe(mda, mda_safe, &info->mdas) {
+		if (mda->mda_num == mda_num) {
+			dm_list_del(&mda->list);
+			mda->bad_fields |= bad_mda_flag;
+			lvmcache_save_bad_mda(info, mda);
+			break;
+		}
+	}
+}
+
 void lvmcache_get_bad_mdas(struct cmd_context *cmd,
 			   const char *vgname, const char *vgid,
                            struct dm_list *bad_mda_list)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index d7e10f4f0..9511bb9e9 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -210,6 +210,8 @@ void lvmcache_del_outdated_devs(struct cmd_context *cmd,
 
 void lvmcache_save_bad_mda(struct lvmcache_info *info, struct metadata_area *mda);
 
+void lvmcache_del_save_bad_mda(struct lvmcache_info *info, int mda_num, int bad_mda_flag);
+
 void lvmcache_get_bad_mdas(struct cmd_context *cmd,
                            const char *vgname, const char *vgid,
                            struct dm_list *bad_mda_list);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c880f0eb6..6a4cc98d8 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -465,6 +465,24 @@ static struct volume_group *_vg_read_raw(struct cmd_context *cmd,
 
 	vg = _vg_read_raw_area(cmd, fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, mda_is_primary(mda));
 
+	if (!vg && !*use_previous_vg) {
+		/*
+		 * This condition (corrupt metadata text) is often seen in the
+		 * label_scan()/_text_read() phase, where this code corresponds to
+		 * the lvmcache_save_bad_mda() in _text_read().  In this case we
+		 * have two mda structs to deal with, one in lvmcache from label scan,
+		 * and the mda copy on fid->metadata_areas_in_use.
+		 */
+		struct device *dev = mdac->area.dev;
+		struct lvmcache_info *info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
+		log_warn("WARNING: reading %s mda%d failed to read metadata.", dev_name(dev), mda_is_primary(mda)?1:2);
+		log_warn("WARNING: repair VG metadata on %s with vgck --updatemetadata.", dev_name(dev));
+		/* remove mda from lvmcache, saving it in info->bad_mdas for possible repair with updatemetadata */
+		lvmcache_del_save_bad_mda(info, mda->mda_num, BAD_MDA_TEXT);
+		/* remove mda from fid */
+		fid_remove_mda(fid, mda, NULL, 0, 0);
+	}
+
 	return vg;
 }
 
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index e4e526354..a3735369d 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -157,13 +157,12 @@ struct volume_group *text_read_metadata(struct format_instance *fid,
 		if (!config_file_read_fd(cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
 					 offset2, size2, checksum_fn, checksum,
 					 skip_parse, 1)) {
-			/* FIXME: handle errors */
-			log_error("Couldn't read volume group metadata from %s.", dev_name(dev));
+			log_warn("WARNING: couldn't read volume group metadata from %s.", dev_name(dev));
 			goto out;
 		}
 	} else {
 		if (!config_file_read(cft)) {
-			log_error("Couldn't read volume group metadata from file.");
+			log_warn("WARNING: couldn't read volume group metadata from file.");
 			goto out;
 		}
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b37b91487..9a7d23365 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4798,7 +4798,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * fid->metadata_areas_in_use by create_instance above, and here we
 	 * read VG metadata from each of those mdas.
 	 */
-	dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+	dm_list_iterate_items_safe(mda, mda2, &fid->metadata_areas_in_use) {
 		mda_dev = mda_get_device(mda);
 
 		/* I don't think this can happen */
diff --git a/test/shell/metadata-bad-text.sh b/test/shell/metadata-bad-text.sh
index 9ccfe5f76..038a88485 100644
--- a/test/shell/metadata-bad-text.sh
+++ b/test/shell/metadata-bad-text.sh
@@ -44,7 +44,7 @@ sed 's/flags =/flagx =/' meta1 > meta1.bad
 dd if=meta1.bad of="$dev1"
 
 pvs 2>&1 | tee out
-grep "bad metadata text" out
+grep "Checksum error" out
 
 pvs "$dev1"
 pvs "$dev2"
@@ -58,7 +58,7 @@ lvcreate -l1 $vg
 vgck --updatemetadata $vg
 
 pvs 2>&1 | tee out
-not grep "bad metadata text" out
+not grep "Checksum error" out
 
 pvs "$dev1"
 pvs "$dev2"
@@ -92,7 +92,8 @@ dd if=meta1.bad of="$dev1"
 dd if=meta2.bad of="$dev2"
 
 pvs 2>&1 | tee out
-grep "bad metadata text" out > out2
+# FIXME: find a better test than looking for a specific message
+grep "Checksum error" out > out2
 grep "$dev1" out2
 grep "$dev2" out2
 
@@ -108,7 +109,7 @@ lvcreate -l1 $vg
 vgck --updatemetadata $vg
 
 pvs 2>&1 | tee out
-not grep "bad metadata text" out
+not grep "Checksum error" out
 
 pvs "$dev1"
 pvs "$dev2"
@@ -149,7 +150,7 @@ dd if=meta2.bad of="$dev2"
 dd if=meta3.bad of="$dev3"
 
 pvs 2>&1 | tee out
-grep "bad metadata text" out > out2
+grep "Checksum error" out > out2
 grep "$dev1" out2
 grep "$dev2" out2
 grep "$dev3" out2
@@ -166,7 +167,7 @@ lvcreate -l1 $vg
 vgck --updatemetadata $vg
 
 pvs 2>&1 | tee out
-not grep "bad metadata text" out
+not grep "Checksum error" out
 
 pvs "$dev1"
 pvs "$dev2"
@@ -197,7 +198,7 @@ sed 's/READ/RRRR/' meta1 > meta1.bad
 dd if=meta1.bad of="$dev1"
 
 pvs 2>&1 | tee out
-grep "bad metadata text" out > out2
+grep "Checksum error" out > out2
 grep "$dev1" out2
 
 # We can still use the VG with other available
@@ -224,7 +225,7 @@ aux enable_dev "$dev2"
 # Both old and bad metadata are reported.
 pvs 2>&1 | tee out
 grep "ignoring metadata seqno" out
-grep "bad metadata text" out
+grep "Checksum error" out
 pvs "$dev1"
 pvs "$dev2"
 pvs "$dev3"
@@ -238,7 +239,7 @@ vgck --updatemetadata $vg
 
 pvs 2>&1 | tee out
 not grep "ignoring metadata seqno" out
-not grep "bad metadata text" out
+not grep "Checksum error" out
 pvs "$dev1"
 pvs "$dev2"
 pvs "$dev3"
@@ -282,7 +283,7 @@ dd if=meta1.bad of="$dev1"
 dd if=meta2.bad of="$dev2"
 
 pvs 2>&1 | tee out
-grep "bad metadata text" out > out2
+grep "Checksum error" out > out2
 grep "$dev1" out2
 grep "$dev2" out2
 
@@ -319,7 +320,7 @@ not ls "$RUNDIR/lvm/vgs_online/$vg"
 vgck --updatemetadata $vg
 
 pvs 2>&1 | tee out
-not grep "bad metadata text" out
+not grep "Checksum error" out
 
 pvs "$dev1"
 pvs "$dev2"


