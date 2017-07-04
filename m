From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 4 Jul 2017 15:20:53 -0400
Subject: master - test: return 0 if ignoring 'a' device health chars is requested
Message-ID: <201707041920.v64JKrdj013046@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70c340dbc25523de18195a7916f27aa37b051e43
Commit:        70c340dbc25523de18195a7916f27aa37b051e43
Parent:        f2eda36cfa9baf3f7e132dbc3a3f34c908cb36d4
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jul 4 19:34:10 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jul 4 19:34:10 2017 +0200

test: return 0 if ignoring 'a' device health chars is requested

This allows lvconvert-raid-reshape-striped_to_linear.sh to succeed when
it reduces raid5 to two stripes before converting to raid1 and linear.
---
 test/lib/check.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index c8efcca..a1abda8 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -234,6 +234,7 @@ in_sync() {
 		[ $ignore_a -eq 0 ] && \
 			die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
 		echo "$lvm_name ($type$snap) is not in-sync"
+		[ $ignore_a -eq 1 ] && return 0
 		return 1
 	fi
 


