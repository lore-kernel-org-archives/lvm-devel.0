From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:44:55 -0400
Subject: stable-2.02 - cov: check result of dev_read_bytes
Message-ID: <201906251544.x5PFit8n012592@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=862899cc88e1697211d478de58b2ddc0eaec9cd9
Commit:        862899cc88e1697211d478de58b2ddc0eaec9cd9
Parent:        09aafb61e31c3781530795057c87afaeb53a2bd4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 14:50:05 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:32:44 2019 +0200

cov: check result of dev_read_bytes

---
 lib/format_text/format-text.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b9d85a4..a09c349 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -468,7 +468,12 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	 */
 	memset(vgnamebuf, 0, sizeof(vgnamebuf));
 
-	dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
+	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf)) {
+		log_error("Failed to read metadata location vg %s at %llu",
+			  dev_name(dev_area->dev),
+			  (unsigned long long)dev_area->start + rlocn->offset);
+		return 0;
+	}
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
@@ -1229,7 +1234,12 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, buf);
+	if (!dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, buf)) {
+		log_error("Can't read metadata location on %s at %llu.",
+			  dev_name(dev_area->dev),
+			  (unsigned long long)(dev_area->start + rlocn->offset));
+		return 0;
+	}
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))


