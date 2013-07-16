From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 16 Jul 2013 13:18:47 +0000 (UTC)
Subject: master - config_settings: add comment about possible types
Message-ID: <20130716131847.1B9526107C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b73fbf8f4a225262b2c1d42978aea015af941a50
Commit:        b73fbf8f4a225262b2c1d42978aea015af941a50
Parent:        63d09b75f8e9a8790124f1ee0e2349a94e7a718d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 16 15:18:40 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 16 15:18:40 2013 +0200

config_settings: add comment about possible types

---
 lib/config/config_settings.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 4d124c8..16a9437 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -32,7 +32,11 @@
  * 				CFG_ADVANCED - this node belongs to advanced config set
  * 				CFG_UNSUPPORTED - this node belongs to unsupported config set
  * 				CFG_PROFILABLE - this node is customizable by a profile
- * type:		allowed type for the value of simple configuation setting
+ * type:		allowed type for the value of simple configuation setting, one of:
+ * 				CFG_TYPE_BOOL
+ * 				CFG_TYPE_INT
+ * 				CFG_TYPE_FLOAT
+ * 				CFG_TYPE_STRING
  * types:		allowed types for the values of array configuration setting
  * 			(use logical "OR" to define more than one allowed type,
  * 			 e.g. CFG_TYPE_STRING | CFG_TYPE_INT)


