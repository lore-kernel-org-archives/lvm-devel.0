From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:54:43 -0400
Subject: master - cov: missed return value test
Message-ID: <201810151554.w9FFsh7j020438@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5811fa33bbdb2065966489f334ba9fb1174369ca
Commit:        5811fa33bbdb2065966489f334ba9fb1174369ca
Parent:        954b885a08a733308e1117f166d41f4443cd13c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:12:18 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 14:24:28 2018 +0200

cov: missed return value test

Check validity of read.
---
 lib/format_text/format-text.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 9634e47..99945b1 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -466,7 +466,8 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	 */
 	memset(vgnamebuf, 0, sizeof(vgnamebuf));
 
-	dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
+	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf))
+		return_NULL;
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
@@ -1469,7 +1470,8 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, buf);
+	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, buf))
+		return_0;
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))


