From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:34:17 +0100
Subject: [PATCH 8/8] Few more files filtered from memory locking
In-Reply-To: <cover.1300829383.git.zkabelac@redhat.com>
References: <cover.1300829383.git.zkabelac@redhat.com>
Message-ID: <c6f8b6bffa5113cf4595b649f6c4b0a1a8eb5f55.1300829384.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mm/memlock.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 0e8f585..363b724 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -89,9 +89,11 @@ static const char * const _ignore_maps[] = {
 /* default blacklist for maps */
 static const char * const _blacklist_maps[] = {
     "locale/locale-archive",
+    "/LC_MESSAGES/",
     "gconv/gconv-modules.cache",
     "/libreadline.so.",	/* not using readline during mlock */
     "/libncurses.so.",	/* not using readline during mlock */
+    "/libtinfo.so.",	/* not using readline during mlock */
     "/libdl-",		/* not using dlopen,dlsym during mlock */
     /* "/libdevmapper-event.so" */
 };
-- 
1.7.4.1


