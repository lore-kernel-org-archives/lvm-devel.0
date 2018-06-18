From: David Teigland <teigland@sourceware.org>
Date: Mon, 18 Jun 2018 13:02:38 -0400
Subject: master - bcache: remove extraneous error message
Message-ID: <201806181702.w5IH2cR0020985@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f85a010a6bc9dc0414ccdf9c6b195c78231f1914
Commit:        f85a010a6bc9dc0414ccdf9c6b195c78231f1914
Parent:        565df4e7321243614fd18c6a45d1f890ab92956b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 18 11:59:57 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 18 12:02:22 2018 -0500

bcache: remove extraneous error message

an error from io_submit is already recognized by
the caller like errors during completion.
---
 lib/device/bcache.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index f4c0712..f315b2a 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -191,7 +191,6 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	} while (r == -EAGAIN);
 
 	if (r < 0) {
-		log_sys_warn("io_submit");
 		_cb_free(e->cbs, cb);
 		return false;
 	}


