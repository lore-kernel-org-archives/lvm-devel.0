From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:01 -0400
Subject: master - fsadm: remove surrounding $()
Message-ID: <201706292025.v5TKP1vA025597@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=439aaca3bc42c73ffe99bbf9b15c726b987ee2a6
Commit:        439aaca3bc42c73ffe99bbf9b15c726b987ee2a6
Parent:        b68235c51970dc3e159ebf7aa0ac5f4928414574
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 16:04:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

fsadm: remove surrounding $()

Remove surrounding $() to avoid executing output
---
 scripts/fsadm.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 996cd1f..f3cc98b 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -613,10 +613,10 @@ for i in "$TUNE_EXT" "$RESIZE_EXT" "$TUNE_REISER" "$RESIZE_REISER" \
 done
 
 "$LVM" version >"$NULL" 2>&1 || error "Could not run lvm binary \"$LVM\"."
-$("$READLINK" -e / >"$NULL" 2>&1) || READLINK_E="-f"
+"$READLINK" -e / >"$NULL" 2>&1 || READLINK_E="-f"
 TEST64BIT=$(( 1000 * 1000000000000 ))
 test "$TEST64BIT" -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic."
-$(echo Y | "$GREP" Y >"$NULL") || error "Grep does not work properly."
+echo Y | "$GREP" Y >"$NULL" || error "Grep does not work properly."
 test "$("$DATE" -u -d"Jan 01 00:00:01 1970" +%s)" -eq 1 || error "Date translation does not work."
 
 


