From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Thu, 16 Mar 2023 08:15:41 +0530
Subject: Reg lvm vg private spare vol
Message-ID: <CAFe+wq11k_6CPd0KasygX5HVLouL51v=0oDAK_=V8RwYzDsPmg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team,
A very good day to you.

I understand when either thinpool (or cachepool) gets used on a vg, there
is an internal meta volume and an additional spare volume that gets created
on the vg.
Under some circumstances, based on metadata utilization, we may end up
resizing the metavolume (lvextend --poolmetadatasize).
In my environment, I see that it only resizes the internal meta volume, but
not the spare volume.

After looking up the prior tickets, I understand this is a known bug that
got fixed in later lvm releases. I also see that if lvmconvert --repair
gets run, then the spare volume gets resized to the same size as internal
metadata volume.

I am trying to understand the impact of this bug in releases that have this
issue.
My follow up question is, if the spare volume is not of the same size as
the metadata volume, what sort of issues would one observe? What will fail
or may not work as expected?

And also whats the workaround, given repair option needs to deactivate all
lvols and vg need to have free space.

Your inputs to clarify on the above are much appreciated.

Thanks
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230316/ffd25c75/attachment.htm>
