From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Feb 2017 12:38:07 +0000 (UTC)
Subject: master - commands: some more dm wrappers
Message-ID: <20170217123807.A0AEB60FCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00f299b93265ea2a9a930f26c68d887b8708da5a
Commit:        00f299b93265ea2a9a930f26c68d887b8708da5a
Parent:        238a79aac41fcba65e7ac9c75f05275ab5915de6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 13:36:57 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 13:36:57 2017 +0100

commands: some more dm wrappers

As man-generator is not liked with libdm as of now - some more wrappers.
---
 tools/command.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index a4139f0..1abac20 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -48,6 +48,18 @@ do { \
 #define dm_malloc malloc
 #define dm_free free
 #define dm_strdup strdup
+#define dm_snprintf snprintf
+
+static int dm_strncpy(char *dest, const char *src, size_t n)
+{
+	if (memccpy(dest, src, 0, n))
+		return 1;
+
+	if (n > 0)
+		dest[n - 1] = '\0';
+
+	return 0;
+}
 
 /* needed to include args.h */
 #define ARG_COUNTABLE 0x00000001


