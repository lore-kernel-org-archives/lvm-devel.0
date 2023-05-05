From: Ming Hung Tsai <mtsai@redhat.com>
Date: Sat, 6 May 2023 00:25:03 +0800
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <2b1b2d49-fe46-e544-03d3-79b831df4a52@gmail.com>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
 <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
 <0c82e706-8051-d131-91fb-f8f5556d88e7@web.de>
 <0780dc89-f6b8-e204-18c3-12e404aeaaff@gmail.com>
 <6c1b291d-b4e4-4698-b9b4-63c43e9e484d@web.de>
 <2b1b2d49-fe46-e544-03d3-79b831df4a52@gmail.com>
Message-ID: <CALjSBEvZUKygHzzMyA2Ga+kqTHV911Jofox91Q8UzDC-cb3OQg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RHEL & Fedora RPMs already have the thin_metadata_pack/unpack tools
integrated. Other distros may offer the tools if they had updated the
package to v1.0.x

On Fri, May 5, 2023 at 11:08?PM Zdenek Kabelac

> Hi
>
> We need the exact binary copy of _tmeta  LV  - thus just use
>
> dd if=/dev/qubes_dom0/pool00_tmeta  /tmp/tmeta_copy  bs=512K
> bzip2 /tmp/tmeta_copy
>
> With this data - also provide full lvm2 metadata for this VG
> (should be as a file in  /etc/lvm/backup  - or you could run
> just vgcfgbackup)
>
> thin_dump is already 'processed' result - so not usable for futher
> investigation.
>
> (Although it might interesting idea to add some 'option' to actually
> provide
> the above 'binary backup' is  built-in feature of this tool for bug
> reporting...)
>
>
> Regards
>
> Zdenek
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230506/fd287b37/attachment.htm>
