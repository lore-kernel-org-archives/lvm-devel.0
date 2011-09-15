From: Petr Rockai <prockai@redhat.com>
Date: Thu, 15 Sep 2011 15:37:49 +0200
Subject: [PATCH] Fix #734193: divisibility issues with striped mirrors
Message-ID: <87vcsusz82.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the divisibility requirement in the allocation code is needlessly (and
incorrectly) strict, accounting not only for stripe layout but also for
mirrors (which do not divide extents among themselves, though). The
attached patch should remedy that. Regression test included.

Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvcreate-striped-mirror.diff
Type: text/x-diff
Size: 3241 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110915/a62743b3/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
