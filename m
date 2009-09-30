From: Petr Rockai <prockai@redhat.com>
Date: Wed, 30 Sep 2009 22:24:36 +0200
Subject: [RFC][PATCH 1/5] support command string with space
In-Reply-To: <4AC2A619.50404@redhat.com> (Takahiro Yasui's message of "Tue, 29
	Sep 2009 20:28:09 -0400")
References: <4AC2A619.50404@redhat.com>
Message-ID: <878wfwdvuj.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui <tyasui@redhat.com> writes:

> Support escaped space by backslash in the command line string passed
> through lvm2 command interface, lvm2_run(). This is used to handle
> "--config" option which contains multiple parameters.
>
> e.g. lvconvert --repair --use-policies --config \
>      devices{ignore_suspended_devices=1\ filter=[...]} vg/lv
>
>
> Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
> ---
>  tools/lvmcmdline.c |    9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> Index: LVM2.02.54-20090928/tools/lvmcmdline.c
> ===================================================================
> --- LVM2.02.54-20090928.orig/tools/lvmcmdline.c
> +++ LVM2.02.54-20090928/tools/lvmcmdline.c
> @@ -1070,8 +1070,15 @@ int lvm_split(char *str, int *argc, char
>  			break;
>  
>  		e = b;
> -		while (*e && !isspace(*e))
> +		while (*e && !isspace(*e)) {
> +			/*
> +			 * 'backslash' is treated as a escape character
> +			 * and the string isn't split at 'backslash + space.'
> +			 */
> +			if (*e == '\\' && isspace(*(e+1)))
> +				*e++ = ' ';
>  			e++;
> +		}
>  
>  		argv[(*argc)++] = b;
>  		if (!*e)
IIUIC, the code will replace "\ " with "  " (double space) -- which may or may
not be correct, depending on where the space appears. It also breaks any code
that may have previously expected "\ " to have no special meaning, even though I
doubt any exists.

Anyway, a more correct solution would entail a lvm2_runv (or similarly named)
function, that would take char **argv -- no escaping issues to care
about. Since this just adds to the library, it should be backwards compatible
just fine.

Yours,
   Petr.


