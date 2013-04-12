From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Apr 2013 09:31:23 +0000 (UTC)
Subject: master - cleanup: add gcc attribute for printf parameter
Message-ID: <20130412093123.91FD233FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=698137ec38a3582954543685bffb1e937ab61c34
Commit:        698137ec38a3582954543685bffb1e937ab61c34
Parent:        2e39392daf1de9c61052edc991f30bda352612c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 11 13:49:13 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 12 11:26:31 2013 +0200

cleanup: add gcc attribute for printf parameter

---
 libdm/libdevmapper.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 172976f..b3ba24d 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1341,7 +1341,8 @@ int dm_fclose(FILE *stream);
  */
 int dm_asprintf(char **buf, const char *format, ...)
     __attribute__ ((format(printf, 2, 3)));
-int dm_vasprintf(char **buf, const char *format, va_list ap);
+int dm_vasprintf(char **buf, const char *format, va_list ap)
+    __attribute__ ((format(printf, 2, 0)));
 
 /*
  * create lockfile (pidfile) - create and lock a lock file


