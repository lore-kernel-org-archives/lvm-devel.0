From: NeilBrown <neilb@suse.de>
Date: Thu, 17 Feb 2022 09:09:28 +1100
Subject: [PATCH] udev-md-raid-assembly.rules: skip if DM_UDEV_DISABLE_OTHER_RULES_FLAG
In-Reply-To: <20220216205914.7575-1-mwilck@suse.com>
References: <20220216205914.7575-1-mwilck@suse.com>
Message-ID: <164504936873.10228.7361167610237544463@noble.neil.brown.name>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 17 Feb 2022, mwilck at suse.com wrote:
> From: Martin Wilck <mwilck@suse.com>
> 
> device-mapper sets the flag DM_UDEV_DISABLE_OTHER_RULES_FLAG to 1 for
> devices which are unusable. They may be no set up yet, suspended, or
> otherwise unusable (e.g. multipath maps without usable path). This
> flag does not necessarily imply SYSTEMD_READY=0 and must therefore
> be tested separately.

I really don't like this - looks like a hack.  A Kludge.

Can you provide a reference to a detailed discussion that explains why
SYSTEMD_READY=0 cannot be used?

Thanks,
NeilBrown


> 
> Signed-off-by: Martin Wilck <mwilck@suse.com>
> ---
>  udev-md-raid-assembly.rules | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/udev-md-raid-assembly.rules b/udev-md-raid-assembly.rules
> index d668cdd..4568b01 100644
> --- a/udev-md-raid-assembly.rules
> +++ b/udev-md-raid-assembly.rules
> @@ -21,6 +21,11 @@ IMPORT{cmdline}="noiswmd"
>  IMPORT{cmdline}="nodmraid"
>  
>  ENV{nodmraid}=="?*", GOTO="md_inc_end"
> +
> +# device mapper sets DM_UDEV_DISABLE_OTHER_RULES_FLAG for devices which
> +# aren't ready to use
> +KERNEL=="dm-*", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="md_inc_end"
> +
>  ENV{ID_FS_TYPE}=="ddf_raid_member", GOTO="md_inc"
>  ENV{noiswmd}=="?*", GOTO="md_inc_end"
>  ENV{ID_FS_TYPE}=="isw_raid_member", ACTION!="change", GOTO="md_inc"
> -- 
> 2.35.1
> 
> 



