From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 26 Aug 2015 12:41:21 +0000 (UTC)
Subject: master - make.tmpl: Mark internal sharedlib symbols local.
Message-ID: <20150826124121.CA83C60573@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34c956afc19cd8a1023444ee333983e8b840e759
Commit:        34c956afc19cd8a1023444ee333983e8b840e759
Parent:        d0ff35c5a6665ef59a5ed86a6b7d920f909300a2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 26 13:36:23 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 26 13:36:23 2015 +0100

make.tmpl: Mark internal sharedlib symbols local.

Since commit 797c18d543947f4c2777b4dcf3ceff57cb55352b some internal symbols
have been exported in shared libraries by mistake because 'local: *' got
lost.  Fix the shell script not to compare the whole filename with
'Base'
---
 WHATS_NEW    |    1 +
 make.tmpl.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ea50997..d98bcc8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.129 -
 ===================================
+  Fix shared library generation to stop exporting internal functions.(2.02.120)
   Accept --cachemode with lvconvert.
   Fix and improve reporting properties of cache-pool.
   Enable usage of --cachepolicy and --cachesetting with lvconvert.
diff --git a/make.tmpl.in b/make.tmpl.in
index dbc839a..2ce2faf 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -505,7 +505,7 @@ else
 	for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | sort -rnt_ -k5 ); do\
 		echo "$${i##*.} {"; echo "	global:";\
 		$(SED) "s/^/		/;s/$$/;/" $$i;\
-		test "$$i" = Base && { echo "	local:"; echo "		*;"; };\
+		test "$${i##*.}" = Base && { echo "	local:"; echo "		*;"; };\
 		echo "};";\
 	done > $@
 endif


