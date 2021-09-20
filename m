From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:55 +0000 (GMT)
Subject: main - gcc-fanalyzer: rewrite _fetch_string
Message-ID: <20210920132955.334913858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=909401226cd7219fa07389bc396723b0c01cd9dd
Commit:        909401226cd7219fa07389bc396723b0c01cd9dd
Parent:        30b188857c51144cd4103850f93287004cc5acaa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 13:51:20 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:18:13 2021 +0200

gcc-fanalyzer: rewrite _fetch_string

Slightly more optimal code, that is less confusing analyzers.
---
 daemons/dmeventd/libdevmapper-event.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 7e09ff07b..237be9fec 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -709,15 +709,11 @@ int dm_event_unregister_handler(const struct dm_event_handler *dmevh)
 static char *_fetch_string(char **src, const int delimiter)
 {
 	char *p, *ret;
+	size_t len = (p = strchr(*src, delimiter)) ?
+		p - *src : strlen(*src);
 
-	if ((p = strchr(*src, delimiter)))
-		*p = 0;
-
-	if ((ret = strdup(*src)))
-		*src += strlen(ret) + 1;
-
-	if (p)
-		*p = delimiter;
+	if ((ret = strndup(*src, len)))
+		*src += len + 1;
 
 	return ret;
 }


