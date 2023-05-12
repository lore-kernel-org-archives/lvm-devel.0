From: Ming Hung Tsai <mtsai@redhat.com>
Date: Fri, 12 May 2023 11:29:48 +0800
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <3ce7f8b3-8c37-8b5f-a4f4-b088baedbb65@web.de>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
 <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
 <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
 <6c1b291d-b4e4-4698-b9b4-63c43e9e484d@web.de>
 <2b1b2d49-fe46-e544-03d3-79b831df4a52@gmail.com>
 <3ce7f8b3-8c37-8b5f-a4f4-b088baedbb65@web.de>
Message-ID: <CALjSBEtkaooosocEAOpa9uuA0d_dYVLhbkfRbTSHGnuixPAyUg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

There's one corrupted leaf node in device #20081, which might possibly be
caused by the hardware failure and that stops thin_dump or lvconvert from
working. Running thin_check would show you the details (I'm using the
v1.0.5):

TRANSACTION_ID=45452
METADATA_FREE_BLOCKS=11827
1 nodes in data mapping tree contain errors
0 io errors, 1 checksum errors
Thin device 20081 has 1 error nodes and is missing 22664 mappings, while
expected 296263
Check of mappings failed

The issue is repairable by rolling back to the previous transaction. I'm
going to patch the program to make it easier to use. It should be ready
next week, and you can try to learn how to build the Rust version for now.

1. Install the Rust toolchain via the rustup script (https://rustup.rs/)
2. Clone the thin-provisioning-tools.git repo, then build it (cargo build
--release)
3. Try the built pdata_tools binary (placed under ./target/release/)


Ming-Hung Tsai

On Thu, May 11, 2023 at 3:39?PM haaber <haaber@web.de> wrote:

> Dear all,
>
> We need the exact binary copy of _tmeta  LV  - thus just use
> >
> > dd if=/dev/qubes_dom0/pool00_tmeta  /tmp/tmeta_copy  bs=512K
> > bzip2 /tmp/tmeta_copy
> >
> the output is here: https://we.tl/t-AEmlc5CYeH
>
> > With this data - also provide full lvm2 metadata for this VG
> > (should be as a file in  /etc/lvm/backup  - or you could run
> > just vgcfgbackup)
> >
> I attached that one directly. Thank you very much!
>
> best, Bernhard
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230512/8865d41b/attachment.htm>
