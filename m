From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:18:17 -0400
Subject: master - dmsetup: Flush ouptut when using --interval
Message-ID: <201703300918.v2U9IHRt021452@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8b2b1efd84fb1e96500d86f2ada3c2efa1338f3
Commit:        b8b2b1efd84fb1e96500d86f2ada3c2efa1338f3
Parent:        c7e4b97abc86da766d8465ff6c9bbc6b77766bba
Author:        Nir Soffer <nsoffer@redhat.com>
AuthorDate:    Thu Mar 30 10:17:32 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 10:17:32 2017 +0100

dmsetup: Flush ouptut when using --interval

---
 tools/dmsetup.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d25b3bd..44ea6f9 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -7080,6 +7080,7 @@ doit:
 
 			if (_count > 1 && r) {
 				printf("\n");
+				fflush(stdout);
 				/* wait for --interval and update timestamps */
 				if (!_do_report_wait()) {
 					ret = 1;


