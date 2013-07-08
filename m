From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:19:16 +0200
Subject: [PATCH 4/4] cleanup: add comment
In-Reply-To: <cover.1373296602.git.zkabelac@redhat.com>
References: <cover.1373296602.git.zkabelac@redhat.com>
Message-ID: <feb06c4334192bbf9a7adf6170dac650079b1768.1373296602.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/display/display.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index e2b0f76..3f7f360 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -928,7 +928,7 @@ char yes_no_prompt(const char *prompt, ...)
 		}
 
 		if ((c = getchar()) == EOF) {
-			ret = 'n';
+			ret = 'n'; /* SIGINT */
 			break;
 		}
 
-- 
1.8.3.1


