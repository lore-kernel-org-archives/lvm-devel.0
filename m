From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:18 +0200
Subject: [PATCH 14/20] label: Track a device pointer in struct label.
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-14-git-send-email-prockai@redhat.com>
	(sfid-20130729_211928_819210_D6C539B2)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/label/label.c | 4 +++-
 lib/label/label.h | 1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index cff6464..e083150 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -282,8 +282,10 @@ int label_read(struct device *dev, struct label **result,
 	if (!(l = _find_labeller(dev, buf, &sector, scan_sector)))
 		goto out;
 
-	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result)
+	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result) {
+		(*result)->dev = dev;
 		(*result)->sector = sector;
+	}
 
       out:
 	if (!dev_close(dev))
diff --git a/lib/label/label.h b/lib/label/label.h
index 8dc49ff..103e799 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -42,6 +42,7 @@ struct label {
 	char type[8];
 	uint64_t sector;
 	struct labeller *labeller;
+	struct device *dev;
 	void *info;
 };
 
-- 
1.8.2


