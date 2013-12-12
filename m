From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:34 +0000 (UTC)
Subject: master - cleanup: add missing backtrace in fail path
Message-ID: <20131212124334.B439F6024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9fcbe3c6f074443248922b61441bb2b37253a59c
Commit:        9fcbe3c6f074443248922b61441bb2b37253a59c
Parent:        fe21b02fabe1dddeb45c4cfd0be475846dd0f906
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 20:49:53 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:29:59 2013 +0100

cleanup: add missing backtrace in fail path

---
 lib/label/label.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index e083150..25e5f2c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -280,7 +280,7 @@ int label_read(struct device *dev, struct label **result,
 	}
 
 	if (!(l = _find_labeller(dev, buf, &sector, scan_sector)))
-		goto out;
+		goto_out;
 
 	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result) {
 		(*result)->dev = dev;


