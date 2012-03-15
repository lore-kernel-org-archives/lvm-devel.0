From: Petr Rockai <prockai@redhat.com>
Date: Thu, 15 Mar 2012 18:49:09 +0100
Subject: [PATCH] Fix broken --major/--minor (RHBZ 801205)
In-Reply-To: <87y5r1srcc.fsf@mornfall.net> (Petr Rockai's message of "Thu, 15
	Mar 2012 18:32:03 +0100")
References: <20120306023051.13816.qmail@sourceware.org>
	<87y5r1srcc.fsf@mornfall.net>
Message-ID: <87ty1psqju.fsf_-_@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <prockai@redhat.com> writes:
> These two changes are responsible for RHBZ 801205, since we use
> arg_int_value on the major/minor _ARG in lvchange/lvcreate etc., but it
> won't work with groupable options.
>
> - add a new first_grouped_arg_int_value and use that

The patch to do the latter, including a regression test for the bug:

-------------- next part --------------
A non-text attachment was scrubbed...
Name: activate-minor.diff
Type: text/x-patch
Size: 4139 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20120315/0711f372/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
