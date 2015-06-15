From: Lidong Zhong <lzhong@suse.com>
Date: Sun, 14 Jun 2015 20:58:14 -0600
Subject: [PATCH] makefile: fail to compile if there are more than one exported symbols.
In-Reply-To: <557B001F.30804@redhat.com>
References: <1434094405-8391-1-git-send-email-lzhong@suse.com>
	<557B001F.30804@redhat.com>
Message-ID: <557EAFC6020000E1000108C5@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>>> On 6/12/2015 at 11:51 PM, in message <557B001F.30804@redhat.com>, Zdenek
Kabelac <zkabelac@redhat.com> wrote: 
> Dne 12.6.2015 v 09:33 Lidong Zhong napsal(a): 
> > --- 
> >   make.tmpl.in | 2 +- 
> >   1 file changed, 1 insertion(+), 1 deletion(-) 
> > 
> > diff --git a/make.tmpl.in b/make.tmpl.in 
> > index 731dab7..60ddd01 100644 
> > --- a/make.tmpl.in 
> > +++ b/make.tmpl.in 
> > @@ -499,7 +499,7 @@ ifeq (,$(firstword $(EXPORTED_SYMBOLS))) 
> >   		 echo "	local:"; echo "		*;"; echo "};") > $@ 
> >   else 
> >   	set -e;\ 
> > -	R=$$(sort $^ | uniq -u);\ 
> > +	R="$$(sort $^ | uniq -u)";\ 
> >   	test -z "$$R" || { echo "Mismatch between symbols in shared library and  
> lists in .exported_symbols.* files: $$R"; false; } ;\ 
> >   	for i in $(EXPORTED_SYMBOLS); do\ 
> >   		echo "$${i##*.} {"; echo "	global:";\ 
>  
> Hi 
>  
> Do you have some example where it fails without "" ? 
> Bash normally should assign $VARS directly. 
Hi  Zdenek,

As the `echo` outputs, if there are more symbols got from `sort $^ | uniq -u`, there will be 
an bash error.
I found this exactly because I forgot to add these symbols to .exported_symbols.* files.

Regards,
Lidong
>  
> Zdenek 
>  
>  
>  
>  
> -- 
> lvm-devel mailing list 
> lvm-devel at redhat.com 
> https://www.redhat.com/mailman/listinfo/lvm-devel 
>  
>  




