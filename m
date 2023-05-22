From: Ming Hung Tsai <mtsai@redhat.com>
Date: Mon, 22 May 2023 15:40:50 +0800
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <2a1a3e85-ba19-5f79-735e-fe518aa03b94@web.de>
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
 <2a1a3e85-ba19-5f79-735e-fe518aa03b94@web.de>
Message-ID: <CALjSBEsSC4X7aeZuNRuTjhY9OZ6d_z=PymBycQ+sBh0ftzmrGQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

There's a debug option `-v` for thin_dump/thin_repair to show verbose logs
including repairing details. In your case, you should see one compatible
root pair found in your metadata:

```
compatible roots (1):
(1150, 7643)
```

Once you had thin_repair'ed the metadata, you could swap the repaired one
into the pool by using lvconvert:

`lvconvert qubes_dom0/pool00 --swapmetadata --poolmetadata qubes_dom0/newlv`

The two volumes "pool00_tmeta" and "newlv" then will have their names
swapped, i.e., "newlv" becomes "pool00_tmeta" and the original
"pool00_tmeta" becomes "newlv", so you have the backup.


On Mon, May 22, 2023 at 2:57?PM haaber <haaber@web.de> wrote:

> Hi Ming
>
> thank you so much. I compiled it, and did make install, but lvconvert is
> still the old one. It should be possible to do the job with   pdata_tools
> directly, right !?  I had formerly created a
> "newlv" inside my qubes_dom0 pool, so I did   run
>
> ./pdata_tools  thin_repair -i /dev/qubes_dom0/pool00_tmeta   -o
> /dev/qubes_dom0/newlv
>
> that command worked 5 seconds, and came back without any notice, which
> usually is good sign. I did not run it with a verbose flag, stupid me.
>
> Can I now run some command that activates the pool with "newlv" as
> metadata ? Or backup the old metadata file, and then copy "newlv" metadata
> into the pool00_tmeta ? I am, of course,  afraid of destroying it all, so
> close to  the end, so I better ask once more  :-)
>
> best, Bernhard
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230522/3f4a66ed/attachment.htm>
