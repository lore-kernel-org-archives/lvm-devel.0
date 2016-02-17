From: Hannes Reinecke <hare@suse.de>
Date: Wed, 17 Feb 2016 08:51:11 +0100
Subject: [PATCH] dmsetup: treat no devices found as error
Message-ID: <1455695471-5710-1-git-send-email-hare@suse.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When calling 'dmsetup ls' and no devices are found the program will
print out 'No devices found' and exit normally.
This makes it really hard for the calling application to determine
if the output 'No devices found' is a valid device or not.
This patch moves the 'No devices found' string to stderr and
sets the return code to non-0 to allow calling applications to
better differentiate here.

Signed-off-by: Hannes Reinecke <hare@suse.com>
---
 tools/dmsetup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4db6004..3629931 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1835,7 +1835,8 @@ static int _process_all(const struct command *cmd, const char *subcommand, int a
 
 	if (!names->dev) {
 		if (!silent)
-			printf("No devices found\n");
+			fprintf(stderr, "No devices found\n");
+		r = 0;
 		goto out;
 	}
 
-- 
2.6.2


