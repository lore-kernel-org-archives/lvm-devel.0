From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 14 Feb 2017 13:32:51 +0000 (UTC)
Subject: master - Makefile: all_man also requires man-generator now
Message-ID: <20170214133251.82F6160C98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c868562a7968db9b0d00df9b1d0a8967a9aacaa3
Commit:        c868562a7968db9b0d00df9b1d0a8967a9aacaa3
Parent:        22457ed4d97e0fdb13b15b44facf21521e8a1549
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Feb 14 13:24:31 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Feb 14 13:24:31 2017 +0000

Makefile: all_man also requires man-generator now

---
 Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index e0a30f3..b525278 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -60,6 +60,7 @@ daemons: lib libdaemon tools
 tools: lib libdaemon device-mapper
 po: tools daemons
 man: tools
+all_man: tools
 scripts: liblvm libdm
 
 lib.device-mapper: include.device-mapper


