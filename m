From: David Teigland <teigland@sourceware.org>
Date: Tue, 20 Nov 2018 10:25:10 -0500
Subject: master - WHATS_NEW: sync io
Message-ID: <201811201525.wAKFPAq9002805@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9deb1340143f4e036e2531788adc5ad82751cbfd
Commit:        9deb1340143f4e036e2531788adc5ad82751cbfd
Parent:        7e721ca04832d36b5ffbb992eaaaeb5e424de271
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 20 09:20:28 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 20 09:20:28 2018 -0600

WHATS_NEW: sync io

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e152027..68cdcea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Use sync io if async io_setup fails, or use_aio=0 is set in config.
 
 Version 2.03.01 - 31st October 2018
 ===================================


