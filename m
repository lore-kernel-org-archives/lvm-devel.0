From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 14 May 2010 00:47:11 +0100
Subject: LVM2 ./WHATS_NEW lib/activate/activate.h lib/a ...
In-Reply-To: <20100513183841.1542.qmail@sourceware.org>
References: <20100513183841.1542.qmail@sourceware.org>
Message-ID: <20100513234711.GP2377@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, May 13, 2010 at 06:38:41PM -0000, mbroz at sourceware.org wrote:
> +	/* Check internal lvm devices */
> +	if (is_reserved_lvname(name) && uuid &&
> +	    !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
> +		log_debug("%s: Reserved internal LVM device not usable.", dev_name(dev));
> +		goto out;
> +	}

Mixing up types there.
name is a dm device name

is_reserved_lvname() accepts an lvname.

They are not the same thing.

E.g. A simple test gives me this bogus error:
  /dev/mapper/pvmove-lvol0: Reserved internal LVM device not usable.

Either perform a type conversion (e.g. using dm_split_lvm_name) or add a
specialist validation function (e.g. move the layer suffix checks out to
a separate shared fn and only pass the LV name part for checking; it
wouldn't be necessary to un-escape the hyphens, but you would have to
parse them properly to find the start of the LV name).

Another matter we need to consider is this:
     # If, while scanning the system for PVs, LVM2 encounters a device-mapper
     # device that has its I/O suspended, it waits for it to become accessible.
     # Set this to 1 to skip such devices.  This should only be needed
     # in recovery situations.
     ignore_suspended_devices = 0

i.e. The default is *disabled*.  (Well, dmeventd may always enable it of
course.)

But should the new check in this patch be independent of that setting and
be *always* enabled?

Alasdair


