From: saulery@free.fr <saulery@free.fr>
Date: Tue, 25 Nov 2014 02:57:22 +0100
Subject: Remove -v option of clvmd
In-Reply-To: <1416880642-26059-1-git-send-email-saulery@free.fr>
References: <1416880642-26059-1-git-send-email-saulery@free.fr>
Message-ID: <1416880642-26059-3-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

-V is documented, not -v. Needless currently. A --version option would be
better.

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 daemons/clvmd/clvmd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 5cd6874..0f1aa5f 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -372,7 +372,7 @@ int main(int argc, char *argv[])
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt_long(argc, argv, "vVhfd:t:RST:CI:E:",
+	while ((opt = getopt_long(argc, argv, "Vhfd:t:RST:CI:E:",
 				  longopts, NULL)) != -1) {
 		switch (opt) {
 		case 'h':
-- 
2.1.3


