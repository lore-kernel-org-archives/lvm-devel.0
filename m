From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 29 Oct 2010 16:44:56 -0400
Subject: Patch for fsadm bz 64146
In-Reply-To: <4CCB2668.8020809@redhat.com>
References: <4CCB2668.8020809@redhat.com>
Message-ID: <20101029204456.GB26687@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 29 2010 at  3:54pm -0400,
Zdenek Kabelac <zkabelac@redhat.com> wrote:

> This patch address problem from  BZ 64146.
> 
> Instead of leaving lvresize to fail when running on the mounted fs (user
> expects online resize to happen and it's currently possible only with -n
> option) - this patch changes 'fsadm check' behavior so it returns success for
> mounted  filesystem. This allows lvresize to processed further and run the
> online resize even without passing -n option.
> 
> Anyone sees this modified behavior of fsadm script as a problem ?
> (change success for mounted fs).
> 
> Zdenek

> Index: scripts/fsadm.sh
> ===================================================================
> RCS file: /cvs/lvm2/LVM2/scripts/fsadm.sh,v
> retrieving revision 1.20
> diff -u -p -r1.20 fsadm.sh
> --- scripts/fsadm.sh	8 Oct 2010 15:02:05 -0000	1.20
> +++ scripts/fsadm.sh	29 Oct 2010 19:43:33 -0000
> @@ -365,7 +365,10 @@ resize() {
>  ###################
>  check() {
>  	detect_fs "$1"
> -	detect_mounted && error "Cannot fsck device \"$VOLUME\", filesystem is mounted on $MOUNTED"
> +	if detect_mounted ; then
> +		verbose "Skipping fsck device \"$VOLUME\" as filesystem is mounted on $MOUNTED";

I think the verbose message should be:
"Skipping fsck for device \"$VOLUME\" as filesystem is mounted on $MOUNTED"

Mike


