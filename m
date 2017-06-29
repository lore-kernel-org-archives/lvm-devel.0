From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:25 -0400
Subject: master - vgimportclone.sh: do not quote regex
Message-ID: <201706292027.v5TKRP4P026645@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afa0bd916e9b54530ad2eb99373c836c5396ea4f
Commit:        afa0bd916e9b54530ad2eb99373c836c5396ea4f
Parent:        ef4506069a1a29cd00532e36c24df9a01cd32600
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 18:54:26 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

vgimportclone.sh: do not quote regex

Don't quote rhs of =~, it'll match literally rather than as a regex.
---
 scripts/vgimportclone.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 7d3118f..783857e 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -48,7 +48,7 @@ function getvgname {
     NAME="${BNAME}"
     I=0
 
-    while [[ "${VGLIST}" =~ ":${NAME}:" ]]
+    while [[ "${VGLIST}" =~ :${NAME}: ]]
     do
         I=$(( I + 1 ))
         NAME="${BNAME}$I"


