From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 15 Jun 2015 11:43:38 +0200
Subject: [PATCH] makefile: fail to compile if there are more than one exported symbols.
In-Reply-To: <557F0AB3020000E1000109DF@relay2.provo.novell.com>
References: <1434094405-8391-1-git-send-email-lzhong@suse.com>	<557B001F.30804@redhat.com>	<557EAFC6020000E1000108C5@relay2.provo.novell.com>	<557E96FF.1050509@redhat.com>
	<557F0AB3020000E1000109DF@relay2.provo.novell.com>
Message-ID: <557E9E4A.6060001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 15.6.2015 v 11:26 Lidong Zhong napsal(a):
> Hi ,
>
> Without this patch, I would get the following error:
>
> set -e;\
> R=dm_lv_simple_resume dm_lv_simple_suspend dm_replace_mirror_table;\
> test -z "$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $R"; false; } ;\
> (for i in ./.exported_symbols.Base ./.exported_symbols.DM_1_02_97 ; do\
> 	echo "${i##*.} {"; echo "	global:";\
> 	/usr/bin/sed "s/^/		/;s/$/;/" < $i;\
> 	test "$i" = Base && { echo "	local:"; echo "		*;"; };\
> 	echo "};";\
> done ) > .export.sym
> /bin/sh: line 1: dm_lv_simple_suspend: command not found
> ../make.tmpl:508: recipe for target '.export.sym' failed
> make[1]: *** [.export.sym] Error 127
> make[1]: Leaving directory '/home/lwang/LVM2.2.02.120/libdm'
> make.tmpl:323: recipe for target 'libdm.device-mapper' failed
> make: *** [libdm.device-mapper] Error 2

Hmmm interesting - in my case I get:

---
set -e;\
R=$(sort .exported_symbols_generated .exported_symbols.Base 
.exported_symbols.DM_1_02_98 .exported_symbols.DM_1_02_97 | uniq -u);\
test -z "$R" || { echo "Mismatch between symbols in shared library and lists 
in .exported_symbols.* files: $R"; false; } ;\
---

While you get directly assigned result.

So how is possible that in your case you get already 'translated' string,
while in my case I get regular  shell evaluation  R=$(sort....) which should 
not need "".

Are you testing against latest 'git' HEAD ?

Do you this in make.tmpl.in?

.export.sym: .exported_symbols_generated $(EXPORTED_SYMBOLS)
ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
	set -e; (echo "Base {"; echo "	global:";\
		 $(SED) "s/^/		/;s/$$/;/" $<;\
		 echo "	local:"; echo "		*;"; echo "};") > $@
else
	set -e;\
	R=$$(sort $^ | uniq -u);\
	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists 
in .exported_symbols.* files: $$R"; false; } ;\
	for i in $(EXPORTED_SYMBOLS); do\
		echo "$${i##*.} {"; echo "	global:";\
		$(SED) "s/^/		/;s/$$/;/" $$i;\
		test "$$i" = Base && { echo "	local:"; echo "		*;"; };\
		echo "};";\
	done > $@
endif


Zdenek


