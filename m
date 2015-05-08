From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:32 +0000 (UTC)
Subject: master - pvcreate: fix test for wiping status
Message-ID: <20150508131632.3E49C60759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cea1c1bd9d432a7544713c49620e4cc2ab56ee6
Commit:        2cea1c1bd9d432a7544713c49620e4cc2ab56ee6
Parent:        bf5cb4af8e7722a4b29bff0caf23a1c5a167a360
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 12:10:20 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 13:36:39 2015 +0200

pvcreate: fix test for wiping status

Commit ed420fb6917162ed17af69a9a0ec9ae26e61e209 changed
paramet wiped to be a pointer, but missed to switch
to test pointer dereferenced value and instead always
checked 'pointer'.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 87ce45c..3b22ec5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Fix check if pvcreate wiped device (2.02.117).
   Fix storing of vgid when caching metadata (2.02.118).
   Fix recursive lvm-config man page. (2.02.119)
   Refactor polldaemon interfaces to poll every operation by VG/LV couple
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a1a31eb..2a5be7d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1504,7 +1504,7 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 		goto out;
 	}
 
-	if (wiped)
+	if (*wiped)
 		filter_refresh_needed = scan_needed = 1;
 
 	if (sigint_caught())


