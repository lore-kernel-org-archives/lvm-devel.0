From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 Jul 2011 13:09:26 +0200
Subject: Do not decode DM flags for device removal
In-Reply-To: <4E2989DC.7070105@gmail.com>
References: <4E2989DC.7070105@gmail.com>
Message-ID: <4E2D4EE6.5010204@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
> index 606a13d..9e8ad0f 100644
> --- a/udev/10-dm.rules.in
> +++ b/udev/10-dm.rules.in
> @@ -24,12 +24,6 @@ ENV{DM_SBIN_PATH}="/sbin"
>  TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
>  TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
>  
> -# Decode udev control flags and set environment variables appropriately.
> -# These flags are encoded in DM_COOKIE variable that was introduced in
> -# kernel version 2.6.31. Therefore, we can use this feature with
> -# kernels >= 2.6.31 only.
> -ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
> -
>  # Device created, major and minor number assigned - "add" event generated.
>  # Table loaded - no event generated.
>  # Device resumed (or renamed) - "change" event generated.
> @@ -42,6 +36,12 @@ ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env
>  # is not recommended.
>  ACTION!="add|change", GOTO="dm_end"
>  
> +# Decode udev control flags and set environment variables appropriately.
> +# These flags are encoded in DM_COOKIE variable that was introduced in
> +# kernel version 2.6.31. Therefore, we can use this feature with
> +# kernels >= 2.6.31 only.
> +ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
> +
>  # Rule out easy-to-detect inappropriate events first.
>  ENV{DISK_RO}=="1", GOTO="dm_disable"

Well, for now, this is OK since nobody does any particular action on REMOVE
uevent, neither do we. So we don't actually need to decode any flags, that's
true. But what if someone adds a hook in the future? We also need to consider
any subsystem that makes use of libdevmapper.

So I'd say fine for now, but once there's a hook on REMOVE event anywhere,
expecting the flags to be decoded, we need to take care of proper dependencies
(among foreign packages vs. libdevmapper) if we revert this change back then.

Peter


