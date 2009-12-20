From: Petr Rockai <prockai@redhat.com>
Date: Sun, 20 Dec 2009 15:45:56 +0100
Subject: [PATCH] Rename mirror_device_fault_policy to mirror_image_fault policy
Message-ID: <87my1demaj.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This should be quite simple, but I have thrown in a simple testcase as
well, for a good measure. There is some code duplication, but I'll
address that separately, since the old codepath (which does not really
do any upconversion, just logs suggestions) is still employed by
vgreduce --removemissing --force. This ought to be simplified to just
remove the faulty images/logs without looking at the policy or writing
any hints (vgreduce --removemissing should issue a hint about lvconvert
--repair instead).

This should fix RHBZ 538620.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: mirror_image_fault_policy.diff
Type: text/x-diff
Size: 4171 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091220/51717728/attachment.bin>
