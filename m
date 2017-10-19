From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 19 Oct 2017 11:42:14 -0400
Subject: master - test: remove 'should's from test to test target status race fix
Message-ID: <201710191542.v9JFgE6L014845@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6f4563103a626bbe6a9e768a090233541ecd24c
Commit:        d6f4563103a626bbe6a9e768a090233541ecd24c
Parent:        f3ae99dcc0b73f5551c08a3e0af8a17b4448ac50
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 19 17:41:44 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 19 17:41:44 2017 +0200

test: remove 'should's from test to test target status race fix

---
 test/shell/lvconvert-raid-status-validation.sh |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index cee3bfe..51c7048 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -76,9 +76,8 @@ while true; do
 		#   Before starting sync thread: "Aa X/X recover"
 		# from the valid case,
 		#   Just finished sync thread: "Aa X/X recover"
-		# We'll just put "should" for now
-		should [ "${a[5]}" = "AA" ]
-		should [ "${a[7]}" = "idle" ]
+		[ "${a[5]}" = "AA" ]
+		[ "${a[7]}" = "idle" ]
 		break
 	fi
         sleep .1
@@ -105,9 +104,8 @@ while true; do
 		#   Before starting sync thread: "Aa X/X recover"
 		# from the valid case,
 		#   Just finished sync thread: "Aa X/X recover"
-		# We'll just put "should" for now
-		should [ "${a[5]}" = "AAA" ]
-		should [ "${a[7]}" = "idle" ]
+		[ "${a[5]}" = "AAA" ]
+		[ "${a[7]}" = "idle" ]
 		break
 	fi
         sleep .1
@@ -129,8 +127,8 @@ while true; do
 		[ "${a[5]}" = "aa" ]
 		[ "${a[7]}" = "resync" ]
 	else
-		should [ "${a[5]}" = "AA" ]
-		should [ "${a[7]}" = "idle" ]
+		[ "${a[5]}" = "AA" ]
+		[ "${a[7]}" = "idle" ]
 		break
 	fi
         sleep .1


