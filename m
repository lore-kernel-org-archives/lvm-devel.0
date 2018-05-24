From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 24 May 2018 07:26:54 -0400
Subject: master - release note: typo
Message-ID: <201805241126.w4OBQsd8019276@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fab063cfcbbe2e3801ba2af7d061059eb37a7eaa
Commit:        fab063cfcbbe2e3801ba2af7d061059eb37a7eaa
Parent:        9337ff48bcf5ed60a06c8cea8daafc855653e493
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 24 12:26:34 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 24 12:26:34 2018 +0100

release note: typo

---
 doc/release-notes/2.02.178 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/doc/release-notes/2.02.178 b/doc/release-notes/2.02.178
index 3a53eab..f986d1d 100644
--- a/doc/release-notes/2.02.178
+++ b/doc/release-notes/2.02.178
@@ -22,7 +22,7 @@ Almost all IO uses libaio now.
 Rewrite label scanning
 ----------------------
 
-Dave Tiegland has reworked the label scanning and metadata reading
+Dave Teigland has reworked the label scanning and metadata reading
 logic to minimise the amount a IOs issued.  Combined with the aio changes 
 this can greatly improve scanning speed for some systems.
 


