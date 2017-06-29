From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:26 -0400
Subject: master - lvmdump: legacy syntax
Message-ID: <201706292026.v5TKQQQu025834@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a458065aa10c12f8a5c89ce7c6140c0459221f60
Commit:        a458065aa10c12f8a5c89ce7c6140c0459221f60
Parent:        a0740f831c4787fbb98a9a7db5ca2f3c0bfdcf6d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 21:00:48 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmdump: legacy syntax

Use $(..) instead of legacy `..`.
---
 scripts/lvmdump.sh.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index 611dda6..f5af242 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -98,7 +98,7 @@ while getopts :acd:hlpmus opt; do
 	esac
 done
 
-NOW=`$DATE -u +%G%m%d%k%M%S | $TR -d ' '`
+NOW=$("$DATE" -u +%G%m%d%k%M%S | "$TR" -d ' ')
 if test -n "$userdir"; then
 	dir="$userdir"
 else


