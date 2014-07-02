From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:46 +0000 (UTC)
Subject: master - display: add display_lvname
Message-ID: <20140702084846.3F8E061054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e21d0eb90e9a842ca5fd4d09c076f5fb894ba6ca
Commit:        e21d0eb90e9a842ca5fd4d09c076f5fb894ba6ca
Parent:        6f6900d457afdf8533968f6cd639d4b14779ad51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 2 00:01:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:42 2014 +0200

display: add display_lvname

Add simple function to print vg/lv name.
Useful i.e. in error messages.
---
 lib/display/display.c |    9 +++++++++
 lib/display/display.h |    2 ++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 9780f10..fd785ed 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -93,6 +93,15 @@ const char *get_percent_string(percent_type_t def)
 	return _percent_types[def];
 }
 
+const char *display_lvname(const struct logical_volume *lv)
+{
+	char buf[NAME_LEN * 2 + 2];
+
+	(void) snprintf(buf, sizeof(buf), "%s/%s", lv->vg->name, lv->name);
+
+	return dm_pool_strdup(lv->vg->cmd->mem, buf) ? : lv->name; /* at least LV name... */
+}
+
 #define BASE_UNKNOWN 0
 #define BASE_SHARED 1
 #define BASE_1024 8
diff --git a/lib/display/display.h b/lib/display/display.h
index d5c0efa..cc5654b 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -22,6 +22,8 @@
 
 #include <stdint.h>
 
+const char *display_lvname(const struct logical_volume *lv);
+
 /* Specify size in KB */
 const char *display_size(const struct cmd_context *cmd, uint64_t size);
 const char *display_size_long(const struct cmd_context *cmd, uint64_t size);


