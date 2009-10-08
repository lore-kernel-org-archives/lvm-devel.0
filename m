From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:11 +0200
Subject: [PATCH 04/11] debian: fix implicit pointer
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <3b7fddbbcca36451e4b8e3617ab54c6e5839877a.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

not sure why the ifdef does not fire, but this is a readline function
and must not be redefined

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 e1f7900... 257cc40... M	tools/lvm.c
 tools/lvm.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index e1f7900..257cc40 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -25,9 +25,6 @@ int main(int argc, char **argv)
 
 #  include <readline/readline.h>
 #  include <readline/history.h>
-#  ifndef HAVE_RL_COMPLETION_MATCHES
-#    define rl_completion_matches(a, b) completion_matches((char *)a, b)
-#  endif
 
 static struct cmdline_context *_cmdline;
 
-- 
1.5.4.3


