From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Fri, 28 Jan 2022 16:33:40 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <20220128134229.1783-1-mwilck@suse.com>
References: <20220128134229.1783-1-mwilck@suse.com>
Message-ID: <10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28. 01. 22 v 14:42 mwilck at suse.com napsal(a):
> From: Martin Wilck <mwilck@suse.com>
> 
> If a dm device is suspended, we can't run blkid on it. But earlier
> rules (e.g. 11-dm-parts.rules) might have imported previously scanned
> properties from the udev db, in particular if the device had been correctly
> set up beforehand (DM_UDEV_PRIMARY_SOURCE_FLAG==1). Symlinks for existing
> ID_FS_xyz properties must be preserved in this case. Otherwise lower-priority
> devices (such as multipath components) might take over the symlink
> temporarily.
> 
> Likewise, we should't stop watching a temporarily suspended, but previously
> correctly configured dm device.


I'm a bit confused here what is the purpose of this patch.

blkid is supposed to scan 'every' disk it's told to scan -  if device is 
suspend - blkid shall fait till it's resumed.

Suspend operation itself is meant to be quick - and process suspending any 
device should be doing it rather 'quickly'  (aka reload DM table)

So now - how do you get 'suspended' devices that are blocking blkid ?

lvm2 has implemented some sort of 'optional' hack to avoid scanning suspended 
devices - but this shouldn't be normally needed - unless your system is flawed 
with some set of suspended devices (maybe from some crashed lvm command).

Regards

Zdenek


