From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:54 +0000 (UTC)
Subject: master - label: Track a device pointer in struct label.
Message-ID: <20131117222654.84428611C5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc633c84cfc82e91e83393271a068a662e7d4678
Commit:        cc633c84cfc82e91e83393271a068a662e7d4678
Parent:        dc3a0711454938e1a6264b7e3bf24a6dd1ac7e9f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 29 19:03:20 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

label: Track a device pointer in struct label.

---
 lib/label/label.c |    4 +++-
 lib/label/label.h |    1 +
 2 files changed, 4 insertions(+), 1 deletions(-)

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
 


