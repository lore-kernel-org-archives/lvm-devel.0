From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:16:55 +0000 (UTC)
Subject: master - clvmd: remove -v option from getopt
Message-ID: <20151116001655.B510F601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=376892ddf8e6a1c3e50240193d6df63418d9392d
Commit:        376892ddf8e6a1c3e50240193d6df63418d9392d
Parent:        e31f4b76f470c7da7328d16551cfaba9cae4674a
Author:        St??phane Aulery <saulery@free.fr>
AuthorDate:    Tue Nov 25 02:57:22 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:15:03 2015 +0100

clvmd: remove -v option from getopt

-V is documented, not -v.

Signed-off-by: St??phane Aulery <saulery@free.fr>
---
 daemons/clvmd/clvmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 96cb697..3f21aba 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -374,7 +374,7 @@ int main(int argc, char *argv[])
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt_long(argc, argv, "vVhfd:t:RST:CI:E:",
+	while ((opt = getopt_long(argc, argv, "Vhfd:t:RST:CI:E:",
 				  longopts, NULL)) != -1) {
 		switch (opt) {
 		case 'h':


