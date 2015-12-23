From: Lidong Zhong <lzhong@suse.com>
Date: Wed, 23 Dec 2015 14:58:15 +0800
Subject: [PATCH] dmsetup: change the return value when no devices are found
Message-ID: <1450853895-9772-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Calling 'dmsetup ls --target=multipath' results in this:

root: dmsetup ls --target=multipath
No devices found
root: echo $?
0

Note, 'No devices found' is printed on _stdout_, making it impossible to
differentiate if this is an error (as in: dmsetup did not find any
devices matching the above criteria) or if this is legit (as in: dmsetup
found a device named 'No devices found').

This is absolutely wrong and makes it impossible to use dmsetup in a
script.
---
 tools/dmsetup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 1efffb6..2be3e6c 100644
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
2.1.2


