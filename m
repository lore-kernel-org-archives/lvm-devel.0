From: Milan Broz <mbroz@redhat.com>
Date: Wed,  8 Jun 2011 20:21:26 +0200
Subject: [PATCH] Fix dmsetup table output (different format in 2.02.85)
Message-ID: <1307557286-4803-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In previous versions < 2.02.85 dmsetup table <dev>
produced just dmsetup table, no device.

# dmsetup table abc
0 100 zero

Now is the output changed to:
# dmsetup table abc
abc: 0 100 zero

It should be only for all and multiple devices, not for one.

It breaks at least cryptsetup test suite, I guess there
are more problems.

Patch somehow workarounds it, I have no idea what was the intention
for this change.
I guess even Alasdair should use patch review process sometimes :-p

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/dmsetup.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 2a8e5a6..a2a4b30 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1590,7 +1590,7 @@ static int _status(CMD_ARGS)
 			   _switches[VERBOSE_ARG]) {
 			if (!matched && _switches[VERBOSE_ARG])
 				_display_info(dmt);
-			if (multiple_devices && !_switches[VERBOSE_ARG])
+			if (multiple_devices > 1 && !_switches[VERBOSE_ARG])
 				printf("%s: ", name);
 			if (target_type) {
 				/* Suppress encryption key */
@@ -3412,7 +3412,10 @@ int main(int argc, char **argv)
 	#endif
 
       doit:
-	multiple_devices = (argc > 1);
+	if (argc > 1)
+		multiple_devices = (argc > 2) ? 2 : 1;
+	else
+		multiple_devices = 0;
 	do {
 		if (!cmd->fn(cmd, argc--, argv++, NULL, multiple_devices)) {
 			fprintf(stderr, "Command failed\n");
-- 
1.7.5.3


