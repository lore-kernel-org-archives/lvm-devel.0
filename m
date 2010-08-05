From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 5 Aug 2010 16:44:21 -0500
Subject: [PATCH] Specified PVs being ignored when performing mirror split (bug 619221)
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228865E3@USINDEVS02.corp.hds.com>
References: <5C30BE7ED8B03E448B2E104602D4848A59228865E3@USINDEVS02.corp.hds.com>
Message-ID: <B9814ACC-9FBA-43B6-814E-4E64992E1EDD@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Aug 5, 2010, at 4:31 PM, Takahiro Yasui wrote:

> # lvconvert --splitmirrors 1 --name new vg/org /dev/sda /dev/sdb
>    vg/org: Mirror volume consists of legs C, D and A   (leg C is  
> primary)
>    vg/new: Linear volume consists of B
>
> Is this change OK? If the answer is yes, I just ask you to change  
> the comments
> of _move_removable_mimages_to_end().

Are you sure?  I've just tried this on my test box, and it behaves as  
expected...

I had thought that I tested your scenario only with one PV specified,  
and that perhaps it was the second (unnecessary) one that was throwing  
off the logic.  However, that doesn't seem to be the case.

Perhaps I am still missing something?

  brassow


