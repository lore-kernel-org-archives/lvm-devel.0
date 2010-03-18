From: Petr Rockai <prockai@redhat.com>
Date: Thu, 18 Mar 2010 10:13:16 +0100
Subject: [PATCH] Also honour abort_on_internal_errors when log_fn is set.
Message-ID: <87wrxa6lhv.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

fairly trivial patch. I'll check in later if there are no objections.

diff -u -p -r1.57 log.c
--- lib/log/log.c	11 Jan 2010 20:41:39 -0000	1.57
+++ lib/log/log.c	18 Mar 2010 09:09:24 -0000
@@ -231,7 +231,8 @@ void print_log(int level, const char *fi
 
 	if (_lvm2_log_fn) {
 		_lvm2_log_fn(level, file, line, 0, message);
-
+		if (fatal_internal_error)
+			abort();
 		return;
 	}
 
Yours,
   Petr.


