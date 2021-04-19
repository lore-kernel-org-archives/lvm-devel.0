From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:45 +0000 (GMT)
Subject: main - makefiles: improved hyphenation replacement
Message-ID: <20210419130045.D81713969019@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=adfdfd9c58aa2bb24d675eaa5f33e0101015d10f
Commit:        adfdfd9c58aa2bb24d675eaa5f33e0101015d10f
Parent:        b94f2a8b552a6089774d5e65082b98cf9579dc6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 14 14:39:17 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:37:07 2021 +0200

makefiles: improved hyphenation replacement

Sed replacements script missed to properly replace several '-' to '\-'.
Replace it with simpler set of regexes.

Also add new target 'make checksed' for testing with examples,
where the replacement should or should not occure for easier testing.
---
 man/Makefile.in | 80 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 48 insertions(+), 32 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index a6029bbe8..d716deb58 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -147,42 +147,58 @@ $(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+" $< > $@
 endef
 
-# Escape any '-':
+# Escape any '-' to '\-'  (except ^.TH line)
+# and fix unwanted changes:
+#    '\\-'  back to '\-'
+#    words like 'device\-mapper' back to 'device-mapper',
+#    \[\->] \[<\-] back to \[->], \[<-]
+#    however for some words i.e. '*-pool' we want '*\-pool'
+#    also 'vg-lv,[systemd-]machine-id,lvm-full,lvm-lvpoll' should go with \-
 #
-# - multiple (>= 2)
-# - in ' -'
-# - in ranges
-# - in middle of options (e.g. '--use-policies') and their arguments
-# - in symbolic use (e.g. '->')
-# - in "$vg-$lv"
-# - in single one in '\\f.-'
 define ESCAPEHYPHENS
-$(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
-	  -e "s+\([ [:alpha:]]\)-\{6\}+\1\\\-\\\-\\\-\\\-\\\-\\\-+g" \
-	  -e "s+\([ [:alpha:]]\)-\{5\}+\1\\\-\\\-\\\-\\\-\\\-+g" \
-	  -e "s+\([ [:alpha:]]\)-\{4\}+\1\\\-\\\-\\\-\\\-+g" \
-	  -e "s+\([ [:alpha:]]\)-\{3\}+\1\\\-\\\-\\\-+g" \
-	  -e "s+\([ [:alpha:]]\)-\{2\}+\1\\\-\\\-+g" \
-	  -e "s+\([^\]\)-\([[:alnum:]\?]\)+\1\\\-\2+g" \
-	  -e "s+ --+\\\-\\\-+g" \
-	  -e "s+|-|+|\\\-|+g" \
-	  -e "s+|-\\\-+\\\-\\\-+g" \
-	  -e "s+ -\"+ \\\-\"+g" \
-	  -e "s+'--'+'\\\-\\\-'+g" \
-	  -e "s+^--+\\\-\\\-+g" \
-	  -e "s+\([[:alnum:]]\) - \([[:alnum:]]\)+\1 \\\- \2+g" \
-	  -e "s+\(<\)-+\1\\\-+g" \
-	  -e "s+[^\\]-\(>\)+\\\-\1+g" \
-	  -e "s+\([[:alnum:]]\{2,\}\)\\\-\([[:alnum:]]\{2,\}\)+\1-\2+g" \
-	  -e "s+\(\\\-\\\-[[:alnum:]]\{2,\}\)-+\1\\\-+g" \
-	  -e "s+\(lvm2\-activation\)+lvm2\\\-activation+" \
-	  -e "s+\([^\\]\)-pool+\1\\\-pool+g" \
-	  -e "s+\([[:digit:]]\)-\([[:digit:]]\)+\1\\\-\2+g" \
-	  -e "s+\\\-git+\-git+g" \
-	  -e "s+\(vg.*\)\-lv+\1\\\-lv+g" \
-	  -e "s+\([[:digit:]]\{4\}\)\\\-\([[:digit:]]\{2\}\)\\\-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
+$(SED) -i -e "/^.TH/ !s+-+\\\-+g" \
+	  -e "s+\\\[\]-+\\\-+g" \
+	  -e "s+\(^\|[^[:alnum:]\-]\)\([[:alpha:]]\{1,\}\)\\\-\((\|[([:alpha:]]\{2,\}\)+\1\2-\3+g" \
+	  -e "s+\([[:alpha:]]\)-\(pool\)+\1\\\-\2+g" \
+	  -e "s+[\][[]\(<\{0,1\}\)\\\-+\\\[\1-+g" \
+	  -e "s+\(vg.\{1,\}[^\]\)-lv+\1\\\-lv+g" \
+	  -e "s+systemd-machine+systemd\\\-machine+g" \
+	  -e "s+machine-id+machine\\\-id+g" \
+	  -e "s+lvm-full+lvm\\\-full+g" \
+	  -e "s+lvm-lvpoll+lvm\\\-lvpoll+g" \
+	  $@
 endef
 
+.PHONY: checksed
+checksed:
+	$(Q) echo "cmd -a -b retry -c ret --use-policy -d" > $@
+	$(Q) echo "cmd \fI-u\fB -d retry \fI--use-pol --use-poli 4.0 --use \"-L|--size\"" >> $@
+	$(Q) echo "cmd --use-pol" >> $@
+	$(Q) echo "cmd --[raid]use device-mapper thin-pool \fB-\fP sdb1:1000-1999 \fB-t\fP|\fB--test\fP -? -o-field3" >> $@
+	$(Q) echo "cmd -dd---- \[->] \[<-] -*- -o#field5 -o-field3 -d" >> $@
+	$(Q) echo "-d" >> $@
+	$(Q) echo ".TH 2.03.12(2)-git" >> $@
+	$(Q) echo "--verbose" >> $@
+	$(Q) echo ".BR -- [ raid ] most  -- [ raid ] most" >> $@
+	$(Q) echo ".BR | --verbose|--verb  --verbose  --verbose --verbose --verbose" >> $@
+	$(Q) echo "skip - unint --aa-dd- --aa-dd-- ---aa-dd 4.0 \-a\-b" >> $@
+	$(Q) echo "cmd \-a \-b retry \-c ret \-\-use\-policy \-d" > $@-e
+	$(Q) echo "cmd \fI\-u\fB \-d retry \fI\-\-use\-pol \-\-use\-poli 4.0 \-\-use \"\-L|\-\-size\"" >> $@-e
+	$(Q) echo "cmd \-\-use\-pol" >> $@-e
+	$(Q) echo "cmd \-\-[raid]use device-mapper thin\-pool \fB\-\fP sdb1:1000\-1999 \fB\-t\fP|\fB\-\-test\fP \-? \-o\-field3" >> $@-e
+	$(Q) echo "cmd \-dd\-\-\-\- \[->] \[<-] \-*\- \-o#field5 \-o\-field3 \-d" >> $@-e
+	$(Q) echo "\-d" >> $@-e
+	$(Q) echo ".TH 2.03.12(2)-git" >> $@-e
+	$(Q) echo "\-\-verbose" >> $@-e
+	$(Q) echo ".BR \-\- [ raid ] most  \-\- [ raid ] most" >> $@-e
+	$(Q) echo ".BR | \-\-verbose|\-\-verb  \-\-verbose  \-\-verbose \-\-verbose \-\-verbose" >> $@-e
+	$(Q) echo "skip \- unint \-\-aa\-dd\- \-\-aa\-dd\-\- \-\-\-aa\-dd 4.0 \-a\-b" >> $@-e
+	$(Q) $(ESCAPEHYPHENS)
+	$(Q) echo "--- H Y P H E N A T E D ---"
+	$(Q) cat $@
+	$(Q) diff -u $@-e $@
+	$(Q) $(RM) $@ $@-e
+
 %.5: $(srcdir)/%.5_main
 	@echo "    [MAN] $@"
 	$(Q) $(SUBSTVARS)


