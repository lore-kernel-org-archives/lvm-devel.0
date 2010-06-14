From: Milan Broz <mbroz@redhat.com>
Date: Mon, 14 Jun 2010 16:26:48 +0200
Subject: [PATCH] Fix udev rules to take into account recent changes in udev and deal with coldplug problem at boot
In-Reply-To: <4C163459.10005@redhat.com>
References: <4C163459.10005@redhat.com>
Message-ID: <4C163C28.5030600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/14/2010 03:53 PM, Peter Rajnoha wrote:

> +# Normally, we operate on "change" events. But when coldplugging, there's an
> +# "add" event present. We have to recognize this and do our actions in this
> +# particular situation, too. Also, we don't want the nodes to be created
> +# prematurely on "add" events while not coldplugging. We check
> +# DM_UDEV_PRIMARY_SOURCE_FLAG to see if the device was activated correctly
> +# before and if not, we ignore the "add" event totally. This way we can support
> +# udev triggers generating "add" events (e.g. "udevadm trigger --action=add" or
> +# "echo add > /sys/block/<dm_device>/uevent"). The trigger with "add" event is
> +# also used at boot to reevaluate udev rules for all existing devices activated
> +# before (e.g. in initrd). If udev is used in initrd, we require the udev init
> +# script to not remove the existing udev database so we can reuse the information
> +# stored at the time of device activation in the initrd.
> +ACTION=="add", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}!="1", GOTO="dm_disable"

Addendum for a gentle reviewer:

GOTO="dm_disable" sets these values to safe defaults, so other rules
can ignore that event for dm device as well (e.g. udisks):

LABEL="dm_disable"                                                                                                                                                                      
ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}="1"
ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"


Ack.

Milan


