From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:59 -0400
Subject: master - tests: aux.sh using grep -c
Message-ID: <201706292027.v5TKRx0n026721@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4f63b7e9c130ce1de12c38fb794fe7b3142dc9bd
Commit:        4f63b7e9c130ce1de12c38fb794fe7b3142dc9bd
Parent:        b16ca76260bbfb950ee7246a249ea7e4987520af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 07:59:11 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: aux.sh using grep -c

Consider using grep -c instead of grep|wc -l.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a3e2b70..b130560 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -423,7 +423,7 @@ teardown_devs_prefixed() {
 	if test -f REMOVE_FAILED; then
 		local num_devs
 		local num_remaining_devs=999
-		while num_devs=$(dm_table | grep "$prefix" | wc -l) && \
+		while num_devs=$(dm_table | grep -c "$prefix") && \
 		    test "$num_devs" -lt "$num_remaining_devs" -a "$num_devs" -ne 0; do
 			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first


