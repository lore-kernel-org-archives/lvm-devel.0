From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Nov 2011 10:59:06 +0100
Subject: [PATCH 4/7] Do not lstat common path prefix
In-Reply-To: <cover.1322213495.git.zkabelac@redhat.com>
References: <cover.1322213495.git.zkabelac@redhat.com>
Message-ID: <1027f3b37610aba066b54ab5d8f23741cf1d505f.1322213495.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When both path have common prefix i.e. /dev/disk/by-id
skip  2xlstat for /dev  /dev/disk /dev/disk/by-id
and directly lstat only different part of path.

Reduces greatly amount of lstat calls on system with
lots of devices.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-cache.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 61f479d..9b401ee 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -266,6 +266,8 @@ static int _compare_paths(const char *path0, const char *path1)
 	strncpy(p1, path1, PATH_MAX);
 	s0 = &p0[0] + 1;
 	s1 = &p1[0] + 1;
+	while (*s0 && *s0 == *s1)
+                s0++, s1++;
 
 	/* We prefer symlinks - they exist for a reason!
 	 * So we prefer a shorter path before the first symlink in the name.
-- 
1.7.7.3


