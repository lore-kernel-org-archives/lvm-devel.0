From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Thu, 13 Jul 2023 19:57:55 +0000
Subject: [Git][lvmteam/lvm2][main] man-generator: ensure p is defined
Message-ID: <64b05743804c0_2923dbbc873485@gitlab-sidekiq-low-urgency-cpu-bound-v2-db56db498-s24dj.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
93484c2a by Zdenek Kabelac at 2023-07-13T21:56:47+02:00
man-generator: ensure p is defined

In error path, p pointer could have been undefined.

- - - - -


1 changed file:

- tools/command.c


Changes:

=====================================
tools/command.c
=====================================
@@ -376,7 +376,7 @@ static int _val_str_to_num(char *str)
 static int _opt_str_to_num(struct command *cmd, char *str)
 {
 	char long_name[MAX_LONG_OPT_NAME_LEN];
-	char *p;
+	char *p = NULL;
 	int i;
 	int first = 0, last = ARG_COUNT - 1, middle;
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/93484c2a62afb59f1503d04c953d76255b9e05b3

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/93484c2a62afb59f1503d04c953d76255b9e05b3
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230713/76075f1c/attachment.htm>
