From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 15 Sep 2009 15:21:13 -0400
Subject: Re: a bug in --namesnapshot merge
In-Reply-To: <Pine.LNX.4.64.0909141225570.18131@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.0909141225570.18131@hs20-bc2-1.build.redhat.com>
Message-ID: <20090915192113.GA25624@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 14 2009 at  1:21pm -0400,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> Hi
> 
> When lvconvert -M --namesnapshot is invoked, there is a bug, it ends up 
> with a message like
> device-mapper: snapshots: exception for block 0 is on disk but not in 
> memory
> 
> The bug is not in the kernel but in the lvm. It loads -real and -cow 
> devices badly, so that the kernel treats the origin volume as the 
> snapshot.
> 
> The --namesnapshot option causes that the snapshot becomes the origin and 
> mergin starts, if we have
> lv-origin   owi-a- origin
> lv-snapshot swi--- snapshot
> , after lvconvert -M --namesnapshot vg/lv-snapshot, we'll have
> lv-snapshot Owi-a- mergin snapshot, containing the previous content of 
> lv-snapshot
> 
> The trick that needs to be done is to preserve the logical volume 
> structure and the device, but move it from one storage to another. Sadly, 
> LVM2 is not designed to do it. That --pivotorigin option that Alasdair 
> implemented needed the same trick and it was buggy too.
> 
> I'd suggest to remove --namesnapshot option at all (and remove patches
> lvm-merge-swap-uuid.patch and 
> lvm-merge-swap-lvid-of-underlying-devices.patch that do most of this 
> stuff) and leave only --nameorigin and --onactivate.
> 
> The implementation of --namesnapshot is very dirty. I was writing that 
> option --namesnapshot for a month, implemented it three times before 
> getting it right. And now some other changes to lvm made it nonworking 
> again. It is unmaintainable over the long term. It is not worth fixing, 
> because it would be beroken again.
> 
> Other that that, I think that snapshot merging could be applied to the 
> kernel and lvm.

I agree with the above.  The two times I rebased those swap uuid patches
they were fairly fragile/subtle/challenging.  Eliminating --namesnapshot
seems reasonable.  I updated the LVM2 snapshot-merge patches accordingly:

http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.52/


