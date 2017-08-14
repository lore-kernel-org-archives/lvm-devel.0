From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 14 Aug 2017 14:50:38 +0200
Subject: [PATCH 0/1] adding Btrfs resizing capability to lvresize/fsadm.sh
In-Reply-To: <bf152578-cca9-b5a1-98a2-4d7a97a21759@suse.com>
References: <20170802174235.19869-1-marcus@hostalia.de>
	<3d78f6d7-dd89-71cb-e754-88a290287404@hostalia.de>
	<bf152578-cca9-b5a1-98a2-4d7a97a21759@suse.com>
Message-ID: <032e16cc-3e25-04ca-8361-3abb767a0538@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 4.8.2017 v 09:13 Eric Ren napsal(a):
> Hi,
> 
> openSUSE has a similar patch [1] for a while. The original author sent it 
> upstream I think,
> but for whatever reason, it was not accepted.
> 
> fsadm-add-support-for-btrfs.patch
> [1] 
> https://build.opensuse.org/package/view_file/Base:System/lvm2/fsadm-add-support-for-btrfs.patch?expand=1 
> 
> 
> @Upstream experts, please let me know if you are open to merge this patch.
> If so, I can give a close review and testing on it. I'd like see your patch to 
> be accepted.
> Then, I can drop our own patch ;-P
> 
> Regards,
> Eric
> 
> On 08/03/2017 04:44 PM, Marcus M?ller wrote:
>> So,
>>
>> I'll admit that me spontaneously handing in above feature patch
>> yesterday was an act of "let's get this out of my head before I go
>> home". For private purposes, I wanted lvresize -r to deal with BTRFS, too.
>> Am I right here to post feature branches at all? Any copyright
>> assignments I need to take care of?
>>


Hi

 From my memory - when we tried to use such patch in past - we've found too 
many rough edges on anything  btrfs related.

I'm not an expert of btrfs at all - but we noticed lot of troubles in terms
of  btrfs was not even noticing it has got smaller, disk got missing
and many other conditions.

So to get such  'btrfs resize' patch accepted - it MUST be equipped with
lvm2 test suite script - possibly with a new separate test file
(so it's not mixed with already complex test/shell/fsadm.sh)

It should test fair amount of condition - so we can be at least partially
sure  'fsadm' will not totally mess users data just because it has run
command on some unexpected variants of 'btrfs' disk layout.

In fact it should check for 'known layout' and only let proceed with
command on this path   (including for checking minimal version
of kernel and btrfs-tools where btrfs is known to be stable enough for this 
operation.


I do believe that format of /test/shell/*sh is relatively readable.
For running the test -

do your lvm2 build and then within subdir /test/  run something like:

'make check_local T=fsadm-btrfs.sh VERBOSE=1'

to check the tool is doing something useful.
If something is unclear - feel free to reach me on freenode #lvm channel
to get this working properly.

Regards

Zdenek


