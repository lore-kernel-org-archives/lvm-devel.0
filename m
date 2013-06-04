From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:29 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: test for -1 value for lseek error
Message-ID: <20130604192729.AA08760DCA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39705ed20123d394f1f0d122704855ec783973da
Commit:        39705ed20123d394f1f0d122704855ec783973da
Parent:        56779c32c500426db33d0e6032160ef4f5e0bbcc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 12:38:09 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:26:42 2013 +0200

cleanup: test for -1 value for lseek error

Error is defined as -1.
Yet it seems we are unable to seek to 0 for devices > 8Exabytes.
---
 lib/device/dev-io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index bb50ae4..34e3064 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -83,7 +83,7 @@ static int _io(struct device_area *where, char *buffer, int should_write)
 		return 0;
 	}
 
-	if (lseek(fd, (off_t) where->start, SEEK_SET) < 0) {
+	if (lseek(fd, (off_t) where->start, SEEK_SET) == (off_t) -1) {
 		log_error("%s: lseek %" PRIu64 " failed: %s",
 			  dev_name(where->dev), (uint64_t) where->start,
 			  strerror(errno));


