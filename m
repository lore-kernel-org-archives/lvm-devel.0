From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Feb 2013 13:06:26 +0000 (UTC)
Subject: master - config: fix config node lookup inside empty sections to not return the section itself
Message-ID: <20130227130626.12A3053C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c81cd26ccb03f3452fedca651c876f2709ff0b8
Commit:        6c81cd26ccb03f3452fedca651c876f2709ff0b8
Parent:        a9d0e25627f751026b2c486cec97c61ecf2af309
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 27 13:47:57 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 27 13:47:57 2013 +0100

config: fix config node lookup inside empty sections to not return the section itself

When a section was empty in a configuration tree (no children - this is
allowed) and we were looking for a config node inside that section, the
_find_config_node function incorrectly returned the section itself if
the node inside that section was not found.

For example the configuration below:

The config:
    abc {
    }

And a function call to get the "def" node inside "abc" section:
     _find_config_node(..., "abc/def")

...returned the "abc" node instead of NULL ("def" not found).

This in turn caused segfaults in the code using lookups in such
a configuration tree as we (correctly) expected that the node
returned was always the one we were looking for or NULL if not
found. But if incorrect node was returned instead, we processed
that as if this was the node we were looking for and so we
processed its value as well. But sections don't have values => segfault.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-config.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 0052e5a..9d9c53d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Fix config node lookup inside empty sections to not return the section itself.
   Extend support for status info of thin pool target.
   Fix segfault for truncated string token in config file after the first '"'.
   Close open dmeventd FIFO file descriptors on exec (FD_CLOEXEC).
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index cc726ae..bd29d32 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -752,12 +752,12 @@ static const struct dm_config_node *_find_config_node(const void *start,
 		if (cn_found && *e)
 			cn = cn_found->child;
 		else
-			break;	/* don't move into the last node */
+			return cn_found;
 
 		path = e;
 	}
 
-	return cn_found;
+	return NULL;
 }
 
 static const struct dm_config_node *_find_first_config_node(const void *start, const char *path)


