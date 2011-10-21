From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 21 Oct 2011 12:55:30 +0200
Subject: [PATCH] Add configure option to select default run directory base and prepare for early /run use
In-Reply-To: <4EA1404A.5020500@redhat.com>
References: <4EA1404A.5020500@redhat.com>
Message-ID: <4EA14FA2.9030705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 21.10.2011 11:50, Peter Rajnoha napsal(a):
> On systemd-enabled systems the /run is writeable and it's accessible early on
> boot so we don't need to use --sysinit anymore on early boot's vgchange call
> (the --sysint is just a shortcut for --ignorelockingfailure, --ignoremonitoring,
> --poll n and setting the LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES).
> 
> This patch adds a new configure option "--with-default-run-dir-base" with which
> it's possible to change the run directory base for all directories/files that
> need to be moved to /run in one go easily.
> 
> This patch also removes some hardcoded defines (in dmeventd.h and dm-event.socket
> files used for systemd).
> 
> The patch also changes the dependencies a bit (in Fedora, but the same logic
> applies anywhere):
> 
> originally:
> 
>   <dm-event.socket>
>   ...
>   fedora-wait-storage.service
>   fedora-storage-init.service (calling vgchange -a y --sysinit)
>   dm-event.service
>   lvm2-monitor.service
> 
> changing to:
> 
>   <dm-event.socket>
>   ...
>   fedora-wait-storage.service
>   dm-event.service
>   fedora-storage-init.service (calling vgchange -a y, without --sysinit!!!)
>   lvm2-monitor.service (this is just for proper shutdown now since the dmevent
>                         registration will happen within the vgchange -a y call
>                         in previous step)
> 
> 
> (For FIFO-based activation, the fifos are already prepared and hence the
> dm-event service could be spawned already)
> 
> Once we have this patch upstream and in the distro, we can remove the --sysinit
> from the vgchange call.
> 
> Peter
> ---
> 
>  configure.in                                |   29 +++++++++++++++++++-------
>  daemons/dmeventd/dmeventd.h                 |    4 +-
>  lib/misc/configure.h.in                     |    3 ++
>  make.tmpl.in                                |    1 +
>  scripts/dm_event_systemd_red_hat.service.in |    4 +-
>  scripts/dm_event_systemd_red_hat.socket     |   11 ----------
>  scripts/dm_event_systemd_red_hat.socket.in  |   11 ++++++++++
>  7 files changed, 40 insertions(+), 23 deletions(-)
> 
> diff --git a/configure.in b/configure.in
> index 5275b95..26eb268 100644
> --- a/configure.in
> +++ b/configure.in
> @@ -425,6 +425,17 @@ AC_ARG_WITH(ocfdir,
>  	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
>  

>  fi
> @@ -1214,9 +1225,9 @@ fi
>  
>  AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default run directory.])
>  AC_ARG_WITH(default-run-dir,
> -	    [  --with-default-run-dir=DIR       Default run directory [[/var/run/lvm]] ],
> +	    [  --with-default-run-dir=DIR       Default run directory [[RDIR/lvm]] ],
>  	    [ DEFAULT_RUN_DIR="$withval" ],
> -	    [ DEFAULT_RUN_DIR="/var/run/lvm" ])
> +	    [ DEFAULT_RUN_DIR="$DEFAULT_RUN_DIR_BASE/lvm" ])
>  AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR,["$DEFAULT_RUN_DIR"] )
>  


I guess we should stay with just one place to configure /var/run

So I'd replace DEFAULT_RUN_DIR usage in the code  with  DEFAULT_RUN_DIR/lvm
and use just this define.

It should be backward compatible - so if someone configured it before - he
will just get there extra lvm subdir - but this shouldn't cause problems.

With double configuration for run dir it's getting way too complex.

Zdenek


