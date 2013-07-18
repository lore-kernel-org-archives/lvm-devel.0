From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:33 +0000 (UTC)
Subject: master - metadata: add is_change_activating
Message-ID: <20130718162633.45E7C6073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5dfe4bec2c5eb24559f650da47678ad1de527b6
Commit:        b5dfe4bec2c5eb24559f650da47678ad1de527b6
Parent:        e8fc77bd6d8986c5c289d4deaaab0120d646b077
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 18 16:17:23 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:42 2013 +0200

metadata: add is_change_activating

Add simple inline function to check, whether the change is activating.
(better then macro since we get type checking).
---
 lib/metadata/metadata-exported.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b571847..f667139 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -689,6 +689,12 @@ typedef enum activation_change {
 	CHANGE_AAY = 5  /* automatic activation */
 } activation_change_t;
 
+/* Returns true, when change activates device */
+static inline int is_change_activating(activation_change_t change)
+{
+        return ((change != CHANGE_AN) && (change != CHANGE_ALN));
+}
+
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */


