From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Jun 2010 10:34:39 +0200
Subject: [PATCH] Fix typo in vgchange command
In-Reply-To: <4C214C09.9010808@redhat.com>
References: <4C214C09.9010808@redhat.com>
Message-ID: <4C21C71F.2070602@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23.6.2010 01:49, Takahiro Yasui napsal(a):
> Fix typo: premitted ->  permitted
>
> Signed-off-by: Takahiro Yasui<tyasui@redhat.com>
> ---
>   tools/vgchange.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: LVM2-2.02.67/tools/vgchange.c
> ===================================================================
> --- LVM2-2.02.67.orig/tools/vgchange.c
> +++ LVM2-2.02.67/tools/vgchange.c
> @@ -627,7 +627,7 @@ int vgchange(struct cmd_context *cmd, in
>
>   	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
>   	     arg_count(cmd, sysinit_ARG))&&  !arg_count(cmd, available_ARG)) {
> -		log_error("Only -a premitted with --ignorelockingfailure and --sysinit");
> +		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
>   		return EINVALID_CMD_LINE;
>   	}

Ack

Zdenek


