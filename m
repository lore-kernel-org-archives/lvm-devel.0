From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:42 +0000 (UTC)
Subject: master - config: use int for type
Message-ID: <20131128114842.CD36E60F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc9d4dd11f2331e056f0b56274877c8a4b4b1570
Commit:        fc9d4dd11f2331e056f0b56274877c8a4b4b1570
Parent:        79991aa7699587b40946d029787b38ae67405336
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 25 13:44:46 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:42:44 2013 +0100

config: use int for type

Since the type is used for 'or' operation of enumerated bit fields,
it doesn't not have type cfg_def_type_t - use proper int type for
bitmask.
---
 lib/config/config.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.h b/lib/config/config.h
index f57757b..0769c40 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -88,7 +88,7 @@ typedef struct cfg_def_item {
 	int id;				/* ID of this item */
 	int parent;			/* ID of parent item */
 	const char *name;		/* name of the item in configuration tree */
-	cfg_def_type_t type;		/* configuration item type */
+	int type;			/* configuration item type (bits of cfg_def_type_t) */
 	cfg_def_value_t default_value;	/* default value (only for settings) */
 	uint16_t flags;			/* configuration item definition flags */
 	uint16_t since_version;		/* version this item appeared in */


