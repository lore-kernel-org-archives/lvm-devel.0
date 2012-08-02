From: Marian Csontos <mcsontos@redhat.com>
Date: Thu,  2 Aug 2012 12:24:57 +0200
Subject: [PATCH] Remove redundant (potentially harmful) semicolon
Message-ID: <1343903097-32142-1-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
-- 
1.7.1


