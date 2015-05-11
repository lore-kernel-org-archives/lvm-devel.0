From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 11 May 2015 09:08:08 +0000 (UTC)
Subject: master - metadata: use log_debug_metadata instead of general log_debug for BA debug messages
Message-ID: <20150511090808.18C4060E72@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18066949282613fad1981804297b3bba01bcc3bd
Commit:        18066949282613fad1981804297b3bba01bcc3bd
Parent:        e3ccf980236a842cfc13be11726be651b127afb0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 11 11:07:53 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 11 11:07:53 2015 +0200

metadata: use log_debug_metadata instead of general log_debug for BA debug messages

---
 lib/format_text/import_vsn1.c |    2 +-
 lib/format_text/text_label.c  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 5e8e049..3030bad 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -251,7 +251,7 @@ static int _read_pv(struct format_instance *fid,
 	_read_uint64(pvn, "ba_start", &ba_start);
 	_read_uint64(pvn, "ba_size", &size);
 	if (ba_start && size) {
-		log_debug("Found bootloader area specification for PV %s "
+		log_debug_metadata("Found bootloader area specification for PV %s "
 			  "in metadata: ba_start=%" PRIu64 ", ba_size=%" PRIu64 ".",
 			  pv_dev_name(pv), ba_start, size);
 		pv->ba_start = ba_start;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 599be41..4ad2ccd 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -418,8 +418,8 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	if (!(ext_version = xlate32(pvhdr_ext->version)))
 		goto out;
 
-	log_debug("%s: PV header extension version %" PRIu32 " found",
-		  dev_name(dev), ext_version);
+	log_debug_metadata("%s: PV header extension version %" PRIu32 " found",
+			   dev_name(dev), ext_version);
 
 	/* Bootloader areas */
 	dlocn_xl = pvhdr_ext->bootloader_areas_xl;


