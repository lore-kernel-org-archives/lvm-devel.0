From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 11 Jan 2011 11:26:14 +0100
Subject: [PATCH 1 of 4] LVM: cleanup 1
In-Reply-To: <201101102056.p0AKuRxu011888@hydrogen.msp.redhat.com>
References: <201101102056.p0AKuRxu011888@hydrogen.msp.redhat.com>
Message-ID: <4D2C3046.9020800@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10.1.2011 21:56, Jonathan Brassow napsal(a):
> Patch name: lvm-cleanup-1.patch
> 
> lvcreate() does a 'memset(&lp, 0, sizeof(lp))', which is done by very
> next function called.  No need to do it twice.
> 
> Index: LVM2/tools/lvcreate.c
> ===================================================================
> --- LVM2.orig/tools/lvcreate.c
> +++ LVM2/tools/lvcreate.c
> @@ -538,8 +538,6 @@ int lvcreate(struct cmd_context *cmd, in
>  	struct lvcreate_cmdline_params lcp;
>  	struct volume_group *vg;
>  
> -	memset(&lp, 0, sizeof(lp));
> -
>  	if (!_lvcreate_params(&lp, &lcp, cmd, argc, argv))
>  		return EINVALID_CMD_LINE;

Ack

Valid and we already do the same with  lcp.

Zdenek


