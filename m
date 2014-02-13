From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 13 Feb 2014 15:15:13 +0000 (UTC)
Subject: master - cache: Update man page to reflect need for dm-cache 1.3.0
Message-ID: <20140213151513.7822660F5D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=907641cd3de5c56c7840f22858c30b928429b1bf
Commit:        907641cd3de5c56c7840f22858c30b928429b1bf
Parent:        a060b3b39088d81a8b5d419ae8e2444aa9b9d8ec
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Feb 13 09:13:57 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Feb 13 09:13:57 2014 -0600

cache:  Update man page to reflect need for dm-cache 1.3.0

Update the man page so the user knows that dm-cache 1.3.0 module
is needed.  Also, enforce that in the code and print a warning if
the module is not new enough.
---
 lib/cache_segtype/cache.c |   19 +++++++++++++++++--
 man/lvcreate.8.in         |    4 ++++
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 7557a7d..2217922 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -257,13 +257,28 @@ static int _target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
 				unsigned *attributes __attribute__((unused)))
 {
+	uint32_t maj, min, patchlevel;
 	static int _cache_checked = 0;
 	static int _cache_present = 0;
 
-	if (!_cache_checked)
+	if (!_cache_checked) {
 		_cache_present = target_present(cmd, "cache", 1);
 
-	_cache_checked = 1;
+		if (!target_version("cache", &maj, &min, &patchlevel)) {
+			log_error("Failed to determine version of cache kernel module");
+			return 0;
+		}
+
+		_cache_checked = 1;
+
+		if ((maj < 1) ||
+		    ((maj == 1) && (min < 3))) {
+			log_error("The cache kernel module is version %u.%u.%u."
+				  "  Version 1.3.0+ is required.",
+				  maj, min, patchlevel);
+			return 0;
+		}
+	}
 
 	return _cache_present;
 }
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 800ae8a..029d8da 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -398,6 +398,7 @@ commandline switch alias that will enable their use
 However, this argument must be used when no existing
 commandline switch alias is available for the desired type,
 as is the case with
+.IR cache ,
 .IR error ,
 .IR raid1 ,
 .IR raid4 ,
@@ -406,6 +407,9 @@ as is the case with
 .IR raid10
 or
 .IR zero .
+Note that the cache segment type requires a dm-cache kernel module version
+1.3.0 or greater or a kernel version 3.14 or newer.
+
 .TP
 .BR \-V ", " \-\-virtualsize " " \fIVirtualSize [ \fIbBsSkKmMgGtTpPeE ]
 Creates a sparse device of the given size (in MiB by default) using a snapshot


