From: Ming Hung Tsai <mtsai@redhat.com>
Date: Wed, 26 Apr 2023 20:06:32 +0800
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
Message-ID: <CALjSBEtX4KONt4=EU40Wu2qx+UmX3k85B5cYcjOZMY+XoAMUBQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

On Tue, Apr 25, 2023 at 9:54?PM haaber <haaber@web.de> wrote:
>
> Dear all,
>
> I had a lethally bad hardware failure and to replace the machine.  Now I try to get some data back that is not contained in half-year backups ... (I know! but it's too late to be sorry). OK,  the old SSD is attached  via usb adapter to a brand new machine. I started
>
> sudo pvscan
> sudo vgscan --mknodes
> sudo vgchange -ay
>
> Here is the  unexpected output:
>
>   PV /dev/mapper/OLDSSD   VG   vg0       lvm2 [238.27 GiB / <15.79 GiB free]
>    Total: 1 [238.27 GiB] / in use: 1 [238.27 GiB] / in no VG: 0 [0   ]
>    Found volume group "vg0" using metadata type lvm2
>    Check of pool vg0/pool00 failed (status:1). Manual repair required!
>    1 logical volume(s) in volume group "vg0" now active
>
> then I consulted dr. google for diagnosis, but found only little help. This one
>
> https://mellowhost.com/billing/index.php?rp=/knowledgebase/65/How-to-Repair-a-lvm-thin-pool.html
>
> suggested to deactivate all sub-volumes so that a repair can work correctly. It happened that only swap was
> active, so I deactivated it. But repair does still not work:
>
> lvconvert --repair vg0/pool00
> terminate called after throwing an instance of 'std::runtime_error'
>    what():  transaction_manager::new_block() couldn't allocate new block
>    Child 21255 exited abnormally
>    Repair of thin metadata volume of thin pool vg0/pool00 failed
> (status:-1). Manual repair required!
>
>
> I would like to find a good soul out there that can give more hints. In particular,
> could it be a metadata overflow? How to check? I seek not for repair, but a "once only"
> read access to the pool data ....

That should be the 'metadata overflow' you're referring to, i.e.,
running out of metadata space. By default, lvconvert allocates a new
metadata volume of the same size, and that might not be sufficient for
restoring a bulk of snapshots. The new version of
thin-provisioning-tools (1.0.x) has addressed this issue, so you could
give it a try. Alternatively, you might have to run thin_repair
manually on a larger metadata volume if you want to stick with the
current version.


Ming-Hung Tsai

