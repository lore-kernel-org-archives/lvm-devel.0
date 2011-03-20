From: Petr Rockai <prockai@redhat.com>
Date: Sun, 20 Mar 2011 10:06:40 +0100
Subject: [PATCH] refactor vgreduce --removemissing --force
Message-ID: <87d3lmnotb.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch slashes a lot of old code specific to vgreduce in favour of
the more generic and better-behaved code used by lvconvert. The three
patches I have sent yesterday are all required for this one.

I have also added a new test for using vgreduce --removemissing --force
in presence of a snapshot -- this is broken with current CVS. The new
code should cover that case gracefully.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgreduce-removemissing-refactor.diff
Type: text/x-diff
Size: 13348 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110320/8fb243bd/attachment.bin>
-------------- next part --------------

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
