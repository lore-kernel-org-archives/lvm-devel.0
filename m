From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 29 Apr 2014 07:16:49 +0000 (UTC)
Subject: master - pvremove: Catch CTRL-c during prompts.
Message-ID: <20140429071649.7704260B65@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1f765d72aa56dab547a819447371b5315e78455
Commit:        b1f765d72aa56dab547a819447371b5315e78455
Parent:        26989e0cd7fab4768f46803cd25bfc7499ab488e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Apr 29 08:16:28 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Apr 29 08:16:28 2014 +0100

pvremove: Catch CTRL-c during prompts.

---
 WHATS_NEW        |    1 +
 tools/pvremove.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fad66bf..bb5b4c3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Catch CTRL-c during pvremove prompts.
   Show correct availability status for snapshot origin in lvscan.
   Move segment thin pool/volume info into segment display 'lvdisplay --maps'.
   Display thin pool usage even when just thin volume is available.
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 7048b97..dfd6007 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -37,6 +37,8 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 			stack;
 			ret = ECMD_FAILED;
 		}
+		if (sigint_caught())
+			return_ECMD_FAILED;
 	}
 
 	return ret;


