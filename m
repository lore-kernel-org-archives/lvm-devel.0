From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:38 +0100
Subject: [PATCH 14/15] Void* arithmetic replaced with char*
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <1c732a837d9f1ed1ddad75dea4c676b44a703170.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c        |    4 ++--
 lib/format_text/text_label.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 8e21732..1f3184e 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1867,7 +1867,7 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 				break;
 			}
 
-			len = write(fd, buf + ptr, msglen - ptr);
+			len = write(fd, (char*)buf + ptr, msglen - ptr);
 
 			if (len <= 0) {
 				if (errno == EINTR)
@@ -2091,7 +2091,7 @@ error:
 	return -1;
 }
 
-void process_message(struct local_client *client, const char *buf, int len,
+void process_message(struct local_client *client, char *buf, int len,
 		     const char *csid)
 {
 	struct clvm_header *inheader;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index e459cde..675dbe8 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -52,7 +52,7 @@ static int _text_write(struct label *label, void *buf)
 
 	strncpy((char *)lh->type, label->type, sizeof(label->type));
 
-	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
+	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 	info = (struct lvmcache_info *) label->info;
 	pvhdr->device_size_xl = xlate64(info->device_size);
 	memcpy(pvhdr->pv_uuid, &info->dev->pvid, sizeof(struct id));
@@ -266,7 +266,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	char *creation_host;
 	struct mda_header *mdah;
 
-	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
+	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 
 	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
 				  FMT_TEXT_ORPHAN_VG_NAME,
-- 
1.7.3.5


