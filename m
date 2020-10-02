From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:59 +0000 (GMT)
Subject: master - debug: drop FD from error message
Message-ID: <20201002202759.0D4E1398E4B8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1af80c81c2c196ccc2e2a3f45e56cd1abc0dd45
Commit:        e1af80c81c2c196ccc2e2a3f45e56cd1abc0dd45
Parent:        dd8212365df356e561fe72e73be804f7313148c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 11:10:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 21:04:16 2020 +0200

debug: drop FD from error message

Since now the error path already has device close and set -1,
there is not much in printing this info - actually shouldn't be
there at all..
---
 lib/format_text/format-text.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e44871226..0de881b67 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -277,7 +277,7 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 	dev_set_last_byte(dev, start_byte + MDA_HEADER_SIZE);
 
 	if (!dev_write_bytes(dev, start_byte, MDA_HEADER_SIZE, mdah)) {
-		log_error("Failed to write mda header to %s fd %d", dev_name(dev), dev->bcache_fd);
+		log_error("Failed to write mda header to %s.", dev_name(dev));
 		return 0;
 	}
 	dev_unset_last_byte(dev);
@@ -972,7 +972,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			   (unsigned long long)write2_size);
 
 	if (!dev_write_bytes(mdac->area.dev, write1_start, (size_t)write1_size, write_buf)) {
-		log_error("Failed to write metadata to %s fd %d", devname, mdac->area.dev->bcache_fd);
+		log_error("Failed to write metadata to %s.", devname);
 		goto out;
 	}
 
@@ -984,7 +984,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 		if (!dev_write_bytes(mdac->area.dev, write2_start, write2_size,
 				     write_buf + new_size - new_wrap)) {
-			log_error("Failed to write metadata wrap to %s fd %d", devname, mdac->area.dev->bcache_fd);
+			log_error("Failed to write metadata wrap to %s", devname);
 			goto out;
 		}
 	}


