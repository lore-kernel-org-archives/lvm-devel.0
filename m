From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:03:02 +0000 (UTC)
Subject: master - cleanup: update comments
Message-ID: <20140408090302.0E76660D76@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1ae39e2ef9e4b31faf655f321ada0b4a3049426
Commit:        c1ae39e2ef9e4b31faf655f321ada0b4a3049426
Parent:        d4d8060ff42ed25886eda71122513873a25a3f12
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:19:26 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:16 2014 +0200

cleanup: update comments

Fix cut&paste comments
---
 lib/mm/memlock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index c08b0eb..e626a6a 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -93,8 +93,8 @@ static const char * const _blacklist_maps[] = {
     "/LC_MESSAGES/",
     "gconv/gconv-modules.cache",
     "/libreadline.so.",	/* not using readline during mlock */
-    "/libncurses.so.",	/* not using readline during mlock */
-    "/libtinfo.so.",	/* not using readline during mlock */
+    "/libncurses.so.",	/* not using ncurses during mlock */
+    "/libtinfo.so.",	/* not using tinfo during mlock */
     "/libdl-",		/* not using dlopen,dlsym during mlock */
     /* "/libdevmapper-event.so" */
 };


