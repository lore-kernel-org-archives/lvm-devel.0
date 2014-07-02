From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:48 +0000 (UTC)
Subject: master - cleanup: libdm simplier error comparation
Message-ID: <20140702084848.4E16D61054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=748af97afc30d65a9b89d877fdbd2e12ea8fb8e3
Commit:        748af97afc30d65a9b89d877fdbd2e12ea8fb8e3
Parent:        e21d0eb90e9a842ca5fd4d09c076f5fb894ba6ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 2 00:00:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:42 2014 +0200

cleanup: libdm simplier error comparation

When testing return value from snprintf
use simplier form '>=' instead of  '+1 >'.
---
 libdm/libdm-string.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 8ad479c..bc41b70 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -122,7 +122,7 @@ int dm_snprintf(char *buf, size_t bufsize, const char *format, ...)
 	n = vsnprintf(buf, bufsize, format, ap);
 	va_end(ap);
 
-	if (n < 0 || ((unsigned) n + 1 > bufsize))
+	if (n < 0 || ((unsigned) n >= bufsize))
 		return -1;
 
 	return n;


