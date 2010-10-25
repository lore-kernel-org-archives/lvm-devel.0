From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:31 +0200
Subject: [PATCH 24/30] bufused is assigned 0 in preceding source line
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <ccf3cb5bb9c8c7fe9256fd60d748b5aae2d4512d.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Idempotent operation

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/log/log.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 5c49586..86b4988 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -359,7 +359,7 @@ void print_log(int level, const char *file, int line, int dm_errno,
 		_already_logging = 1;
 		memset(&buf, ' ', sizeof(buf));
 		bufused = 0;
-		if ((n = dm_snprintf(buf, sizeof(buf) - bufused - 1,
+		if ((n = dm_snprintf(buf, sizeof(buf) - 1,
 				      "%s:%d %s%s", file, line, log_command_name(),
 				      _msg_prefix)) == -1)
 			goto done;
-- 
1.7.3.1


