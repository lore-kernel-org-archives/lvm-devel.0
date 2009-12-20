From: Milan Broz <mbroz@redhat.com>
Date: Sun, 20 Dec 2009 17:01:59 +0100
Subject: [PATCH] Rename mirror_device_fault_policy to mirror_image_fault policy
In-Reply-To: <87my1demaj.fsf@twilight.int.mornfall.net.>
References: <87my1demaj.fsf@twilight.int.mornfall.net.>
Message-ID: <4B2E4A77.9030708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/20/2009 03:45 PM, Petr Rockai wrote:
> This should be quite simple, but I have thrown in a simple testcase as
> well, for a good measure. There is some code duplication, but I'll
> address that separately, since the old codepath (which does not really
> do any upconversion, just logs suggestions) is still employed by
> vgreduce --removemissing --force. This ought to be simplified to just
> remove the faulty images/logs without looking at the policy or writing
> any hints (vgreduce --removemissing should issue a hint about lvconvert
> --repair instead).

ack for patch, grumble for posting it so late.

(for vgreduce simplification, take into account problems described in patch
I just posted...)

Milan


