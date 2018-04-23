From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:38 -0400
Subject: master - [device/bcache] fix missing max_io fn in bcache async engine
Message-ID: <201804231347.w3NDlcFl031317@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9e6298edb0bc6533c22f7e95e613189abe89c99
Commit:        d9e6298edb0bc6533c22f7e95e613189abe89c99
Parent:        dc8034f5eb8d14b621c3d99ff58c95f74153c448
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 8 10:10:31 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] fix missing max_io fn in bcache async engine

---
 lib/device/bcache.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index dce05ef..cea4db4 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -134,6 +134,7 @@ struct async_engine {
 	struct io_engine e;
 	io_context_t aio_context;
 	struct cb_set *cbs;
+	unsigned max_io;
 };
 
 static struct async_engine *_to_async(struct io_engine *e)
@@ -233,6 +234,12 @@ static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 	return true;
 }
 
+static unsigned _async_max_io(struct io_engine *ioe)
+{
+	struct async_engine *e = _to_async(ioe);
+	return e->max_io;
+}
+
 struct io_engine *create_async_io_engine(unsigned max_io)
 {
 	int r;
@@ -241,9 +248,12 @@ struct io_engine *create_async_io_engine(unsigned max_io)
 	if (!e)
 		return NULL;
 
+	e->max_io = max_io;
+
 	e->e.destroy = _async_destroy;
 	e->e.issue = _async_issue;
 	e->e.wait = _async_wait;
+	e->e.max_io = _async_max_io;
 
 	e->aio_context = 0;
 	r = io_setup(max_io, &e->aio_context);


