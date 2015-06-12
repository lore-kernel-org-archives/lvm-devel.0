From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Jun 2015 17:51:59 +0200
Subject: [PATCH] makefile: fail to compile if there are more than one exported symbols.
In-Reply-To: <1434094405-8391-1-git-send-email-lzhong@suse.com>
References: <1434094405-8391-1-git-send-email-lzhong@suse.com>
Message-ID: <557B001F.30804@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.6.2015 v 09:33 Lidong Zhong napsal(a):
> ---
>   make.tmpl.in | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/make.tmpl.in b/make.tmpl.in
> index 731dab7..60ddd01 100644
> --- a/make.tmpl.in
> +++ b/make.tmpl.in
> @@ -499,7 +499,7 @@ ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
>   		 echo "	local:"; echo "		*;"; echo "};") > $@
>   else
>   	set -e;\
> -	R=$$(sort $^ | uniq -u);\
> +	R="$$(sort $^ | uniq -u)";\
>   	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
>   	for i in $(EXPORTED_SYMBOLS); do\
>   		echo "$${i##*.} {"; echo "	global:";\

Hi

Do you have some example where it fails without "" ?
Bash normally should assign $VARS directly.

Zdenek





