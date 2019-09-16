From: Milan Broz <gmazyland@gmail.com>
Date: Mon, 16 Sep 2019 20:16:41 +0200
Subject: [dm-devel] [PATCH] dm: introduce DM_GET_TARGET_VERSION
In-Reply-To: <20190916180107.GA725@infradead.org>
References: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
	<20190916180107.GA725@infradead.org>
Message-ID: <127b8c4e-a6dc-6d5e-caff-fe1a0ca3a5bb@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 16/09/2019 20:01, Christoph Hellwig wrote:
> On Mon, Sep 16, 2019 at 05:55:42AM -0400, Mikulas Patocka wrote:
>> This patch introduces a new ioctl DM_GET_TARGET_VERSION. It will load a
>> target that is specified in the "name" entry in the parameter structure
>> and return its version.
>>
>> This functionality is intended to be used by cryptsetup, so that it can
>> query kernel capabilities before activating the device.
> 
> Well, if you want to query kernel features you better ask for a feature
> bitmap than a version number, which can be rather meaningless with
> the amount of backporting that is going on.

Actually we have a feature bitmap in userspace (derived from dm target version)
and there was even a nice versioning scheme way when backporting features
(used in RHEL for example).

Most of the libcrypsetup features that depend on some DM internals works the way
that userspace tries the feature and fallbacks if it fails.

But many functions are really user-unfriendly this way - imagine we ask for passphrases,
calculate LUKS keyslots, do benchmarks (all this do not need DM backend) - and then it
fails on activation because DM table load detects old (or missing) dm-crypt feature.
(There was no way to get dm target version before table load if module is not loaded.)

And I tried to avoid modprobe calls from libcryptsetup.

So the main idea behind this was just use already existing functionality
in kernel DM, and provide simple user-friendly way to detect some incompatibilites
more early. If detection is not there, we just fallback to the old way.

Milan


