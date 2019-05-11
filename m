From: Rikard Falkeborn <rikard.falkeborn@gmail.com>
Date: Sun, 12 May 2019 01:19:52 +0200
Subject: [PATCH] scripts: generator-internals: Fix return value
Message-ID: <20190511231952.11876-1-rikard.falkeborn@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Returning -1 from a function with bool as return type is the same as
returning true. Change to false to indicate failure if there is an error
in the child.

Signed-off-by: Rikard Falkeborn <rikard.falkeborn@gmail.com>
---
 scripts/generator-internals.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
index 733e8189c..c39c35324 100644
--- a/scripts/generator-internals.c
+++ b/scripts/generator-internals.c
@@ -101,7 +101,7 @@ static bool _close_child(struct child_process *child)
 
 	while (waitpid(child->pid, &status, 0) < 0)
 		if (errno != EINTR)
-			return -1;
+			return false;
 
 	if (WIFEXITED(status) && !WEXITSTATUS(status))
 		return true;
-- 
2.21.0


