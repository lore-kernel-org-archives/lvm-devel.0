From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:30:53 +0100
Subject: [PATCH 07/16] Void* arithmetic replaced with char*
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <3448a98d55d1b7cc40b128e0d1ef1d1f05dc2640.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c        |    2 +-
 lib/format_text/text_label.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 8e21732..3726324 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1867,7 +1867,7 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 				break;
 			}
 
-			len = write(fd, buf + ptr, msglen - ptr);
+			len = write(fd, (char*)buf + ptr, msglen - ptr);
 
 			if (len <= 0) {
 				if (errno == EINTR)
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index ce250e6..b12250f 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -52,7 +52,7 @@ static int _text_write(struct label *label, void *buf)
 
 	strncpy((char *)lh->type, label->type, sizeof(label->type));
 
-	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
+	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 	info = (struct lvmcache_info *) label->info;
 	pvhdr->device_size_xl = xlate64(info->device_size);
 	memcpy(pvhdr->pv_uuid, &info->dev->pvid, sizeof(struct id));
@@ -268,7 +268,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	char *creation_host;
 	struct mda_header *mdah;
 
-	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
+	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 
 	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
 				  text_orphan_vg_name, text_orphan_vg_name, 0)))
-- 
1.7.4


