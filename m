From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:54:58 +0000 (UTC)
Subject: master - asprintf: fix test for error result
Message-ID: <20140418145458.3BB0060758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e05e1cf6cb9323cc48ff38adc781f22a3c7d172
Commit:        0e05e1cf6cb9323cc48ff38adc781f22a3c7d172
Parent:        0b6d6bfb772f8320866e938ecba9894dc2d1cd7e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 10:05:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:47 2014 +0200

asprintf: fix test for error result

On error this function returns -1. Since the functions however
do not propagate error upward, it's rather cleanup change.
---
 lib/cache/lvmetad.c |    2 +-
 tools/pvscan.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index c1eb4aa..d0c4a4d 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -124,7 +124,7 @@ void lvmetad_set_token(const struct dm_config_value *filter)
 		filter = filter->next;
 	}
 
-	if (!dm_asprintf(&_lvmetad_token, "filter:%u", ft))
+	if (dm_asprintf(&_lvmetad_token, "filter:%u", ft) < 0)
 		log_warn("WARNING: Failed to set lvmetad token. Out of memory?");
 }
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 4121c7b..ac43295 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -166,7 +166,7 @@ static int _clear_dev_from_lvmetad_cache(dev_t devno, int32_t major, int32_t min
 {
 	char *buf;
 
-	if (!dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor))
+	if (dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor) < 0)
 		stack;
 	if (!lvmetad_pv_gone(devno, buf ? : "", handler)) {
 		dm_free(buf);


