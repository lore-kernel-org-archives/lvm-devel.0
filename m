From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu,  2 Aug 2012 14:52:35 +0000 (UTC)
Subject: master - Remove redundant (potentially harmful) semicolon
Message-ID: <20120802145235.0D40B127E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55c9286dea6b7d77338b4663d67337ca5a7b2b55
Commit:        55c9286dea6b7d77338b4663d67337ca5a7b2b55
Parent:        49ae67cba364e7fba0d0715c4350f28239d42a68
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Aug 2 11:38:19 2012 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 2 16:50:37 2012 +0200

Remove redundant (potentially harmful) semicolon

---
 libdm/libdm-config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 8457497..2423f9b 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -77,7 +77,7 @@ static const int sep = '/';
 		  p->tb - p->fb + 1, p->line); \
       return 0;\
    } \
-} while(0);
+} while(0)
 
 static int _tok_match(const char *str, const char *b, const char *e)
 {


