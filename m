From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 12 Aug 2015 09:35:02 +0200
Subject: [PATCH] udev: Do not override SYSTEMD_WANTS environment variable
In-Reply-To: <1439279042-2040-1-git-send-email-thomas@archlinux.org>
References: <1439279042-2040-1-git-send-email-thomas@archlinux.org>
Message-ID: <55CAF726.5080907@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/11/2015 09:44 AM, Thomas B?chler wrote:
> Instead of using = to override SYSTEMD_WANTS, use += to add the pvscan service.
> ---
>  udev/Makefile.in | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/udev/Makefile.in b/udev/Makefile.in
> index 390069b..c4cc2bd 100644
> --- a/udev/Makefile.in
> +++ b/udev/Makefile.in
> @@ -47,7 +47,7 @@ BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
>  endif
>  
>  ifeq ("@UDEV_SYSTEMD_BACKGROUND_JOBS@", "yes")
> -PVSCAN_RULE=ACTION\!=\"remove\", ENV{LVM_PV_GONE}==\"1\", RUN\+=\"@bindir@/systemd-run $(LVM_EXEC)\/lvm pvscan --cache \$$major\:\$$minor\", GOTO=\"lvm_end\"\nENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}=\"lvm2-pvscan@\$$major:\$$minor.service\"
> +PVSCAN_RULE=ACTION\!=\"remove\", ENV{LVM_PV_GONE}==\"1\", RUN\+=\"@bindir@/systemd-run $(LVM_EXEC)\/lvm pvscan --cache \$$major\:\$$minor\", GOTO=\"lvm_end\"\nENV{SYSTEMD_ALIAS}=\"\/dev\/block\/\$$major:\$$minor\"\nENV{ID_MODEL}=\"LVM PV \$$env{ID_FS_UUID_ENC} on \/dev\/\$$name\"\nENV{SYSTEMD_WANTS}+=\"lvm2-pvscan@\$$major:\$$minor.service\"
>  else
>  PVSCAN_RULE=RUN\+\=\"$(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major \$$major --minor \$$minor\", ENV{LVM_SCANNED}=\"1\"
>  endif
> 

Nice catch! Applied. Thanks!

https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=3ea396e9d220cec55fd4e139be7ae486cb4ddb91

-- 
Peter


