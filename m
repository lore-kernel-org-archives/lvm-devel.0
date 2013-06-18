From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Jun 2013 20:14:01 +0000 (UTC)
Subject: master - vgcfgrestore: fix crash on restore of wrong vgname
Message-ID: <20130618201401.4718160ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25629688643958e12859af0d53e818b8b111b4a9
Commit:        25629688643958e12859af0d53e818b8b111b4a9
Parent:        1acad23d68b6b82a297fb4106f016ae7a15fcf1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 18 21:50:29 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 18 22:11:21 2013 +0200

vgcfgrestore: fix crash on restore of wrong vgname

When vgname has not existed in metadata, it has crashed on double free
in format_instance destroy() -  since VG was created, used FID and was
released - which also released FID, so further use was accessing bad
memory.

Fix it for this code path before release_vg() so FID will exists
when _vg_read_file_name() returns NULL.
---
 WHATS_NEW                       |    1 +
 lib/format_text/format-text.c   |    1 +
 test/shell/vgcfgbackup-usage.sh |    3 +++
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 97e3ebf..1eb440f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix vgcfgrestore crash when specified incorrect vg name.
   Refine lvm.conf and man page documentation for autoactivation feature.
   Add support for thin volumes in vgsplit.
   Also filter partitions on mpath components if multipath_component_detection=1.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 1a16134..3157252 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -857,6 +857,7 @@ static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 	 * check that it contains the correct volume group.
 	 */
 	if (vgname && strcmp(vgname, vg->name)) {
+		fid->ref_count++; /* Preserve FID after vg release */
 		release_vg(vg);
 		log_error("'%s' does not contain volume group '%s'.",
 			  read_path, vgname);
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index c8245b0..7a1e530 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -38,6 +38,9 @@ vgcfgbackup -f "$(pwd)/backup.$$" $vg
 sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
 pvcreate -ff -y --norestorefile -u $pv1_uuid "$dev1"
 pvcreate -ff -y --norestorefile -u $pv2_uuid "$dev2"
+
+# Try to recover nonexisting vgname
+not vgcfgrestore -f "$(pwd)/backup.$$1" ${vg}_nonexistent
 vgcfgrestore -f "$(pwd)/backup.$$1" $vg
 vgremove -ff $vg
 


