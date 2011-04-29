From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Apr 2011 14:24:20 +0200
Subject: LVM2/lib locking/locking.c locking/locking.h m ...
In-Reply-To: <20110428203001.9308.qmail@sourceware.org>
References: <20110428203001.9308.qmail@sourceware.org>
Message-ID: <4DBAADF4.2060507@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28.4.2011 22:30, agk at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	agk at sourceware.org	2011-04-28 20:30:00
> 
> Modified files:
> 	lib/locking    : locking.c locking.h 
> 	lib/metadata   : metadata-exported.h mirror.c 
> 	lib/mm         : memlock.h 
> 
> Log message:
> 	clean up critical section patch
>  
> --- LVM2/lib/locking/locking.c	2011/02/18 14:16:12	1.93
> +++ LVM2/lib/locking/locking.c	2011/04/28 20:29:59	1.94
> @@ -574,11 +574,13 @@
>  int sync_local_dev_names(struct cmd_context* cmd)
>  {
>  	memlock_unlock(cmd);
> -	return lock_vol(cmd, VG_SYNC_NAMES, LCK_NONE | LCK_CACHE | LCK_LOCAL);
> +
> +	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC_LOCAL);
>  }

I believe we have decided here we will move into this direction.


>  
> +#define LCK_VG_SYNC		(LCK_NONE | LCK_CACHE)
> +#define LCK_VG_SYNC_LOCAL	(LCK_NONE | LCK_CACHE | LCK_LOCAL)
> +
>  #define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL)
>  #define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE)
>  #define LCK_LV_RESUME		(LCK_LV | LCK_UNLOCK)

So instead of using this 'lock_vol()' constants  - we will switch into


>  int sync_local_dev_names(struct cmd_context* cmd);
>  int sync_dev_names(struct cmd_context* cmd);

function calls - so the setting flags will disappear from generally used
header file and will be private to .c implementation.

I think this 'cleanup' patch is rather going in opposite direction ?

Zdenek

