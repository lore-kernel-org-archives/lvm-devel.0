From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:30 +0000 (UTC)
Subject: master - makefiles: generate Local
Message-ID: <20151013140430.92C3060FAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f9e7f692ea1dc6370ee9978b34c4255d28b3c3c
Commit:        4f9e7f692ea1dc6370ee9978b34c4255d28b3c3c
Parent:        4b586ad3c26be5eaaeff38d767d5f2421ee1151b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 21:31:41 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:20 2015 +0200

makefiles: generate Local

Use same  exported symbols list for other generated symfile
as it appeared to be the right way for libdm.

Local {
	local:
		*;
};
---
 make.tmpl.in |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 1217278..f1d4fad 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -497,7 +497,9 @@ EXPORTED_SYMBOLS := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.expor
 ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
 	set -e; (echo "Base {"; echo "	global:";\
 		 $(SED) "s/^/		/;s/$$/;/" $<;\
-		 echo "	local:"; echo "		*;"; echo "};") > $@
+		 echo "};";\
+		 echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
+		 ) > $@
 else
 	set -e;\
 	R=$$(sort $^ | uniq -u);\


