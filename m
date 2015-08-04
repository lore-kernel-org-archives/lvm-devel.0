From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Aug 2015 08:25:58 +0000 (UTC)
Subject: master - coverity: fix cppcheck warnings
Message-ID: <20150804082558.A7BDB609D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83541123c81b8ff129175963866d9fbd01c21e38
Commit:        83541123c81b8ff129175963866d9fbd01c21e38
Parent:        46e6b2b86e58e081fa40e9cc724f09f03ecf843e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 4 09:33:55 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 4 09:33:55 2015 +0200

coverity: fix cppcheck warnings

/lib/log/log.c:88: warning[invalidScanfArgType_int]: %llu in format string (no. 2) requires 'unsigned long long *' but the argument type is 'long long *'.
daemons/lvmlockd/lvmlockd-core.c:791: error[uninitstring]: Dangerous usage of 'version' (strncpy doesn't always null-terminate it).
---
 daemons/lvmlockd/lvmlockd-core.c |    1 +
 lib/log/log.c                    |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 2f470f5..266339d 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -787,6 +787,7 @@ int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsi
 	char *n, *d1, *d2;
 
 	strncpy(version, args, MAX_ARGS);
+	version[MAX_ARGS] = '\0';
 
 	n = strstr(version, ":");
 	if (n)
diff --git a/lib/log/log.c b/lib/log/log.c
index 9929090..bd11363 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -69,7 +69,7 @@ void init_log_file(const char *log_file, int append)
 	static const char statfile[] = "/proc/self/stat";
 	const char *env;
 	int pid;
-	long long starttime;
+	unsigned long long starttime;
 	FILE *st;
 	int i = 0;
 


