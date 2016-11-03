From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 11:43:23 +0000 (UTC)
Subject: master - cleanup: drop unused attribute
Message-ID: <20161103114323.DAB2C60DB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1db4b81d5a1e7c85ab5928c9f6a62ec9565885df
Commit:        1db4b81d5a1e7c85ab5928c9f6a62ec9565885df
Parent:        4b4d19e3aa1da061fed35edb979e1ca2a29fb7ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 2 10:55:19 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 12:43:09 2016 +0100

cleanup: drop unused attribute

In this function we pass args through so make the function
header look the same as with _default_log().
---
 libdm/libdm-common.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 5deb555..17f55ab 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -137,8 +137,7 @@ static void _default_log_line(int level,
 
 __attribute__((format(printf, 5, 6)))
 static void _default_log_with_errno(int level,
-	    const char *file __attribute__((unused)),
-	    int line __attribute__((unused)), int dm_errno_or_class,
+	    const char *file, int line, int dm_errno_or_class,
 	    const char *f, ...)
 {
 	va_list ap;


