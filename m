From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 17 Jan 2015 11:30:49 +0000 (UTC)
Subject: master - man: Remove renamed writebehind field from lvs.8.
Message-ID: <20150117113049.2EBB860E52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5ffacc43440d5aef5ec84d4c9df62faca103fe6
Commit:        e5ffacc43440d5aef5ec84d4c9df62faca103fe6
Parent:        651549594ea24dd516538ca8ac1603b3b7c944f4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 17 11:05:25 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 17 11:05:25 2015 +0000

man: Remove renamed writebehind field from lvs.8.

---
 man/lvs.8.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index f268584..3cb2ec0 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -134,7 +134,6 @@ stripe_size,
 sync_percent,
 thin_count,
 transaction_id,
-writebehind,
 zero.
 .IP
 With \fB\-\-segments\fP, any "seg_" prefixes are optional;


