From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 29 Aug 2014 11:12:37 +0000 (UTC)
Subject: master - makefiles: include path missing
Message-ID: <20140829111237.18F7860FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db77041d93a946384cadecdb3a33466e09f77b00
Commit:        db77041d93a946384cadecdb3a33466e09f77b00
Parent:        ca32920b1646b5d124c729e1ed7a83ce277d4803
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 29 12:51:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 29 13:10:20 2014 +0200

makefiles: include path missing

For deps calcs path for blkid.h needs to be known.
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 5d4c144..5e597df 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -411,7 +411,7 @@ $(LIB_STATIC): $(OBJECTS)
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
 	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
-	$(CC) -MM $(INCLUDES) $(DEFS) -o $@ $<; \
+	$(CC) -MM $(INCLUDES) $(BLKID_CFLAGS) $(DEFS) -o $@ $<; \
 	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
 	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
 	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \


