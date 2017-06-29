From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:13 -0400
Subject: master - tests: aux.sh add -r to read
Message-ID: <201706292028.v5TKSDjN026748@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96fcf82dddd7bcc7b5c09de09d49d70a04ae8b12
Commit:        96fcf82dddd7bcc7b5c09de09d49d70a04ae8b12
Parent:        ec02307e952ef29d4a28fe134c807ac79a61908a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 20:50:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: aux.sh add -r to read

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5e7340e..f39d400 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -877,7 +877,7 @@ common_dev_() {
 	local pvdev
 	local offset
 
-	read pos size type pvdev offset < "$name.table"
+	read -r pos size type pvdev offset < "$name.table"
 
 	for fromlen in "${offsets[@]}"; do
 		from=${fromlen%%:*}


