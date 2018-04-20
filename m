From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:24 -0400
Subject: master - cleanup: correct casting
Message-ID: <201804201102.w3KB2O0V031329@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e878c3fc32161048e76c2b8e6a33d84f6852cdd4
Commit:        e878c3fc32161048e76c2b8e6a33d84f6852cdd4
Parent:        27a1a0e5c04806e217dbd9c197dc95c05341ed54
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 16 12:57:02 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

cleanup: correct casting

---
 lib/device/dev-io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 1d16a66..d631b86 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -242,7 +242,7 @@ int dev_async_getevents(void)
 				  dev_name(devbuf->where.dev), _aio_events[event_nr].res,
 				  (uint64_t) devbuf->where.size, (uint64_t) devbuf->where.start,
 				  _reason_text(devbuf->reason),
-				  ((int64_t)_aio_events[event_nr].res < 0) ? strerror(-(int64_t)_aio_events[event_nr].res) : 0);
+				  (((int64_t)_aio_events[event_nr].res) < 0) ? strerror(-(int64_t)_aio_events[event_nr].res) : 0);
 			_release_devbuf(devbuf);
 			if (dev_read_callback_fn)
 				dev_read_callback_fn(1, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, NULL);


