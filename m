From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:49 +0000 (UTC)
Subject: dev-mornfall-activate - config: fix bitfield for section
Message-ID: <20130604192549.A14736115D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f319a61e9c374bd3277deba90216f67fdcb505e9
Commit:        f319a61e9c374bd3277deba90216f67fdcb505e9
Parent:        2ac217d408470dcecb69b83d9cbf7a254747fa5b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 29 12:38:56 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 15:42:44 2013 +0200

config: fix bitfield for section

Since the cfg_def_type_t is used as bitfield in some tests,
use bitshifting to create valid bit sequence.

(in release fix)
---
 lib/config/config.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/config/config.h b/lib/config/config.h
index 7e40420..155d69a 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -34,12 +34,12 @@ struct cmd_context;
 
 /* configuration definition item type (for item's accepted types) */
 typedef enum {
-	CFG_TYPE_SECTION = 0,		/* section */
-	CFG_TYPE_ARRAY = 1,		/* setting */
-	CFG_TYPE_BOOL = 2,		/* setting */
-	CFG_TYPE_INT = 4,		/* setting */
-	CFG_TYPE_FLOAT = 8,		/* setting */
-	CFG_TYPE_STRING = 16		/* setting */
+	CFG_TYPE_SECTION =	1 << 0,	/* section */
+	CFG_TYPE_ARRAY =	1 << 1,	/* setting */
+	CFG_TYPE_BOOL =		1 << 2,	/* setting */
+	CFG_TYPE_INT =		1 << 3,	/* setting */
+	CFG_TYPE_FLOAT =	1 << 4,	/* setting */
+	CFG_TYPE_STRING =	1 << 5,	/* setting */
 } cfg_def_type_t;
 
 /* configuration definition item value (for item's default value) */


