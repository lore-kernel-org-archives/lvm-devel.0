From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:30 +0000 (UTC)
Subject: master - cleanup: use const format
Message-ID: <20131122200930.2718060E20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8f72c0f2c41fa76bdd3f4c0d73cf31dc9ce9b88
Commit:        b8f72c0f2c41fa76bdd3f4c0d73cf31dc9ce9b88
Parent:        62db5c1e48467ef846432652dd1058eb85c0bcbd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 20:43:30 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:56 2013 +0100

cleanup: use const format

---
 lib/label/label.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.h b/lib/label/label.h
index 103e799..253e1e8 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -88,7 +88,7 @@ struct label_ops {
 
 struct labeller {
 	struct label_ops *ops;
-	struct format_type *fmt;
+	const struct format_type *fmt;
 };
 
 int label_init(void);


