From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:18 -0400
Subject: master - lvmdump: replace printf
Message-ID: <201706292026.v5TKQIsB025811@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e08e714b68cce5b46fe47af7716a6d5236f5c683
Commit:        e08e714b68cce5b46fe47af7716a6d5236f5c683
Parent:        e292c1a1cac4edc394fe9daa9ef11b691216740d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:54:00 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmdump: replace printf

Don't use variables in the printf format string. Use printf "..%s.." "$foo".
Advice replaced with plain 'echo'.
---
 scripts/lvmdump.sh.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index 6744058..143b819 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -164,7 +164,8 @@ if (( $clustered )); then
 	{
 	for i in nodes status services; do
 		cap_i=$(echo $i|tr a-z A-Z)
-		printf "$cap_i:\n----------------------------------\n"
+		echo "$cap_i:"
+		echo "----------------------------------"
 		log "cman_tool $i 2>> \"$log\""
 		echo
 	done


