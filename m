From: Nir Soffer <nirsof@gmail.com>
Date: Sun, 26 Mar 2017 10:06:15 +0300
Subject: [PATCH] dmsetup: Flush ouptut when using --interval
Message-ID: <20170326070615.9880-1-nsoffer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A program may like to run "dmstatus report --interval 2" and read the
report output via a pipe. Flush stdout after outputting each report to
make this possible.
---
 tools/dmsetup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 1e22cf1..1529fb3 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -7081,6 +7081,7 @@ doit:
 
 			if (_count > 1 && r) {
 				printf("\n");
+				fflush(stdout);
 				/* wait for --interval and update timestamps */
 				if (!_do_report_wait()) {
 					ret = 1;
-- 
2.9.3


