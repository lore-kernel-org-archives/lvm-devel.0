From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:48 -0400
Subject: master - coverity: make use of defined variable
Message-ID: <201803172234.w2HMYmgH011208@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2d0eefa770468e8cdd126ce09a251bdf804884e
Commit:        f2d0eefa770468e8cdd126ce09a251bdf804884e
Parent:        26c58027fb9df068c927abe61336ff6364fe3d0e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 13:56:44 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

coverity: make use of defined variable

Since we declare 'r', let's use the value for something.
---
 lib/device/dev-io.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index cb3a234..1d16a66 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -649,14 +649,10 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 	/* ... then we write */
 	devbuf->write = 1;
 	if (!(r = _io(devbuf, 0)))
-		goto_bad;
-
-	_release_devbuf(devbuf);
-	return 1;
-
+		stack;
 bad:
 	_release_devbuf(devbuf);
-	return 0;
+	return r;
 }
 
 static int _dev_get_size_file(struct device *dev, uint64_t *size)


