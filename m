From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 29 Aug 2014 11:12:28 +0000 (UTC)
Subject: master - libdm: revert incorrect path length size for sscanf
Message-ID: <20140829111228.9F93760FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93e9b3a1d142b3fcef3866599f8e395636a25ddb
Commit:        93e9b3a1d142b3fcef3866599f8e395636a25ddb
Parent:        2faf416e0ed639b453c4ccf0d7f6f0217b644d5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 29 11:52:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 29 13:10:18 2014 +0200

libdm: revert incorrect path length size for sscanf

Commit 94786a3bbf0b68883a2618c9bc25fc88e367f9f8 introduced
another bug - since sscanf needs extra 1 byte for \0.

Since there is no easy way to do a macro evaluation for (PATH_MAX-1)
and string concatation of this number to get resulting (%4095s) - let's
go with easiest path and restore extra byte for 0.

Other option would be to prepare sscanf parsing string in runtime.

But lets resolve it when we look at PATH_MAX handling later...
---
 libdm/libdm-common.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index bfa60a2..bd51645 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1649,8 +1649,8 @@ static void _unmangle_mountinfo_string(const char *src, char *buf)
 /* Parse one line of mountinfo and unmangled target line */
 static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min, char *buf)
 {
-	char root[PATH_MAX];
-	char target[PATH_MAX];
+	char root[PATH_MAX + 1]; /* sscanf needs extra '\0' */
+	char target[PATH_MAX + 1];
 
 	/* TODO: maybe detect availability of  %ms  glib support ? */
 	if (sscanf(line, "%*u %*u %u:%u %" DM_TO_STRING(PATH_MAX)


