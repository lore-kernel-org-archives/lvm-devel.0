From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:15 +0000 (UTC)
Subject: master - libdaemonclient: Use dm_{malloc, free} in place of {malloc, free}.
Message-ID: <20120926175615.10064A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a2a1a7456be3adbfe5a3d034e122ea5e7cae6a0
Commit:        7a2a1a7456be3adbfe5a3d034e122ea5e7cae6a0
Parent:        3124840185f9dc3e842c812e490a6f61ae040a2b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 26 13:10:53 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

libdaemonclient: Use dm_{malloc,free} in place of {malloc,free}.

---
 libdaemon/client/daemon-shared.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/libdaemon/client/daemon-shared.c b/libdaemon/client/daemon-shared.c
index 6a1cf05..e6f17a0 100644
--- a/libdaemon/client/daemon-shared.c
+++ b/libdaemon/client/daemon-shared.c
@@ -14,7 +14,6 @@
 
 #include <errno.h>
 #include <stdio.h>
-#include <malloc.h>
 #include <string.h>
 #include <unistd.h>
 
@@ -34,7 +33,7 @@ int read_buffer(int fd, char **buffer) {
 	int bytes = 0;
 	int buffersize = 32;
 	char *new;
-	*buffer = malloc(buffersize + 1);
+	*buffer = dm_malloc(buffersize + 1);
 
 	while (1) {
 		int result = read(fd, (*buffer) + bytes, buffersize - bytes);
@@ -62,7 +61,7 @@ int read_buffer(int fd, char **buffer) {
 	}
 	return 1;
 fail:
-	free(*buffer);
+	dm_free(*buffer);
 	*buffer = NULL;
 	return 0;
 }


