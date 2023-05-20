From: haaber <haaber@web.de>
Date: Sat, 20 May 2023 22:34:55 +0200
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <CALjSBEsTnEdGx70-QFz-pLO42he=O1-dys9iRcg7ytKk8SnKKQ@mail.gmail.com>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
 <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
 <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
 <6c1b291d-b4e4-4698-b9b4-63c43e9e484d@web.de>
 <2b1b2d49-fe46-e544-03d3-79b831df4a52@gmail.com>
 <3ce7f8b3-8c37-8b5f-a4f4-b088baedbb65@web.de>
 <CALjSBEsTnEdGx70-QFz-pLO42he=O1-dys9iRcg7ytKk8SnKKQ@mail.gmail.com>
Message-ID: <2a1a3e85-ba19-5f79-735e-fe518aa03b94@web.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Ming

thank you so much. I compiled it, and did make install, but lvconvert is
still the old one. It should be possible to do the job with ?
pdata_tools? directly, right !?? I had formerly created a
"newlv" inside my qubes_dom0 pool, so I did?? run

./pdata_tools? thin_repair -i /dev/qubes_dom0/pool00_tmeta?? -o
/dev/qubes_dom0/newlv

that command worked 5 seconds, and came back without any notice, which
usually is good sign. I did not run it with a verbose flag, stupid me.

Can I now run some command that activates the pool with "newlv" as
metadata ? Or backup the old metadata file, and then copy "newlv"
metadata into the pool00_tmeta ? I am, of course,? afraid of destroying
it all, so close to? the end, so I better ask once more? :-)

best, Bernhard




On 5/17/23 17:17, Ming Hung Tsai wrote:
> Hi,
>
> I've pushed the changes upstream. Now you should be able to repair the
> pool via "lvconvert --repair" after installation.
>
> On Thu, May 11, 2023 at 3:39?PM haaber <haaber@web.de> wrote:
>
>     Dear all,
>
>     We need the exact binary copy of _tmeta? LV? - thus just use
>     >
>     > dd if=/dev/qubes_dom0/pool00_tmeta? /tmp/tmeta_copy bs=512K
>     > bzip2 /tmp/tmeta_copy
>     >
>     the output is here: https://we.tl/t-AEmlc5CYeH
>
>     > With this data - also provide full lvm2 metadata for this VG
>     > (should be as a file in? /etc/lvm/backup? - or you could run
>     > just vgcfgbackup)
>     >
>     I attached that one directly. Thank you very much!
>
>     best, Bernhard
>
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://listman.redhat.com/mailman/listinfo/lvm-devel
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230520/47f3e0ff/attachment.htm>
