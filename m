From: okozina <okozina@fedoraproject.org>
Date: Mon, 11 May 2015 17:08:53 +0000 (UTC)
Subject: master - lvmpolld: by default spawn lvpoll cmd with -An
Message-ID: <20150511170853.1549660222@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7581157861722b832afd17f83a71f993a9e44a0
Commit:        d7581157861722b832afd17f83a71f993a9e44a0
Parent:        5cfd7074afb03c4e34ced4008e0d706d9f4b36ba
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 11 15:22:18 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 11 19:08:13 2015 +0200

lvmpolld: by default spawn lvpoll cmd with -An

---
 daemons/lvmpolld/lvmpolld-cmd-utils.c |    4 ++++
 tools/commands.h                      |    3 ++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-cmd-utils.c b/daemons/lvmpolld/lvmpolld-cmd-utils.c
index cd789a3..0248221 100644
--- a/daemons/lvmpolld/lvmpolld-cmd-utils.c
+++ b/daemons/lvmpolld/lvmpolld-cmd-utils.c
@@ -86,6 +86,10 @@ const char **cmdargv_ctr(const struct lvmpolld_lv *pdlv, const char *lvm_binary,
 	if (!add_to_cmd_arr(&cmd_argv, pdlv->lvname, &i))
 		goto err;
 
+	/* disable metadata backup */
+	if (!add_to_cmd_arr(&cmd_argv, "-An", &i))
+		goto err;
+
 	/* terminating NULL */
 	if (!add_to_cmd_arr(&cmd_argv, NULL, &i))
 		goto err;
diff --git a/tools/commands.h b/tools/commands.h
index 2e53d8f..bbfcd72 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -886,6 +886,7 @@ xx(lvpoll,
    "\t[--abort]\n"
    "\t[--handlemissingpvs]\n"
    "\t[--polloperation\n"
+   "\t[-A|--autobackup {y|n}]\n"
    "\t[-d|--debug]\n "
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
@@ -893,7 +894,7 @@ xx(lvpoll,
    "\t[-v|--verbose]\n "
    "\t[--version]\n",
 
-   abort_ARG, handlemissingpvs_ARG, interval_ARG, polloperation_ARG,
+   abort_ARG, autobackup_ARG, handlemissingpvs_ARG, interval_ARG, polloperation_ARG,
    test_ARG)
 
 xx(pvremove,


