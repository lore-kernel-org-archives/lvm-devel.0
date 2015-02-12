From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:42:11 +0000 (UTC)
Subject: master - makefiles: more _CFLAGS for -MM
Message-ID: <20150212144211.BD75D6010E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1002e98e020e0a9e35bcf75eac5a991550fc0b2
Commit:        b1002e98e020e0a9e35bcf75eac5a991550fc0b2
Parent:        65d95caad5cb7410286b1c2b189cfedb69fcbe7d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 12 10:38:01 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 12 15:38:50 2015 +0100

makefiles: more _CFLAGS for -MM

Move of valgrind flags to _CFLAGS make the -MM generation
not compilable (d571eab3b2bbb9be80e75e633bf2e30834975552)

Add these _CFLAGS right into .c->.d rules
(as well as  UDEV)
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index cfa065c..72e2613 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -423,7 +423,7 @@ $(LIB_STATIC): $(OBJECTS)
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
 	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
-	$(CC) -MM $(INCLUDES) $(BLKID_CFLAGS) $(DEFS) -o $@ $<; \
+	$(CC) -MM $(INCLUDES) $(BLKID_CFLAGS) $(VALGRIND_CFLAGS) $(UDEV_CFLAGS) $(DEFS) -o $@ $<; \
 	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
 	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
 	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \


