From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Apr 2010 16:56:49 +0200
Subject: [PATCH] Utilize new IMPORT{db} udev rule to repopulate udev db for spurious events
In-Reply-To: <4BCDBF80.3010902@redhat.com>
References: <4BCDBF80.3010902@redhat.com>
Message-ID: <4BCDC0B1.1080302@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/20/2010 04:51 PM, Peter Rajnoha wrote:
> +IMPORT{db}="DM_UDEV_DISABLE_DM_RULES_FLAG"
> +IMPORT{db}="DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG"
> +IMPORT{db}="DM_UDEV_DISABLE_DISK_RULES_FLAG"
> +IMPORT{db}="DM_UDEV_DISABLE_OTHER_RULES_FLAG"
> +IMPORT{db}="DM_UDEV_LOW_PRIORITY_FLAG"
> +IMPORT{db}="DM_UDEV_DISABLE_LIBRARY_FALLBACK_FLAG"
> +IMPORT{db}="DM_UDEV_FLAG7"
> +IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG0"
> +IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG1"
> +IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG2"
> +IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG3"
> +IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG4"
> +IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG5"
> +IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG6"
> +IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG7"

...just for the record - the IMPORT{db} rule does not support
pattern matching (not now at least), so that's the reason why
I have to write it this way instead of something like
IMPORT{db}="DM_*_FLAG".

Peter


