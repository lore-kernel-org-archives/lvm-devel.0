From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 22 Jan 2009 11:13:57 -0500
Subject: [PATCH 12/14] Port process_each_pv to new vg_read.
In-Reply-To: <1232619010-4858-13-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
	<1232619010-4858-5-git-send-email-prockai@redhat.com>
	<1232619010-4858-6-git-send-email-prockai@redhat.com>
	<1232619010-4858-7-git-send-email-prockai@redhat.com>
	<1232619010-4858-8-git-send-email-prockai@redhat.com>
	<1232619010-4858-9-git-send-email-prockai@redhat.com>
	<1232619010-4858-10-git-send-email-prockai@redhat.com>
	<1232619010-4858-11-git-send-email-prockai@redhat.com>
	<1232619010-4858-12-git-send-email-prockai@redhat.com>
	<1232619010-4858-13-git-send-email-prockai@redhat.com>
Message-ID: <1232640838.8897.3.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2009-01-22 at 11:10 +0100, Petr Rockai wrote:
>  
>  int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
> -		    struct volume_group *vg, uint32_t lock_type, void *handle,
> +		    struct volume_group *vg, uint32_t flags, void *handle,
>  		    int (*process_single) (struct cmd_context * cmd,
>  					   struct volume_group * vg,
>  					   struct physical_volume * pv,
> @@ -673,25 +673,11 @@ int process_each_pv(struct cmd_context *
>  		if (!dm_list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
>  			   !dm_list_empty(vgnames)) {
>  			dm_list_iterate_items(sll, vgnames) {
> -				if (!lock_vol(cmd, sll->str, lock_type)) {
> -					log_error("Can't lock %s: skipping", sll->str);
> -					continue;
> -				}
> -				if (!(vg = vg_read_internal(cmd, sll->str, NULL, &consistent))) {
> -					log_error("Volume group \"%s\" not found", sll->str);
> -					unlock_vg(cmd, sll->str);
> +				vg = vg_read(cmd, sll->str, NULL, flags);
> +				if (vg_read_error(vg)) {
>  					ret_max = ECMD_FAILED;
>  					continue;
>  				}
> -				if (!consistent) {
> -					unlock_vg(cmd, sll->str);
> -					continue;
> -				}
> -
> -				if (!vg_check_status(vg, CLUSTERED)) {
> -					unlock_vg(cmd, sll->str);
> -					continue;
> -				}
>  
>  				ret = process_each_pv_in_vg(cmd, vg, &tags,
>  							    handle,

'consistent' declaration can be removed (saw it when I compiled).

Not critical to the patch though here's an updated patch with this one
line removed.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-Port-process_each_pv-to-new-vg_read.patch
Type: application/mbox
Size: 4475 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090122/c23defaa/attachment.mbox>
