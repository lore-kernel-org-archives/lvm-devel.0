From: David Teigland <teigland@sourceware.org>
Date: Thu, 20 Sep 2018 16:38:52 -0400
Subject: master - metadata: remove incorrect comment about alignment
Message-ID: <201809202038.w8KKcqI6030576@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=91c7e66f2b47f4ef814dcf85e1641d49e5123cc7
Commit:        91c7e66f2b47f4ef814dcf85e1641d49e5123cc7
Parent:        09131e3922ffbea35733aecbc538cdbf415b43ac
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 20 15:37:06 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 20 15:38:09 2018 -0500

metadata: remove incorrect comment about alignment

---
 lib/format_text/format-text.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e987849..de4be47 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -487,11 +487,6 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 /*
  * Determine offset for new metadata
  *
- * Adjusting new offsets to begin on 512 boundaries is fairly new, and metadata
- * previously begain immediately after the old, without rounding up.  The
- * rounding should have no practical benefit since it does not affect the
- * actual disk io.
- *
  * FIXME: The rounding can have a negative effect: when the current metadata
  * text size is just below the max, a command to remove something, that
  * *reduces* the text metadata size, can still be rejected for being too large,


