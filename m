From: Lidong Zhong <lzhong@suse.com>
Date: Mon, 15 Jun 2015 03:26:11 -0600
Subject: [PATCH] makefile: fail to compile if there are more than one exported symbols.
In-Reply-To: <557E96FF.1050509@redhat.com>
References: <1434094405-8391-1-git-send-email-lzhong@suse.com>
	<557B001F.30804@redhat.com>
	<557EAFC6020000E1000108C5@relay2.provo.novell.com>
	<557E96FF.1050509@redhat.com>
Message-ID: <557F0AB3020000E1000109DF@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi ,

Without this patch, I would get the following error:

set -e;\
R=dm_lv_simple_resume dm_lv_simple_suspend dm_replace_mirror_table;\
test -z "$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $R"; false; } ;\
(for i in ./.exported_symbols.Base ./.exported_symbols.DM_1_02_97 ; do\
	echo "${i##*.} {"; echo "	global:";\
	/usr/bin/sed "s/^/		/;s/$/;/" < $i;\
	test "$i" = Base && { echo "	local:"; echo "		*;"; };\
	echo "};";\
done ) > .export.sym
/bin/sh: line 1: dm_lv_simple_suspend: command not found
../make.tmpl:508: recipe for target '.export.sym' failed
make[1]: *** [.export.sym] Error 127
make[1]: Leaving directory '/home/lwang/LVM2.2.02.120/libdm'
make.tmpl:323: recipe for target 'libdm.device-mapper' failed
make: *** [libdm.device-mapper] Error 2

Regards,
Lidong

> > Hi  Zdenek, 
> > 
> > As the `echo` outputs, if there are more symbols got from `sort $^ | uniq  
> -u`, there will be 
> > an bash error. 
> > I found this exactly because I forgot to add these symbols to  
> .exported_symbols.* files. 
>  
> But the bash error here is wanted when symbols are missing - it's the purpose  
>  
> to stop compilation. So please specify more closely the example where it  
> fails  
> because of missing "". 
>  
> This output is wanted: 
>  
> Mismatch between symbols in shared library and lists in .exported_symbols.*  
> files: dm_tree_node_set_XXXX 
> dm_tree_node_set_YYYY 
> ../make.tmpl:501: recipe for target '.export.sym' failed 
> make: *** [.export.sym] Error 1 
>  
> If the dm_tree_node_set_XXXX|YYYY is not defined in any .exported_symbols* 
>  
> Zdenek 
>  
> -- 
> lvm-devel mailing list 
> lvm-devel at redhat.com 
> https://www.redhat.com/mailman/listinfo/lvm-devel 
>  
>  




